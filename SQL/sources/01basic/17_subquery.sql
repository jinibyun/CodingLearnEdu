/*********************************
subquery
*********************************/

--------------------------------------
-- sales orders of the customers located in New York
--------------------------------------
SELECT
    order_id,
    order_date,
    customer_id
FROM
    sales.orders
WHERE
    customer_id IN (
        SELECT
            customer_id
        FROM
            sales.customers
        WHERE
            city = 'New York'
    )
ORDER BY
    order_date DESC;

--------------------------------------
-- another example
--------------------------------------
SELECT
    product_name,
    list_price
FROM
    production.products
WHERE
    list_price > (
        SELECT
            AVG (list_price)
        FROM
            production.products
        WHERE
            brand_id IN (
                SELECT
                    brand_id
                FROM
                    production.brands
                WHERE
                    brand_name = 'Strider'
                OR brand_name = 'Trek'
            )
    )
ORDER BY
    list_price;

--------------------------------------
-- in place of an expression
--------------------------------------
SELECT
    order_id,
    order_date,
    (
        SELECT
            MAX (list_price)
        FROM
            sales.order_items i
        WHERE
            i.order_id = o.order_id
    ) AS max_list_price
FROM
    sales.orders o
order by order_date desc;

-------------------------------------- 
-- with "any" operator 
-- "any" operator returns TRUE if one of a comparison pair (scalar_expression, vi) evaluates to TRUE; otherwise, it returns FALSE
-- finds the products whose list prices are greater than or equal to the average list price
--------------------------------------
SELECT
    product_name,
    list_price
FROM
    production.products
WHERE
    list_price >= ANY (
        SELECT
            AVG (list_price)
        FROM
            production.products
        GROUP BY
            brand_id
    )

--------------------------------------
-- with "all" : returns TRUE if all comparison pairs (scalar_expression, vi) evaluate to TRUE; otherwise, it returns FALSE  */
-- products whose list price is greater than or equal to the average list price
--------------------------------------
SELECT
    product_name,
    list_price
FROM
    production.products
WHERE
    list_price >= ALL (
        SELECT
            AVG (list_price)
        FROM
            production.products
        GROUP BY
            brand_id
    )

--------------------------------------
-- with "exist" returns TRUE if the subquery return results; otherwise, it returns FALSE */
-- finds the customers who bought products in 2017
--------------------------------------
SELECT
    customer_id,
    first_name,
    last_name,
    city
FROM
    sales.customers c
WHERE
    EXISTS (
        SELECT
            customer_id
        FROM
            sales.orders o
        WHERE
            o.customer_id = c.customer_id
        AND YEAR (order_date) = 2017
    )
ORDER BY
    first_name,
    last_name;

--------------------------------------
-- opposite of exist
-- customers who did not buy any products in 2017
--------------------------------------
SELECT
    customer_id,
    first_name,
    last_name,
    city
FROM
    sales.customers c
WHERE
    NOT EXISTS (
        SELECT
            customer_id
        FROM
            sales.orders o
        WHERE
            o.customer_id = c.customer_id
        AND YEAR (order_date) = 2017
    )
ORDER BY
    first_name,
    last_name;


--------------------------------------
-- from clauses
--------------------------------------
SELECT 
   staff_id, 
   COUNT(order_id) order_count
FROM 
   sales.orders
GROUP BY 
   staff_id;

--------------------------------------
-- another  example
--------------------------------------
SELECT 
   AVG(order_count) average_order_count_by_staff
FROM
(
    SELECT 
	staff_id, 
        COUNT(order_id) order_count
    FROM 
	sales.orders
    GROUP BY 
	staff_id
) t; -- always have table alias

