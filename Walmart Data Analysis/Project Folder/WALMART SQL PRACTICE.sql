CREATE DATABASE Walmart;
USE Walmart;

CREATE TABLE Sales(
Invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
Branch VARCHAR(5) NOT NULL,
City VARCHAR(10) NOT NULL,
Customer_type VARCHAR(30) NOT NULL,
Gender VARCHAR(10) NOT NULL,
Product_line VARCHAR(100) NOT NULL,
Unit_price DECIMAL(10,2) NOT NULL,
Quantity INT(20) NOT NULL,
VAT FLOAT(6,4) NOT NULL,
Total DECIMAL(12,4) NOT NULL,
Date DATETIME NOT NULL,
Time TIME NOT NULL,
Payment VARCHAR(15) NOT NULL,
Cogs DECIMAL(10,2) NOT NULL,
Gross_Margin FLOAT(11,9),
Gross_income DECIMAL(12,4),
Rating FLOAT(2,1)
);

-----------------------------Feature Engineering-------------------
1) Time_of_Day:-
SELECT * FROM Sales;
SELECT Time,
CASE
	WHEN `Time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
    WHEN `Time` BETWEEN "12:00:01" AND "17:00:00" THEN "Afternoon"
    ELSE "Evening"
END Time_of_day
FROM Sales;

ALTER TABLE Sales ADD COLUMN Time_of_day VARCHAR(20);

UPDATE Sales
SET Time_of_day= (
CASE
	WHEN `Time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
    WHEN `Time` BETWEEN "12:00:01" AND "17:00:00" THEN "Afternoon"
    ELSE "Evening"
END
);

SELECT * FROM Sales;

-- Q-2) Day_name;-
SELECT date, DAYNAME(Date) Day_name
FROM Sales;

ALTER TABLE Sales ADD COLUMN Day_name VARCHAR(15);

UPDATE Sales 
SET Day_name= DAYNAME(Date);

SELECT Date, MONTHNAME(Date) Month_name FROM Sales;

ALTER TABLE Sales ADD COLUMN Month_name VARCHAR(25);

UPDATE Sales 
Set Month_name= MONTHNAME(Date);
SELECT * FROM Sales;

-------------- EXPLORATORY DATA ANALYSIS
-- 1.How many distinct cities are present in the dataset?
SELECT DISTINCT city FROM Sales;

-- 2.In which city is each branch situated?
SELECT Distinct Branch, City FROM Sales;

-- Product analysis
-- 1.How many distinct product lines are there in the dataset?
SELECT DISTINCT Product_line FROM sales;

-- 2.What is the most common payment method?
SELECT Payment, COUNT(Payment) Common_Payment_Method FROM Sales
GROUP BY Payment ORDER BY Common_Payment_Method DESC LIMIT 1;

-- 3.What is the most selling product line?
SELECT Product_line, COUNT(Product_line) Most_selling_product_line FROM Sales
GROUP BY Product_line ORDER BY  Most_selling_product_line DESC LIMIT 1;

-- 4. What is Total Revenue by month?
SELECT Month_name, sum(total) As Revenue
FROM sales GROUP BY Month_name ORDER BY Revenue DESC;

-- 5.Which month recorded the highest Cost of Goods Sold (COGS)?
SELECT Month_name, Sum(Cogs) total_cogs FROM Sales 
GROUP BY Month_name ORDER BY Cogs DESC LIMIT 1;

-- 6.Which product line generated the highest revenue?
SELECT Product_line, sum(Total) Revenue 
FROM Sales 
GROUP BY Product_line 
ORDER BY Revenue DESC
LIMIT 1;

-- 7.Which city has the highest revenue?
SELECT City, SUM(Total) Revenue FROM Sales
GROUP BY City ORDER BY Revenue DESC LIMIT 1;

-- 8.Which product line incurred the highest VAT?
SELECT Product_line, sum(VAT) highest_vat FROM Sales 
GROUP BY Product_line ORDER BY highest_vat DESC LIMIT 1;

-- 9.Retrieve each product line and add a column product_category, indicating 'Good' or 'Bad,'based on whether its sales are above the average.
SELECT * FROM Sales;

ALTER TABLE Sales ADD COLUMN Product_Category VARCHAR(20);
select avg(Total) from Sales;
UPDATE Sales 
SET Product_Category=
(CASE 
     WHEN Total >= '322.49888894' THEN "Good"
     ELSE "Bad"
END);

