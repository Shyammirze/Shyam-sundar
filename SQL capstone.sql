create database if not exists amazon;
use amazon;
select * from amazon;

ALTER TABLE amazon CHANGE COLUMN `Invoice ID` invoice_id text;
ALTER TABLE amazon CHANGE COLUMN `Customer type` Customer_type text;
ALTER TABLE amazon CHANGE COLUMN `Product line` Product_line text;
ALTER TABLE amazon CHANGE COLUMN `Unit price` Unit_price double;
ALTER TABLE amazon CHANGE COLUMN `Tax 5%` VAT double;
ALTER TABLE amazon CHANGE COLUMN `Payment` payment_method text;
ALTER TABLE amazon CHANGE COLUMN `gross margin percentage` gross_margin_percentage double;
ALTER TABLE amazon CHANGE COLUMN `gross income` gross_income double;
select * from amazon;

ALTER TABLE amazon MODIFY COLUMN invoice_id VARCHAR(30);
ALTER TABLE amazon MODIFY COLUMN branch VARCHAR(5);
ALTER TABLE amazon MODIFY COLUMN city VARCHAR(30);
ALTER TABLE amazon MODIFY COLUMN Customer_type VARCHAR(30);
ALTER TABLE amazon MODIFY COLUMN gender VARCHAR(10);
ALTER TABLE amazon MODIFY COLUMN product_line VARCHAR(100);
ALTER TABLE amazon MODIFY COLUMN unit_price DECIMAL(10, 2);
ALTER TABLE amazon MODIFY COLUMN VAT FLOAT(6, 4);
ALTER TABLE amazon MODIFY COLUMN total DECIMAL(10, 2);
ALTER TABLE amazon MODIFY COLUMN date DATE;
ALTER TABLE amazon MODIFY COLUMN time TIME;
ALTER TABLE amazon MODIFY COLUMN payment_method VARCHAR(100);
ALTER TABLE amazon MODIFY COLUMN cogs DECIMAL(10, 2);
ALTER TABLE amazon MODIFY COLUMN gross_margin_percentage FLOAT(11, 9);
ALTER TABLE amazon MODIFY COLUMN gross_income DECIMAL(10, 2);
ALTER TABLE amazon MODIFY COLUMN rating double;
Select * from amazon;
-- no null values present in table 

-- 1 Feature Engineering 
,Adding a new column named timeofday

ALTER TABLE amazon
ADD COLUMN timeofday VARCHAR(15);

SET SQL_SAFE_UPDATES = 0;

UPDATE amazon
SET timeofday = 
    CASE 
        WHEN HOUR(time) < 12 THEN 'Morning'
        WHEN HOUR(time) < 18 THEN 'Afternoon'
        ELSE 'Evening'
    END;
    
  --  2,Adding a new column named dayname

ALTER TABLE amazon
ADD COLUMN dayname VARCHAR(10);

UPDATE amazon
SET dayname = DAYNAME(date);
Select * from amazon;


-- 3,Adding a new column named monthname

 //*Analysis List

-- 1,Product Analysis and 2, Sales Analysis*/


SELECT product_line, 
COUNT(*) AS transaction_count,
AVG(quantity) AS avg_quantity_sold_per_trans,
SUM(quantity) AS total_quantity_sold,
AVG(unit_price) AS average_unit_price,
SUM(total) AS total_sales_revenue,
SUM(gross_income) AS total_gross_income,
(SUM(gross_income) / SUM(total)) * 100 as gross_margin_percentage
FROM amazon
GROUP BY product_line
ORDER BY total_sales_revenue DESC;

/*
-- ==========
-- ==========

-- 3,Customer Analysis

-- total spending and purchase frequency, rating of Product_line according to gender */
WITH gender_spending AS (
SELECT gender,product_line,
COUNT(*) AS no_of_purchase,
SUM(total) AS total_spending,
ROUND(AVG(rating), 2) AS avg_rating
FROM amazon
GROUP BY gender, product_line
)
SELECT product_line,
SUM(CASE WHEN gender = 'Male' THEN no_of_purchase ELSE 0 END) AS male_no_of_purchase,
SUM(CASE WHEN gender = 'Female' THEN no_of_purchase ELSE 0 END) AS female_no_of_purchase,
SUM(CASE WHEN gender = 'Male' THEN total_spending ELSE 0 END) AS male_spending,
SUM(CASE WHEN gender = 'Female' THEN total_spending ELSE 0 END) AS female_spending,
SUM(CASE WHEN gender = 'Male' THEN avg_rating ELSE 0 END) AS male_avg_rating,
SUM(CASE WHEN gender = 'Female' THEN avg_rating ELSE 0 END) AS female_avg_rating
FROM gender_spending
GROUP BY product_line
ORDER BY male_spending DESC;

