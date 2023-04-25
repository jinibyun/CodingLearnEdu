/*********************************
Sorting
*********************************/

-- Ascending, Descending  */
SELECT first_name
    , last_name
FROM sales.customers
ORDER BY first_name DESC

--------------------------------------
-- Multitple
--------------------------------------
SELECT city
    , first_name
    , last_name
FROM sales.customers
ORDER BY city
    , first_name

--------------------------------------
-- One for ASC, other for DESC
--------------------------------------
SELECT city
    , first_name
    , last_name
FROM sales.customers
ORDER BY city DESC
    , first_name ASC;

--------------------------------------
-- order by function result
--------------------------------------
SELECT first_name
    , last_name
FROM sales.customers
ORDER BY LEN(first_name) DESC;

-- by position
SELECT first_name
    , last_name
FROM sales.customers
ORDER BY 1, 2;
