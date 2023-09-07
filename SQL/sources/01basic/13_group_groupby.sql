/*********************************
group by -- 통계
*********************************/

-- sum, max, min, count, avg 함수와 관련 있음

-- the customer id and the ordered year
--------------------------------------
-- without grouping
--------------------------------------
SELECT
    customer_id,
    YEAR (order_date) 'order_year' -- year 함수는 year 만 리턴
FROM
    sales.orders
WHERE
    customer_id IN (1, 2)
ORDER BY
    customer_id;

--------------------------------------
-- with grouping for above (not with any aggregate (계산) function)
-- sum, max, min, count, avg
--------------------------------------
SELECT
    customer_id,
    YEAR (order_date) order_year
FROM
    sales.orders
WHERE
    customer_id IN (1, 2)
GROUP BY
    customer_id,
    YEAR (order_date)
ORDER BY
    customer_id;

--------------------------------------
-- same effect with distinct
--------------------------------------
SELECT DISTINCT
    customer_id,
    YEAR (order_date) order_year
FROM
    sales.orders
WHERE
    customer_id IN (1, 2)
ORDER BY
    customer_id;


--------------------------------------
-- group by with aggregate function
-- number of orders placed by the customer by year
--------------------------------------
SELECT
    customer_id,
    YEAR (order_date) order_year,
    COUNT (order_id) order_placed -- count  함수: 레코드 숫자 리턴
FROM
    sales.orders
WHERE
    customer_id IN (1, 2)
GROUP BY
    customer_id,
    YEAR (order_date)
ORDER BY
    customer_id; 

--------------------------------------
-- another example
-- the number of customers by state and city
--------------------------------------
SELECT
    city,
    state,
    COUNT (customer_id) customer_count
FROM
    sales.customers
GROUP BY
    state,
    city
ORDER BY
    city,
    state;

--------------------------------------
-- another example with min and max
--------------------------------------
SELECT
    brand_name,
    MIN (list_price) min_price,
    MAX (list_price) max_price,
	AVG (list_price) avg_price
FROM
    production.products p
INNER JOIN production.brands b ON b.brand_id = p.brand_id
WHERE
    model_year = 2018
GROUP BY
    brand_name
ORDER BY
    brand_name;

--------------------------------------
-- anoter example with avg
--------------------------------------
SELECT
    brand_name,
    AVG (list_price) avg_price
FROM
    production.products p
INNER JOIN production.brands b ON b.brand_id = p.brand_id
WHERE
    model_year = 2018
GROUP BY
    brand_name
ORDER BY
    brand_name;

--------------------------------------
-- another example with sum
--------------------------------------
select * from sales.order_items
SELECT
    order_id,
    SUM (
        quantity * list_price * (1 - discount)
    ) net_value
FROM
    sales.order_items
--WHERE order_id = 1
GROUP BY
    order_id;

--------------------------------------
-- with having condition 조건
--------------------------------------
--find the customers who placed at least two orders per year
SELECT
    customer_id,
    YEAR (order_date),
    COUNT (order_id) order_count
FROM
    sales.orders
-- WHERE
GROUP BY
    customer_id,
    YEAR (order_date)
HAVING -- 계산 함수 (aggregate function) 를 통해 얻어진 결과 값에 대한 추가 조건 정의
    COUNT (order_id) > 2
ORDER BY
    customer_id;

--------------------------------------
-- sales orders whose net values are greater than 20,000
--------------------------------------
SELECT
    order_id,
    SUM (
        quantity * list_price * (1 - discount)
    ) net_value
FROM
    sales.order_items
GROUP BY
    order_id
HAVING
    SUM (
        quantity * list_price * (1 - discount)
    ) > 25000
ORDER BY
    net_value;

--------------------------------------
-- category which has the maximum list price greater than 4,000 or the minimum list price less than 500
--------------------------------------
SELECT
    category_id,
    MAX (list_price) max_list_price,
    MIN (list_price) min_list_price
FROM
    production.products
GROUP BY
    category_id
HAVING
    MAX (list_price) > 4000 OR MIN (list_price) < 500;

--------------------------------------
-- product categories whose average list prices are between 500 and 1,000
--------------------------------------
select distinct category_id FROM
    production.products

SELECT
    category_id,
    AVG (list_price) avg_list_price
FROM
    production.products
GROUP BY
    category_id
HAVING
    AVG (list_price) BETWEEN 500 AND 1000;

/************************************************
Assignment 5

1. store 가 확보 하고 있는 stock 정보를 확인하는데 product 별로 총 몇 개를 가지고 있는 지를 조회한다. (store name 도 보여 주어야 한다) 추가 적인 조건은 가게별, product 별 합이 10 개 미만인 레코드만을 조회 한다.

*************************************************/
select s.store_name, p.product_name,  sum(st.quantity) sumOfStock
from sales.stores s 
inner join
production.stocks st
on s.store_id = st.store_id
inner join production.products p
on p.product_id = st.product_id
group by s.store_name, p.product_name
having sum(st.quantity) < 10
order by s.store_name asc

