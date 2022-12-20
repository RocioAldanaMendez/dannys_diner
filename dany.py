import streamlit as st
import pandas as pd
from sqlalchemy import create_engine
import altair as alt

cadena_conexion='mysql+pymysql://root:1235@localhost:3306/dannys_diner'

conexion=create_engine(cadena_conexion)


# pregunta 1
sql='''
select s.customer_id as customer,sum(me.price) as total_spent
from sales s join menu me on s.product_id=me.product_id
group by s.customer_id
'''
df1=pd.read_sql_query(sql,con=conexion)
print(df1)


st.title('Case Study #1 - Danny\'s Diner')
st.subheader('1. What is the total amount each customer spent at the restaurant?')
p = alt.Chart(df1).mark_bar().encode(
    x='customer',
    y='total_spent'
)
p = p.properties(
    width=alt.Step(80)  # controls width of bar.
)
st.write(p)



# pregunta 2

sql='''
select customer_id as customer,count(distinct order_date) as days from sales
group by customer_id
'''
df2=pd.read_sql_query(sql,con=conexion)
print(df2)


st.subheader('2. How many days has each customer visited the restaurant?')
p = alt.Chart(df2).mark_bar().encode(
    x='customer',
    y='days'
)
p = p.properties(
    width=alt.Step(80)  # controls width of bar.
)
st.write(p)



# pregunta 3

sql='''
select t.customer,t.order_date,t.product_name from
(
select s.customer_id as customer,
	s.order_date,
    me.product_name ,
row_number() over (partition by customer_id order by order_date) as orden 
from sales s join menu me on s.product_id=me.product_id) as t
where t.orden=1;
'''
df3=pd.read_sql_query(sql,con=conexion)
print(df3)


st.subheader('3. What was the first item from the menu purchased by each customer?')
st.dataframe(df3)



# pregunta 4

sql1='''
select t.product_name from
(
select me.product_name,count(me.product_name) most_purchased
from sales s join menu me on s.product_id=me.product_id
group by me.product_name
order by 2 desc
limit 1) as t
'''
df_4_1=pd.read_sql_query(sql1,con=conexion)
escalar=df_4_1.iloc[0][0]
print(escalar)


st.subheader('4. What is the most purchased item on the menu and how many times was it purchased by all customers?')
st.text('The most purchased item was {}'.format(escalar))



sql2='''
select s.customer_id,count(me.product_name) as 'queantity purchased per customer'
from sales s join menu me on s.product_id=me.product_id
where me.product_name=(
select t.product_name from
-- subconsulta para obtener el producto más comprado
(
select me.product_name,count(me.product_name) most_purchased
from sales s join menu me on s.product_id=me.product_id
group by me.product_name
order by 2 desc
limit 1) as t
)
group by s.customer_id
'''

st.text('An it was purchased as follow:')
df_4_2=pd.read_sql_query(sql2,con=conexion)
print(df_4_2)
st.dataframe(df_4_2)

