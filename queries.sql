-- Запрос возвращает количество пользователей в таблице.
select COUNT(c.customer_id) as customers_count
from customers c;

-- Запрос возвращает данные по десятке лучших продавцов.
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

-- Запрос возвращает данные по продавцам,
-- чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам.
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
