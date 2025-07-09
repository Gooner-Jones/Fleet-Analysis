-- ================================================================================================================
-- Create Silver Layer Tables (with Data Quality Improvements)
-- ================================================================================================================
/*
This script creates tables in the 'silver' schema, dropping existing tables 
if they already exist. 
Run this script to re-define the DDL structure of the 'bronze' Tables
*/

-- ================================================================================================================
-- Drop existing silver tables if they exist
IF OBJECT_ID('silver.customers', 'U') IS NOT NULL DROP TABLE silver.customers;
IF OBJECT_ID('silver.vehicles', 'U') IS NOT NULL DROP TABLE silver.vehicles;
IF OBJECT_ID('silver.sales', 'U') IS NOT NULL DROP TABLE silver.sales;
IF OBJECT_ID('silver.rentals', 'U') IS NOT NULL DROP TABLE silver.rentals;
IF OBJECT_ID('silver.leasing_contracts', 'U') IS NOT NULL DROP TABLE silver.leasing_contracts;
IF OBJECT_ID('silver.maintenance', 'U') IS NOT NULL DROP TABLE silver.maintenance;
IF OBJECT_ID('silver.customer_interactions', 'U') IS NOT NULL DROP TABLE silver.customer_interactions;
IF OBJECT_ID('silver.vehicle_telemetry', 'U') IS NOT NULL DROP TABLE silver.vehicle_telemetry;
GO

-- Customers Table (Standardized and Enhanced)
CREATE TABLE silver.customers (
    customer_id NVARCHAR(50) NOT NULL PRIMARY KEY,
    customer_name NVARCHAR(100) NOT NULL,
    email NVARCHAR(100),
    phone NVARCHAR(20),
    address NVARCHAR(100),
    city NVARCHAR(50),
    country NVARCHAR(50),
    customer_type NVARCHAR(50) NOT NULL,
    registration_date DATE NOT NULL,
    corporate_discount DECIMAL(5,2),
    loyalty_points INT,
    preferred_branch NVARCHAR(50),
    last_interaction_date DATE,
    marketing_consent NVARCHAR(5),
    customer_segment NVARCHAR(50),
    crm_last_updated DATETIME2
);
GO

-- Vehicles Table (Standardized and Enhanced)
CREATE TABLE silver.vehicles (
    vehicle_id NVARCHAR(50) NOT NULL PRIMARY KEY,
    registration_number NVARCHAR(50) NOT NULL,
    make VARCHAR(50) NOT NULL,
    model NVARCHAR(50) NOT NULL,
    model_year INT,
    vehicle_type VARCHAR(50) NOT NULL,
    segment VARCHAR(50),
    current_branch VARCHAR(50),
    acquisition_date DATE NOT NULL,
    purchase_price DECIMAL(12,2),
    current_value DECIMAL(12,2),
    status VARCHAR(50) NOT NULL,
    odometer INT,
    warranty_expiry DATE,
    insurance_policy NVARCHAR(50),
    erp_last_updated DATETIME2
);

GO
-- Sales Table (Standardized and Enhanced)
CREATE TABLE silver.sales (
    sale_id NVARCHAR(50) NOT NULL PRIMARY KEY,
    vehicle_id NVARCHAR(50) NOT NULL,
    customer_id NVARCHAR(50),
    sale_date DATE NOT NULL,
    sale_price DECIMAL(12,2) NOT NULL,
    original_cost DECIMAL(12,2),
    sale_channel NVARCHAR(50) NOT NULL,
    buyer_type NVARCHAR(50) NOT NULL,
    days_on_market INT,
    profit_margin DECIMAL(5,2),
    dealer_discount DECIMAL(5,2),
    sales_person NVARCHAR(100),
    finance_option NVARCHAR(50),
    erp_last_updated DATETIME2,
);
GO

-- Rentals Table (Standardized and Enhanced)
CREATE TABLE silver.rentals (
    rental_id NVARCHAR(50) NOT NULL PRIMARY KEY,
    customer_id NVARCHAR(50) NOT NULL,
    vehicle_id NVARCHAR(50) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    branch VARCHAR(50) NOT NULL,
    segment VARCHAR(50),
    duration_days INT,
    rate_per_day DECIMAL(10,2) NOT NULL,
    total_amount DECIMAL(12,2),
    revenue_channel VARCHAR(50) NOT NULL,
    rental_status VARCHAR(20) NOT NULL,
    insurance_option VARCHAR(50),
    payment_status VARCHAR(15) NOT NULL,
    invoice_number NVARCHAR(50),
    erp_last_updated DATETIME2,
);
GO

-- Leasing Contracts Table (Standardized and Enhanced)
CREATE TABLE silver.leasing_contracts (
    contract_id NVARCHAR(50) NOT NULL PRIMARY KEY,
    customer_id NVARCHAR(50) NOT NULL,
    vehicle_id NVARCHAR(50) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    monthly_payment DECIMAL(12,2),
    branch NVARCHAR(50) NOT NULL,
    contract_type NVARCHAR(50) NOT NULL,
    km_limit INT,
    maintenance_included NVARCHAR(5),
    insurance_included NVARCHAR(5),
    payment_method NVARCHAR(50),
    contract_status NVARCHAR(50) NOT NULL,
    erp_last_updated DATETIME2,
);
GO

-- Maintenance Table (Standardized and Enhanced)
CREATE TABLE silver.maintenance (
    maintenance_id NVARCHAR(50) NOT NULL PRIMARY KEY,
    vehicle_id NVARCHAR(50) NOT NULL,
    service_date DATE NOT NULL,
    service_type VARCHAR(50) NOT NULL,
    odometer INT,
    cost DECIMAL(12,2),
    branch VARCHAR(50),
    service_provider VARCHAR(100),
    downtime_days INT,
    main_description VARCHAR(500),
    warranty_claim NVARCHAR(5),
    erp_last_updated DATETIME2,
);
GO

-- Customer Interactions Table (Standardized and Enhanced)
CREATE TABLE silver.customer_interactions (
    interaction_id NVARCHAR(50) NOT NULL PRIMARY KEY,
    customer_id NVARCHAR(50) NOT NULL,
    interaction_date DATETIME2 NOT NULL,
    interaction_type NVARCHAR(50) NOT NULL,
    interaction_channel NVARCHAR(50) NOT NULL,
    subject_matter NVARCHAR(100),
    outcome NVARCHAR(100),
    assigned_agent NVARCHAR(100),
    followup_required NVARCHAR(5),
    followup_date DATE,
    crm_last_updated DATETIME2,
);
GO

-- Vehicle Telemetry Table (Standardized and Enhanced)
CREATE TABLE silver.vehicle_telemetry (
    telemetry_id NVARCHAR(50) NOT NULL PRIMARY KEY,
    vehicle_id NVARCHAR(50) NOT NULL,
    record_date DATETIME2 NOT NULL,
    odometer INT,
    fuel_level DECIMAL(5,2),
    fuel_consumption DECIMAL(5,2),
    location_lat DECIMAL(9,6),
    location_long DECIMAL(9,6),
    branch NVARCHAR(50),
    engine_status NVARCHAR(50),
    speed INT,
    battery_voltage DECIMAL(5,2),
    tire_pressure DECIMAL(5,2),
    iot_last_updated DATETIME2,
);
GO
