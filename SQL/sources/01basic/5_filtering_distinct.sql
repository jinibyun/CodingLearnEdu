/*********************************
distinct
*********************************/

SELECT city
FROM sales.customers
ORDER BY city;

SELECT DISTINCT city
FROM sales.customers
ORDER BY city;

--------------------------------------
-- distinct multiple
--------------------------------------
SELECT DISTINCT city, STATE, first_name
FROM sales.customers
ORDER BY city, STATE;

-- 위의 결과는 다음의 group by 구문과 일치
--1
SELECT city
    , STATE
    , zip_code
FROM sales.customers
GROUP BY city
    , STATE
    , zip_code
ORDER BY city
    , STATE
    , zip_code

--2
SELECT DISTINCT city
    , STATE
    , zip_code
FROM sales.customers;
