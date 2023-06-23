/*********************************
where condition
*********************************/
--------------------------------------
-- using equality
--------------------------------------
SELECT
    product_id,
    product_name,
    category_id,
    model_year,
    list_price
FROM
    production.products
WHERE
    category_id = 1
ORDER BY
    list_price DESC;
--------------------------------------
-- using "and" operator
--------------------------------------
SELECT
    product_id,
    product_name,
    category_id,
    model_year,
    list_price
FROM
    production.products
WHERE
    category_id = 1 AND model_year = 2018
ORDER BY
    list_price DESC;

--------------------------------------
-- using comparison operator
--------------------------------------
SELECT
    product_id,
    product_name,
    category_id,
    model_year,
    list_price
FROM
    production.products
WHERE
    list_price > 300 AND model_year = 2018
ORDER BY
    list_price DESC;

--------------------------------------
-- using "or" operator
--------------------------------------
SELECT
    product_id,
    product_name,
    category_id,
    model_year,
    list_price
FROM
    production.products
WHERE
    list_price > 3000 OR model_year = 2018
ORDER BY
    list_price DESC;

--------------------------------------
-- between 
--------------------------------------
SELECT
    product_id,
    product_name,
    category_id,
    model_year,
    list_price
FROM
    production.products
WHERE
    list_price BETWEEN 1899.00 AND 1999.99
ORDER BY
    list_price DESC;

--------------------------------------
-- in keyword
--------------------------------------
SELECT
    product_id,
    product_name,
    category_id,
    model_year,
    list_price
FROM
    production.products
WHERE
    list_price IN (299.99, 369.99, 489.99)
ORDER BY
    list_price DESC;

--------------------------------------
-- in keyword with subquery
--------------------------------------
SELECT
    product_name,
    list_price
FROM
    production.products
WHERE
    product_id IN (
        SELECT
            product_id
        FROM
            production.stocks
        WHERE
            store_id = 1 AND quantity >= 30
    )
ORDER BY
    product_name;

--------------------------------------
-- like pattern matching
--------------------------------------
-- 1
SELECT
    product_id,
    product_name,
    category_id,
    model_year,
    list_price
FROM
    production.products
WHERE
    product_name LIKE '%Cruiser%'
ORDER BY
    list_price;

--2
SELECT
    customer_id,
    first_name,
    last_name
FROM
    sales.customers
WHERE
    last_name LIKE 'z%'
ORDER BY
    first_name;


--3. where the first character in the last name is Y or Z
SELECT
    customer_id,
    first_name,
    last_name
FROM
    sales.customers
WHERE
    last_name LIKE '[YZ]%'
ORDER BY
    last_name;


-- 4. range A through C
SELECT
    customer_id,
    first_name,
    last_name
FROM
    sales.customers
WHERE
    last_name LIKE '[A-C]%'
ORDER BY
    first_name;


--5. the last name is not the letter in the range A through X
SELECT
    customer_id,
    first_name,
    last_name
FROM
    sales.customers
WHERE
    last_name LIKE '[^A-X]%'
ORDER BY
    last_name;


--6. not like
SELECT
    customer_id,
    first_name,
    last_name
FROM
    sales.customers
WHERE
    first_name NOT LIKE 'A%'
ORDER BY
    first_name;

/************************************************
Assignment 2

위에서 적용한 sub query 를 이용하여 다음 로직을 완성시킬 query 작성하기

우선 sales.customers (고객 테이블) 로 부터 레코드를 조회하는데, state 는  'NY" 에 살고 있어야 하며, phone 의 정보가 있어야 하고 동시에 이메일은 gmail 혹은 hotmail 이 아닌 고객 들의 정보를 조회 한다.

그 후에 이 고객들의 customer_id (아이디) 정보를 바탕으로 sales.orders (주문 정보) 의 모든 칼럼을 조회한다.  추가 조건은 2017 년에 주문한 정보를 가져오고 이 주문한 날짜 칼럼 (order_date) 를 기준으로 올림차순으로 정렬한다. (ascending)
*************************************************/
