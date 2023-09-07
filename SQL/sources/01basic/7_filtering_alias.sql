/*********************************
alias - 별칭 
*********************************/

--------------------------------------
-- column alias - heading
--------------------------------------
SELECT
	-- + 의 의미 : 문자열 결합
    -- last_name + ', ' + first_name AS full_name -- alias
	-- last_name + ', ' + first_name full_name -- alias
	last_name + ', ' + first_name 'full_name' -- alias
FROM
    sales.customers
ORDER BY
    first_name;

--------------------------------------
-- same expression. use heading to order
--------------------------------------
-- 1
SELECT
    category_name 'Product Category'
FROM
    production.categories
ORDER BY
    category_name;  

-- 2
SELECT
    category_name 'Product Category'
FROM
    production.categories
ORDER BY
    'Product Category';

--------------------------------------
-- table alias - join
--------------------------------------
SELECT
    c.customer_id,
    first_name,
    last_name,
    order_id
FROM
    sales.customers c
INNER JOIN sales.orders o ON o.customer_id = c.customer_id;