-- 10.Which branch sold more products than average product sold?
SELECT Branch, sum(Quantity) Product_sold from Sales
GROUP BY Branch HAVING SUM(Quantity)> AVG(Quantity)
ORDER BY Product_sold DESC LIMIT 1;

-- 11.What is the most common product line by gender?
SELECT Product_Line, Gender, Count(Gender) total_count 
FROM Sales
GROUP BY Gender, Product_Line
ORDER BY total_count DESC
LIMIT 1;

-- 12.What is the average rating of each product line?
SELECT Product_line, AVG(Rating) Average_Rating
FROM Sales
GROUP BY Product_line
ORDER BY Average_Rating DESC;

-- ---------------------------------------------Sales Analysis
-- 1.Number of sales made in each time of the day per weekday
SELECT * FROM Sales;
SELECT COUNT(Invoice_id), Time_of_day, Day_name
FROM Sales 
WHERE Day_name NOT IN ('Sunday','Saturday')
GROUP BY Time_of_day, Day_name;

SELECT COUNT(Invoice_id) Number_of_Sales , Time_of_day, Day_name
FROM Sales 
GROUP BY Time_of_day, Day_name
HAVING Day_Name NOT IN ('Sunday','Saturday')
ORDER BY Number_of_Sales DESC;

-- 2.Identify the customer type that generates the highest revenue.
SELECT Customer_Type, SUM(Total) Revenue FROM Sales
GROUP BY Customer_Type 
ORDER BY Revenue DESC
LIMIT 1 ;

-- 3.Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT City, sum(VAT) FROM Sales
GROUP BY City 
ORDER BY VAT DESC LIMIT 1;

-- 4.Which customer type pays the most in VAT?
SELECT Customer_type, sum(VAT) TAX FROM Sales
GROUP BY Customer_type 
ORDER BY TAX DESC LIMIT 1;

-- Customer Analysis
-- 1.How many unique customer types does the data have?
SELECT  COUNT(DISTINCT Customer_Type) FROM Sales;

-- 2.How many unique payment methods does the data have?
SELECT COUNT(DISTINCT Payment) From Sales;

-- 3.Which is the most common customer type?

SELECT Customer_type, COUNT(Customer_type) Most_Common_Type  FROM Sales 
GROUP BY customer_type
ORDER BY Most_Common_Type DESC 
limit 1 ;

-- 4.Which customer type buys the most?

SELECT Customer_type, sum(Total) Buys_Most
FROM Sales
GROUP BY Customer_type
ORDER BY Buys_Most
LIMIT 1;

-- 5.What is the gender of most of the customers?
SELECT * FROM Sales;
SELECT Gender, count(*) Most_customers FROM Sales
GROUP BY Gender 
ORDER BY Most_customers DESC
Limit 1;

-- 6.What is the gender distribution per branch?
SELECT * FROM Sales;
SELECT Gender, COUNT(Gender) Gender_distribution, Branch
FROM Sales
GROUP BY Branch, Gender
ORDER BY  Branch;

-- 7.Which time of the day do customers give most ratings?
SELECT * FROM Sales;
SELECT Time_of_day, AVG(Rating) Most_Rating FROM Sales
GROUP BY Time_of_day
ORDER BY Most_Rating DESC
LIMIT 1;

-- 8.Which time of the day do customers give most ratings per branch?
SELECT * FROM Sales;
SELECT Time_of_day, Branch, AVG(Rating) Most_Rating  FROM Sales
GROUP BY Branch, Time_of_day 
ORDER BY Most_Rating DESC;

SELECT branch, time_of_day, AVG(rating) AS average_rating
FROM sales GROUP BY branch, time_of_day ORDER BY average_rating DESC;
SELECT Branch, Time_of_day, 
AVG(Rating) OVER(PARTITION BY Branch) AS Ratings
FROM Sales GROUP BY Branch;

-- 9.Which day of the week has the best avg ratings?
SELECT * FROM Sales;
SELECT Day_name, avg(Rating) Avg_Ratings
FROM Sales
GROUP BY Day_name
ORDER BY Avg_Ratings DESC
LIMIT 1;

-- 10.Which day of the week has the best average ratings per branch?
SELECT Branch, Day_name, 
AVG(Rating) OVER(PARTITION BY Branch) AS Ratings
FROM Sales GROUP BY Branch ORDER by Rating desc;
