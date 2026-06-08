## Creating tables for 3 years and truncating and inserting data from CSV file and Creating Stored Procedures

CREATE TABLE bronze.crm_cust_info(
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_firstname NVARCHAR(100),
	cst_lastname NVARCHAR(100),
	cst_marital_status NVARCHAR(10),
	cst_gndr NVARCHAR(10),
	cst_create_date DATE
);

CREATE TABLE bronze.crm_prd_info(
	prd_id INT,
	pro_key NVARCHAR(500),
	prd_nm NVARCHAR(500),
	prd_cost BIGINT,
	prd_line NVARCHAR(50),
	prd_start_dt DATE,
	prd_end_dt DATE
);

CREATE TABLE bronze.crm_sales_details(
	sls_ord_num NVARCHAR(100),
	sls_prd_key NVARCHAR(100),
	sls_cust_id BIGINT,
	sls_order_dt INT,
	sls_ship_dt INT,
	sls_due_dt INT,
	sls_sales BIGINT,
	sls_quantity INT,
	sls_price BIGINT
);

CREATE TABLE bronze.erp_CUST_AZ12(
	CID NVARCHAR(100),
	BDATE DATE,
	GEN NVARCHAR(50)
);

CREATE TABLE bronze.erp_LOC_A101(
	CID NVARCHAR(100),
	CNTRY NVARCHAR(100)
);

CREATE TABLE bronze.erp_PX_CAT_G1V2(
	ID NVARCHAR(100),
	CAT NVARCHAR(100),
	SUBCAT NVARCHAR(100),
	MAINTENANCE NVARCHAR(100)
);

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	BEGIN TRY

		TRUNCATE TABLE bronze.crm_cust_info;

		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\praga\OneDrive\Desktop\cust_info.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);




		TRUNCATE TABLE bronze.crm_prd_info;

		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\praga\OneDrive\Desktop\prd_info.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);




		TRUNCATE TABLE bronze.crm_sales_details;

		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\praga\OneDrive\Desktop\sales_details.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);



		TRUNCATE TABLE bronze.erp_CUST_AZ12;

		BULK INSERT bronze.erp_CUST_AZ12
		FROM 'C:\Users\praga\OneDrive\Desktop\CUST_AZ12.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);



		TRUNCATE TABLE bronze.erp_LOC_A101;

		BULK INSERT bronze.erp_LOC_A101
		FROM 'C:\Users\praga\OneDrive\Desktop\LOC_A101.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		TRUNCATE TABLE bronze.erp_PX_CAT_G1V2;

		BULK INSERT bronze.erp_PX_CAT_G1V2
		FROM 'C:\Users\praga\OneDrive\Desktop\PX_CAT_G1V2.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		END TRY
		BEGIN CATCH
			PRINT 'ERROR'
		END CATCH	
END


