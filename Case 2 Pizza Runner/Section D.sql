/*-----------D. Pricing and Ratings-----------*/

Select * from customer_orders;
select * from pizza_names;
select * from pizza_recipes;
select * from pizza_toppings;
select * from runner_orders;
select * from runners;

-- 1: If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
WITH CTE AS 
	(SELECT 
		order_id,
        pizza_id,
	CASE WHEN pizza_id =  1 then 12 else 10 end as pizza_cost
		from customer_orders)
SELECT
	SUM(pizza_cost) as total_revenue
from cte as c
JOIN runner_orders ro ON c.order_id = ro.order_id
where pickup_time is not null;


-- 2: What if there was an additional $1 charge for any pizza extras ex:Add cheese is $1 extra ?
with cte as
	(select
		order_id,
        pizza_id,
	case
		when pizza_id = 1 then 12 else 10
        end as price,
		extras
	from customer_orders
    join runner_orders using(order_id)
    where pickup_time is not null)
select
	sum(case
		when extras is null then price
        when extras = '' then price
        when length(replace(extras, ', ', '')) = 1 then price + 1
        else price + 2
        end) as total_price
from cte;

/* 3: The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional
 table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.*/
drop table if EXISTS rating;
create table rating
select
	order_id,
    case
		when duration is null then null
		when duration = 10 then 5
        when duration BETWEEN 15 and 20 then 4
        when duration BETWEEN 20 and 30 then 3
        when duration BETWEEN 30 and 35 then 2
        else 1
        end as rating
	from runner_orders;

-- 4: Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?*/
select
		co.customer_id,
		co.order_id,
		ro.runner_id,
		r.rating,
		co.order_time,
		ro.pickup_time,
        time_format(timediff(pickup_time, order_time), '%i.%s') as timediff,
        duration as delivery_time,
        round(avg(distance/duration),2) as avg_speed,
        count(pizza_id) as total_pizza
	from customer_orders as co
    join runner_orders as ro on co.order_id = ro.order_id
    join rating as r on r.order_id = co.order_id
    where pickup_time is not null
    group by 1,2,3,4,5,6,8;
select  * from customer_orders;
    
/* 5: If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled
 - how much money does Pizza Runner have left over after these deliveries?*/

select
	@distance_travel_revenue:= sum(distance * .3)
from runner_orders
where pickup_time is not null;
with cte as
	(select
		ro.order_id,
		case when pizza_id = 1 then 12 else 10 
		end as price,
		distance
	from runner_orders as ro
	join customer_orders as co using (order_id)
	where pickup_time is not null)
select
	sum(price) - @distance_travel_revenue as profit
from cte;


	