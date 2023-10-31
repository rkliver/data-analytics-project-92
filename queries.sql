-- Запрос считает общее количество покупателей из таблицы customers.
select COUNT(c.customer_id) as customers_count
from customers c;

-- Запрос возвращает информацию о десятке лучших продавцов.
-- Таблица состоит из трех колонок - данных о продавце, суммарной выручке с проданных товаров и количестве проведенных сделок. 
-- Отсортирована по убыванию выручки
select
    e.first_name || ' '  || e.last_name  as name,
    COUNT(s.sales_id) as operations,
    ROUND(SUM(s.quantity * p.price)) as income
from employees e
    inner join sales s
        on e.employee_id = s.sales_person_id
    inner join products p
        on s.product_id = p.product_id
group by e.first_name || ' '  || e.last_name
order by income desc  
limit 10;

-- Запрос возвращает информацию о продавцах, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам.
-- Таблица отсортирована по выручке по возрастанию.
with avg_by_sallers as (
    select
        e.first_name || ' '  || e.last_name  as name,
        ROUND(AVG(s.quantity * p.price)) as average_income
    from
        employees e
    inner join sales s
        on e.employee_id = s.sales_person_id
    inner join products p
        on s.product_id = p.product_id
    group by e.first_name || ' '  || e.last_name
)
select
    name,
    average_income
from avg_by_sallers
where average_income < (select AVG(average_income) from avg_by_sallers)
order by average_income;

-- Запрос возвращает информацию о выручке по дням недели.
-- Каждая запись содержит имя и фамилию продавца, день недели и суммарную выручку.
-- Отсортировано по порядковому номеру дня недели и name
with tab_before_sort AS(
    select
        e.first_name || ' ' || e.last_name as name,
        TO_CHAR(s.sale_date, 'ID') as weekday_num,
        TO_CHAR(s.sale_date, 'day') as weekday,
        ROUND(SUM(s.quantity * p.price)) as income
    from employees e
        inner join sales s
            on e.employee_id = s.sales_person_id
        inner join products p
            on s.product_id = p.product_id
    group by
        TO_CHAR(s.sale_date, 'day'),
        TO_CHAR(s.sale_date, 'ID'),
        e.first_name || ' ' || e.last_name
)
select
    name,
    weekday,
    income
from tab_before_sort
order by weekday_num, name;

-- Запрос возвращает количество покупателей в разных возрастных группах: 16-25, 26-40 и 40+.
-- Итоговая таблица отсортирована по возрастным группам.
select
    (case
    when age between 16 and 25 then '16-25'
    when age between 26 and 40 then '26-40'
    when age > 40 then '40+'
    end) as age_category,
    COUNT(customer_id)
from customers
group by (case
    when age between 16 and 25 then '16-25'
    when age between 26 and 40 then '26-40'
    when age > 40 then '40+'
    end)
order by age_category;

-- Запрос возвращает данные по количеству уникальных покупателей и выручке, которую они принесли.
-- Сгруппировано по дате, которая представлена в числовом виде ГОД-МЕСЯЦ
-- Итоговая таблица отсортирована по дате по возрастанию.
select
    TO_CHAR(s.sale_date,'YYYY-MM') as date,
    COUNT(distinct s.customer_id) as total_customers,
    ROUND(SUM(s.quantity * p.price)) as income
from sales s
    inner join products p
        on s.product_id = p.product_id
group by TO_CHAR(s.sale_date,'YYYY-MM')
order by date;

-- Запрос возвращает информацию о покупателях, первая покупка которых была в ходе проведения акций (акционные товары отпускали со стоимостью равной 0).
-- Итоговая таблица отсортирована по id покупателя.
with promo_sales as (
    select
        s.customer_id,
        c.first_name ||' '|| c.last_name as customer,
        MIN(s.sale_date) as sale_date
    from sales s
        inner join products p
            on s.product_id = p.product_id
        inner join customers c
            on s.customer_id = c.customer_id
    where p.price = 0
    group by
        s.customer_id,
        c.first_name ||' '|| c.last_name
    order by s.customer_id
)

select
    ps.customer,
    ps.sale_date,
    e.first_name ||' '|| e.last_name as seller
from promo_sales ps
    inner join sales s
        on ps.customer_id = s.customer_id
        and ps.sale_date = s.sale_date
    inner join employees e
        on s.sales_person_id = e.employee_id
group by
    ps.customer,
    ps.sale_date,
    e.first_name ||' '|| e.last_name
    order by customer;
