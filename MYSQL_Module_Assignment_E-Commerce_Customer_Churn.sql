-- Creating a copy of table customer_churn with name customer_churn_final to update the values
create table customer_churn_final 
as with CopyTable as (
select * from customer_churn
)
select * from CopyTable;

-- ********************SECTION 1 ********************--
-- Data Cleaning: --
-- Handling Missing Values and Outliers: --
-- ******************** SECTION 1 QUESTION 1 ********************  --
-- Impute mean for the following columns, and round off to the nearest integer if --
-- required: WarehouseToHome, HourSpendOnApp, OrderAmountHikeFromlastYear, --
-- DaySinceLastOrder --

--  ******************** SECTION 1 ANSWER 1 ********************  --
-- Identifying The count of null values for each of those columns
select sum(WarehouseToHome is null or Trim(WarehouseToHome) = '') as Missing_WarehouseToHome 
,sum(HourSpendOnApp is null or Trim(WarehouseToHome) = '') as Missing_WarehouseToHome 
,sum(OrderAmountHikeFromlastYear is null or Trim(WarehouseToHome) = '') as Missing_WarehouseToHome 
,sum(DaySinceLastOrder is null or Trim(WarehouseToHome) = '') as Missing_WarehouseToHome 
from customer_churn;

-- Disabling Safe update and updating the copy table customer_churn_final to impute mean values
-- for the colums WarehouseToHome, HourSpendOnApp, OrderAmountHikeFromlastYear, DaySinceLastOrder
set sql_safe_updates = 0;
update customer_churn_final
set WarehouseToHome = case 
when WarehouseToHome is null  then (select round(avg(WarehouseToHome)) from customer_churn) 
when Trim(WarehouseToHome) = ''  then (select round(avg(WarehouseToHome)) from customer_churn) 
else WarehouseToHome end,
 HourSpendOnApp = case 
when HourSpendOnApp is null  then (select round(avg(HourSpendOnApp)) from customer_churn) 
when Trim(HourSpendOnApp) = ''  then (select round(avg(HourSpendOnApp)) from customer_churn) 
else HourSpendOnApp end,
 OrderAmountHikeFromlastYear = case 
when OrderAmountHikeFromlastYear is null  then (select round(avg(OrderAmountHikeFromlastYear)) from customer_churn) 
when Trim(OrderAmountHikeFromlastYear) = ''  then (select round(avg(OrderAmountHikeFromlastYear)) from customer_churn) 
else OrderAmountHikeFromlastYear end,
 DaySinceLastOrder = case 
when DaySinceLastOrder is null  then (select round(avg(DaySinceLastOrder)) from customer_churn) 
when Trim(DaySinceLastOrder) = ''  then (select round(avg(DaySinceLastOrder)) from customer_churn) 
else DaySinceLastOrder end
;
-- Verifing customer_churn_final to see if missing values are cleared or not
select sum(WarehouseToHome is null or Trim(WarehouseToHome) = '') as Missing_WarehouseToHome 
,sum(HourSpendOnApp is null or Trim(WarehouseToHome) = '') as Missing_WarehouseToHome 
,sum(OrderAmountHikeFromlastYear is null or Trim(WarehouseToHome) = '') as Missing_WarehouseToHome 
,sum(DaySinceLastOrder is null or Trim(WarehouseToHome) = '') as Missing_WarehouseToHome 
from customer_churn_final;

--  ******************** SECTION 1 QUESTION 2 ********************  --
--  Impute mode for the following columns: Tenure, CouponUsed, OrderCount. --

--  ******************** SECTION 1 ANSWER 2  ********************  --
-- Identifying The count of null values for each of those columns
select sum(Tenure is null or Trim(Tenure) = '') as Missing_Tenure 
,sum(CouponUsed is null or Trim(CouponUsed) = '') as Missing_CouponUsed 
,sum(OrderCount is null or Trim(OrderCount) = '') as Missing_OrderCount 
from customer_churn;

