--20
select
    c.category_name,
    count(product_id)
from
    categories c
join
    products p on c.category_id = p.category_id
group by
    1
order by 2 desc;


--21

select
    city,
    country,
    count(customer_id)
from
    customers
group by 1,2
order by 3 desc

--22

select
    product_id, product_name, units_in_stock, reorder_level
from
    products
where
    units_in_stock<=reorder_level
order by product_id

--23
select
    product_id, product_name, units_in_stock, units_on_order, reorder_level, discontinued
from
    products
where
    units_in_stock+units_on_order<=reorder_level
and
    discontinued = 0
order by product_id;

--24
select
    customer_id, company_name, region
from
    customers
order by
    --case when region is null then 1 else 0 end ,
    region, customer_id

--25
select
    ship_country,
    avg(freight) as average_freight
from orders
group by 1
order by 2 desc
limit 3;

--26
select
    ship_country,
    avg(freight) as average_freight
from orders
where
    --date_part('YEAR', order_date) = '1996'
    --order_date >='19960101' and order_date<='19961231' --uses index
    order_date between '19960101' and '19961231' --uses index
group by 1
order by 2 desc
limit 3;

select
    ship_country,
    date_part('YEAR', order_date) dp
from orders;


--28

select
    ship_country,
    avg(freight)
from orders
where
    order_date >= (select max(order_date)- interval '12 MONTH' from orders)
group by 1
order by 2 desc
limit 3

--29

select
    e.employee_id,
    e.last_name,
    o.order_id,
    p.product_name,
    od.quantity
from orders o
join order_details od
on od.order_id=o.order_id
join employees e
on e.employee_id=o.employee_id
join products p
on p.product_id=od.product_id
order by order_id, p.product_id

--30

select
    c.customer_id,
    o.customer_id
from
    customers c
left join
    orders o
on c.customer_id=o.customer_id
where
   o.customer_id is null;

select
    customer_id
from
    customers
where customer_id not in (select customer_id from orders)

select * from orders;

--31

select
    c.customer_id,
    o.customer_id,
    o.employee_id
from
    customers c
left join
    orders o
on o.customer_id=c.customer_id
and employee_id=4
where
    o.customer_id is null

select count(*) from customers;
select count(*) from orders;

--wrong
select
    c.customer_id,
    o.customer_id,
    o.employee_id
from
    customers c
left join
    orders o
on
    o.customer_id=c.customer_id
where
    o.customer_id is null
and
    employee_id=4