
-- ================================================
-- View: gold_dim_customers
-- Description: Dimension view for customer master data
-- Source: silver_crm_crust_cust_info, erp_cust_az12, erp_loc_a101
-- ================================================
CREATE OR REPLACE VIEW gold_dim_customers AS
SELECT 
  ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,          
  ci.cst_id AS customer_id,                                        
  ci.cst_key AS customer_number,                                    
  ci.cst_firstname AS first_name,                                   
  ci.cst_lastname AS last_name,                                     
  la.cntry AS country,                                              
  ci.cst_material_status AS marital_status,                        
  CASE 
    WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr                     
    ELSE COALESCE(ca.gen, 'n/a')                                   
  END AS gender,
  ca.bdate AS birthdate,                                            
  ci.cst_create_date AS create_date                               
FROM silver_crm_crust_cust_info ci
LEFT JOIN silver_erp_cust_az12 ca
  ON ci.cst_key = ca.cid
LEFT JOIN silver_erp_loc_a101 la
  ON ci.cst_key = la.cid;



-- ================================================
-- View: gold_dim_products
-- Description: Dimension view for product master data
-- Source: silver_crm_prd_info, erp_px_cat_g1v2
-- ================================================
CREATE OR REPLACE VIEW gold_dim_products AS
SELECT 
  ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
  pn.prd_id AS product_id,                                                 
  pn.prd_key AS product_number,                                           
  pn.prd_nm AS product_name,                                              
  REPLACE(SUBSTRING(pn.prd_key, 1, 5), '-', '_') AS category_id,           
  pc.cat AS category,                                                      
  pc.subcat AS subcategory,                                               
  pc.maintenance,                                                         
  pn.prd_cost AS cost,                                                    
  pn.prd_line AS product_line,                                           
  pn.prd_start_dt AS start_date                                          
FROM silver_crm_prd_info pn
LEFT JOIN silver_erp_px_cat_g1v2 pc
  ON REPLACE(SUBSTRING(pn.prd_key, 1, 5), '-', '_') = pc.id
WHERE pn.prd_end_dt IS NULL;                                             


-- ================================================
-- View: gold_fact_sales
-- Description: Fact table for sales transactions
-- Source: silver_crm_sales_details joined with dim_products and dim_customers
-- ================================================
CREATE OR REPLACE VIEW gold_fact_sales AS
SELECT 
  sd.sls_ord_num AS order_number,        
  cu.customer_key,                      
  pr.product_key,                        
  sd.sls_order_date AS order_date,      
  sd.sls_ship_date AS shipping_date,     
  sd.sls_due_dt AS due_date,            
  sd.sls_sales AS sales_amount,          
  sd.sls_qunatity AS quantity,          
  sd.sls_price AS price                 
FROM silver_crm_sales_details sd
LEFT JOIN gold_dim_products pr
  ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold_dim_customers cu
  ON sd.sls_cust_id = cu.customer_id;
