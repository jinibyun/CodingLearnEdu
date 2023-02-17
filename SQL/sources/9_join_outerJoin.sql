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
