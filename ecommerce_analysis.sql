

CREATE DATABASE E_Commerce
use E_Commerce

-- 1. Create Customers Table
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    city VARCHAR(50),
    join_date DATE
);

-- 2. Create Products Table
CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10, 2)
);

-- 3. Create Orders Table
CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    order_date DATE,
    quantity INT,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- Insert Customers
INSERT INTO Customers VALUES 
(1, 'Alice', 'Smith', 'New York', '2025-01-15'),
(2, 'Bob', 'Johnson', 'Los Angeles', '2025-03-22'),
(3, 'Charlie', 'Brown', 'New York', '2025-04-10'),
(4, 'Diana', 'Prince', 'Chicago', '2025-05-01'),
(5, 'Evan', 'Wright', 'Los Angeles', '2025-06-18');

-- Insert Products
INSERT INTO Products VALUES 
(101, 'Laptop', 'Electronics', 1200.00),
(102, 'Smartphone', 'Electronics', 800.00),
(103, 'Desk Chair', 'Furniture', 150.00),
(104, 'Coffee Maker', 'Appliances', 60.00),
(105, 'Headphones', 'Electronics', 120.00);

-- Insert Orders
INSERT INTO Orders VALUES 
(1001, 1, 101, '2026-01-10', 1),
(1002, 1, 104, '2026-01-12', 2),
(1003, 2, 102, '2026-02-20', 1),
(1004, 3, 101, '2026-03-05', 1),
(1005, 4, 103, '2026-04-14', 4),
(1006, 2, 105, '2026-05-22', 2),
(1007, 5, 104, '2026-06-01', 1),
(1008, 1, 102, '2026-06-15', 1),
(1009, 3, 105, '2026-07-02', 3),
(1010, 4, 102, '2026-07-20', 1);


select * from Customers
select * from Products
select * from Orders

-- LEVEL 1 – Strong Basics

--Q1: Customers from New York (Full details)
select * from Customers
where city = 'New york'

--Q2: Total Revenue (not just quantity)
select sum(p.price * o.quantity) as Total_revenue
from Products p
join Orders o on p.product_id = o.product_id

--Q3: Average Order Value (AOV)
select sum(p.price * o.quantity)/ count(distinct o.order_id) as Avg_order_value
from Products p 
join Orders o on p.product_id = o.product_id

--LEVEL 2 – Business Analysis

--Q4: Top 3 Customers by Spending
select top 3
	c.customer_id,c.first_name,sum(p.price * o.quantity) as total_spent 
	from Customers c
	join Orders o on c.customer_id = o.customer_id
	join Products p on o.product_id = p.product_id
	group by c.customer_id,c.first_name
	order by total_spent desc

--Q5: Revenue by City
select c.city,sum(p.price * o.quantity) as City_revenue
from Customers c 
join Orders o on c.customer_id = o.customer_id
join Products p on o.product_id = p.product_id
group by c.city
order by City_revenue desc

--Most Sold Product
select top 1
	p.product_name,sum(o.quantity) as Total_quantity
	from Products p
	join Orders o on p.product_id = o.product_id
	group by p.product_name
	order by Total_quantity desc

--Q7: Customers with No Orders
select c.customer_id,c.first_name
from Customers c
left join Orders o on c.customer_id = o.customer_id
where o.order_id is null

--LEVEL 3 – Advanced

--Q8: Monthly Revenue Trend
select 
	format(o.order_date,'yyyy-MM') AS Month,
	sum(p.price * o.quantity) as Montly_revenue
from orders o
join Products p on o.product_id = p.product_id
group by format(o.order_date,'yyyy-MM')
order  by Month

--Q9: Month-over-Month Growth %
with Monthly as (
	select 
		FORMAT(o.order_date,'yyyy-mm') as Month,
		sum(p.price * o.quantity) as revenue
	from orders o
	join Products p on o.product_id = p.product_id
	group by FORMAT(o.order_date,'yyyy-mm')
)
select 
	month,
	revenue,
	lag(revenue) over (order by month) as prev_month,
	round(
		(revenue - lag(revenue) over (order by month)) * 100
		/ lag(revenue) over (order by month),2
		) as growth_percent
	from monthly

--Q10: Top Product in Each Category
select * 
from (	
	select
		p.category,
		p.product_name,
		sum(p.price * o.quantity) as revenue,
		RANK() OVER (PARTITION by p.category order by sum(p.price * o.quantity) desc) as rnk
	from Orders o
	join Products p on o.product_id = p.product_id
	group by p.category,p.product_name
)t
where rnk = 1
		
--Q11: Customer Lifetime Value (CLV)
select 
	c.customer_id,
	c.first_name,
	sum(p.price * o.quantity) as lifetime_value
from Customers c
join Orders o on c.customer_id = o.customer_id
join Products p on o.product_id = p.product_id
group by c.customer_id,c.first_name
order by lifetime_value desc

--Q12: Repeat vs One-Time Customers
select 
	case
		when count(o.order_id) = 1 then 'one-time'
		else 'repeat'
	end as customer_type,
	count(distinct c.customer_id) AS Total_customers
	from Customers c
	join Orders o on c.customer_id = o.customer_id

--Q13: Running Revenue
select 
	o.order_date,
	sum(o.quantity * p.price) as Monthy_revenue,
	sum(sum(o.quantity * p.price)) over (order by o.order_date) as Running_total
from orders o
join Products p on o.product_id = p.product_id
group by o.order_date