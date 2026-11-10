-- -------------------------------------------------------------------
-- DDL Script: Create Silver Table
-- -------------------------------------------------------------------
-- Script Purpose:
--   This script creates tables in the 'silver' schema, dropping existing tables
--   if they already exist.
--   Run this script to re-define the DDL structure of 'silver' tables
-- -------------------------------------------------------------------

CREATE OR ALTER PROCEDURE Silver.load_silver AS 
BEGIN
DECLARE @start_time DATETIME,@end_time DATETIME,@duration INT,@batch_start_time DATETIME , @batch_end_time DATETIME;
SET @batch_start_time = GETDATE();
  BEGIN TRY
print '==============================================================';
print 'Loading Silver Layer                                          ';
print '==============================================================';

SET @start_time = GETDATE();
print '>>truncating table: Silver.crm_cust_info                      ';
TRUNCATE TABLE Silver.crm_cust_info;

print '>>Insert Data Into: Silver.crm_cust_info                      ';
INSERT INTO Silver.crm_cust_info(
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,
        cst_create_date
    )
        SELECT
            cst_id,
            cst_key,
            TRIM(cst_firstname) AS cst_firstname,
            TRIM(cst_lastname) AS cst_lastname,
        CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
             WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
             ELSE 'n/a'
             END cst_marital_status,
        CASE WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
             WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
             ELSE 'n/a'
             END cst_gndr,
        cst_create_date
        FROM
        (
        SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS FLAG_LAST
        FROM bronze.crm_cust_info
    
       )t WHERE FLAG_LAST = 1 AND cst_id IS NOT NULL

   SET @end_time = GETDATE();
   PRINT'>> Load Duration: ' +CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(10)) + 'seconds';
   PRINT '>> ------------';

   SET @start_time = GETDATE();
    print '>>truncating table: Silver.crm_prd_info                               ' ;
    TRUNCATE TABLE Silver.crm_prd_info;

    print '>>Insert Data Into: Silver.crm_prd_info                               ' ;
    INSERT INTO Silver.crm_prd_info(
	    prd_id  ,
	    cat_id , 
	    prd_key  ,
	    prd_nm  ,
	    prd_cost  ,
	    prd_line  ,
	    prd_start_dt  ,
	    prd_end_dt
	
    )
        SELECT 
        prd_id,
        REPLACE(SUBSTRING(prd_key,1,5),'-','_') as cat_id,
        SUBSTRING(prd_key,7,LEN(prd_key))AS prd_key,
        prd_nm,
        ISNULL(prd_cost,0) AS prd_cost,
        CASE UPPER(TRIM(prd_line)) 
         WHEN 'M' THEN 'Mountin'
         WHEN 'R' THEN 'Road'
         WHEN 'S' THEN 'Other Sale'
         WHEN 'T' THEN 'Touring'
         ELSE 'n/a'
         END AS prd_line,    
        CAST(prd_start_dt AS date) AS prd_start_dt,
        CAST(DATEADD(DAY, -1,LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)) AS date) AS prd_end_dt
        FROM bronze.crm_prd_info
        
   SET @end_time = GETDATE();
   PRINT'>> Load Duration: ' +CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(10)) + 'seconds';
   PRINT '>> ------------';

   SET @start_time = GETDATE();
    print '>>truncating table: Silver.crm_sales_details                         ' ;
    TRUNCATE TABLE Silver.crm_sales_details;

    print '>>INSERT Data Into: Silver.crm_sales_details                         ' ;
    INSERT INTO Silver.crm_sales_details(
	    sls_ord_num,
	    sls_prd_key,
	    sls_cust_id,
	    sls_order_dt,
	    sls_ship_dt,
	    sls_due_dt,
	    SLS_sales ,
	    sls_quantity,
	    sls_price
    )
        SELECT 
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        CASE WHEN sls_order_dt = 0  OR LEN(sls_order_dt) !=8 THEN NULL 
        ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS date)
        END AS sls_order_dt,
        CASE WHEN sls_ship_dt = 0  OR LEN(sls_ship_dt) !=8 THEN NULL 
        ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS date)
        END AS sls_ship_dt,
        CASE WHEN sls_ship_dt = 0  OR LEN(sls_due_dt) !=8 THEN NULL 
        ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS date)
        END AS sls_due_dt,
        CASE WHEN SLS_sales IS NULL
                  OR SLS_sales != sls_quantity * ABS(sls_price)
                  THEN sls_quantity * ABS(sls_price)
                  ELSE SLS_sales
                  END AS SLS_sales,
        sls_quantity,
        CASE WHEN sls_price IS NULL 
                  OR sls_price <= 0
                 THEN SLS_sales/NULLIF(sls_quantity,0)
        ELSE sls_price
        END AS sls_price
        FROM bronze.crm_sales_details

   SET @end_time = GETDATE();
   PRINT'>> Load Duration: ' +CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(10)) + 'seconds';
   PRINT '>> ------------';

   SET @start_time = GETDATE();
   print '>>truncating table: Silver.erp_cus_az12                            ' 
   TRUNCATE TABLE Silver.erp_cus_az12;

    print '>>INSERT Data into: Silver.erp_cus_az12                            ';
    INSERT INTO Silver.erp_cus_az12(CID,BDATE,GEN)
        SELECT
        CASE WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID,4,LEN(CID))
               ELSE CID
               END CID,
        CASE WHEN BDATE > GETDATE() THEN NULL
             ELSE BDATE
             END BDATE,
         CASE WHEN TRIM(UPPER(GEN)) IN ('F','Female') THEN 'Female'
              WHEN TRIM(UPPER(GEN)) IN ('M','Male') THEN  'Male'
              ELSE 'n/a'
        END GEN
        FROM bronze.erp_cus_az12

   SET @end_time = GETDATE();
   PRINT'>> Load Duration: ' +CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(10)) + 'seconds';
   PRINT '>> ------------';

   SET @end_time = GETDATE();
   print '>>truncating table: Silver.erp_loc_a101                        ';
   TRUNCATE TABLE Silver.erp_loc_a101

    print '>> Insert Data into table: Silver.erp_loc_a101                        ';
    INSERT INTO Silver.erp_loc_a101(CID,CNTRY)
        SELECT 
        REPLACE(CID,'-','') CID,
        CASE WHEN TRIM(CNTRY) = 'DE' THEN 'Germany'
             WHEN TRIM(CNTRY) IN ('US','USA') THEN 'United States' 
             WHEN TRIM(CNTRY) = '' OR CNTRY IS NULL  THEN 'n/a'
             ELSE TRIM(CNTRY)
             END  CNTRY
        FROM bronze.erp_loc_a101
   SET @end_time = GETDATE();
   PRINT'>> Load Duration: ' +CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(10)) + 'seconds';
   PRINT '>> ------------';
        
    SET @start_time = GETDATE();         
    print '>>truncating table: Silver.erp_cus_az12                       ';       
    TRUNCATE TABLE Silver.erp_px_cat_g1v1

    print '>>Insert Data Into table: Silver.erp_cus_az12                 '; 
    INSERT INTO Silver.erp_px_cat_g1v1(
        ID,
        CAT,
        SUBCAT,
        MAINTENANCE
        )
        SELECT 
        ID,
        CAT,
        SUBCAT,
        MAINTENANCE
        FROM bronze.erp_px_cat_g1v1
   SET @end_time = GETDATE();
   PRINT'>> Load Duration: ' +CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(10)) + 'seconds';
   PRINT '>> ------------';
   SET @batch_end_time = GETDATE();
    PRINT '========================================================================================='
    PRINT 'loading Bronze Lyer is completed';
    PRINT ' - Total Load Duration: ' + cast(DATEDIFF(SECOND,@batch_start_time,@batch_end_time)AS NVARCHAR) + 'seconds';
    PRINT '>> ========================================'
END TRY
BEGIN CATCH
  PRINT'==============================================================================';
       PRINT'ERROR OCCURED DURING LOADING Silver LAYER'
       PRINT'Error Message' + ERROR_MESSAGE();
       PRINT'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
       PRINT'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
       PRINT'=========================================================================';
END CATCH
END