-- ============================

-- Business Questions To Answer:

-- 1,What is the count of distinct cities in the dataset? */
  
  SELECT DISTINCT city FROM amazon;
  
   /*
distinct cities in the dataset are 
Yangon
Mandalay
Naypyitaw
*/

/* 2,For each branch, what is the corresponding city?*/

SELECT DISTINCT branch,city FROM sales;
/*
for each branch,the corresponding city are 
branch  city   
 A	  Yangon
 B	  Mandalay
 C	  Naypyitaw
*/
-- ---------
  
/* 3,What is the count of distinct product lines in the dataset?*/

SELECT COUNT(DISTINCT product_line) AS NO_OF_PRODUCT_LINES FROM amazon;

-- count of distinct product lines in the dataset is '6'

-- 4,Which payment method occurs most frequently?

SELECT payment_method, COUNT(*) as count FROM amazon
GROUP BY payment_method
ORDER BY count DESC
LIMIT 1;

-- compare to others, "Ewallet" occurs most frequently

-- 5,Which product line has the highest sales?

SELECT product_line, SUM(quantity) AS total_quantity_sold
FROM amazon
GROUP BY product_line
ORDER BY total_quantity_sold DESC
LIMIT 1;

-- "Electronic accessories" product line has the highest sales

-- 6,How much revenue is generated each month?

SELECT monthname,SUM(total) AS revenue_generated
FROM amazon
GROUP BY monthname;

-- January	116292.11
-- February	97219.58
-- March	109455.74

-- 7,In which month did the cost of goods sold reach its peak?
SELECT monthname,SUM(cogs) AS total_cogs
FROM amazon
GROUP BY monthname
ORDER BY total_cogs DESC
LIMIT 1;

-- in "January" month the cost of goods sold reach its peak

-- 8,Which product line generated the highest revenue?
SELECT product_line, SUM(total) AS total_revenue
FROM amazon
GROUP BY product_line
ORDER BY total_revenue DESC
LIMIT 1;

-- "Food and beverages" product line has the highest sales 

-- 9,In which city was the highest revenue recorded?
SELECT city, SUM(total) AS total_revenue
FROM amazon
GROUP BY city
ORDER BY total_revenue DESC
LIMIT 1;

-- "Naypyitaw" city has the highest sales

-- 10,Which product line incurred the highest Value Added Tax?

SELECT product_line, ROUND(SUM(VAT),2) AS total_VAT
FROM amazon
GROUP BY product_line
ORDER BY total_VAT DESC
LIMIT 1;

-- "Food and beverages" product line has the highest Value Added Tax?

-- 11,For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."

SELECT product_line,SUM(total) AS total_sales,
CASE 
  WHEN SUM(total)  > (SELECT AVG(total) FROM amazon) THEN 'Good'
  ELSE 'Bad'
END AS sales_category
FROM amazon
GROUP BY product_line;

-- 12,Identify the branch that exceeded the average number of products sold.

WITH branch_avg AS (
SELECT branch,AVG(quantity) AS avg_products_sold
FROM amazon
GROUP BY branch
)

SELECT branch
FROM branch_avg
WHERE avg_products_sold > (SELECT AVG(quantity) FROM amazon);

-- 'C' branch exceeded the average number of products sold

-- 13,Which product line is most frequently associated with each gender?
WITH gender_spending AS (
SELECT gender,product_line,
COUNT(*) AS no_of_purchase
FROM amazon
GROUP BY gender, product_line
)

SELECT product_line,
SUM(CASE WHEN gender = 'Male' THEN no_of_purchase ELSE 0 END) AS male_frequency,
SUM(CASE WHEN gender = 'Female' THEN no_of_purchase ELSE 0 END) AS female_frequency
FROM gender_spending
GROUP BY product_line
ORDER BY male_frequency DESC ; -- ORDER BY female_frequency DESC;

/*
"Health and beauty" is the most frequently associated with male gender
"Fashion accessories" is the most frequently associated with female gender
*/

-- 14,Calculate the average rating for each product line.

SELECT product_line,ROUND(AVG(rating),2) AS average_rating
FROM amazon
GROUP BY product_line
ORDER BY average_rating DESC ;

-- 15,Count the sales occurrences for each time of day on every weekday.

SELECT dayname,timeofday,COUNT(*) AS sales_occurrences
FROM amazon
GROUP BY dayname,timeofday
ORDER BY dayname;

-- 16,Identify the customer type contributing the highest revenue.

