/*********************************
generate multiple grouping sets
*********************************/

-- prep  (select * into "new table" from .....) : 임시로 table 을 만드는 방법 중 하나 (물리적 생성). 용도: 레코드셋을 임시 저장하거나, 중요 데이타를 변경하기에 앞서 일종의 간단한 backup 을 해두는 방법

select * 
into sales.stores_20230630
from sales.stores

select * from sales.stores_20230630







SELECT
    b.brand_name AS brand,
    c.category_name AS category,
    p.model_year,
    round( -- 반올림 함수
        SUM (
            quantity * i.list_price * (1 - discount)
        ),
        0
    ) 
	sales INTO sales.sales_summary -- new table 을 생성해서 결과 셋을 저장
FROM
    sales.order_items i
INNER JOIN production.products p ON p.product_id = i.product_id
INNER JOIN production.brands b ON b.brand_id = p.brand_id
INNER JOIN production.categories c ON c.category_id = p.category_id
GROUP BY
    b.brand_name,
    c.category_name,
    p.model_year
ORDER BY
    b.brand_name,
    c.category_name,
    p.model_year;

-- confirm: the sales amount data by brand and category
SELECT
	*
FROM
	sales.sales_summary
ORDER BY
	brand,
	category,
	model_year;


-- prep: union (레코드 결과 값을 물리적으로 합치는 것. 조건은 레코드를 구성하는 칼럼의 숫자가 같아야 한다.)

select order_id, customer_id from sales.orders where order_id < 5
union
select product_id, brand_id from production.products where list_price > 6000

--------------------------------------
-- grouping set - union all from several group by result
--------------------------------------
SELECT
	brand,
	category,
	SUM (sales) sales
FROM
	sales.sales_summary
GROUP BY
	GROUPING SETS ( -- it contains "union all"
		(brand, category),
		(brand),
		(category),
		()
	)
ORDER BY
	brand,
	category;
--------------------------------------
-- same result as above (grouping set 이라는 개념이 없어도 아래와 같은 구문으로 진행할 수 있다)
--------------------------------------
/*   
SELECT
    brand,
    category
	,
    SUM (sales) sales
FROM
    sales.sales_summary
GROUP BY
    brand,
    category
UNION ALL -- UNION ALL 은 UNION 과 비슷한데, 단 중복된 데이타도 함께 보여준다.
SELECT
    brand,
    NULL,
    SUM (sales) sales
FROM
    sales.sales_summary
GROUP BY
    brand
UNION ALL
SELECT
    NULL,
    category,
    SUM (sales) sales
FROM
    sales.sales_summary
GROUP BY
    category
UNION ALL
SELECT
    NULL,
    NULL,
    SUM (sales)
FROM
    sales.sales_summary
ORDER BY brand, category;

 */