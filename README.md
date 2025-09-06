# Data Warehouse Project

## Overview  
This project implements a **Data Warehouse** in **MySQL** to consolidate and transform data from **CRM** and **ERP** systems into analytics-ready datasets. The warehouse supports efficient querying, reporting, and business insights by leveraging **ETL pipelines** and a **Star Schema** design.

---

## Features  
- ETL Pipelines with **Bronze, Silver, and Gold layers** for scalable and modular data processing  
- **Star Schema Design** with a **Sales Fact Table** linked to **Customer** and **Product Dimensions**  
- Automated Data Ingestion & Transformation using **stored procedures**  
- Analytics-ready datasets for business reporting and dashboards  
- Advanced Analytics including:  
  - Trends  
  - Segmentation  
  - Ranking  
  - Change-over-time reporting  

---

## Architecture  

### Data Flow
1. **Bronze Layer** → Raw data ingestion from CRM & ERP  
2. **Silver Layer** → Data cleaning, deduplication, and standardization  
3. **Gold Layer** → Aggregated and business-ready datasets  

### Schema Design
- **Fact Table**: `sales_fact`  
- **Dimensions**:  
  - `customer_dim`  
  - `product_dim`  

---

## Tools & Technologies  
- Database: MySQL  
- ETL Pipelines: Custom scripts + stored procedures  
- Data Modeling: Star Schema  
- Analytics: SQL queries for insights & reporting  

---

## Example Analytics Queries  

```sql
-- Monthly Sales Trends
SELECT DATE_FORMAT(sale_date, '%Y-%m') AS month, SUM(sales_amount) AS total_sales
FROM sales_fact
GROUP BY month
ORDER BY month;

-- Top 5 Products by Sales Volume
SELECT p.product_name, SUM(s.quantity) AS total_qty
FROM sales_fact s
JOIN product_dim p ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_qty DESC
LIMIT 5;
