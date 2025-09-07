-- This script is used for creating all the necessary Bronze-layer tables
-- for the Data Warehouse project. Since MySQL doesn't support schemas inside 
-- a single database, logical layers (like bronze) are simulated using table name prefixes.

-- Step 1: Create and select the database
CREATE DATABASE IF NOT EXISTS DataWarehouse;
USE DataWarehouse;

-- ========================
-- CRM: Customer Information
-- ========================
CREATE TABLE bronze_crm_crust_cust_info (
    cst_id INT,
    cst_key VARCHAR(50),
    cst_firstname VARCHAR(50),
    cst_lastname VARCHAR(50),
    cst_material_status VARCHAR(50),
    cst_gndr VARCHAR(50),
    cst_create_date DATE
);

-- ========================
-- CRM: Product Information
-- ========================
CREATE TABLE bronze_crm_prd_info (
    prd_id INT,
    prd_key VARCHAR(50),
    prd_nm VARCHAR(50),
    prd_cost INT,
    prd_line VARCHAR(50),
    prd_start_dt DATETIME,
    prd_end_dt DATETIME
);

-- ========================
-- CRM: Sales Details
-- ========================
CREATE TABLE bronze_crm_sales_details (
    sls_ord_num VARCHAR(50),
    sls_prd_key VARCHAR(50),
    sls_cust_id INT,
    sls_order_date INT,
    sls_ship_date INT,
    sls_due_dt INT,
    sls_sales INT,
    sls_qunatity INT,
    sls_price INT
);

-- ========================
-- ERP: Location Data
-- ========================
CREATE TABLE bronze_erp_loc_a101 (
    cid VARCHAR(50),
    cntry VARCHAR(50)
);

-- ========================
-- ERP: Customer Basic Info
-- ========================
CREATE TABLE bronze_erp_cust_az12 (
    cid VARCHAR(50),
    bdate DATE,
    gen VARCHAR(50)
);

-- ========================
-- ERP: Product Category
-- ========================
CREATE TABLE bronze_erp_px_cat_g1v2 (
    id VARCHAR(50),
    cat VARCHAR(50),
    subcat VARCHAR(50),
    maintenance VARCHAR(50)
);