-- Step 1 Finding the mode value for each of those columns
select
(select Tenure from customer_churn 
where Tenure is not null and Trim(Tenure) <> '' group by Tenure order by count(*) desc limit 1)
as Mode_Tenure,
(select CouponUsed from customer_churn 
where CouponUsed is not null and Trim(CouponUsed) <> '' group by CouponUsed order by count(*) desc limit 1)
as Mode_CouponUsed,
(select OrderCount from customer_churn 
where OrderCount is not null and Trim(OrderCount) <> '' group by OrderCount order by count(*) desc limit 1)
as Mode_OrderCount;

-- Updating the copy table customer_churn_final to impute mode values
-- for the colums Tenure, CouponUsed, OrderCount
update customer_churn_final
set Tenure = case 
when Tenure is null  then 1
when Trim(Tenure) = ''  then 1
else Tenure end,
 CouponUsed = case 
when CouponUsed is null  then 1
when Trim(CouponUsed) = ''  then 1
else CouponUsed end,
 OrderCount = case 
when OrderCount is null  then 2
when Trim(OrderCount) = ''  then 2
else OrderCount end;

-- Verifing customer_churn_final to see if missing values are cleared or not
select sum(Tenure is null or Trim(Tenure) = '') as Missing_Tenure 
,sum(CouponUsed is null or Trim(CouponUsed) = '') as Missing_CouponUsed 
,sum(OrderCount is null or Trim(OrderCount) = '') as Missing_OrderCount 
from customer_churn_final;

--  ******************** SECTION 1 QUESTION 3 ********************  --
--  Handle outliers in the 'WarehouseToHome' column by deleting rows where the
-- values are greater than 100.

--  ******************** SECTION 1 ANSWER 3  ********************  --
-- verifying WarehouseToHome' column  where the values are greater than 100
select WarehouseToHome, count(*) from customer_churn where WarehouseToHome > 100 
group by WarehouseToHome;
-- deleting rows  where the value of WarehouseToHome is greater than 100
delete from customer_churn_final where WarehouseToHome > 100;
-- verifying WarehouseToHome' column  where the values are greater than 100
select WarehouseToHome, count(*) from customer_churn_final where WarehouseToHome > 100 
group by WarehouseToHome;

--  ******************** SECTION 1 QUESTION 4 ********************  --
-- Dealing with Inconsistencies:
--  Replace occurrences of “Phone” in the 'PreferredLoginDevice' column and
-- “Mobile” in the 'PreferedOrderCat' column with “Mobile Phone” to ensure uniformity.

--  ******************** SECTION 1 ANSWER 4  ********************  --
-- verifying before change
select a.customerid, a.PreferredLoginDevice as PreferredLoginDevice_Original,
a.PreferedOrderCat as PreferedOrderCat_original,
b.customerid, b.PreferredLoginDevice as PreferredLoginDevice_AfterChange,
b.PreferedOrderCat as PreferedOrderCat_AfterChange
from customer_churn a join customer_churn_final b on a.customerid = b.customerid
where a.PreferredLoginDevice = 'Phone' or a.PreferedOrderCat = 'Mobile';

-- Updating table customer_churn_final to change the values to Mobile Phone
update customer_churn_final
set PreferredLoginDevice = case when PreferredLoginDevice='Phone' then 'Mobile Phone' else PreferredLoginDevice end,
PreferedOrderCat = case when PreferedOrderCat='Mobile' then 'Mobile Phone' else PreferedOrderCat end;

-- verifying after change
select a.customerid, a.PreferredLoginDevice as PreferredLoginDevice_Original,
a.PreferedOrderCat as PreferedOrderCat_original,
b.customerid, b.PreferredLoginDevice as PreferredLoginDevice_AfterChange,
b.PreferedOrderCat as PreferedOrderCat_AfterChange
from customer_churn a join customer_churn_final b on a.customerid = b.customerid
where a.PreferredLoginDevice = 'Phone' or a.PreferedOrderCat = 'Mobile';

--  ******************** SECTION 1 QUESTION 5 ********************  --
-- Dealing with Inconsistencies:
--   Standardize payment mode values: Replace "COD" with "Cash on Delivery" and
-- "CC" with "Credit Card" in the PreferredPaymentMode column.

