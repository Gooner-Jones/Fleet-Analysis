-- ================================================================================================================
-- Advanced Fleet Data Analysis Queries using Gold Layer
-- ================================================================================================================

USE Fleet;
GO

-- 1. Change-over-Time: Monthly Fleet Utilization Trend
SELECT 
      dt.year,
      dt.month,
      AVG(fp.utilization_rate) AS avg_utilization_rate
FROM gold.FactFleetPerformance fp
JOIN gold.DimTime dt ON fp.time_key = dt.time_key
GROUP BY dt.year, dt.month
ORDER BY dt.year, dt.month;
GO

-- 2. Cumulative Analysis: YTD Revenue by Branch
SELECT 
      dt.year,
      dt.month,
      b.branch_name,
      SUM(SUM(ff.revenue)) OVER (PARTITION BY b.branch_name, dt.year ORDER BY dt.month) AS ytd_revenue
FROM gold.FactFinancials ff
JOIN gold.DimTime dt ON ff.time_key = dt.time_key
JOIN gold.DimBranches b ON ff.branch_key = b.branch_key
GROUP BY dt.year, dt.month, b.branch_name
ORDER BY b.branch_name, dt.year, dt.month;
GO

-- 3. Performance Analysis: Maintenance Cost vs Operating Profit
SELECT 
      dt.year,
      dt.month,
      b.branch_name,
      SUM(fp.maintenance_cost) AS total_maintenance_cost,
      SUM(f.revenue * 0.2) AS operating_profit
FROM gold.FactFleetPerformance fp
JOIN gold.DimTime dt ON fp.time_key = dt.time_key
JOIN gold.DimBranches b ON fp.branch_key = b.branch_key
JOIN gold.FactFinancials f ON f.time_key = dt.time_key AND f.branch_key = b.branch_key
GROUP BY dt.year, dt.month, b.branch_name
ORDER BY dt.year, dt.month, b.branch_name;
GO

-- 4. Part-to-Whole: Revenue Contribution by Branch (Annual)
SELECT 
      dt.year,
      b.branch_name,
      SUM(f.revenue) AS branch_revenue,
      SUM(SUM(f.revenue)) OVER (PARTITION BY dt.year) AS total_revenue,
      ROUND(100.0 * SUM(f.revenue) / SUM(SUM(f.revenue)) OVER (PARTITION BY dt.year), 2) AS revenue_pct
FROM gold.FactFinancials f
JOIN gold.DimTime dt ON f.time_key = dt.time_key
JOIN gold.DimBranches b ON f.branch_key = b.branch_key
GROUP BY dt.year, b.branch_name
ORDER BY dt.year, revenue_pct DESC;
GO

-- 5. Data Segmentation: Utilization Rate by Vehicle Segment
SELECT 
      v.segment,
      ROUND(AVG(fp.utilization_rate), 2) AS avg_utilization_rate,
      COUNT(*) AS vehicle_records
FROM gold.FactFleetPerformance fp
JOIN gold.DimVehicles v ON fp.vehicle_key = v.vehicle_key
GROUP BY v.segment
ORDER BY avg_utilization_rate DESC;
GO

-- ================================================================================================================
-- Exploratory Data Analysis Queries using Gold Layer
-- ================================================================================================================

-- 1. Dimensions Exploration - Cardinality Analysis
SELECT 'Customers' AS dimension, COUNT(*) AS count FROM gold.DimCustomers
UNION ALL
SELECT 'Vehicles' AS dimension, COUNT(*) AS count FROM gold.DimVehicles
UNION ALL
SELECT 'Branches' AS dimension, COUNT(*) AS count FROM gold.DimBranches
UNION ALL
SELECT 'Time' AS dimension, COUNT(*) AS count FROM gold.DimTime;

-- 2. Dimensions Exploration: Customer Types & Segments
SELECT 
      customer_type,
      customer_segment,
      COUNT(*) AS customer_count
FROM gold.DimCustomers
GROUP BY customer_type, customer_segment
ORDER BY customer_count DESC;
GO

-- 3. Date Exploration: Telemetry Coverage Summary
SELECT 
      MIN(date) AS earliest_date,
      MAX(date) AS latest_date,
      COUNT(*) AS total_days
FROM gold.DimTime;
GO

-- 4. Measure Exploration: Distribution of Revenue and EBITDA
SELECT 
      b.branch_name,
      AVG(ff.revenue) AS avg_revenue,
      AVG(ff.ebitda) AS avg_ebitda,
      MAX(ff.revenue) AS max_revenue,
      MIN(ff.revenue) AS min_revenue
FROM gold.FactFinancials ff
JOIN gold.DimBranches b ON ff.branch_key = b.branch_key
GROUP BY b.branch_name
ORDER BY avg_revenue DESC;
GO

-- 5. Magnitude: Highest Downtime by Branch
SELECT TOP 10
      b.branch_name,
      SUM(fp.downtime_days) AS total_downtime
FROM gold.FactFleetPerformance fp
JOIN gold.DimBranches b ON fp.branch_key = b.branch_key
GROUP BY b.branch_name
ORDER BY total_downtime DESC;
GO

-- 6. Ranking Analysis: Top 5 Branches by Profit Margin
SELECT TOP 5
      b.branch_name,
      SUM(ff.revenue) AS total_revenue,
      SUM(ff.operating_profit) AS total_profit,
      ROUND(100.0 * SUM(ff.operating_profit) / NULLIF(SUM(ff.revenue), 0), 2) AS profit_margin_pct
FROM gold.FactFinancials ff
JOIN gold.DimBranches b ON ff.branch_key = b.branch_key
GROUP BY b.branch_name
ORDER BY profit_margin_pct DESC;
GO

PRINT 'Advanced and Exploratory Data Analysis queries executed successfully.';
