-- ============================================
-- KFC PROJECT DATABASE & ANALYSIS
-- ============================================

-- ============================================
-- DATA LOADING
-- ============================================

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/kfc_orders_2026.csv' 
INTO TABLE kfc_orders_2026
CHARACTER SET utf8
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(order_id, @date, month, quarter, week_number, day_of_week, hour, minute,
 is_wednesday, is_weekend, city, outlet_id, channel, item_name, category,
 quantity, unit_price, discount_pct, total_price, order_status,
 delivery_time_mins, is_late_delivery, customer_id)
SET date = STR_TO_DATE(@date, '%m/%d/%Y');

-- Verify Data Load
SELECT COUNT(*) AS total_records FROM kfc_orders_2026;

-- ============================================
-- DATA VALIDATION
-- ============================================

-- Missing Customer IDs
SELECT * FROM kfc_orders_2026 WHERE customer_id IS NULL;

-- Duplicate Orders
SELECT order_id, COUNT(*) 
FROM kfc_orders_2026
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Invalid Delivery Time
SELECT * 
FROM kfc_orders_2026
WHERE delivery_time_mins < 0;

-- ============================================
-- VIEWS FOR ANALYSIS
-- ============================================

-- 1. Key Business Metrics
CREATE VIEW Business_Metrics AS
SELECT 
    SUM(total_price) AS total_sales,
    COUNT(order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers
FROM kfc_orders_2026;

-- 2. Monthly Sales Trend
CREATE VIEW Monthly_Sales AS
SELECT 
    YEAR(date) AS year,
    MONTH(date) AS month,
    SUM(total_price) AS total_sales
FROM kfc_orders_2026
GROUP BY YEAR(date), MONTH(date);

-- 3. Peak Order Hours
CREATE VIEW Peak_Hours AS
SELECT 
    hour,
    COUNT(order_id) AS total_orders
FROM kfc_orders_2026
GROUP BY hour;

-- 4. Sales by City
CREATE VIEW Sales_By_City AS
SELECT 
    city,
    SUM(total_price) AS total_sales
FROM kfc_orders_2026
GROUP BY city;

-- 5. Top 5 Selling Items
CREATE VIEW Top_5_Items AS
SELECT 
    item_name,
    SUM(total_price) AS total_sales
FROM kfc_orders_2026
GROUP BY item_name
ORDER BY total_sales DESC
LIMIT 5;

-- 6. Bottom 5 Items
CREATE VIEW Bottom_5_Items AS
SELECT 
    item_name,
    SUM(total_price) AS total_sales
FROM kfc_orders_2026
GROUP BY item_name
ORDER BY total_sales ASC
LIMIT 5;

-- 7. Late Delivery Percentage
CREATE VIEW Late_Delivery AS
SELECT 
    ROUND(
        SUM(CASE WHEN is_late_delivery = 1 THEN 1 ELSE 0 END) * 100.0 
        / COUNT(*), 2
    ) AS late_delivery_pct
FROM kfc_orders_2026;

-- 8. Weekend vs Weekday Sales
CREATE VIEW Weekend_Sales AS
SELECT 
    is_weekend,
    SUM(total_price) AS total_sales
FROM kfc_orders_2026
GROUP BY is_weekend;

-- 9. Average Delivery Time
CREATE VIEW Avg_Delivery_Time AS
SELECT 
    AVG(delivery_time_mins) AS avg_delivery_time
FROM kfc_orders_2026;

-- ============================================
-- SAMPLE QUERIES (OPTIONAL CHECKS)
-- ============================================

SELECT * FROM Business_Metrics;
SELECT * FROM Monthly_Sales;
SELECT * FROM Peak_Hours;
SELECT * FROM Sales_By_City;
SELECT * FROM Top_5_Items;
SELECT * FROM Bottom_5_Items;
SELECT * FROM Late_Delivery;
SELECT * FROM Weekend_Sales;
SELECT * FROM Avg_Delivery_Time;

-- ============================================
-- END OF PROJECT
-- ============================================