--  ******************** SECTION 1 ANSWER 5  ********************  --
-- verifying before change
select a.customerid, a.PreferredPaymentMode as PreferredPaymentMode_Original,
b.customerid, b.PreferredPaymentMode as PreferredPaymentMode_AfterChange
from customer_churn a join customer_churn_final b on a.customerid = b.customerid
where a.PreferredPaymentMode in ('COD','CC');

-- Updating table customer_churn_final to change the values
update customer_churn_final
set PreferredPaymentMode = case 
when PreferredPaymentMode='COD' then 'Cash on Delivery' 
when PreferredPaymentMode='CC' then 'Credit Card' 
else PreferredPaymentMode end;
-- verifying after change
select a.customerid, a.PreferredPaymentMode as PreferredPaymentMode_Original,
b.customerid, b.PreferredPaymentMode as PreferredPaymentMode_AfterChange
from customer_churn a join customer_churn_final b on a.customerid = b.customerid
where a.PreferredPaymentMode in ('COD','CC');
--  ******************** SECTION 2 QUESTION 1 ********************  --
-- Data Transformation:
-- Column Renaming:
-- Rename the column "PreferedOrderCat" to "PreferredOrderCat".  
-- Rename the column "HourSpendOnApp" to "HoursSpentOnApp

--  ******************** SECTION 2 ANSWER 1  ********************  --
-- verifying before change
select * from customer_churn;
-- Updating Column Names
alter table customer_churn_final rename column PreferedOrderCat to PreferredOrderCat;
alter table customer_churn_final rename column HourSpendOnApp to HoursSpentOnApp;
-- verifying after change
select * from customer_churn_final;

--  ******************** SECTION 2 QUESTION 2 ********************  --
-- Data Transformation:
-- Creating New Columns:
--  Create a new column named ‘ComplaintReceived’ with values "Yes" if the
-- corresponding value in the ‘Complain’ is 1, and "No" otherwise.

-- Create a new column named 'ChurnStatus'. Set its value to “Churned” if the
-- corresponding value in the 'Churn' column is 1, else assign “Active”.

--  ******************** SECTION 2 ANSWER 2  ********************  --
-- verifying before change
-- N/A
-- Creating New Columns in customer_churn_final
alter table customer_churn_final add column ComplaintReceived varchar(3);
alter table customer_churn_final add column ChurnStatus varchar(7);

-- Adding values to new colums as required
update customer_churn_final set
ComplaintReceived = case when Complain=1 then "Yes" else "No" end,
ChurnStatus = case when Churn=1 then "Churned" else "Active" end;
-- Verifying after change
select distinct Complain, Churn, ComplaintReceived, ChurnStatus from customer_churn_final;

--  ******************** SECTION 2 QUESTION 3 ********************  --
-- Data Transformation:
-- Column Dropping
--  Drop the columns "Churn" and "Complain" from the table

--  ******************** SECTION 2 ANSWER 3  ********************  --
-- Dropping columns from customer_churn_final
alter table customer_churn_final 
drop column Complain,
drop column Churn;
-- Verifying after change
select distinct Complain, Churn, ComplaintReceived, ChurnStatus from customer_churn_final;

--  ******************** SECTION 3 QUESTION 1 ********************  --
-- Data Exploration and Analysis:
--  Retrieve the count of churned and active customers from the dataset.

--  ******************** SECTION 3 ANSWER 1  ********************  --
select ChurnStatus, count(*) as Count from customer_churn_final group  by ChurnStatus;

--  ******************** SECTION 3 QUESTION 2 ********************  --
-- Data Exploration and Analysis:
--  Display the average tenure and total cashback amount of customers who churned.

--  ******************** SECTION 3 ANSWER 2  ********************  --
select round(avg(Tenure)) as Aerage_Tenure, sum(CashbackAmount) as Total_CashBack
from customer_churn_final where ChurnStatus='Churned';

