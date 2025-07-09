-- ================================================================================================================
-- Create Gold Layer Tables (Star Schema)
-- ================================================================================================================
/*
This script creates tables in the 'gold' schema, dropping existing tables 
if they already exist. 
Run this script to re-define the DDL structure of the 'gold' Tables
*/

USE ZedaFleet;
GO

-- Drop existing gold tables if they exist
IF OBJECT_ID('gold.DimCustomers', 'U') IS NOT NULL DROP TABLE gold.DimCustomers;
IF OBJECT_ID('gold.DimVehicles', 'U') IS NOT NULL DROP TABLE gold.DimVehicles;
IF OBJECT_ID('gold.DimBranches', 'U') IS NOT NULL DROP TABLE gold.DimBranches;
IF OBJECT_ID('gold.DimTime', 'U') IS NOT NULL DROP TABLE gold.DimTime;
IF OBJECT_ID('gold.FactFleetPerformance', 'U') IS NOT NULL DROP TABLE gold.FactFleetPerformance;
IF OBJECT_ID('gold.FactFinancials', 'U') IS NOT NULL DROP TABLE gold.FactFinancials;
GO

-- ================================================================================================================
-- Dimension Tables
-- ================================================================================================================

-- DimCustomers: Customer attributes
CREATE TABLE gold.DimCustomers (
      customer_key INT IDENTITY(1,1) PRIMARY KEY,
      customer_id NVARCHAR(50) NOT NULL,
      customer_name NVARCHAR(100) NOT NULL,
      customer_type NVARCHAR(50) NOT NULL,
      country NVARCHAR(50),
      customer_segment NVARCHAR(50),
      registration_date DATE,
      corporate_discount DECIMAL(5,2),
      loyalty_points INT,
      preferred_branch NVARCHAR(50)
);
GO

-- DimVehicles: Vehicle attributes
CREATE TABLE gold.DimVehicles (
      vehicle_key INT IDENTITY(1,1) PRIMARY KEY,
      vehicle_id NVARCHAR(50) NOT NULL,
      registration_number NVARCHAR(50) NOT NULL,
      make NVARCHAR(50) NOT NULL,
      model NVARCHAR(50) NOT NULL,
      model_year INT,
      vehicle_type NVARCHAR(50) NOT NULL,
      segment NVARCHAR(50),
      acquisition_date DATE,
      current_value DECIMAL(12,2),
      warranty_expiry DATE
);
GO

-- DimBranches: Branch locations
CREATE TABLE gold.DimBranches (
      branch_key INT IDENTITY(1,1) PRIMARY KEY,
      branch_id NVARCHAR(50) NOT NULL,
      branch_name NVARCHAR(100) NOT NULL,
      city NVARCHAR(50),
      country NVARCHAR(50)
  );
GO

-- DimTime: Time hierarchy for analysis
CREATE TABLE gold.DimTime (
      time_key INT IDENTITY(1,1) PRIMARY KEY,
      date DATE NOT NULL,
      day INT NOT NULL,
      month INT NOT NULL,
      quarter INT NOT NULL,
      year INT NOT NULL,
      day_of_week NVARCHAR(10) NOT NULL
);
GO

-- ================================================================================================================
-- Fact Tables
-- ================================================================================================================

-- FactFleetPerformance: Fleet KPIs
CREATE TABLE gold.FactFleetPerformance (
      performance_key INT IDENTITY(1,1) PRIMARY KEY,
      time_key INT NOT NULL,
      vehicle_key INT NOT NULL,
      branch_key INT NOT NULL,
      odometer INT,
      fuel_consumption DECIMAL(10,2),
      utilization_rate DECIMAL(5,2),
      maintenance_cost DECIMAL(12,2),
      downtime_days INT,
      FOREIGN KEY (time_key) REFERENCES gold.DimTime(time_key),
      FOREIGN KEY (vehicle_key) REFERENCES gold.DimVehicles(vehicle_key),
      FOREIGN KEY (branch_key) REFERENCES gold.DimBranches(branch_key)
);
GO

-- FactFinancials: Financial metrics
CREATE TABLE gold.FactFinancials (
      financial_key INT IDENTITY(1,1) PRIMARY KEY,
      time_key INT NOT NULL,
      branch_key INT NOT NULL,
      revenue DECIMAL(15,2),
      ebitda DECIMAL(15,2),
      operating_profit DECIMAL(15,2),
      fleet_size INT,
      rental_days INT,
      leasing_contracts INT,
      FOREIGN KEY (time_key) REFERENCES gold.DimTime(time_key),
      FOREIGN KEY (branch_key) REFERENCES gold.DimBranches(branch_key)
);
GO

PRINT 'Gold layer tables created successfully';
