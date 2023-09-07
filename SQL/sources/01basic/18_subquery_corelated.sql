/*********************************
correlated subquery (상호 연관 쿼리)
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


/************************************************
Assignment 6

sales.order_items (주문 상세 table) 에서 주문별 최고 가격에 해당하는 제품과 가격을 얻어 오는데, 이때 이 최고 가격에 해당하는 제품의 discount 를 (각각 다르게 적용돼었음) 알고 싶을 때 작성할 수 있는 corelated subquery

*************************************************/
select * from sales.order_items

SELECT
	order_id,
	product_id,
	list_price as 'MaxPrice',
    discount
FROM
    sales.order_items s1
WHERE
    list_price IN (
        SELECT  
			-- .order_id,
            MAX (s2.list_price)
        FROM
            sales.order_items s2
        WHERE
           s2.order_id = s1.order_id
        GROUP BY
            s2.order_id
    )
ORDER BY
    s1.order_id,
    s1.product_id;