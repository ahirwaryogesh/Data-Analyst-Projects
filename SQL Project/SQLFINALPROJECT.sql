-- Task 1  Identifying the Top Branch by Sales Growth Rate 

USE sql_project;
select * from walmart;
SELECT Branch, 	date_format(STR_TO_DATE(date,'%d-%m-%Y'), '%Y-%M') As YearMonth, SUM(TOTAL) AS Total_Sales 
from walmart group by Branch, YearMonth order by Branch, YearMonth; 	

WITH Monthlysales As (
Select 
Branch,
 date_format(STR_TO_DATE(date,'%d-%m-%Y'), '%Y-%M') As YearMonth, 
 
SUM(TOTAL) AS Total_Sales

FROM 
WALMART 
GROUP BY 
Branch, Yearmonth
),
GrowthRate As (
select 
Branch, 
YearMonth, 
Total_Sales, 
Lag(Total_Sales) over (Partition by Branch Order By Yearmonth) AS Previous_Month_Sales,
Round(
((Total_Sales - Lag(Total_Sales) over (Partition by Branch Order by YearMonth)) 
/ Lag(Total_Sales) over (Partition by Branch Order by YearMonth))*100, 2
)	as Growthrate_Percentage
From Monthlysales) select * From Growthrate order by Branch, Yearmonth;


WITH Monthlysales As (
Select 
Branch,
 date_format(STR_TO_DATE(date,'%d-%m-%Y'), '%Y-%M') As YearMonth, 
 
SUM(TOTAL) AS Total_Sales

FROM 
WALMART 
GROUP BY 
Branch, Yearmonth
),
GrowthRate As (
select 
Branch, 
YearMonth, 
Total_Sales, 
Lag(Total_Sales) over (Partition by Branch Order By Yearmonth) AS Previous_Month_Sales,
Round(
((Total_Sales - Lag(Total_Sales) over (Partition by Branch Order by YearMonth)) 
/ Lag(Total_Sales) over (Partition by Branch Order by YearMonth))*100, 2
)	as Growthrate_Percentage
From Monthlysales) select * From Growthrate where Growthrate_Percentage is not Null
order by Growthrate_Percentage DESC Limit 1;


-- Task 2 Finding the Most Profitable Product Line for Each Branch 

select * from walmart;
select Branch, `Product Line`, 	sum(`Gross Income` - 'Cogs') As Profit
from walmart
Group by Branch, `Product line`
Order by  Branch, Profit Desc;

With Productline_Profit As( select Branch, `Product Line`, 	sum(`Gross Income` - 'Cogs') As Profit
from walmart
Group by Branch, `Product line`),
ProfitRanking as (Select *, Row_number() over (Partition by Branch order by Profit desc) as Rank_no
from Productline_Profit)
select Branch, `Product line`, Profit from ProfitRanking where rank_no = 1; 

-- Task 3  Analyzing Customer Segmentation Based on Spending   

	select `Customer ID`, Sum(total) as Total_Spend,
	case when sum(Total) > 23000 then 'High'
	when sum(Total) > 20000 then  'Medium'
	else 'low'
	end as spending_Tier
	from walmart
	Group by `Customer ID`;


-- Task 4 Detecting Anomalies in Sales Transactions

with Productstats as ( select `Product line`, Avg(Total) as Avg_Total,
STDDEV(Total) as Stdev_Total
 from walmart
 Group by `Product Line`)
 select 
w.`Invoice ID`, w.Branch, w.`Product Line`, w.Total, ps.Avg_Total, ps.stdev_Total
from walmart w
jOIN  Productstats ps on w.`Product line` = ps.`product line`
where 
w.Total < (ps.avg_total - 2 * ps.stdev_total)
or
w.Total < (ps.avg_total + 2 * ps.stdev_total)
order by 
w.`Product line`, w.total;

-- Task 5 Most Popular Payment Method by City

select * from walmart;
select city, count(Payment) from walmart;
with Payment_Counts as ( Select City, Payment, Count(*) as Paymentcount,
Row_number() over (Partition by City order by count(*) desc) as Ranknumber
from walmart
group by City, Payment)
select city, payment, Paymentcount from Payment_counts where ranknumber = 1;

-- Task 6 Monthly Sales Distribution by Gender

Select 
Gender,
 monthname(STR_TO_DATE(date,'%d-%m-%Y')) As Months, 
SUM(TOTAL) AS Total_Sales
FROM 
WALMART 
GROUP BY 
month(STR_TO_DATE(date,'%d-%m-%Y')),
months, Gender
order by
month(STR_TO_DATE(date,'%d-%m-%Y')),
Gender;

-- Task 7 Best Product Line by Customer Type 

select `Customer Type`, `Product Line`, Count(*) as Number_of_Purchases
from walmart group by `Customer type`, `Product line` 
order by `Customer type`, Number_of_Purchases desc;

-- Task 8  Identifying Repeat Customers 

SELECT 
a.`Customer ID`,
a.`Invoice id` as First_Invoice,
b.`Invoice id` as Repeat_Invoice,
STR_TO_DATE(a.date,'%d-%m-%Y') as First_Purchase_date,
STR_TO_DATE(b.date,'%d-%m-%Y') as Repeat_Purchase_date,
Datediff(STR_TO_DATE(b.date,'%d-%m-%Y'),STR_TO_DATE(a.date,'%d-%m-%Y')) as Days_Between
from
walmart a
join
walmart b 
on 
a.`Customer ID` = b.`Customer ID`
AND STR_TO_DATE(b.date,'%d-%m-%Y') > STR_TO_DATE(a.date,'%d-%m-%Y')
AND datediff(STR_TO_DATE(b.date,'%d-%m-%Y'),STR_TO_DATE(a.date,'%d-%m-%Y')) <= 30
ORDER BY a.`Customer ID`, a.Date;


-- Task 9 Finding Top 5 Customers by Sales Volume 	

select `Customer ID`, SUM(Total) as Total_Revenue
from walmart
group by `Customer ID`
order by Total_Revenue desc Limit 5;

-- Task 10  Analyzing Sales Trends by Day of the Week

select 
dayname(STR_TO_DATE(Date, '%d-%m-%Y')) As Weekdays, sum(total) as Total_Sales
From Walmart
group by Weekdays
Order by Total_sales desc;