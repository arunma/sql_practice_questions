--32
select
    o.customer_id,
    c.company_name,
    o.order_id,
    sum (od.unit_price * od.quantity) as total_order_amount
from
    orders o
join
    order_details od
on o.order_id = od.order_id
join
    customers c
on
    c.customer_id=o.customer_id
where
    o.order_date between '19980101' and '19981231'
group by 1,2,3
having sum (od.unit_price * od.quantity) >10000
order by 4 desc


--33

select
    o.customer_id,
    c.company_name,
    sum(od.unit_price*od.quantity) as total_order_amount
from
    orders o
join
    order_details od
on o.order_id = od.order_id
join
    customers c
on c.customer_id = o.customer_id
where
    o.order_date between '19980101' and '19981231'
group by 1,2
having sum(od.unit_price*od.quantity) >=15000
order by total_order_amount desc

--34

--select * from order_details limit 10

select
    c.customer_id,
    c.company_name,
    sum(od.unit_price*od.quantity) as total_with_discount,
    sum(od.unit_price*od.quantity*(1-discount)) as total_with_discount
from
    order_details od
join
    orders o
on od.order_id = o.order_id
join
    customers c
on o.customer_id = c.customer_id
where
    date_part('YEAR', order_date)=1998
group by 1,2
having sum(od.unit_price*od.quantity*(1-discount))>=15000
order by 4 desc

--35

select
    employee_id,
    order_id,
    order_date,
    date_trunc('month', order_date::date) + interval '1 MONTH - 1 DAY'
from orders
where order_date=date_trunc('month', order_date::date) + interval '1 MONTH - 1 DAY'
order by 1

--36
select
    order_id,
    count(concat(order_id, product_id))
from
    order_details
group by 1
order by 2 desc
limit 10;

--37
select
    order_id,
    random()
from
    orders
order by 2


--38

select
    order_id
from
    order_details
where quantity>=60
group by order_id, quantity
having count(*)>1
order by 1;

select
    order_id,
    quantity,
    count(quantity)
from
    order_details
where quantity>=60
group by 1,2
having count(quantity)>1

--39

with duplicate_orders as (
    select
        order_id
    from
        order_details
    where quantity>=60
    group by order_id, quantity
    having count(*)>1
)
select
    od.order_id,
    product_id,
    unit_price,
    quantity,
    discount
from order_details od
join duplicate_orders dod
on od.order_id = dod.order_id;

with oldest_employee as (select employee_id
                         from employees
                         where birth_date = (select max(birth_date) from employees))
select
    order_id,
    order_date,
    employee_id
from orders
where employee_id in (select employee_id from oldest_employee)

--41

select
    order_id,
    order_date,
    required_date,
    shipped_date
from
    orders
where required_date<shipped_date


--42
select
    o.employee_id,
    e.last_name,
    count(order_id) as total_late_orders
from
    orders o
join
    employees e
on o.employee_id=e.employee_id
where required_date<shipped_date
group by 1,2
order by 3 desc

--43

with total_late_orders as (
    select
    o.employee_id,
    count(order_id) as total_late_orders
    from
        orders o
    where required_date<shipped_date
    group by 1
),
total_orders as (
    select
    o.employee_id,
    count(order_id) as total_orders
    from
        orders o
    group by 1
)
select
    e.last_name,
    too.total_orders,
    tl.total_late_orders
from
    employees e
join
    total_late_orders tl
on tl.employee_id=e.employee_id
join
    total_orders too
on too.employee_id=e.employee_id
order by 2 desc


/*select
    e.employee_id,
    e.last_name,
    sum(count(order_id)) over () as total_count -- (partition by o.employee_id)
from employees e
join
    orders o
on o.employee_id=e.employee_id*/

with total_late_orders as (
    select
    o.employee_id,
    count(order_id) as total_late_orders
    from
        orders o
    where required_date<shipped_date
    group by 1
),
total_orders as (
    select
    o.employee_id,
    count(order_id) as total_orders
    from
        orders o
    group by 1
)
select
    e.last_name,
    too.total_orders,
    coalesce(tl.total_late_orders, 0),
    round(((tl.total_late_orders*1.0/total_orders)*100)::numeric, 2) as percent_late_orders
