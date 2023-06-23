/*********************************
outer join
*********************************/

--------------------------------------
-- left join
-- right join is same. but location of table is important
--------------------------------------

SELECT
    product_name,
    order_id
FROM
    production.products p
LEFT OUTER JOIN sales.order_items o 
ON o.product_id = p.product_id
ORDER BY
    order_id;

--------------------------------------
-- product not sold
--------------------------------------
SELECT
    product_name,
    order_id
FROM
    production.products p
LEFT JOIN sales.order_items o ON o.product_id = p.product_id
WHERE order_id IS NULL

--------------------------------------
-- more than tables
--------------------------------------
SELECT
    p.product_name,
    o.order_id,
    i.item_id,
    o.order_date
FROM
    production.products p
	LEFT JOIN sales.order_items i
		ON i.product_id = p.product_id
	LEFT JOIN sales.orders o
		ON o.order_id = i.order_id
ORDER BY
    order_id;

--------------------------------------
-- NOTE: difference between "on" condition and "where" condition
--------------------------------------
SELECT
    product_name,
    order_id
FROM
    production.products p
LEFT JOIN sales.order_items o 
   ON o.product_id = p.product_id
WHERE order_id = 100
ORDER BY
    order_id;


/************************************************
Assignment 4

sales.orders (주문) 레코드는 sales.staffs (점원) 레코드를 바탕으로 주문이 이뤄진다. 하지만 반대로 sales.staffs 가 반드시 주문정보를 가지고 있다고 할 수는 없다. (예를 들어 주문에 대한 정보가 없는 새로운 점원 정보)

1. 이 두 가지 table 을 통해 주문 정보가 없는 점원정보를 조회 한다.

2. outer join 으로 진행한 바로 위의 query 를 inner join 으로 "바꾸지 않고", 그대로 조건만 바꿔서 주문정보가 "있는" 점원 (staff) 정보를 조회 한다.

*************************************************/

