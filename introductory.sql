--1
select * from shippers;

--2
select * from categories;
select category_name, description from categories;


--3
select first_name, last_name, hire_date from employees;

--4
select * from employees;
select first_name, last_name, hire_date from employees where title='Sales Representative';

--5
select order_id, order_date from orders where employee_id='5';

--6
select supplier_id, contact_name, contact_title from suppliers where contact_title!='Marketing Manager';

--7
select * from products where upper(product_name) like '%QUESO%';

--8
select order_id, customer_id, ship_country from orders where ship_country='France' or ship_country='Belgium';

--9
select
    order_id, customer_id, ship_country
from
    orders
where
    ship_country in ('Brazil', 'Mexico', 'Argentina', 'Venezuela');

--10
select
    first_name, last_name, title, birth_date
from
    employees
order by
    birth_date asc;

--12

select
    first_name, last_name, concat(first_name, ' ', last_name)
from
    employees;


--13
select
    d.order_id,
    d.product_id,
    d.unit_price,
    d.quantity,
    round(cast(d.quantity * d.unit_price as numeric), 2) as total_price
from
    order_details d;

--14

select
    count(*) as total_customers
from
    customers;

--15
select
    min(order_date)
from
    orders;

--16
select
    distinct(country)
from
    customers;

select
    country
from
    customers
group by country;

--17
select
    contact_title,
    count(contact_title) as total_contact_title
from
    customers
group by contact_title
order by 2 desc
;

--18
select
    p.product_id,
    p.product_name,
    s.company_name as supplier
from
    products p
    join suppliers s on p.supplier_id = s.supplier_id

--19
select
    o.order_id,
    o.order_date,
    sh.company_name as Shipper
from
    orders o
    join shippers sh on o.ship_via = sh.shipper_id
where
    o.order_id<10270
order by o.order_date