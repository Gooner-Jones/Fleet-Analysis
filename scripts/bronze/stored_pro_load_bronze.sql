-- ================================================================================================================
--Stored Procedure: Load Bronze Layer (Source -> Bronze)
-- ================================================================================================================
/* This stored procedure loads data into the 'bronze' schema from external CSV files. 

   Actions actions:
   - Truncates the bronze tables before loading data.
   - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

   Parameters: This stored procedure does not accept any parameters or return any values.
   
   Usage Example: EXEC bronze.load_bronze;
*/

CREATE or ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	PRINT '=====================================================================================';
	PRINT 'Loading Bronze Layer'
	PRINT '=====================================================================================';
	PRINT 'Loading CRM Tables'
	PRINT '=====================================================================================';
	TRUNCATE TABLE bronze.crm_customer_interactions;
	BULK INSERT bronze.crm_customer_interactions
	FROM 'C:\Users\User\OneDrive\Desktop\ZEDA LTD\fleet_data\crm_data\customer_interactions.csv'
	WITH (FIRSTROW = 2,
	      FIELDTERMINATOR = ',',
	      TABLOCK);

	TRUNCATE TABLE bronze.crm_customers;
	BULK INSERT bronze.crm_customers
	FROM 'C:\Users\User\OneDrive\Desktop\ZEDA LTD\fleet_data\crm_data\customers.csv'
	WITH (FIRSTROW = 2,
	      FIELDTERMINATOR = ',',
	      TABLOCK);

	PRINT '=====================================================================================';
	PRINT 'Loading ERP Tables'
	PRINT '=====================================================================================';
	TRUNCATE TABLE bronze.erp_car_sales;
	BULK INSERT bronze.erp_car_sales
	FROM 'C:\Users\User\OneDrive\Desktop\ZEDA LTD\fleet_data\erp_data\car_sales.csv'
	WITH (FIRSTROW = 2,
	      FIELDTERMINATOR = ',',
	      TABLOCK);
		  
	TRUNCATE TABLE bronze.erp_leasing_contracts;
	BULK INSERT bronze.erp_leasing_contracts
	FROM 'C:\Users\User\OneDrive\Desktop\ZEDA LTD\fleet_data\erp_data\leasing_contracts.csv'
	WITH (FIRSTROW = 2,
	      FIELDTERMINATOR = ',',
	      TABLOCK);

	TRUNCATE TABLE bronze.erp_rentals;
	BULK INSERT bronze.erp_rentals
	FROM 'C:\Users\User\OneDrive\Desktop\ZEDA LTD\fleet_data\erp_data\rentals.csv'
	WITH (FIRSTROW = 2,
	      FIELDTERMINATOR = ',',
	      TABLOCK);

	TRUNCATE TABLE bronze.erp_vehicle_maintenance;
	BULK INSERT bronze.erp_vehicle_maintenance
	FROM 'C:\Users\User\OneDrive\Desktop\ZEDA LTD\fleet_data\erp_data\vehicle_maintenance.csv'
	WITH (FIRSTROW = 2,
	      FIELDTERMINATOR = ',',
	      TABLOCK);

	TRUNCATE TABLE bronze.erp_vehicles;
	BULK INSERT bronze.erp_vehicles
	FROM 'C:\Users\User\OneDrive\Desktop\ZEDA LTD\fleet_data\erp_data\vehicles.csv'
	WITH (FIRSTROW = 2,
	      FIELDTERMINATOR = ',',
	      TABLOCK);

	PRINT '=====================================================================================';
	PRINT 'Loading IOT Table'
	PRINT '=====================================================================================';
	TRUNCATE TABLE bronze.iot_fleet_telemetry;
	BULK INSERT bronze.iot_fleet_telemetry
	FROM 'C:\Users\User\OneDrive\Desktop\ZEDA LTD\fleet_data\iot_data\fleet_telemetry.csv'
	WITH (FIRSTROW = 2,
	      FIELDTERMINATOR = ',',
	      TABLOCK);
END
GO

EXEC bronze.load_bronze;