--  ******************** SECTION 3 QUESTION 3 ********************  --
-- Data Exploration and Analysis:
--  Determine the percentage of churned customers who complained

--  ******************** SECTION 3 ANSWER 3  ********************  --
select round(
sum(case when ChurnStatus='Churned' and ComplaintReceived='Yes' then 1 else 0 end) * 100
 /
 sum(case when ChurnStatus='Churned' then 1 else 0 end),2)
as Percentage_Of_Churned_Customers_Who_Complained
from customer_churn_final;

--  ******************** SECTION 3 QUESTION 4 ********************  --
-- Data Exploration and Analysis:
--  Identify the city tier with the highest number of churned customers whose
-- preferred order category is Laptop & Accessory

--  ******************** SECTION 3 ANSWER 4  ********************  --
select CityTier, count(*) as Count from customer_churn_final
where ChurnStatus='Churned' and PreferredOrderCat='Laptop & Accessory'
group by CityTier order by Count desc limit 1;

--  ******************** SECTION 3 QUESTION 5 ********************  --
-- Data Exploration and Analysis:
--  Identify the most preferred payment mode among active customers

--  ******************** SECTION 3 ANSWER 5  ********************  --
select PreferredPaymentMode, count(*) as Count from customer_churn_final
where ChurnStatus='Active' 
group by PreferredPaymentMode order by Count desc limit 1;

--  ******************** SECTION 3 QUESTION 6 ********************  --
-- Data Exploration and Analysis:
-- Calculate the total order amount hike from last year for customers who are single
-- and prefer mobile phones for ordering.
--  ******************** SECTION 3 ANSWER 6  ********************  --

select sum(OrderAmountHikeFromlastYear) as Total_OrderAmountHikeFromlastYear  
from customer_churn_final
where MaritalStatus='Single' and PreferredLoginDevice='Mobile Phone';

--  ******************** SECTION 3 QUESTION 7 ********************  --
-- Data Exploration and Analysis:
-- Find the average number of devices registered among customers who used UPI as
-- their preferred payment mode
--  ******************** SECTION 3 ANSWER 7  ********************  --
select round(avg(NumberOfDeviceRegistered)) as Average_NumberOfDeviceRegistered
from customer_churn_final
where PreferredPaymentMode='UPI';

--  ******************** SECTION 3 QUESTION 8 ********************  --
-- Data Exploration and Analysis:
-- Determine the city tier with the highest number of customers.
--  ******************** SECTION 3 ANSWER 8  ********************  --
select CityTier, count(*) as Count from customer_churn_final
group by CityTier order by Count desc limit 1;

--  ******************** SECTION 3 QUESTION 9 ********************  --
-- Data Exploration and Analysis:
-- Identify the gender that utilized the highest number of coupons.
--  ******************** SECTION 3 ANSWER 9  ********************  --
select Gender, sum(CouponUsed) as Total_CouponUsed from customer_churn_final
group by Gender order by Total_CouponUsed desc limit 1;

--  ******************** SECTION 3 QUESTION 10 ********************  --
-- Data Exploration and Analysis:
-- List the number of customers and the maximum hours spent on the app in each
-- preferred order category
--  ******************** SECTION 3 ANSWER 10  ********************  --
select PreferredOrderCat, count(*) as Total_Customers, max(HoursSpentOnApp) as Maximum_HoursSpentOnApp
from customer_churn_final 
group by PreferredOrderCat;

--  ******************** SECTION 3 QUESTION 11 ********************  --
-- Data Exploration and Analysis:
-- Calculate the total order count for customers who prefer using credit cards and
-- have the maximum satisfaction score
--  ******************** SECTION 3 ANSWER 11  ********************  --
select  SatisfactionScore, sum(OrderCount) as Total_OrderCount from customer_churn_final
where PreferredPaymentMode='Credit Card'
group by SatisfactionScore order by SatisfactionScore desc limit 1;

