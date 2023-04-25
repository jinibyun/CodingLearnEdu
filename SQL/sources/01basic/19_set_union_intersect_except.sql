/*********************************
union, intersect, except
*********************************/

-- result
SELECT
    COUNT (*) -- 10  
FROM
    sales.staffs;
     
SELECT
    COUNT (*) -- 1445
FROM
    sales.customers;

--------------------------------------
-- union and union all
--------------------------------------
SELECT
    first_name,
    last_name
FROM
    sales.staffs
UNION ALL -- compare with UNION
SELECT
    first_name,
    last_name
FROM
    sales.customers;
-- 1455


--------------------------------------
-- intersect
--------------------------------------
SELECT
    city
FROM
    sales.customers
INTERSECT
SELECT
    city
FROM
    sales.stores
ORDER BY
    city;


--------------------------------------
-- except
--  products that have no sales
--------------------------------------
SELECT
    product_id
FROM
    production.products
EXCEPT
SELECT
    product_id
FROM
    sales.order_items;
