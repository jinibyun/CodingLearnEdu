/*********************************
union, intersect, except

join 구문을 편하게 사용하기 위한 연산자
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

-- 중복된 데이타 검색
select t1.first_name, t1.last_name, count(*)
from 
	( 
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
			sales.customers
	) t1
group by t1.first_name, t1.last_name
having count(*) > 1


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
