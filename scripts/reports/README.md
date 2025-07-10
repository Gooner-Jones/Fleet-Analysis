# 📊 Fleet & Financial Performance Analytics (Gold Layer)

**Pinnova Mobility Group – Modern Data Stack | Microsoft Fabric Warehouse | Power BI Embedded**

---

## 🔍 Overview

This reporting layer provides curated, high-value metrics and analyses derived from cleansed Silver Layer data. These insights support tactical and strategic decisions across operational, financial, and customer dimensions.

All queries run against the **Gold Layer** in the `Fleet` database and are production-ready for visualisation in Power BI and distribution to EXCO, OEMs, and internal GM stakeholders.

---

## 🧩 Gold Layer Components

* **Fact Tables**:

  * `FactFleetPerformance` — Utilization, fuel, maintenance, downtime.
  * `FactFinancials` — Revenue, EBITDA, profit, fleet size.

* **Dimension Tables**:

  * `DimCustomers` — Profiles and segmentation.
  * `DimVehicles` — Specs, segments, lifecycle status.
  * `DimBranches` — Location-level hierarchies.
  * `DimTime` — Date intelligence for trend analysis.

---

## 📈 Advanced Data Analysis

| Use Case                | Description                                                      |
| ----------------------- | ---------------------------------------------------------------- |
| 1. Change-over-Time     | Monthly utilization trends by year.                              |
| 2. Cumulative Analysis  | YTD revenue trends per branch using running totals.              |
| 3. Performance Analysis | Compare maintenance costs vs operating profit by month & branch. |
| 4. Part-to-Whole        | Branch-level contribution to total annual revenue.               |
| 5. Data Segmentation    | Utilization behavior by vehicle segment.                         |

1. Change-over-Time Analysis
```sql
-- Monthly Fleet Utilization Trend
SELECT 
    dt.year,
    dt.month,
    AVG(fp.utilization_rate) AS avg_utilization_rate
FROM gold.FactFleetPerformance fp
JOIN gold.DimTime dt ON fp.time_key = dt.time_key
GROUP BY dt.year, dt.month
ORDER BY dt.year, dt.month;
```
---
2. Cumulative Analysis
```sql
-- YTD Revenue by Branch
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
```
---
3. Performance Analysis
```sql
-- Maintenance Cost vs Operating Profit
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
```
---
4. Part-to-Whole Analysis
```sql
-- Revenue Contribution by Branch (Annual)
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
```
---
5. Data Segmentation
```sql
-- Utilization Rate by Vehicle Segment
SELECT 
    v.segment,
    ROUND(AVG(fp.utilization_rate), 2) AS avg_utilization_rate,
    COUNT(*) AS vehicle_records
FROM gold.FactFleetPerformance fp
JOIN gold.DimVehicles v ON fp.vehicle_key = v.vehicle_key
GROUP BY v.segment
ORDER BY avg_utilization_rate DESC;
```

## 🔬 Exploratory Data Analysis

| Area                 | Insight                                                       |
| -------------------- | ------------------------------------------------------------- |
| 1. Dimensions        | Volume of unique Customers, Vehicles, Branches, and Dates.    |
| 2. Customer Segments | Counts by `customer_type` and `customer_segment`.             |
| 3. Date Coverage     | Earliest/latest telemetry date to validate time series range. |
| 4. Measure Spread    | Min, Max, Avg of Revenue and EBITDA by Branch.                |
| 5. Magnitude         | Top branches with the highest vehicle downtime.               |
| 6. Ranking           | Top 5 branches by profit margin (%).                          |

1. Database Exploration
```sql
-- Dimensions Exploration - Cardinality Analysis
SELECT 'Customers' AS dimension, COUNT(*) AS count FROM gold.DimCustomers
UNION ALL
SELECT 'Vehicles' AS dimension, COUNT(*) AS count FROM gold.DimVehicles
UNION ALL
SELECT 'Branches' AS dimension, COUNT(*) AS count FROM gold.DimBranches
UNION ALL
SELECT 'Time' AS dimension, COUNT(*) AS count FROM gold.DimTime;
```
---
2. Dimensions Exploration
```sql
-- Customer Types & Segments
SELECT 
    customer_type,
    customer_segment,
    COUNT(*) AS customer_count
FROM gold.DimCustomers
GROUP BY customer_type, customer_segment
ORDER BY customer_count DESC;
```
---
3. Date Exploration
```sql
-- Telemetry Coverage Summary
SELECT 
    MIN(date) AS earliest_date,
    MAX(date) AS latest_date,
    COUNT(*) AS total_days
FROM gold.DimTime;
```
---
4. Measure Exploration
```sql
-- Distribution of Revenue and EBITDA
SELECT 
    b.branch_name,
    AVG(ff.revenue) AS avg_revenue,
    AVG(ff.ebitda) AS avg_ebitda,
    MAX(ff.revenue) AS max_revenue,
    MIN(ff.revenue) AS min_revenue
FROM gold.FactFinancials ff
JOIN gold.DimBranches b ON ff.branch_key = b.branch_key
GROUP BY b.branch_name
ORDER BY avg_revenue DESC
```
---
5. Magnitude Analysis
```sql
-- Highest Downtime by Branch
SELECT TOP 10
    b.branch_name,
    SUM(fp.downtime_days) AS total_downtime
FROM gold.FactFleetPerformance fp
JOIN gold.DimBranches b ON fp.branch_key = b.branch_key
GROUP BY b.branch_name
ORDER BY total_downtime DESC;
```
---
6. Ranking Analysis
```sql
-- Top 5 Branches by Profit Margin
SELECT TOP 5
    b.branch_name,
    SUM(ff.revenue) AS total_revenue,
    SUM(ff.operating_profit) AS total_profit,
    ROUND(100.0 * SUM(ff.operating_profit) / NULLIF(SUM(ff.revenue), 0), 2) AS profit_margin_pct
FROM gold.FactFinancials ff
JOIN gold.DimBranches b ON ff.branch_key = b.branch_key
GROUP BY b.branch_name
ORDER BY profit_margin_pct DESC;
```
---
## 📋 Key Objects

| Object Type | Object Name                            | Purpose                                   |
| ----------- | -------------------------------------- | ----------------------------------------- |
| View        | `vw_MonthlyFleetUtilization`           | Trend analysis                            |
| View        | `vw_YTDRevenueByBranch`                | Running totals (window functions)         |
| View        | `vw_RevenueContribution`               | Part-to-whole branch impact               |
| View        | `vw_TopBranchesByProfitMargin`         | Ranking by performance                    |
| Proc        | `usp_GetRevenueAndUtilizationByBranch` | Dynamic report filtering by year & branch |

---

## 🧠 Business Questions Answered

* What’s the **utilization trend** of our fleet across time?
* Which branches are **contributing the most** to our annual revenue?
* How does **maintenance cost compare** to operating profit?
* Where are we **underperforming** in terms of vehicle downtime?
* What **segments or customer types** dominate our base?
---
