-- Запрос считает количество строк в таблице customers.
select count(*) as customers_count from customers;


-- Запрос для поиска топ 10 лучших продавцов
-- Складывает имя и фамилию в единое поле таблицы, через группировку считает для каждого значения такого поля количество строк в таблице с продажами и 
-- считает округленную в меньшую сторону сумму выручки со всех продаж, сортирует в порядке убывания выручки и ограничивает количество записей до 10.
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


-- Запрос для поиска продавцов, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам
-- Складывает имя и фамилию в единое поле таблицы, через группировку считает для каждого значения такого поля среднюю выручку за сделку, округленную
-- в меньшую сторону и затем сравнивает ее со средней выручкой за сделку по всем продажам, посчитанной в подзапросе. Далее сортирует в по рядке возрастания
-- средней выручки.
select
	concat(e.first_name, ' ', e.last_name) as name,
	floor(avg(p.price * s.quantity)) as average_income
from employees e
inner join sales s on s.sales_person_id = e.employee_id 
inner join products p on p.product_id = s.product_id 
group by concat(e.first_name, ' ', e.last_name)
having floor(avg(p.price * s.quantity)) < (
	select avg(p.price * s.quantity)
	from sales s inner join products p on s.product_id = p.product_id 
)
order by average_income;


-- Запрос для демонстрации средней выручки по дням недели в зависимости от продавца
-- Складывает имя и фамилию в единое поле таблицы, извлекает из даты совершения продажи день недели, через группировку считает для каждой
-- пары значений таких полей округленную в меньшую сторону сумму выручки с продаж. Для сортировки с понедельника по воскресенье добавлена мнимая группировка
-- для упорядочивания элементов: вычисляет день недели в виде цифры, преобразует тип данных в целочисленный, прибавляет 5 и 
-- находит остаток результата от деления на 7.
select
	concat(e.first_name, ' ', e.last_name) as name,
	to_char(s.sale_date, 'day') as weekday,
	floor(sum(p.price * s.quantity)) as income
from employees e
inner join sales s on s.sales_person_id = e.employee_id 
inner join products p on p.product_id = s.product_id 
group by concat(e.first_name, ' ', e.last_name), to_char(s.sale_date, 'day'), mod(cast(to_char(s.sale_date, 'd') as integer) + 5, 7)
order by mod(cast(to_char(s.sale_date, 'd') as integer) + 5, 7), name;


-- Подзапрос извлекает строки с возрастом каждого покупателя и добавляет возрастную категорию в зависимости от него.
-- Основной запрос агрегирует данные из подзапроса и группирует по возрастной категории.
select age_category, count(*)
from (select age, case
	when age between 16 and 25 then '16-25'
	when age between 26 and 40 then '26-40'
	else '40+'
end as age_category
from customers) as subquery
group by age_category
order by age_category;


-- Запрос группирует строки по доте в нужном формате и агрегирует данные по количеству покупателей и округленной сумме.
select 
	to_char(s.sale_date, 'yyyy-mm') as date,
	count(distinct s.customer_id) as total_customers,
	floor(sum(s.quantity * p.price)) as income
from sales s
inner join products p on s.product_id = p.product_id
group by to_char(s.sale_date, 'yyyy-mm')
order by date;


-- CTE: Подзапрос выбирает акционные товары. Запрос добавляет нумерацию по партиции customer_id, сортированную по дате
-- Основной запрос: формирует строки с именами продавцов, покупателей и дат для тех строк, чей номер по нумерации - 1
-- (первая покупка акционного товара)
with subquery as (select 
	customer_id,
	product_id,
	sales_person_id,
	sale_date,
	row_number() over(partition by customer_id order by sale_date) as number
from sales s
where product_id in (select product_id
	from products
	where price = 0)
order by customer_id, sale_date, number)
select 
	concat(c.first_name, ' ', c.last_name) as customer,
	sq.sale_date as sale_date,
	concat(e.first_name, ' ', e.last_name) as seller
from subquery sq
inner join customers c on sq.customer_id = c.customer_id
inner join employees e on e.employee_id = sq.sales_person_id
where number = 1;
