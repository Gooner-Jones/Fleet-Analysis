-- ================================================================================================================
-- Transform and Load Data from Bronze to Silver
-- ================================================================================================================
/* This stored procedure performs the ETL (Extract, Transform, Load) process to 
   populate the 'silver' schema tables from the 'bronze' schema.
   
   Actions Performed:
   - Truncates Silver tables.
   - Inserts transformed and cleansed data from Bronze into Silver tables.
		
   Parameters: This stored procedure does not accept any parameters or return any values.

   Usage Example: EXEC Silver.load_silver;
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
PRINT '================================================';
PRINT 'Loading Silver Layer';
PRINT '================================================';
-- ================================================================================================================
-- 1. Silver Customers Table

TRUNCATE TABLE silver.customers
INSERT INTO silver.customers (
		customer_id,
		customer_name,
		email,
		phone,
		address,
		city,
		country,
		customer_type,
		registration_date,
		corporate_discount,
		loyalty_points,
		preferred_branch,
		last_interaction_date,
		marketing_consent,
		customer_segment,
		crm_last_updated
		)
-- Customers Transformation
SELECT crm_customer_id,
	   TRIM(name),
	   LOWER(TRIM(email)),
	   phone,
	   TRIM(address),
	   TRIM(city),
	   TRIM(country),
	   customer_type,
	   registration_date,
	   COALESCE(corporate_discount, 0),
	   COALESCE(loyalty_points, 0),
	   TRIM(preferred_branch),
	   last_interaction_date,
	   -- Normalize follow up values to readable format
	   CASE UPPER(TRIM(marketing_consent))
		WHEN 'Y' THEN 'YES'
		WHEN 'N' THEN 'NO'
		ELSE NULL
	   END marketing_consent,
	   customer_segment,
	   crm_last_updated
FROM bronze.crm_customers;
GO

-- ================================================================================================================
-- 2. Silver Vehicles Table

TRUNCATE TABLE silver.vehicles
INSERT INTO silver.vehicles (
		vehicle_id,
		registration_number,
		make,
		model,
		model_year,
		vehicle_type,
		segment,
		current_branch,
		acquisition_date,
		purchase_price,
		current_value,
		status,
		odometer,
		warranty_expiry,
		insurance_policy,
		erp_last_updated
		)
-- Vehicles Transformation
SELECT erp_vehicle_id,
	   registration,
	   TRIM(make),
	   model,
	   model_year,
	   vehicle_type,
	   segment,
	   TRIM(branch),
	   acquisition_date,
	   purchase_price,
	   current_value,
	   status,
	   COALESCE(odometer, 0),
	   warranty_expiry,
	   insurance_policy,
	   erp_last_updated
FROM bronze.erp_vehicles;
GO

-- ================================================================================================================
-- 3. Silver Sales Table

TRUNCATE TABLE silver.sales
INSERT INTO silver.sales (
		sale_id,
		vehicle_id,
		customer_id,
		sale_date,
		sale_price,
		original_cost,
		sale_channel,
		buyer_type,
		days_on_market,
		profit_margin,
		dealer_discount,
		sales_person,
		finance_option,
		erp_last_updated
		)
-- Sales Transformation
SELECT erp_sale_id,
	   erp_vehicle_id,
	   NULL, -- Customer ID not available in bronze, would need to be linked
       sale_date,
	   sale_price,
       original_cost,
       sale_channel,
       buyer_type,
       days_on_market,
       profit_margin,
       dealer_discount,
       TRIM(sales_person),
	   finance_option,
       erp_last_updated
FROM bronze.erp_car_sales;
GO

-- ================================================================================================================
-- 4. Silver Rentals Table

TRUNCATE TABLE silver.rentals
INSERT INTO silver.rentals(
		rental_id,
		customer_id,
		vehicle_id,
		start_date,
		end_date,
		branch,
		segment,
		duration_days,
		rate_per_day,
		total_amount,
		revenue_channel,
		rental_status,
		insurance_option,
		payment_status,
		invoice_number,
		erp_last_updated
		)
-- Rentals Transformation
SELECT erp_rental_id,
	   crm_customer_id,
	   erp_vehicle_id,
	   start_dt,
	   end_dt,
	   TRIM(branch),
	   segment,
	   COALESCE(duration_days, DATEDIFF(DAY, start_dt, end_dt)),
	   rate_per_day,
	   COALESCE(total_amount, rate_per_day * DATEDIFF(DAY, start_dt, end_dt)),
	   revenue_channel,
	   rental_status,
	   insurance_option,
	   payment_status,
	   invoice_number,
	   erp_last_updated
FROM bronze.erp_rentals;
GO

-- ================================================================================================================
-- 5. Leasing Contracts Table

TRUNCATE TABLE silver.leasing_contracts
INSERT INTO silver.leasing_contracts(
		contract_id,
		customer_id,
		vehicle_id,
		start_date,
		end_date,
		monthly_payment,
		branch,
		contract_type,
		km_limit,
		maintenance_included,
		insurance_included,
		payment_method,
		contract_status,
		erp_last_updated
		)
-- Leasing Contracts Transformation
SELECT erp_contract_id,
	   crm_customer_id,
	   erp_vehicle_id,
	   start_dt,
	   end_dt,
	   monthly_payment,
	   TRIM(branch),
	   contract_type,
	   km_limit,
	   -- Normalize follow up values to readable format
	   CASE UPPER(TRIM(maintenance_included))
		WHEN 'Y' THEN 'YES'
		WHEN 'N' THEN 'NO'
		ELSE NULL
	   END maintenance_included,
	   CASE UPPER(TRIM(insurance_included))
		WHEN 'Y' THEN 'YES'
		WHEN 'N' THEN 'NO'
		ELSE NULL
	   END insurance_included,
	   payment_method,
	   contract_status,
	   erp_last_updated
FROM bronze.erp_leasing_contracts;
GO

-- ================================================================================================================
-- 6. Silver Maintenance Table

TRUNCATE TABLE silver.maintenance
INSERT INTO silver.maintenance(
		maintenance_id,
		vehicle_id,
		service_date,
		service_type,
		odometer,
		cost,
		branch,
		service_provider,
		downtime_days,
		main_description,
		warranty_claim,
		erp_last_updated
		)
-- Maintenance Transformation
SELECT erp_maintenance_id,
	   erp_vehicle_id,
	   service_date,
	   service_type,
	   COALESCE(odometer, 0),
	   cost,
	   TRIM(branch),
	   service_provider,
	   COALESCE(downtime_days, 0),
	   main_description,
	   -- Normalize follow up values to readable format
	   CASE UPPER(TRIM(warranty_claim)) 
		WHEN 'Y' THEN 'YES'
		WHEN 'N' THEN 'NO'
		ELSE NULL
	   END warranty_claim,
	   erp_last_updated
FROM bronze.erp_vehicle_maintenance;
GO

-- ================================================================================================================
-- 7. Silver Customer Interactions Table

TRUNCATE TABLE silver.customer_interactions
INSERT INTO silver.customer_interactions(
		interaction_id,
		customer_id,
		interaction_date,
		interaction_type,
		interaction_channel,
		subject_matter,
		outcome,
		assigned_agent,
		followup_required,
		followup_date,
		crm_last_updated
		)
-- Customer Interactions Transformation
SELECT crm_interaction_id,
	   crm_customer_id,
	   CAST(interaction_date AS DATETIME2),
	   interaction_type,
	   interaction_channel,
	   subject_matter,
	   outcome,
	   TRIM(assigned_agent),
	   -- Normalize follow up values to readable format
	   CASE UPPER(TRIM(followup_required))
		WHEN 'Y' THEN 'YES'
		WHEN 'N' THEN 'NO'
		ELSE NULL
	   END followup_required,
	   followup_date,
	   crm_last_updated
FROM bronze.crm_customer_interactions;
GO

-- ================================================================================================================
-- 8. Silver Vehicle Telemetry Table

TRUNCATE TABLE silver.vehicle_telemetry
INSERT INTO silver.vehicle_telemetry(
		telemetry_id,
		vehicle_id,
		record_date,
		odometer,
		fuel_level,
		fuel_consumption,
		location_lat,
		location_long,
		branch,
		engine_status,
		speed,
		battery_voltage,
		tire_pressure,
		iot_last_updated
		)
-- Vehicle Telemetry Transformation
SELECT iot_telemetry_id,
	   erp_vehicle_id,
	   record_date,
	   COALESCE(odometer, 0),
	   ROUND(fuel_level, 2),
       ROUND(fuel_consumption, 2),
       ROUND(location_lat, 6),
       ROUND(location_long, 6),
	   TRIM(branch),
	   engine_status,
	   speed,
	   ROUND(battery_voltage, 2),
	   ROUND(tire_pressure, 2),
	   iot_last_updated
FROM bronze.iot_fleet_telemetry;
GO
-- ================================================================================================================
PRINT '=========================================='
PRINT 'Silver layer tables created and populated successfully'
PRINT '=========================================='
END