from
    employees e
join
    total_late_orders tl
on tl.employee_id=e.employee_id
join
    total_orders too
on too.employee_id=e.employee_id
order by 3 desc


--48
with total_order_cte as (
    select
        c.customer_id,
        sum(od.unit_price*od.quantity) as total_order_amount
    from
        customers c
    join orders o
    on o.customer_id=c.customer_id
    join order_details od
    on od.order_id=o.order_id
    where date_part('YEAR', o.order_date)='1998'
    group by 1
)
select
    c.customer_id,
    c.company_name,
    round(tot.total_order_amount::numeric, 2) as total_order_amount,
    case when tot.total_order_amount between 0 and 5000 then 'Low'
        when  tot.total_order_amount between 1000 and 5000 then 'Medium'
        when  tot.total_order_amount between 5000 and 10000 then 'High'
        when  tot.total_order_amount > 10000 then 'High'
    end as "Customer Group"
from
    customers c
join
    total_order_cte tot
on c.customer_id=tot.customer_id;

--50
with total_order_cte as (
    select
        c.customer_id,
        sum(od.unit_price*od.quantity) as total_order_amount
    from
        customers c
    join orders o
    on o.customer_id=c.customer_id
    join order_details od
    on od.order_id=o.order_id
    where date_part('YEAR', o.order_date)='1998'
    group by 1
),
groups as (
select c.customer_id,
  --round(tot.total_order_amount::numeric, 2) as total_order_amount,
  case
      when tot.total_order_amount>=0 and tot.total_order_amount<1000 then 'Low'
      when tot.total_order_amount >=1000 and tot.total_order_amount<5000 then 'Medium'
      when tot.total_order_amount >=5000 and tot.total_order_amount<10000 then 'High'
      when tot.total_order_amount > 10000 then 'Very High'
      end  as "customer_group"
from customers c
    join
total_order_cte tot
on c.customer_id = tot.customer_id
)
select
    g.customer_group,
    count(customer_id) as total_in_group,
    round((count(customer_id)*1.0/(select count(*) from groups))::numeric, 2) as percentage_in_group
from
    groups g
group by 1

--52

select
    country
from customers
union
select
    country
from suppliers
order by 1


--53

with customer_countries as (select distinct country from customers),
supplier_countries as (select distinct country from suppliers)
select
    s.country,
    c.country
from
    customer_countries c
full outer join supplier_countries s
on c.country=s.country



-- 54
with customer_countries as (select distinct country, count(customer_id) cust_count from customers group by 1),
     supplier_countries as (select distinct country, count(supplier_id) supp_count from suppliers group by 1)
select
    coalesce(c.country, s.country),
    coalesce(s.supp_count, 0) total_suppliers,
    coalesce(c.cust_count, 0) total_customers
from
    customer_countries c
full outer join
    supplier_countries s
on c.country=s.country
order by 1;

--55
/*with min_order_id as(
    select order_id, min(order_date) order_date from orders group by ship_country, order_id
)
select
    o.ship_country,
    o.customer_id,
    o.order_id,
    m.order_date
from
    orders o
join
    min_order_id m
on m.order_id=o.order_id
order by 1
*/

with min_order_date as (select ship_country,
                               customer_id,
                               order_id,
                               order_date,
                               row_number() over (partition by ship_country order by order_date) row_num
                            from orders
                        )
select ship_country,
       customer_id,
       order_id,
       order_date
from min_order_date
where row_num=1;

--56

with orders_cte as (
    select customer_id,
        order_id   as                                                        initial_order_id,
        order_date as                                                        initial_order_date,
        lead(order_id) over (partition by customer_id order by order_date)   next_order_id,
        lead(order_date) over (partition by customer_id order by order_date) next_order_date
    from orders
    )
select customer_id,
       initial_order_id,
       initial_order_date,
       next_order_id,
       next_order_date,
       next_order_date - initial_order_date as days_between
from orders_cte
where  next_order_date - initial_order_date  <=5


