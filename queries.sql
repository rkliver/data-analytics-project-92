-- Запрос считает количество пользователй (customer_id) в таблице customers
select COUNT(c.customer_id) as customers_count
from customers c;
