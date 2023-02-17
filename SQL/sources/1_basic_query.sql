/*********************************
Basic Query
*********************************/

--------------------------------------
-- single 
--------------------------------------
SELECT first_name
    , last_name
FROM sales.customers;

--------------------------------------
-- multiple
--------------------------------------
SELECT first_name
    , last_name
    , email
FROM sales.customers;

--------------------------------------
-- all
--------------------------------------
SELECT *
FROM sales.customers;

--------------------------------------
-- where
--------------------------------------
SELECT *
FROM sales.customers
WHERE STATE = 'CA';

--------------------------------------
-- where and order by
--------------------------------------
SELECT *
FROM sales.customers
WHERE STATE = 'CA'
ORDER BY first_name;

--------------------------------------
-- grouping
--------------------------------------
SELECT city
    , COUNT(*)
FROM sales.customers
WHERE STATE = 'CA'
GROUP BY city
ORDER BY city;

--------------------------------------
-- grouping and condition
--------------------------------------
SELECT city
    , COUNT(*)
FROM sales.customers
WHERE STATE = 'CA'
GROUP BY city
HAVING COUNT(*) > 10
ORDER BY city;
