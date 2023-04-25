/*********************************
correlated subquery
*********************************/

/*-------------------------------
correlated subquery is a subquery that uses the values of the outer query.
Because of this dependency, a correlated subquery cannot be executed independently as a simple subquery.
--------------------------------*/

--------------------------------------
-- products whose list price is equal to the highest list price of the products within the same category
--------------------------------------
SELECT
    product_name,
    list_price,
    category_id
FROM
    production.products p1
WHERE
    list_price IN (
        SELECT  -- the correlated subquery is executed once for each product evaluated by the outer query
            MAX (p2.list_price)
        FROM
            production.products p2
        WHERE
            p2.category_id = p1.category_id
        GROUP BY
            p2.category_id
    )
ORDER BY
    category_id,
    product_name;


