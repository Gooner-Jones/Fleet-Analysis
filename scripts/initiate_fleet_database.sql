-- ================================================================================================================
-- Create Database and Schemas
-- ================================================================================================================

/* This script creates a new database named 'Fleet' after checking if it already exists. 
   If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas 
   within the database: 'bronze', 'silver', and 'gold'.
*/

USE master;
GO

-- Drop and recreate the 'Fleet' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Fleet')
BEGIN
    ALTER DATABASE Fleet SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Fleet;
END;
GO

-- Create the 'Fleet' database
CREATE DATABASE Fleet;
GO

USE Fleet;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
