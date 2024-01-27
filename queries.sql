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


-- Запрос для поиска продавцов, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам
-- Складывает имя и фамилию в единое поле таблицы, через группировку считает для каждого значения такого поля среднюю выручку за сделку, округленную
-- в меньшую сторону и затем сравнивает ее со средней выручкой за сделку по всем продажам, посчитанной в подзапросе. Далее сортирует в по рядке возрастания
-- средней выручки
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
