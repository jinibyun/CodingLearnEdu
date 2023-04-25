/*********************************
view
*********************************/
/*-------------------------------
save "query" (not result)
NOTE: they do "not" improve the underlying query performance.

advantages
1. security 2.simplicity 3.consistency
--------------------------------*/

CREATE VIEW sales.product_info
AS
SELECT
    product_name, 
    brand_name, 
    list_price
FROM
    production.products p
INNER JOIN production.brands b 
        ON b.brand_id = p.brand_id;

-- test
SELECT * FROM sales.product_info;


--------------------------------------
-- anoter example
--------------------------------------
CREATE VIEW sales.daily_sales ( -- 별도로 칼럼 이름을 지정할 수도 있다.
    year,
    month,
    day,
    customer_name,
    product_id,
    product_name,
    sales
)
AS
SELECT
    year(order_date),
    month(order_date),
    day(order_date),
    concat(
        first_name,
        ' ',
        last_name
    ),
    p.product_id,
    product_name,
    quantity * i.list_price
FROM
    sales.orders AS o
    INNER JOIN
        sales.order_items AS i
    ON o.order_id = i.order_id
    INNER JOIN
        production.products AS p
    ON p.product_id = i.product_id
    INNER JOIN sales.customers AS c
    ON c.customer_id = o.customer_id;


-- test
SELECT 
    * 
FROM 
    sales.daily_sales
ORDER BY 
    year, 
    month, 
    day, 
    customer_name;

--------------------------------------
-- aggregate functions 적용된 결과 셋을 view 와 함께 적용
--------------------------------------
CREATE VIEW sales.staff_sales (
        first_name, 
        last_name,
        year, 
        amount
)
AS 
    SELECT 
        first_name,
        last_name,
        YEAR(order_date),
        SUM(list_price * quantity) amount
    FROM
        sales.order_items i
    INNER JOIN sales.orders o
        ON i.order_id = o.order_id
    INNER JOIN sales.staffs s
        ON s.staff_id = o.staff_id
    GROUP BY 
        first_name, 
        last_name, 
        YEAR(order_date);


-- test
select * from sales.staff_sales

--------------------------------------
-- Drop View
--------------------------------------
DROP VIEW IF EXISTS sales.daily_sales;

-- prep
CREATE VIEW sales.product_catalog
AS
SELECT 
    product_name, 
    category_name, 
	brand_name,
    list_price
FROM 
    production.products p
INNER JOIN production.categories c 
    ON c.category_id = p.category_id
INNER JOIN production.brands b
	ON b.brand_id = p.brand_id;

-- multiple deletion
DROP VIEW IF EXISTS 
    sales.staff_sales, 
    sales.product_catalogs;


/* -------- normalization and de-normalization(정규화와 비정규화) -------- */
-- ref: https://owlyr.tistory.com/20

--------------------------------------
-- List View infromation from system table
--------------------------------------
-- TIP: 하나의 utility 처럼 알고 있으면 편함
-- ref: https://learn.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-objects-transact-sql?view=sql-server-ver16
SELECT 
	OBJECT_SCHEMA_NAME(o.object_id) schema_name,
	o.name
FROM
	sys.objects o
WHERE
	o.type = 'V';

-- TIP: view 구문을 알아내기 위한 방법 중 많이 사용
sp_helptext 'sales.staff_sales'

--------------------------------------
-- Indexed View == Materialized View
-- 결과 셋 저장
--------------------------------------
/*-------------------------------
-- stores "data" (not just query) physically like a table hence may provide some the performance benefit if they are used appropriately
-- NOTE: consider using only for "in"freqent change of data
-- When changing the structure of the underlying tables, then, you must "drop" indexed view first.
-- requires all referenced objects in the "same" database
-- When the data (not structure) of the underlying tables changes, the data in the indexed view is also "automatically" updated
    -- When you write to underlying table, SQL server has to write to the index of the view. Therefore, you "should" only create an indexed view against the tables that have in-frequent data updates
--------------------------------*/

CREATE VIEW production.product_master
WITH SCHEMABINDING -- binding to underlying tables (주의: index 를 생성하기 전까지는 아직 physical 하게 결과셋을 저장했다고 볼 수 없다. 아래의 IO 결과 참조)
AS 
SELECT
    product_id,
    product_name,
    model_year,
    list_price,
    brand_name,
    category_name
FROM
    production.products p
INNER JOIN production.brands b 
    ON b.brand_id = p.brand_id
INNER JOIN production.categories c 
    ON c.category_id = p.category_id;


-- test
SET STATISTICS IO ON  -- 이 옵션을 켜고 query 를 던지면, query 에 대한 I/O 상황을 체크할 수 있음
GO

SELECT 
    * 
FROM
    production.product_master
ORDER BY
    product_name;
GO 

/*-------------------------------
-- I/O 확인
-- Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'products'. Scan count 1, logical reads 5, physical reads 1, read-ahead reads 3, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'categories'. Scan count 1, logical reads 2, physical reads 1, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'brands'. Scan count 1, logical reads 2, physical reads 1, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

-- 위에서 알 수 있듯이, view 에 대한 I/O 는 products, categories 그리고 brands 라는 테이블을 조회한다.
-- 즉 아직은 view 자체가 일반 view 를 조회하는 것처럼 관련 있는 table 들을 scan 하고 있다.
--------------------------------*/

-- 다음과 같이 index 를 적용할 때에 "비로소" physical 하게 결과셋을 저장한다.
-- apply index to the view
CREATE UNIQUE CLUSTERED INDEX 
    ucidx_product_id 
ON production.product_master(product_id);

-- test
SELECT 
    * 
FROM
    production.product_master
    WITH (NOEXPAND) -- 주의: Enterprise Edition 이 아닌 버전에서는 사용해야 함
ORDER BY
    product_name;
GO 

/*-------------------------------
-- I/O 확인
-- Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'product_master'. Scan count 1, logical reads 6, physical reads 1, read-ahead reads 11, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

-- 위에서 알 수 있듯이, underlying table 에 대한 scanning 을 하지 않고, 바로 indexed view 로부터 값을 가져온다.
--------------------------------*/