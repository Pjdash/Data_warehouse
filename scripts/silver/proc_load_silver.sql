DELIMITER //

DROP PROCEDURE IF EXISTS load_all_silver;
CREATE PROCEDURE load_all_silver()
BEGIN
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION 
    BEGIN 
      SELECT ' Error occurred while loading silver tables.' AS status_msg;
    END;

  -- CRM Customer Info
  DELETE FROM silver_crm_crust_cust_info;
  INSERT INTO silver_crm_crust_cust_info (
    cst_id, cst_key, cst_firstname, cst_lastname,
    cst_material_status, cst_gndr, cst_create_date
  )
  SELECT 
    cst_id,
    cst_key,
    TRIM(cst_firstname),
    TRIM(cst_lastname),
    CASE 
      WHEN TRIM(cst_material_status) = '' OR cst_material_status IS NULL THEN 'n/a'
      ELSE TRIM(cst_material_status)
    END AS cst_material_status,
    CASE 
      WHEN TRIM(cst_gndr) = '' OR cst_gndr IS NULL THEN 'n/a'
      ELSE TRIM(cst_gndr)
    END AS cst_gndr,
    cst_create_date
  FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS rn
    FROM bronze_crm_crust_cust_info
  ) AS t
  WHERE rn = 1;

  -- CRM Product Info
  DELETE FROM silver_crm_prd_info;
  INSERT INTO silver_crm_prd_info (
    prd_id, prd_key, prd_nm, prd_cost,
    prd_line, prd_start_dt, prd_end_dt
  )
  SELECT 
    prd_id,
    SUBSTRING(prd_key, 7, CHAR_LENGTH(prd_key)) AS prd_key,
    prd_nm,
    IFNULL(prd_cost, 0),
    CASE UPPER(TRIM(prd_line))
      WHEN 'M' THEN 'Mountain'
      WHEN 'R' THEN 'Road'
      WHEN 'S' THEN 'Other Sales'
      WHEN 'T' THEN 'Touring'
      ELSE 'n/a'
    END,
    DATE(prd_start_dt),
    DATE(DATE_SUB(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt), INTERVAL 1 DAY))
  FROM bronze_crm_prd_info;

  -- CRM Sales Details
  DELETE FROM silver_crm_sales_details;
  INSERT INTO silver_crm_sales_details (
    sls_ord_num, sls_prd_key, sls_cust_id,
    sls_order_date, sls_ship_date, sls_due_dt,
    sls_sales, sls_qunatity, sls_price
  )
  SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    STR_TO_DATE(sls_order_date, '%Y%m%d'),
    STR_TO_DATE(sls_ship_date, '%Y%m%d'),
    STR_TO_DATE(sls_due_dt, '%Y%m%d'),
    CASE
      WHEN sls_sales IS NULL OR sls_sales <= 0 
        OR sls_sales != sls_qunatity * ABS(sls_price)
      THEN sls_qunatity * ABS(sls_price)
      ELSE sls_sales
    END,
    sls_qunatity,
    CASE
      WHEN sls_price IS NULL OR sls_price <= 0
      THEN sls_sales / NULLIF(sls_qunatity, 0)
      ELSE sls_price
    END
  FROM bronze_crm_sales_details
  WHERE 
    CHAR_LENGTH(sls_order_date) = 8 AND STR_TO_DATE(sls_order_date, '%Y%m%d') IS NOT NULL
    AND CHAR_LENGTH(sls_ship_date) = 8 AND STR_TO_DATE(sls_ship_date, '%Y%m%d') IS NOT NULL
    AND CHAR_LENGTH(sls_due_dt) = 8 AND STR_TO_DATE(sls_due_dt, '%Y%m%d') IS NOT NULL;

  -- ERP Customer AZ12
  DELETE FROM silver_erp_cust_az12;
  INSERT INTO silver_erp_cust_az12 (cid, bdate, gen)
  SELECT 
    CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4) ELSE cid END,
    CASE WHEN bdate > CURRENT_DATE() THEN NULL ELSE bdate END,
    CASE 
      WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
      WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
      ELSE 'n/a'
    END
  FROM bronze_erp_cust_az12;

  -- ERP Location A101
  DELETE FROM silver_erp_loc_a101;
  INSERT INTO silver_erp_loc_a101 (cid, cntry)
  SELECT 
    REPLACE(cid, '-', ''),
    CASE 
      WHEN TRIM(cntry) = 'DE' THEN 'Germany'
      WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
      WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
      ELSE TRIM(cntry)
    END
  FROM bronze_erp_loc_a101;

  -- ERP PX Category
  DELETE FROM silver_erp_px_cat_g1v2;
  INSERT INTO silver_erp_px_cat_g1v2 (id, cat, subcat, maintenance)
  SELECT * FROM bronze_erp_px_cat_g1v2;

  SELECT 'All silver tables loaded successfully.' AS status_msg;
END;
//

DELIMITER ;

