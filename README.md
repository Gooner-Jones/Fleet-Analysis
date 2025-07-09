# 📊 Pinnova Mobility Group | Fleet & Financial Performance BI Report  

---

## 1. Background and Overview

**Pinnova Mobility Group (Pty) Ltd** is a Southern African mobility services provider specializing in vehicle leasing, fleet rentals, and fleet lifecycle management. Serving both commercial and consumer markets, Pinnova operates a national fleet spanning multiple brands, segments, and use cases.

This BI initiative was developed using the **Medalion architectural framework (Bronze → Silver → Gold layers)** to centralize and optimize reporting for:

- **Internal Stakeholders**: EXCO, Regional GMs, Fleet Ops, and Finance, enabling agile and data-driven planning.
- **External Stakeholders**: OEM partners and NAAMSA, offering transparency into utilization, maintenance, and vehicle lifecycle metrics.

The report delivers strategic insight into asset performance, customer trends, revenue generation, and operational efficiencies.

---

## 2. Data Architecture and Model Overview

The architecture leverages a **layered transformation approach** aligned with the Microsoft Fabric ecosystem:

### Bronze Layer: Raw ingest from ERP, CRM, IoT

### Silver Layer: Cleansed operational tables (wide schema)

- `silver.customers`  
- `silver.vehicles`  
- `silver.sales`  
- `silver.rentals`  
- `silver.leasing_contracts`  
- `silver.maintenance`  
- `silver.customer_interactions`  
- `silver.vehicle_telemetry`

### Gold Layer: Star Schema for BI

#### Dimensions:
- `DimCustomers`, `DimVehicles`, `DimBranches`, `DimTime`

#### Fact Tables:
- `FactFleetPerformance`: Odometer, fuel, downtime, maintenance cost, utilization  
- `FactFinancials`: Revenue, EBITDA, operating profit, rental/lease activity

---

## 3. Executive Summary

This report empowers stakeholders with high-level and drill-down views on:

- **Fleet Performance**: Utilization, mileage trends, downtime hotspots  
- **Revenue and Profitability**: Branch-level margins, contract mix, EBITDA tracking  
- **Customer Segments**: Retention patterns, corporate spend, CRM effectiveness  
- **Maintenance Patterns**: Service types, warranty activity, and downtime cost  

KPI cards and interactive visuals enable real-time monitoring and dynamic storytelling for strategic reviews and partner briefings.

---

## 4. Insights Deep Dive

### Fleet Utilization & Maintenance

- **Top Performing Assets**: Toyota Corolla and VW Polo fleets show >90% utilization  
- **Service Impact**: 1.5 avg. downtime days per event in major metros  
- **Telemetry Findings**: SUVs record 18% higher average fuel consumption than sedans  

### Financial Trends

- **Branch EBITDA Spread**: Western Cape branches yield the highest EBITDA per asset  
- **Contract Growth**: Leasing contracts rose 14% QoQ, especially among logistics clients  
- **Revenue Concentration**: Top 5 branches contribute 62% of YTD income  

### Customer Behavior

- **Loyalty Leverage**: Customers with loyalty status spend 2.1x more per year  
- **Consent for Marketing**: 74% CRM opt-in rate enables targeted campaigns  
- **Corporate Share**: 65% of revenue is attributed to long-term B2B clients  

---

## 5. Strategic Recommendations

### Operational Actions

- **Reallocate Idle Fleet**: Shift underutilized vehicles to Gauteng’s high-demand corridor  
- **Branch SLA Reviews**: Target top-3 branches with extended maintenance turnaround times  

### Financial Optimization

- **Expand Leasing in Profitable Segments**: Target B2B SMEs and corporate logistics  
- **Incorporate Predictive Pricing Models**: Dynamic discounting based on vehicle wear, telemetry, and utilization  

### Stakeholder Engagement

- **OEM Briefings**: Share usage and failure trends with OEMs to optimize service intervals and specs  
- **NAAMSA Submissions**: Automate KPI extracts for regulatory and benchmarking transparency  

---

## 6. Next Steps

This BI solution forms the foundation for future enhancements:

- **Power BI Service Deployment** with row-level security  
- **Automated data refresh via Microsoft Fabric Pipelines**  
- **Self-service dashboards** for EXCO and Operations teams  
- **OEM-specific scorecards** tailored to brand partnerships  

---
