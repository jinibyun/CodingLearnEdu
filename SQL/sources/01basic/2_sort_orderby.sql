/*********************************
Sorting (정렬)
*********************************/

-- Ascending, Descending  */
SELECT first_name
    , last_name
FROM sales.customers
ORDER BY first_name DESC -- ....

--------------------------------------
-- Multitple (다중 정렬)
--------------------------------------
SELECT city
    , first_name
    , last_name
FROM sales.customers
ORDER BY city --ASC
    , first_name --ASC

--------------------------------------
-- One for ASC, other for DESC
--------------------------------------
SELECT city
    , first_name
    , last_name
FROM sales.customers
ORDER BY city DESC , first_name ASC;

--------------------------------------
-- order by function result
--------------------------------------
SELECT first_name
    , last_name
FROM sales.customers
ORDER BY LEN(first_name) DESC; -- 문자열의 길이를 return


