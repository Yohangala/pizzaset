-- Basic:
-- Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS Total_Order
FROM
    orders;
-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(o.quantity * p.price)) AS total_sales
FROM
    order_detail o
        JOIN
    pizzas p ON p.pizza_id = o.pizza_id;
-- Identify the highest-priced pizza.
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types 
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;
-- Identify the most common pizza size ordered.
SELECT 
    p.size, COUNT(o.order_detail_id) AS common_size
FROM
    order_detail o
        JOIN
    pizzas p ON o.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY common_size DESC
LIMIT 1;
-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.name, COUNT(o.order_detail_id) AS common_size
FROM
    order_detail o
        JOIN
    pizzas p ON o.pizza_id = p.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = p.pizza_type_id
GROUP BY pizza_types.name
ORDER BY common_size DESC
LIMIT 5;



-- Intermediate:
-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.category, SUM(order_detail.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_detail ON order_detail.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;
-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS hours, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(order_time)
ORDER BY hours;
-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;
-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    orders.order_date, SUM(order_detail.quantity)
FROM
    orders
        JOIN
    order_detail ON orders.order_id = order_detail.order_id
GROUP BY orders.order_date;
-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pizza_types.name,
    ROUND(SUM(pizzas.price * order_detail.quantity)) AS revenue
FROM
    pizzas
        JOIN
    order_detail ON pizzas.pizza_id = order_detail.pizza_id
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

-- Advanced:
-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category,
    ROUND((SUM(pizzas.price * order_detail.quantity) / (SELECT 
                    ROUND(SUM(o.quantity * p.price)) AS total_sales
                FROM
                    order_detail o
                        JOIN
                    pizzas p ON p.pizza_id = o.pizza_id)) * 100,
            2) AS revenue
FROM
    pizzas
        JOIN
    order_detail ON pizzas.pizza_id = order_detail.pizza_id
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.category
ORDER BY revenue DESC
;
-- Analyze the cumulative revenue generated over time.
select order_date,
round(sum(revenue) over (order by order_date),2) as cum_revenue from
(select orders.order_date, sum(order_detail.quantity*pizzas.price) as revenue from order_detail join pizzas on order_detail.pizza_id=pizzas.pizza_id
join orders on orders.order_id=order_detail.order_id
group by orders.order_date) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name,revenue from(
select category,name,revenue,rank() over(partition by category order by revenue desc)as rn
 from
(sELECT 
    pizza_types.category,pizza_types.name,
    ROUND(SUM(pizzas.price * order_detail.quantity)) AS revenue
FROM
    pizzas
        JOIN
    order_detail ON pizzas.pizza_id = order_detail.pizza_id
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY   pizza_types.category,pizza_types.name
ORDER BY revenue DESC) as a) as b
where rn<= 3
;




