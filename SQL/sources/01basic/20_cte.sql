/*********************************
CTE: common table expression
*********************************/

/*-------------------------------
 "temporary named result set" that available temporarily in the execution scope of a statement such as SELECT, INSERT, UPDATE, DELETE, or MERGE
 NOTE: very similar to subquery. but it is more readable
--------------------------------*/

select t1.*
from
(
	SELECT    -- it is like "subquery"
			first_name + ' ' + last_name 'name', 
			SUM(quantity * list_price * (1 - discount)) 'sumOfX',
			YEAR(order_date) 'orderYear'
		FROM    
			sales.orders o
		INNER JOIN sales.order_items i ON i.order_id = o.order_id
		INNER JOIN sales.staffs s ON s.staff_id = o.staff_id
		GROUP BY 
			first_name + ' ' + last_name,
			year(order_date)
) t1
where t1.name like 'k%'

--------------------------------------
-- the sales amounts by sales staffs in 2018
--------------------------------------
WITH cte_sales_amounts (staff, sales, year) AS (
    SELECT    -- it is like "subquery"
        first_name + ' ' + last_name, 
        SUM(quantity * list_price * (1 - discount)),
        YEAR(order_date)
    FROM    
        sales.orders o
    INNER JOIN sales.order_items i ON i.order_id = o.order_id
    INNER JOIN sales.staffs s ON s.staff_id = o.staff_id
    GROUP BY 
        first_name + ' ' + last_name,
        year(order_date)
)

SELECT
    staff, 
    sales
FROM 
    cte_sales_amounts
WHERE
    year = 2018;

--------------------------------------
-- average number of sales orders in 2018 for all sales staffs
--------------------------------------
WITH cte_sales AS ( -- can skip column list
    SELECT 
        staff_id, 
        COUNT(*) order_count  
    FROM
        sales.orders
    WHERE 
        YEAR(order_date) = 2018
    GROUP BY
        staff_id

)
SELECT
    AVG(order_count) average_orders_by_staff
FROM 
    cte_sales;

--------------------------------------
-- multiple CTE
--------------------------------------
WITH cte_category_counts (
    category_id, 
    category_name, 
    product_count
)
AS (
    SELECT 
        c.category_id, 
        c.category_name, 
        COUNT(p.product_id)
    FROM 
        production.products p
        INNER JOIN production.categories c 
            ON c.category_id = p.category_id
    GROUP BY 
        c.category_id, 
        c.category_name
),
cte_category_sales(category_id, sales) AS (
    SELECT    
        p.category_id, 
        SUM(i.quantity * i.list_price * (1 - i.discount))
    FROM    
        sales.order_items i
        INNER JOIN production.products p 
            ON p.product_id = i.product_id
        INNER JOIN sales.orders o 
            ON o.order_id = i.order_id
    WHERE order_status = 4 -- completed
    GROUP BY 
        p.category_id
) 

SELECT 
    c.category_id, 
    c.category_name, 
    c.product_count, 
    s.sales
FROM
    cte_category_counts c
    INNER JOIN cte_category_sales s 
        ON s.category_id = c.category_id
ORDER BY 
    c.category_name;


/************************************************
Assignment 7

Assignment 2 (6_filtering_where.sql file) 에서 작성한 sub query 구문을 위의 common table expression 구문을 이용하여 재 구성하기

*************************************************/