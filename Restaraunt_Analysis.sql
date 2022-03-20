create schema PizzaTime;
use PizzaTime;

select * from pizza;

create table Pizza_Customer 
	(
	Customer_Email varchar(250) primary key,
    Customer_Phone varchar(250),
    Customer_Name char(250)    
    );
    
insert into Pizza_Customer (Customer_Email, Customer_Phone, Customer_Name)
select distinct Customer_Email, Customer_Phone, Customer_Name from pizza;
 
create table Pizza_Store
	(
    Store_Number int primary key,
    Store_Address text
    );
    
insert into Pizza_Store (Store_Number, Store_Address)
select distinct(Store_Number), Store_Address from pizza;

create table Pizza_Order
	(
    Order_Num int primary key,
    Time_Min int,
    Time_Max int,
    Date text,
    Dow text, 
    Time text,
    Payment_Detail text,
    Delivery int
    );
    
insert into Pizza_Order (Order_Num, Time_Min, Time_Max, Date, Dow, Time, Payment_Detail, Delivery)
select distinct (Order_Num), Time_Min, Time_Max, Date, Dow, Time, Payment_Detail, Delivery from pizza;

create table Pizza_Else
	(
    Record_Id int primary key,
    Store_Number int,
    Customer_Email varchar(250),
    Order_Num int,
    Item text,
    Item_Description text,
    Item_Size text,
    Original_Amt double,
    Coupon_Used int,
    Savings double,
    Net_Amt double,
    Tip double,
    Tax double,
    Total_Due double,
    Constraint FK3 foreign key (Store_Number) References Pizza_Store (Store_Number),
	Constraint FK4 foreign key (Customer_Email) References Pizza_Customer (Customer_Email),
	Constraint FK5 foreign key (Order_Num) References Pizza_Order (Order_Num)
    );
insert into Pizza_Else (Record_Id, Store_Number, Customer_Email, Order_Num, Item, Item_Description, Item_Size, Original_Amt, Coupon_Used, Savings, Net_Amt, Tip, Tax, Total_Due)
select Record_Id, Store_Number, Customer_Email, Order_Num, Item, Item_Description, Item_Size, Original_Amt, Coupon_Used, Savings, Net_Amt, Tip, Tax, Total_Due from pizza;
    
-- 1. How many pizzas were ordered containing chicken? 
select count(*) as "Count of Chicken Pizzas"
from Pizza_Else
where item like "%pizza%" and item_description like "%Chicken%";

-- 2. What day of the week receives the most orders?
select Dow, count(*)
from Pizza_Order
group by 1
order by 2 desc;

-- 3. What is the average delivery/pick-up time (based on min_time)? 
select avg(Time_Min) as "Average Delivery/Pickup Time"
from Pizza_Order;

-- 4. What is the average delivery/pick-up time (based on max_time)? 
select avg(Time_Max) as "Average Delivery/Pickup Time"
from Pizza_Order;

-- 5. What percentage of customers use coupons?
select sum(Coupon_Used)/count(distinct(Customer_Email)) as "Couponer %"
from Pizza_Else;

-- 6. What is the average percent saving for orders that use coupons?
select avg(Savings/Original_Amt) as "Average % Savings"
from Pizza_Else
where Coupon_Used = 1;

-- 7. Besides pizza, what are our most popular items?
select item, count(*)
from Pizza_Else
where Item not like "%pizza%"
group by 1
order by 2 desc;

-- 8. What is the average tip percentage of customers? 
select sum(Tip)/count(distinct(Customer_Email)) as "Average Tip"
from Pizza_Else;

-- 9. What is the breakdown of white pizza sauce sales versus red pizza sauce sales? 
select count(Item),
case 
	when item like "%pizza%" and item_description like "%Ranch%" then "White Sauce"
    when item like "%pizza%" and item_description like "%Garlic Parmesan%"  then "White Sauce"
    when item like "%pizza%" and item_description like "%Alfredo Sauce%"  then "White Sauce"
    when item like "%pizza%" and item_description like "%tomato sauce%"  then "Red Sauce"
    else "No Sauce"
    end as SauceType
	from Pizza_Else
    group by SauceType;

-- 10. What is the cheapest item from the order list, based on total paid?
select item, min(Total_Due) as "Total Paid"
from Pizza_Else
group by 1
order by 2 asc
limit 1;

-- 11. Create View- Which customer order the most number of items?
create view PizzaTable as 
select customer_name, count(item) as totalorders
from pizza
group by customer_name
order by count(*) desc;

select * from PizzaTable;

select * from PizzaTable
where totalorders = (
select max(totalorders) from PizzaTable
);


-- 12. Create View- Display the order total by Customer

create view PizzaTable2 as
select customer_name, item, Total_Due 
from pizza;

select * from PizzaTable2;

select customer_name, sum(Total_Due) as "Total Paid"
from PizzaTable2
group by customer_name;

-- Joins and Subqueries 
-- 13. Find the number of customers who ordered on Thursday, our most popular day, using subquery
select count(Customer_name)
from Pizza_Customer
where Customer_Email in (
	select Customer_Email from Pizza_Else where Order_Num in (
		select Order_Num from Pizza_Order where Dow = 'Thu'));
        
-- 14. Find the number of customers who ordered on Thursday, our most popular day using inner join
select count(distinct(Customer_name)), Dow
from Pizza_Customer 
inner join Pizza_Else on Pizza_Customer.Customer_Email = Pizza_Else.Customer_Email
inner join Pizza_Order on Pizza_Else.Order_Num = Pizza_Order.Order_Num
where Dow = 'Thu'; 

--  15. Find the overall average max delivery times of our Large Pizza Pies using subqueries
select avg(Time_Max)
from Pizza_Order
where Order_Num in (
select Order_Num from Pizza_Else where Item_Size = 'Large');

--  16. Find the individual average min delivery times of our Large Pizza Pies using inner joins
select distinct(po.Order_Num), Time_Min
from Pizza_Order as po
inner join Pizza_Else on po.Order_Num = Pizza_Else.Order_Num
where Item_Size = 'Large';


-- 17. What store address are our customers using? Solve with inner join 
select pc.Customer_name, ps.Store_Address
from Pizza_Customer as pc
inner join Pizza_Else on pc.customer_email = Pizza_Else.customer_email
inner join Pizza_Store as ps on Pizza_Else.Store_Number = ps.Store_Number
group by 1
order by 1;

-- Future Questions:
-- Which hour of day receives the most orders and what is the order total? Solve with inner join
select HOUR(Pizza_Order.Time) as "Hour of the Day", count(distinct(Pizza_Order.Order_Num)) as "Number of Orders", sum(Total_due) as "Total Order"
from Pizza_Order
inner join Pizza_Else on Pizza_Order.Order_Num = Pizza_Else.Order_Num
group by 1
order by 2 desc;

    
    