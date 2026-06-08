--**Creating Data Warehouse named 'DataWarehouse'and Schemas named 'bronze', 'silver' and 'gold'**--

USE master;

--Create the 'DataWarehouse' database

CREATE DATABASE DataWareHouse;

USE DataWareHouse;

--Create Schemas

CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
