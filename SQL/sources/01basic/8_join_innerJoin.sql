/*********************************
inner join
*********************************/

--------------------------------------
-- inner join: looking at entire diagram
--------------------------------------
SELECT
    product_name,
    category_name,
    list_price,
	brand_id
FROM
    production.products t1
    INNER JOIN 
	production.categories t2
ON t1.category_id = t2.category_id -- on 은 Join 성립 조건
ORDER BY
    product_name DESC;

--------------------------------------
-- more than 2
--------------------------------------
SELECT
    product_name,
    category_name,
    brand_name,
    list_price
FROM
	production.products p
INNER JOIN production.categories c 
	ON c.category_id = p.category_id
INNER JOIN production.brands b 
	ON b.brand_id = p.brand_id
ORDER BY
    product_name DESC;

/************************************************
Assignment 3

앞서 진행했던 Assingment 2 (6_filtering_where.sql file)는 다음과 같다. (반복)

```
우선 sales.customers (고객 테이블) 로 부터 레코드를 조회하는데, state 는  'NY" 에 살고 있어야 하며, phone 의 정보가 있어야 하고 동시에 이메일은 gmail 혹은 hotmail 이 아닌 고객 들의 정보를 조회 한다.

그 후에 이 고객들의 customer_id (아이디) 정보를 바탕으로 sales.orders (주문 정보) 의 모든 칼럼을 조회한다.  추가 조건은 2017 년에 주문한 정보를 가져오고 이 주문한 날짜 칼럼 (order_date) 를 기준으로 올림차순으로 정렬한다. (ascending)
```

sub query 를 통해 작성했던 쿼리를 위의 inner join 구문을 이용하여 바꾼다.
*************************************************/

select * from sales.orders
where customer_id in 
(
    select customer_id
    from sales.customers     
    where state = 'NY' 
    and phone is not null
    and email not like '%@gmail.com%' and email not like '%@hotmail.com%'
)
and order_date > '2016-12-31' and order_date < '2018-01-01'
order by order_date ASC
---->>

select s.* from sales.customers c
inner join sales.orders s
on c.customer_id = s.customer_id -- inner join 조건
where c.state = 'NY' 
    and c.phone is not null
    and c.email not like '%@gmail.com%' and c.email not like '%@hotmail.com%'
	and s.order_date > '2016-12-31' and s.order_date < '2018-01-01'
order by s.order_date ASC
