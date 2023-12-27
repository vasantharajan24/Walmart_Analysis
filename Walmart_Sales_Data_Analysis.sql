-- create database
create database walmartsales;
use walmartsales;
-- create table
create table sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);

select * from sales;

select time,
(CASE WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
	WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
    ELSE "Evening"
    END) as time_of_day
 from sales;

-- add column time_of_day

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales
SET time_of_day =(CASE WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
	WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
    ELSE "Evening"
    END);
    
SELECT date, dayname(date)
FROM sales;
    
-- add day_name

ALTER TABLE sales ADD COLUMN day_name VARCHAR(20);

UPDATE sales
SET day_name = DAYNAME(date);

SELECT date,MONTHNAME(date)
FROM sales;

-- add month_name
ALTER TABLE sales ADD COLUMN month_name VARCHAR(20);

UPDATE sales
SET month_name = MONTHNAME(date);


-- -------GENRIC---
-- How many unique cities does the data have?
SELECT COUNT( DISTINCT city)
FROM sales;

-- In which city is each branch?

SELECT city, branch
FROM sales
GROUP BY city;

-- ---------PRODUCT-----

-- How many unique product lines does the data have?

SELECT product_line,COUNT(DISTINCT product_line)
FROM sales
GROUP BY product_line;

-- What is the most common payment method?
with count as (SELECT payment, COUNT(payment) as method_count
FROM sales
GROUP BY payment)
SELECT payment
FROM count
HAVING MAX(method_count);

-- What is the most selling product line?
SELECT SUM(quantity) as qty, product_line
FROM sales
GROUP BY product_line
ORDER BY qty DESC;

-- What is the total revenue by month?

SELECT month_name, SUM(total) as total_revenue
FROM sales
GROUP BY month_name
ORDER BY total_revenue DESC;

-- What month had the largest COGS?

SELECT month_name as month, SUM(cogs) as COGS
FROM sales
GROUP BY month_name
ORDER BY COGS DESC;

-- What product line had the largest revenue?

SELECT product_line, SUM(total) AS revenue
FROM sales
GROUP BY product_line
ORDER BY revenue DESC;

-- What is the city with the largest revenue?

SELECT city, branch, SUM(total) as revenue
FROM sales
GROUP BY city, branch
ORDER BY revenue DESC;

-- What product line had the largest VAT?
SELECT product_line, 0.05 * cogs as vat
FROM sales
GROUP BY product_line
ORDER BY vat DESC;

-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
with average as (
SELECT product_line, avg(quantity) avg_qty
FROM sales)

SELECT product_line, 
(case when avg_qty >6 then "Good"
else "Bad"
end) as remark
FROM average
GROUP BY product_line;

-- Which branch sold more products than average product sold

SELECT branch, SUM(quantity) as total_sales
FROM sales
GROUP BY branch
HAVING total_sales > (SELECT avg(quantity) as avg_qty
FROM sales);

-- What is the most common product line by gender?

with count as ( SELECT gender, product_line,COUNT(product_line) as pd_count
FROM sales
GROUP BY gender,product_line)

SELECT gender, product_line
FROM count
GROUP BY gender
HAVING MAX(pd_count)
ORDER BY pd_count DESC;

-- What is the average rating of each product line?

SELECT product_line, avg(rating) as avg_rating
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;

-- ----------- SALES----

-- Number of sales made in each time of the day per weekday

SELECT time_of_day, COUNT(*) as total_sales
FROM sales
WHERE day_name = 'Sunday'
GROUP BY time_of_day
ORDER BY total_sales DESC;
-- Evening has more sales, then most of the sales happened at evening

-- Which of the customer types brings the most revenue?

SELECT customer_type, SUM(total) as revenue
FROM sales
GROUP BY customer_type
ORDER BY revenue DESC;

-- Member cutomer type brings the most revenue

-- Which city has the largest tax percent/ VAT (**Value Added Tax**)?

SELECT city, tax_pct
FROM sales
GROUP BY city
ORDER BY tax_pct DESC;
-- Mandalay has the largest tax percent

-- Which customer type pays the most in VAT?
SELECT customer_type, tax_pct
FROM sales
GROUP BY customer_type
ORDER BY tax_pct DESC;
-- Normal type pays the most in VAT

-- --------CUSTOMER------

-- How many unique customer types does the data have?

SELECT customer_type, COUNT(DISTINCT customer_type) as count
FROM sales
GROUP BY customer_type
ORDER BY count DESC;

-- How many unique payment methods does the data have?

SELECT payment, count(distinct payment)
FROM sales 
GROUP BY payment;

-- What is the most common customer type?

SELECT customer_type, count(customer_type) as cus_count
FROM sales
GROUP BY customer_type
ORDER BY cus_count DESC;

-- Which customer type buys the most?
SELECT customer_type, COUNT(*) as sales
FROM sales
GROUP BY customer_type
ORDER BY sales DESC;

-- What is the gender of most of the customers?
SELECT gender, COUNT(*) as gd_count
FROM sales
GROUP BY gender
ORDER BY gd_count DESC;

-- What is the gender distribution per branch?
SELECT gender, COUNT(*) as gd_count
FROM sales
WHERE branch= 'A'
GROUP BY gender
ORDER BY gd_count DESC;

-- Which time of the day do customers give most ratings?
SELECT time_of_day, avg(rating) as avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Which time of the day do customers give most ratings per branch?
SELECT time_of_day, avg(rating) as avg_rating
FROM sales
WHERE branch='B'
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Which day fo the week has the best avg ratings?

SELECT day_name, avg(rating) as avg_rating
FROM sales
GROUP BY day_name
ORDER BY avg_rating DESC;

-- Which day of the week has the best average ratings per branch?

SELECT day_name, avg(rating) as avg_rating
FROM sales
WHERE branch = 'C'
GROUP BY day_name
ORDER BY avg_rating DESC;