/*
-------------------------------------------------------------------
Quality Checks
-------------------------------------------------------------------
Script Purpose:
    This script performs various quality checks for data consistency, accuracy,
    and standardization across the 'silver' schema. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
-------------------------------------------------------------------
*/
-- Checking "silver.crm_cust_info"
-------------------------------------------------------------------

-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT
    cst_id,
    COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL
-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key)
   OR cst_firstname != TRIM(cst_firstname)
   OR cst_lastname != TRIM(cst_lastname)
   OR cst_marital_status != TRIM(cst_marital_status)
   OR cst_gndr != TRIM(cst_gndr);

-- Data Standardization & Consistency
SELECT DISTINCT
    cst_marital_status
FROM silver.crm_cust_info;
----------------------------------------------------------------------------
-- Check for Null or Negative Values in Cost FROM silver.crm_prd_info
-- Expectation: No Results
--------------------------------------------------------------------------------
SELECT
    prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Data Standardization & Consistency
SELECT DISTINCT
    prd_line
FROM silver.crm_prd_info;

-- Check for Invalid Date Orders (Start Date > End Date)
-- Expectation: No Results
SELECT
    prd_start_dt,
    prd_end_dt
FROM silver.crm_prd_info
WHERE prd_start_dt > prd_end_dt;
--- check for NULL OR DUBLICATE IN PRIMARY KEY
SELECT 
prd_id,
COUNT(*)
FROM Silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 or prd_id IS NULL
--- check for unwanted spaces
-----expectation: no result
SELECT 
prd_nm
FROM Silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)  
---- check if i have null or negative numbers
---- expectation : no result
SELECT
prd_cost
FROM Silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL
----- Data standardization @ consistency
SELECT DISTINCT prd_line
FROM Silver.crm_prd_info

-------------------------------------------------------------------
-- Checking "silver.crm_sales_details"
-------------------------------------------------------------------

---- check for invalid date 
SELECT 
NULLIF(sls_due_dt,0) AS sls_due_dt
from Silver.crm_sales_details
WHERE sls_due_dt<0
or LEN(sls_due_dt) != 8
or sls_due_dt> 20500101
or sls_due_dt< 19000101
------ check for invalid date order 
SELECT *
FROM Silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt or sls_order_dt > sls_ship_dt
---SALES = QUANTITY * PRICE
----VALUE MUST BE NOT NULL ,ZERO OR NEGATIVE
SELECT DISTINCT
SLS_sales,
sls_quantity,
sls_price 
FROM Silver.crm_sales_details
WHERE SLS_sales != sls_quantity * sls_price
OR SLS_sales IS  NULL OR sls_quantity IS  NULL OR sls_price IS  NULL
OR SLS_sales <= 0 OR sls_quantity < = 0 OR sls_price < = 0
ORDER BY SLS_sales,sls_quantity,sls_price
-----------------------------------------------  
-- Check for Unwanted Spaces FROM silver.erp_loc_a101
-- Expectation: No Results
 --------------------------------------------------- 
SELECT
    cid,
    cntry
FROM silver.erp_loc_a101
WHERE cid != TRIM(cid)
   OR cntry != TRIM(cntry);

-- Data Standardization & Consistency
SELECT DISTINCT
    cntry
FROM silver.erp_loc_a101;

-------------------------------------------------------------------
-- Checking "silver.erp_px_cat_g1v2"
-------------------------------------------------------------------

-- Data Standardization & Consistency
SELECT DISTINCT
    id,
    cat,
    subcat,
    maintenance
FROM silver.erp_px_cat_g1v2;
-------------------------------------------------------------------------
-- Identify Out-of-Range Dates FROM silver.erp_cust_az12
-- Expectation: Birthdays between 1924-01-01 and Today
-------------------------------------------------------------------------
SELECT DISTINCT
    bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01'
   OR bdate > GETDATE();

-- Data Standardization & Consistency
