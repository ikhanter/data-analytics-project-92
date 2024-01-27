-- Запрос считает количество строк в таблице customers
select count(*) as customers_count from customers;


-- Запрос для поиска топ 10 лучших продавцов
-- Складывает имя и фамилию в единое поле таблицы, через группировку считает для каждого значения такого поля количество строк в таблице с продажами и 
-- считает округленную в меньшую сторону сумму выручки со всех продаж, сортирует в порядке убывания выручки и ограничивает количество записей до 10
select
	concat(e.first_name, ' ', e.last_name) as name,
	count(s.*) as operations,
	floor(sum(p.price * s.quantity)) as income
from employees e
inner join sales s on s.sales_person_id = e.employee_id 
inner join products p on p.product_id = s.product_id 
group by concat(e.first_name, ' ', e.last_name)
order by income desc
limit 10;