SELECT customer_type,SUM(total) AS total_revenue
FROM amazon
GROUP BY customer_type
ORDER BY total_revenue DESC
LIMIT 1;

-- "Member" customer type contributing the highest revenue

-- 17,Determine the city with the highest VAT percentage.

SELECT city, AVG((VAT / total) * 100) AS avg_vat_percentage
FROM amazon
GROUP BY city
ORDER BY avg_vat_percentage DESC
LIMIT 1;

-- "Naypyitaw" city has the highest VAT percentage

-- 18,Identify the customer type with the highest VAT payments.

SELECT Customer_type,SUM(VAT) AS total_vat_payments
FROM amazon
GROUP BY Customer_type
ORDER BY total_vat_payments DESC
LIMIT 1;

-- "Member" customer type have the highest VAT payments

-- 19,What is the count of distinct customer types in the dataset?

SELECT COUNT(DISTINCT customer_type) AS distinct_customer_types
FROM amazon;

-- '2' are the distinct customer types in the dataset

-- 20,What is the count of distinct payment methods in the dataset?

SELECT COUNT(DISTINCT payment_method) AS distinct_payment_methods
FROM amazon;

-- '3' are the distinct payment methods in the dataset


-- 21,Which customer type occurs most frequently?
-- 22,Identify the customer type with the highest purchase frequency.

-- both are same question 

SELECT customer_type,COUNT(*) AS frequency
FROM amazon
GROUP BY customer_type
ORDER BY frequency DESC
LIMIT 1;

-- "Member" customer type occurs most frequently

-- 23,Determine the predominant gender among customers.

SELECT gender,COUNT(*) AS frequency
FROM amazon
GROUP BY gender
ORDER BY frequency DESC
LIMIT 1;

-- "Female" is the predominant gender among customers

-- 24,Examine the distribution of genders within each branch.

SELECT branch, gender, COUNT(*) AS count
FROM amazon
GROUP BY branch, gender
ORDER BY branch, count DESC;

-- 25,Identify the time of day when customers provide the most ratings.

SELECT timeofday, COUNT(*) AS rating_count
FROM amazon
GROUP BY timeofday
ORDER BY rating_count DESC
LIMIT 1;

-- "Afternoon" time customers provide the most ratings

-- 26,Determine the time of day with the highest customer ratings for each branch.

WITH branch_rating AS (
SELECT branch,timeofday, COUNT(*) AS rating_count
FROM amazon
GROUP BY branch, timeofday
)

SELECT branch,
SUM(CASE WHEN timeofday = 'Morning' THEN rating_count ELSE 0 END) AS morning_count,
SUM(CASE WHEN timeofday = 'Afternoon' THEN rating_count ELSE 0 END) AS Afternoon_count,
SUM(CASE WHEN timeofday = 'Evening' THEN rating_count ELSE 0 END) AS Evening_count
FROM branch_rating
GROUP BY branch;
/*
for branch 'A' it is "Afternoon"
for branch 'B' also "Afternoon"
for branch 'C' also "Afternoon"
*/


-- 27,Identify the day of the week with the highest average ratings.

SELECT dayname,ROUND(AVG(rating),2) AS average_rating
FROM amazon
GROUP BY dayname
ORDER BY average_rating DESC
LIMIT 1;

-- on "Monday" has the highest average ratings

--  28,Determine the day of the week with the highest average ratings for each branch.'

WITH branch_rating AS (
SELECT branch,dayname, COUNT(*) AS rating_count
FROM amazon
GROUP BY branch, dayname
)

SELECT branch,
SUM(CASE WHEN dayname = 'Monday' THEN rating_count ELSE 0 END) AS Monday_count,
SUM(CASE WHEN dayname = 'Tuesday' THEN rating_count ELSE 0 END) AS Tuesday_count,
SUM(CASE WHEN dayname = 'Wednesday' THEN rating_count ELSE 0 END) AS Wednesday_count,
SUM(CASE WHEN dayname = 'Thursday' THEN rating_count ELSE 0 END) AS Thursday_count,
SUM(CASE WHEN dayname = 'Friday' THEN rating_count ELSE 0 END) AS Friday_count,
SUM(CASE WHEN dayname = 'Saturday' THEN rating_count ELSE 0 END) AS Saturday_count,
SUM(CASE WHEN dayname = 'Sunday' THEN rating_count ELSE 0 END) AS Sunday_count
FROM branch_rating
GROUP BY branch;
/*
for brach 'A' its on "Sunday"
for brach 'B' its on "Saturday"
for brach 'C' its on "Tuesday" and "Saturday"
*/
