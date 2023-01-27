use dannys_diner;

# 1. What is the total amount each customer spent at the restaurant?
select s.customer_id as customer,sum(me.price) as total_spent
from sales s join menu me on s.product_id=me.product_id
group by s.customer_id;

# 2. How many days has each customer visited the restaurant?

select customer_id as customer,count(distinct order_date) as days from sales
group by customer_id;


# 3. What was the first item from the menu purchased by each customer?
select t.customer,t.order_date,t.product_name from
(
select s.customer_id as customer,
	s.order_date,
    me.product_name ,
row_number() over (partition by customer_id order by order_date) as orden 
from sales s join menu me on s.product_id=me.product_id) as t
where t.orden=1;


# 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

-- query para obtener el producto más comprado
select @var:=t.product_name from
(
select me.product_name,count(me.product_name) most_purchased
from sales s join menu me on s.product_id=me.product_id
group by me.product_name
order by 2 desc
limit 1) as t;

select s.customer_id,count(me.product_name) as 'queantity purchased per customer'
from sales s join menu me on s.product_id=me.product_id
where me.product_name=@var
group by s.customer_id;




# 5. Which item was the most popular for each customer?

select t2.* from
(
select t.*,row_number() over (partition by t.customer_id order by cantidad desc) as orden from
(select s.customer_id,m.product_name,count(s.product_id) as cantidad from sales s 
join menu m on s.product_id=m.product_id
group by s.customer_id,m.product_name
order by s.customer_id,cantidad desc) as t
) as t2
where t2.orden=1;


# 6. Which item was purchased first by the customer after they became a member?

select t.* from
(
select s.customer_id,s.order_date,me.product_name,mb.join_date ,row_number() over (partition by  s.customer_id order by s.order_date) as orden
from sales s join members mb on s.customer_id=mb.customer_id 
join menu me on me.product_id=s.product_id
where s.order_date>mb.join_date
) as t
where t.orden=1;


# 7. Which item was purchased just before the customer became a member?

select t.* from
(
select s.customer_id,s.order_date,me.product_name,mb.join_date ,row_number() over (partition by  s.customer_id order by s.order_date desc) as orden
from sales s join members mb on s.customer_id=mb.customer_id 
join menu me on me.product_id=s.product_id
where s.order_date<mb.join_date
) as t
where t.orden=1;


# 8. What is the total items and amount spent for each member before they became a member?
select t.customer_id,count(t.product_id) as total_items, sum(t.price) as spent
from
(
select s.customer_id,s.order_date,me.product_id,me.price,mb.join_date,
row_number() over (partition by s.customer_id order by s.order_date) as orden 
from sales s join menu me on s.product_id=me.product_id
join members mb on mb.customer_id=s.customer_id
where s.order_date<mb.join_date
) as t
group by t.customer_id;


# 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

select t.customer_id,sum(t.puntos) as puntaje from
(
select s.customer_id,s.order_date,me.product_name,me.price,
case
when me.product_name='sushi' then price*10*2
else price*10
end as puntos
from sales s join menu me on s.product_id=me.product_id
) as t
group by t.customer_id;

# 10. In the first week after a customer joins the program (including their join date) 
# they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?




select t.customer_id as customer,sum(t.puntos) as puntaje_total 
from
(
select s.customer_id,
	s.order_date,
    mb.join_date,
    me.product_name,
    me.price,
case
when s.order_date between mb.join_date and adddate(mb.join_date,7) then price*10*2
else price*10
end as puntos
from sales s  join menu me on s.product_id=me.product_id
 join members mb on mb.customer_id=s.customer_id
 where month(s.order_date)=1
order by s.customer_id,	s.order_date) as t
group by t.customer_id;






/*************************BONUS QUESTIONS****************************/

# Join all the things

select s.customer_id,s.order_date,me.product_name,me.price,
case
when s.order_date>=mb.join_date then 'Y'
else 'N'
end as member
from
sales s left join menu me on s.product_id=me.product_id
left join members mb on mb.customer_id=s.customer_id
order by s.customer_id,s.order_date,me.product_name;


# Rank All The Things

select t.*, 
case
when t.member='N' then null
else row_number() over (partition by t.customer_id,t.member order by t.customer_id,t.order_date,t.product_name)
end as ranking

from
(
select s.customer_id,s.order_date,me.product_name,me.price,
case
when s.order_date>=mb.join_date then 'Y'
else 'N'
end as member
from
sales s left join menu me on s.product_id=me.product_id
left join members mb on mb.customer_id=s.customer_id
order by s.customer_id,s.order_date,me.product_name) as t;







