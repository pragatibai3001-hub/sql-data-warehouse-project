CREATE OR ALTER PROCEDURE silver.load_silver AS 
BEGIN

	TRUNCATE TABLE silver.crm_cust_info

	INSERT INTO silver.crm_cust_info (
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_status,
	cst_gndr
	)

	SELECT 
	cst_id,
	cst_key,
	TRIM(cst_firstname) AS cst_firstname,
	TRIM(cst_lastname) AS cst_lastname,
	CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
		 WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
		 ELSE 'Unknown'
	END AS cst_marital_status,
	CASE
	WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
	WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
	ELSE 'Unknown'
	END AS cst_gndr

	FROM 
	(SELECT *,
	ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_number
	FROM bronze.crm_cust_info
	WHERE cst_id IS NOT NULL) AS t
	WHERE flag_number = 1;


	IF OBJECT_ID ('silver.crm_prd_info','U') IS NOT NULL
		DROP TABLE silver.crm_prd_info

	CREATE TABLE silver.crm_prd_info(
		prd_id INT,
		cat_id NVARCHAR(50),
		prd_key NVARCHAR(50),
		prd_nm NVARCHAR(100),
		prd_cost BIGINT,
		prd_line NVARCHAR(100),
		prd_start_dt DATE,
		prd_end_dt DATE,
		dwh_create_date DATETIME2 DEFAULT GETDATE()
		);

	TRUNCATE TABLE silver.crm_prd_info

	INSERT INTO silver.crm_prd_info(
		prd_id,
		cat_id,
		prd_key,
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt
		)

	SELECT 
	prd_id,
	REPLACE(SUBSTRING(pro_key, 1, 5), '-', '_') AS cat_id,
	SUBSTRING(pro_key, 7, LEN(pro_key)) AS prd_key,
	TRIM(prd_nm) AS prd_nm,
	ISNULL(prd_cost,0) AS prd_cost,
	CASE UPPER(TRIM(prd_line))
		 WHEN 'M' THEN 'Mountain'
		 WHEN 'R' THEN 'Road'
		 WHEN 'S' THEN 'Other Sales'
		 WHEN 'T' THEN 'Touring'
		 ELSE 'Unknown'
	END AS prd_line,
	prd_start_dt,
	DATEADD(DAY, -1, LEAD(prd_start_dt) OVER(PARTITION BY pro_key ORDER BY prd_start_dt)) AS prd_end_dt

	FROM bronze.crm_prd_info;


	IF OBJECT_ID ('silver.crm_sales_details','U') IS NOT NULL
		DROP TABLE silver.crm_sales_details

	CREATE TABLE silver.crm_sales_details(
		sls_ord_num NVARCHAR(100),
		sls_prd_key NVARCHAR(100),
		sls_cust_id BIGINT,
		sls_order_dt DATE,
		sls_ship_dt DATE,
		sls_due_dt DATE,
		sls_sales BIGINT,
		sls_quantity INT,
		sls_price BIGINT,
		dwh_create_date DATETIME2 DEFAULT GETDATE()
	);

	TRUNCATE TABLE silver.crm_sales_details

	INSERT INTO silver.crm_sales_details(
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		sls_order_dt,
		sls_ship_dt,
		sls_due_dt,
		sls_sales,
		sls_quantity,
		sls_price)

	SELECT 
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	CASE WHEN sls_order_dt <= 0 OR LEN(sls_order_dt) != 8 THEN NULL
		 ELSE CAST(CAST(sls_order_dt AS VARCHAR)AS DATE)
	END AS sls_order_dt,
	CASE WHEN sls_ship_dt <= 0 OR LEN(sls_ship_dt) != 8 THEN NULL
		 ELSE CAST(CAST(sls_ship_dt AS VARCHAR)AS DATE)
	END AS sls_ship_dt,
	CASE WHEN sls_due_dt <= 0 OR LEN(sls_due_dt) != 8 THEN NULL
		 ELSE CAST(CAST(sls_due_dt AS VARCHAR)AS DATE)
	END AS sls_due_dt,
	CASE WHEN sls_sales <= 0 OR sls_sales IS NULL THEN sls_quantity*ABS(sls_price)
		 ELSE sls_quantity*sls_price
	END AS sls_sales,
	sls_quantity,
	CASE WHEN sls_price <= 0 OR sls_price IS NULL THEN sls_sales/NULLIF(sls_quantity,0)
		 ELSE sls_price
	END AS sls_price
	FROM bronze.crm_sales_details
	ORDER BY sls_price;

	TRUNCATE TABLE silver.erp_CUST_AZ12

	INSERT INTO silver.erp_CUST_AZ12(
		CID,
		BDATE,
		GEN)

	SELECT 
	CASE WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID,4,LEN(CID))
		 ELSE CID
	END AS CID,
	CASE WHEN BDATE > GETDATE() THEN NULL
		 ELSE BDATE
	END AS BDATE,
	CASE WHEN UPPER(TRIM(GEN)) IN ('M', 'MALE') THEN 'Male'
		 WHEN UPPER(TRIM(GEN)) IN ('F', 'FEMALE') THEN 'Female'
		 ELSE 'Uknown'
	END AS GEN
	FROM bronze.erp_CUST_AZ12;

	TRUNCATE TABLE silver.erp_LOC_A101

	INSERT INTO silver.erp_LOC_A101
	(
		CID,
		CNTRY)



	SELECT 
	REPLACE(CID, '-', '') AS CID, 
	CASE WHEN CNTRY IN ('US', 'USA') THEN 'United States'
		 WHEN CNTRY = 'DE' THEN 'Germany'
		 WHEN CNTRY IS NULL OR CNTRY = '' THEN 'Unknown'
		 ELSE CNTRY
	END AS CNTRY
	FROM bronze.erp_LOC_A101;

	TRUNCATE TABLE silver.erp_PX_CAT_G1V2

	INSERT INTO silver.erp_PX_CAT_G1V2(
		ID,
		CAT,
		SUBCAT,
		MAINTENANCE)

	SELECT
	ID,
	CAT,
	SUBCAT,
	MAINTENANCE
	FROM bronze.erp_PX_CAT_G1V2

END

