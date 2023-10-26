-- Запрос считает общее количество покупателей из таблицы customers.
select COUNT(c.customer_id) as customers_count
from customers c;

-- Запрос возвращает информацию о десятке лучших продавцов.
-- Таблица состоит из трех колонок - данных о продавце, суммарной выручке с проданных товаров и количестве проведенных сделок. 
-- Отсортирована по убыванию выручки
select
    e.first_name || ' '  || e.last_name  as name,
    COUNT(s.sales_id) as operations,
    FLOOR(SUM(s.quantity * p.price)) as income
from employees e
    left join sales s
        on e.employee_id = s.sales_person_id
    left join products p
        on s.product_id = p.product_id
group by e.first_name || ' '  || e.last_name
order by income desc nulls last  
limit 10;

-- Запрос возвращает информацию о продавцах, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам.
-- Таблица отсортирована по выручке по возрастанию.
with avg_by_sallers as (
    select
        e.first_name || ' '  || e.last_name  as name,
        COALESCE(FLOOR(AVG(s.quantity * p.price)), 0) as average_income
    from
        employees e
    left join sales s
        on e.employee_id = s.sales_person_id
    left join products p
        on s.product_id = p.product_id
    group by e.first_name || ' '  || e.last_name
)
select *
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
        FLOOR(SUM(s.quantity * p.price)) as income
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
