--  Question 2: identify the highest rating category in each branch
select * from
(
select
	branch,
	category,
	avg(rating) as avg_rating,
	rank() over(partition by branch order by avg(rating) desc) as ranking
from sales
group by branch, category
)
where ranking =1;


--Quest 3: identify the busiest day for each branch based on the numer of transactions
select *
from
	(select
		branch,
		TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'DAY') as "day",
		count(*) as interactions,
		rank() over(partition by branch order by count(*) desc)
	from sales
	group by branch, "day"
	)
where
rank = 1;


-- Quest 4: List quantities sold with their payment methods.
select payment_method, sum(quantity) as "quantité vendue"
from sales
group by payment_method
order by "quantité vendue" desc;


-- Quest 5: determine the min, avg, and max rating of category for each city.
select city, category, avg(rating), min(rating), max(rating)
from sales
group by city, category;


-- Question 6: Calculate the total profit for each category by considering total_profit as
-- (unit_price * quantity * profit_margin). List category and total_profit from highest to lowest.
select
	category,
	sum(total_amount) as total_revenue,
	sum(total_amount * profit_margin) as profit
from sales
group by category;


-- Q.7: Determine the most common payment method for each branch
-- Display branch and the preferred-payment-method
with cte
as 
(
	select
		branch,
		payment_method,
		count(*) as "total transactions",
		rank() over(partition by branch order by count(*) desc)
	from sales
	group by branch, payment_method
)
select *
from cte
where "rank" = 1;


-- Q.8: categorize sales into 3 grps morning, afternoon, and evening.
-- find out each of the shift and number of invoices.
select
	branch,
	case
		when extract (hour from (time::time)) < 12 then 'morning'
		when extract (hour from (time::time)) between 12 and 17 then 'afternoon'
		else 'evening'
	end "day time",
	count(*)
from sales
group by branch, "day time"
order by branch, count(*);


-- Q.9: Identify 5 branches with highest decrease ration in revenue compare to last year
with rev_2022 as
(select
	branch,
	sum(total_amount) as total_revenue
from sales
where extract(year from to_date(date, 'dd/mm/yy')) = 2022
group by branch
),
rev_2023 as
(select
	branch,
	sum(total_amount) as total_revenue
from sales
where extract(year from to_date(date, 'dd/mm/yy')) = 2023
group by branch
)
select
	ly.branch,
	ly.total_revenue as last_year_rev,
	cy.total_revenue as current_year_rev,
	round(((ly.total_revenue - cy.total_revenue) / ly.total_revenue * 100)::numeric, 2)
from rev_2022 as ly
join rev_2023 as cy
on ly.branch = cy.branch
where
	ly.total_revenue - cy.total_revenue > 0
order by round desc
limit 5;