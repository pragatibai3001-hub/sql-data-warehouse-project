CREATE VIEW gold.dim_customers AS
SELECT 
ROW_NUMBER() OVER(ORDER BY cst_id) AS customer_key,
ca.cst_id AS customer_id,
ca.cst_key AS customer_number,
ca.cst_firstname AS first_name,
ca.cst_lastname AS last_name,
cl.CNTRY AS country,
ca.cst_marital_status AS marital_status,
CASE WHEN ca.cst_gndr != 'Unknown' THEN cst_gndr
	 ELSE COALESCE(GEN, 'Unknown')
END as gender,
ci.BDATE AS birthdate,
ca.cst_create_date AS create_date

FROM
silver.crm_cust_info ca
LEFT JOIN silver.erp_CUST_AZ12 ci
ON ca.cst_key = ci.CID
LEFT JOIN silver.erp_LOC_A101 cl
ON ca.cst_key = cl.CID



CREATE VIEW gold.dim_products AS
SELECT 
ROW_NUMBER() OVER(ORDER BY pr.prd_start_dt, pr.prd_key) AS product_key,
pr.prd_id AS product_id,
pr.prd_key AS product_number,
pr.prd_nm AS product_name,
pr.cat_id AS category_id,
px.CAT AS category,
px.SUBCAT AS subcategory,
px.MAINTENANCE,
pr.prd_cost AS cost,
prd_line AS product_line,
pr.prd_start_dt AS start_date
FROM silver.crm_prd_info pr
LEFT JOIN silver.erp_PX_CAT_G1V2 px
ON pr.cat_id = px.ID
WHERE prd_end_dt IS NULL



CREATE VIEW gold.fact_sales AS

SELECT 
sd.sls_ord_num,
gp.product_key,
gc.customer_key,
sd.sls_order_dt AS order_date,
sd.sls_ship_dt AS shipping_date,
sd.sls_due_dt AS due_date,
sd.sls_sales AS sales_amount,
sd.sls_quantity AS quantity,
sd.sls_price AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products gp
ON sd.sls_prd_key = gp.product_number
LEFT JOIN gold.dim_customers gc
ON sd.sls_cust_id = gc.customer_id