--  ******************** SECTION 3 QUESTION 12 ********************  --
-- Data Exploration and Analysis:
-- What is the average satisfaction score of customers who have complained?
--  ******************** SECTION 3 ANSWER 12  ********************  --
select round(avg(SatisfactionScore)) as Average_SatisfactionScore_ComplaintReceived
from customer_churn_final
where ComplaintReceived='Yes';

--  ******************** SECTION 3 QUESTION 13 ********************  --
-- Data Exploration and Analysis:
-- List the preferred order category among customers who used more than 5 coupons.
--  ******************** SECTION 3 ANSWER 13  ********************  --
select distinct PreferredOrderCat from customer_churn_final
where CouponUsed > 5;

--  ******************** SECTION 3 QUESTION 14 ********************  --
-- Data Exploration and Analysis:
-- List the top 3 preferred order categories with the highest average cashback amount.
--  ******************** SECTION 3 ANSWER 14  ********************  --
select PreferredOrderCat, round(avg(CashbackAmount),2) as Average_CashbackAmount from customer_churn_final
group by PreferredOrderCat order by Average_CashbackAmount desc limit 3;

--  ******************** SECTION 3 QUESTION 15 ********************  --
-- Data Exploration and Analysis:
-- Find the preferred payment modes of customers whose average tenure is 10
-- months and have placed more than 500 orders.
--  ******************** SECTION 3 ANSWER 15  ********************  --
select PreferredPaymentMode,round(avg(tenure)) as Average_tenure, sum(OrderCount) as Total_OrderCount
from customer_churn_final
group by PreferredPaymentMode
having Average_tenure=10 and Total_OrderCount>500;

--  ******************** SECTION 3 QUESTION 16 ********************  --
-- Data Exploration and Analysis:
-- Categorize customers based on their distance from the warehouse to home such
-- as 'Very Close Distance' for distances <=5km, 'Close Distance' for <=10km,
-- 'Moderate Distance' for <=15km, and 'Far Distance' for >15km. Then, display the
-- churn status breakdown for each distance category.
--  ******************** SECTION 3 ANSWER 16  ********************  --
select CustomerID, WarehouseToHome, case
when WarehouseToHome <= 5 then 'Very Close Distance'
when WarehouseToHome <= 10 then 'Close Distance'
when WarehouseToHome <= 15 then 'Moderate Distance'
else 'Far Distance' end as Distance_Category
from customer_churn_final;

--  ******************** SECTION 3 QUESTION 17 ********************  --
-- Data Exploration and Analysis:
-- List the customer’s order details who are married, live in City Tier-1, and their
-- order counts are more than the average number of orders placed by all
-- customers.
--  ******************** SECTION 3 ANSWER 17  ********************  --
select * from customer_churn_final where
MaritalStatus='Married' and
CityTier=1 and
OrderCount>(select round(avg(OrderCount)) from customer_churn_final);

--  ******************** SECTION 3 QUESTION 18 ********************  --
-- a) Create a ‘customer_returns’ table in the ‘ecomm’ database and insert the following data:
--  ******************** SECTION 3 ANSWER 18  ********************  --
create table customer_returns(
ReturnID int primary key,
CustomerID int,
ReturnDate date,
RefundAmount int
);
insert into customer_returns
(ReturnID,CustomerID,ReturnDate,RefundAmount) values
(1001,50022, '2023-01-01', 2130),
(1002, 50316, '2023-01-23', 2000),
(1003, 51099, '2023-02-14', 2290),
(1004, 52321, '2023-03-08', 2510),
(1005, 52928, '2023-03-20', 3000),
(1006, 53749, '2023-04-17', 1740),
(1007, 54206, '2023-04-21', 3250),
(1008, 54838, '2023-04-30', 1990);
select * from customer_returns;

--  ******************** SECTION 3 QUESTION 18 ********************  --
-- b) Display the return details along with the customer details of those who have
-- churned and have made complaints.
--  ******************** SECTION 3 ANSWER 18  ********************  --
select * from customer_returns cr join  customer_churn_final ccf
on ccf.CustomerID=cr.CustomerID
where ccf.ChurnStatus='Churned' and ccf.ComplaintReceived='Yes';