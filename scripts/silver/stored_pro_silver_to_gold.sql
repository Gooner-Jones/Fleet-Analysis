-- ================================================================================================================
-- Load Data into Gold Layer Tables 
-- ================================================================================================================
/* 
This script performs the transformation and load process for the Gold Layer 
(Star Schema) tables based on the cleansed and structured data from the Silver Layer.

Updated to use DELETE for tables involved in foreign key relationships.
*/

USE ZedaFleet;
GO

-- ================================================================================================================
-- Load Dimension Tables
-- ================================================================================================================

-- 1. Load DimCustomers
DELETE FROM gold.DimCustomers;
INSERT INTO gold.DimCustomers (
  	customer_id,
  	customer_name,
  	customer_type,
  	country,
  	customer_segment,
  	registration_date,
  	corporate_discount,
  	loyalty_points,
  	preferred_branch
)
SELECT 
  	customer_id,
  	customer_name,
  	customer_type,
  	COALESCE(country, 'South Africa'),
  	customer_segment,
  	registration_date,
  	corporate_discount,
  	loyalty_points,
  	preferred_branch
FROM silver.customers;
GO

-- 2. Load DimVehicles
DELETE FROM gold.DimVehicles;
INSERT INTO gold.DimVehicles (
  	vehicle_id,
  	registration_number,
  	make,
  	model,
  	model_year,
  	vehicle_type,
  	segment,
  	acquisition_date,
  	current_value,
  	warranty_expiry
)
SELECT 
  	vehicle_id,
  	registration_number,
  	make,
  	model,
  	model_year,
  	vehicle_type,
  	segment,
  	acquisition_date,
  	current_value,
  	warranty_expiry
FROM silver.vehicles;
GO

-- 3. Load DimBranches
DELETE FROM gold.DimBranches;
INSERT INTO gold.DimBranches (
  	branch_id,
  	branch_name,
  	city,
  	country
)
SELECT DISTINCT 
	LOWER(REPLACE(branch, ' ', '_')) AS branch_id,
	branch AS branch_name,
	NULL AS city,
	'South Africa' AS country
FROM (
	SELECT preferred_branch AS branch FROM silver.customers
	UNION
	SELECT current_branch FROM silver.vehicles
	UNION
	SELECT branch FROM silver.rentals
	UNION
	SELECT branch FROM silver.leasing_contracts
	UNION
	SELECT branch FROM silver.maintenance
	UNION
	SELECT branch FROM silver.vehicle_telemetry
) AS branches
WHERE branch IS NOT NULL;
GO

-- 4. Load DimTime
DELETE FROM gold.DimTime;
INSERT INTO gold.DimTime (date, day, month, quarter, year, day_of_week)
    SELECT DISTINCT
        CAST(record_date AS DATE) AS date,
        DAY(record_date) AS day,
        MONTH(record_date) AS month,
        DATEPART(QUARTER, record_date) AS quarter,
        YEAR(record_date) AS year,
        DATENAME(WEEKDAY, record_date) AS day_of_week
    FROM silver.vehicle_telemetry
    WHERE record_date IS NOT NULL;
GO

-- ================================================================================================================
-- Load Fact Tables
-- ================================================================================================================

-- 5. Load FactFleetPerformance
DELETE FROM gold.FactFleetPerformance;
INSERT INTO gold.FactFleetPerformance (
  	time_key,
  	vehicle_key,
  	branch_key,
  	odometer,
  	fuel_consumption,
  	utilization_rate,
  	maintenance_cost,
  	downtime_days
)
SELECT 
  	t.time_key,
  	v.vehicle_key,
  	b.branch_key,
  	vt.odometer,
  	vt.fuel_consumption,
  	-- Utilization can be derived from rental days / calendar days (simplified assumption)
  	CAST(ISNULL(r.duration_days, 0) * 1.0 / 30 AS DECIMAL(5,2)) AS utilization_rate,
  	ISNULL(m.cost, 0) AS maintenance_cost,
  	ISNULL(m.downtime_days, 0) AS downtime_days
FROM silver.vehicle_telemetry vt
JOIN gold.DimVehicles v ON vt.vehicle_id = v.vehicle_id
JOIN gold.DimBranches b ON vt.branch = b.branch_name
JOIN gold.DimTime t ON CAST(vt.record_date AS DATE) = t.date
LEFT JOIN silver.maintenance m ON vt.vehicle_id = m.vehicle_id AND CAST(vt.record_date AS DATE) = CAST(m.service_date AS DATE)
LEFT JOIN silver.rentals r ON vt.vehicle_id = r.vehicle_id AND CAST(vt.record_date AS DATE) BETWEEN r.start_date AND r.end_date;
GO

-- 6. Load FactFinancials
DELETE FROM gold.FactFinancials;
INSERT INTO gold.FactFinancials (
  	time_key,
  	branch_key,
  	revenue,
  	ebitda,
  	operating_profit,
  	fleet_size,
  	rental_days,
  	leasing_contracts
)
SELECT 
  	t.time_key,
  	b.branch_key,
  	SUM(r.total_amount) AS revenue,
  	-- Simplified EBITDA calculation: Revenue - (Maintenance + Discounts)
  	SUM(r.total_amount) - ISNULL(SUM(m.cost), 0) - ISNULL(SUM(s.dealer_discount), 0) AS ebitda,
  	SUM(r.total_amount) * 0.20 AS operating_profit, -- Assume 20% margin
  	COUNT(DISTINCT v.vehicle_id) AS fleet_size,
  	SUM(r.duration_days) AS rental_days,
  	COUNT(DISTINCT lc.contract_id) AS leasing_contracts
FROM gold.DimTime t
JOIN silver.rentals r ON CAST(r.start_date AS DATE) = t.date
JOIN gold.DimBranches b ON r.branch = b.branch_name
LEFT JOIN silver.maintenance m ON r.vehicle_id = m.vehicle_id AND CAST(m.service_date AS DATE) = t.date
LEFT JOIN silver.vehicles v ON r.vehicle_id = v.vehicle_id
LEFT JOIN silver.sales s ON r.vehicle_id = s.vehicle_id AND CAST(s.sale_date AS DATE) = t.date
LEFT JOIN silver.leasing_contracts lc ON lc.branch = b.branch_name AND CAST(lc.start_date AS DATE) = t.date
GROUP BY t.time_key, b.branch_key;
GO

PRINT 'Gold layer tables loaded successfully with safe DELETE operations.';
