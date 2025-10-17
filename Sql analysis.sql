
-- Create and use database
CREATE DATABASE IF NOT EXISTS supply_chain_db;
USE supply_chain_db;

--Create table (structure should match your cleaned CSV)
CREATE TABLE IF NOT EXISTS supply_chain (
    order_id INT PRIMARY KEY,
    order_date DATE,
    delivery_date DATE,
    region VARCHAR(50),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(100),
    supplier_name VARCHAR(100),
    cost_price DECIMAL(10,2),
    selling_price DECIMAL(10,2),
    quantity INT,
    profit DECIMAL(10,2),
    delivery_days INT
);


-- Top 10 Suppliers by Total Profit
SELECT supplier_name,
       ROUND(SUM(profit), 2) AS total_profit
FROM supply_chain
GROUP BY supplier_name
ORDER BY total_profit DESC
LIMIT 10;

--  Average Delivery Time by Supplier
SELECT supplier_name,
       ROUND(AVG(delivery_days), 1) AS avg_delivery_days
FROM supply_chain
GROUP BY supplier_name
ORDER BY avg_delivery_days ASC;

--Top 5 Products per Region by Sales
WITH product_sales AS (
    SELECT region, product_name,
           SUM(selling_price * quantity) AS total_sales
    FROM supply_chain
    GROUP BY region, product_name
)
SELECT region, product_name, total_sales
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY region ORDER BY total_sales DESC) AS rn
    FROM product_sales
) ranked
WHERE rn <= 5;

-- Monthly Sales Trend (Year-over-Year)
SELECT YEAR(order_date) AS order_year,
       MONTH(order_date) AS order_month,
       ROUND(SUM(selling_price * quantity), 2) AS total_sales
FROM supply_chain
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY order_year, order_month;

--  Category-wise Highest Profit Month
WITH monthly_profit AS (
    SELECT category,
           DATE_FORMAT(order_date, '%Y-%m') AS year_month,
           SUM(profit) AS total_profit
    FROM supply_chain
    GROUP BY category, year_month
)
SELECT category, year_month, total_profit
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY total_profit DESC) AS rn
    FROM monthly_profit
) ranked
WHERE rn = 1;

--  Top Supplier per Region by Profit
WITH regional_profit AS (
    SELECT region, supplier_name,
           SUM(profit) AS total_profit
    FROM supply_chain
    GROUP BY region, supplier_name
)
SELECT region, supplier_name, total_profit
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY region ORDER BY total_profit DESC) AS rn
    FROM regional_profit
) ranked
WHERE rn = 1;

