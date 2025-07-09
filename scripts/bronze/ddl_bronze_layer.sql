-- ================================================================================================================
-- Create Bronze Layer Tables
-- ================================================================================================================
/*
This script creates tables in the 'bronze' schema, dropping existing tables 
if they already exist. 
Run this script to re-define the DDL structure of the 'bronze' Tables
*/

IF OBJECT_ID('bronze.crm_customer_interactions', 'U') IS NOT NULL
DROP TABLE bronze.crm_customer_interactions;
GO
CREATE TABLE bronze.crm_customer_interactions (crm_interaction_id NVARCHAR(50) NOT NULL,
											   crm_customer_id NVARCHAR(50) NOT NULL,
											   interaction_date DATE NOT NULL,
											   interaction_type NVARCHAR(50) NOT NULL,
											   interaction_channel NVARCHAR(50) NOT NULL,
											   subject_matter NVARCHAR(100),
											   outcome NVARCHAR(100),
											   assigned_agent NVARCHAR(100),
											   followup_required NVARCHAR(5),
											   followup_date DATE,
											   crm_last_updated DATETIME2 NOT NULL);
GO

IF OBJECT_ID('bronze.crm_customers', 'U') IS NOT NULL
DROP TABLE bronze.crm_customers;
GO
CREATE TABLE bronze.crm_customers (crm_customer_id NVARCHAR(50) NOT NULL,
								   name NVARCHAR(100) NOT NULL,
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
								   crm_last_updated DATETIME2 NOT NULL);
GO

IF OBJECT_ID('bronze.erp_car_sales', 'U') IS NOT NULL
DROP TABLE bronze.erp_car_sales;
GO
CREATE TABLE bronze.erp_car_sales (erp_sale_id NVARCHAR(50) NOT NULL,
								   erp_vehicle_id NVARCHAR(50) NOT NULL,
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
								   erp_last_updated DATETIME2 NOT NULL);
GO

IF OBJECT_ID('bronze.erp_leasing_contracts', 'U') IS NOT NULL
DROP TABLE bronze.erp_leasing_contracts;
GO
CREATE TABLE bronze.erp_leasing_contracts (erp_contract_id NVARCHAR(50) NOT NULL,
										   crm_customer_id NVARCHAR(50) NOT NULL,
										   erp_vehicle_id NVARCHAR(50) NOT NULL,
										   start_dt DATE NOT NULL,
										   end_dt DATE NOT NULL,
										   monthly_payment DECIMAL(12,2),
										   branch NVARCHAR(50) NOT NULL,
										   contract_type NVARCHAR(50) NOT NULL,
										   km_limit INT,
										   maintenance_included NVARCHAR(5),
										   insurance_included NVARCHAR(5),
										   payment_method NVARCHAR(50),
										   contract_status NVARCHAR(50) NOT NULL,
										   erp_last_updated DATETIME2 NOT NULL);
GO

IF OBJECT_ID('bronze.erp_rentals', 'U') IS NOT NULL
DROP TABLE bronze.erp_rentals;
GO
CREATE TABLE bronze.erp_rentals (erp_rental_id NVARCHAR(50) NOT NULL,
								 crm_customer_id NVARCHAR(50) NOT NULL,
								 erp_vehicle_id NVARCHAR(50) NOT NULL,
								 start_dt DATE NOT NULL,
								 end_dt DATE NOT NULL,
								 branch VARCHAR(50) NOT NULL,
								 segment VARCHAR(50),
								 duration_days INT,
								 rate_per_day DECIMAL(10,2) NOT NULL,
								 total_amount DECIMAL(12,2),
								 revenue_channel VARCHAR(50) NOT NULL,
								 rental_status VARCHAR(20) NOT NULL ,
								 insurance_option VARCHAR(50),
								 payment_status VARCHAR(15) NOT NULL,
								 invoice_number NVARCHAR(50),
								 erp_last_updated DATETIME2 NOT NULL);
GO

IF OBJECT_ID('bronze.erp_vehicle_maintenance', 'U') IS NOT NULL
DROP TABLE bronze.erp_vehicle_maintenance;
GO
CREATE TABLE bronze.erp_vehicle_maintenance (erp_maintenance_id NVARCHAR(50) NOT NULL,
											 erp_vehicle_id NVARCHAR(50) NOT NULL,
											 service_date DATE NOT NULL,
											 service_type VARCHAR(50) NOT NULL,
											 odometer INT,
											 cost DECIMAL(12,2),					-- Better than FLOAT for monetary values
											 branch VARCHAR(50),
											 service_provider VARCHAR(100),         -- Increased length for provider names
											 downtime_days INT,
											 main_description VARCHAR(500),         -- Increased for longer descriptions
											 warranty_claim VARCHAR(10),
											 erp_last_updated DATETIME2 NOT NULL);
GO

IF OBJECT_ID('bronze.erp_vehicles', 'U') IS NOT NULL
DROP TABLE bronze.erp_vehicles;
GO
CREATE TABLE bronze.erp_vehicles (erp_vehicle_id NVARCHAR(50) NOT NULL,
								  registration NVARCHAR(50) NOT NULL,
								  make VARCHAR(50) NOT NULL,
								  model NVARCHAR(50) NOT NULL,
								  model_year INT,
								  vehicle_type VARCHAR(50) NOT NULL,
								  segment VARCHAR(50),
								  branch VARCHAR(50),
								  acquisition_date DATE NOT NULL,
								  purchase_price DECIMAL(12,2),  -- Better than INT for monetary values
								  current_value DECIMAL(12,2),
								  status VARCHAR(50) NOT NULL,
								  odometer INT,
								  warranty_expiry DATE,
								  insurance_policy NVARCHAR(50),
								  erp_last_updated DATETIME2 NOT NULL);
GO

IF OBJECT_ID('bronze.iot_fleet_telemetry', 'U') IS NOT NULL
DROP TABLE bronze.iot_fleet_telemetry;
GO
CREATE TABLE bronze.iot_fleet_telemetry (iot_telemetry_id NVARCHAR(50) NOT NULL,
										 erp_vehicle_id NVARCHAR(50) NOT NULL,
										 record_date DATETIME2 NOT NULL,
										 odometer INT,
										 fuel_level FLOAT,
										 fuel_consumption FLOAT,
										 location_lat FLOAT,
										 location_long FLOAT,
										 branch NVARCHAR(50),
										 engine_status NVARCHAR(50),
										 speed INT,
										 battery_voltage FLOAT,
										 tire_pressure FLOAT,
										 iot_last_updated DATETIME2 NOT NULL);
GO
