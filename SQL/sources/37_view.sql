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
-- anoter 
--------------------------------------
CREATE OR ALTER sales.daily_sales (
    year,
    month,
    day,
    customer_name,
    product_id,
    product_name
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
    y, 
    m, 
    d, 
    customer_name;

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

--------------------------------------
-- Indexed View == Materialized View
--------------------------------------
/*-------------------------------
-- stores "data" (not just query) physically like a table hence may provide some the performance benefit if they are used appropriately
-- NOTE: consider using only for "in"freqent change of data
-- When changing the structure of the underlying tables, then, you must "drop" indexed view first.
-- requires all referenced objects in the "same" database
-- When the data (not structure) of the underlying tables changes, the data in the indexed view is also "automatically" updated
    -- When you write to underlying table, SQL server has to write to the index of the view. Therefore, you "should" only create an indexed view against the tables that have in-frequent data updates
--------------------------------*/

CREATE VIEW product_master
WITH SCHEMABINDING -- binding to underlying tables
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
    WITH (NOEXPAND) -- Enterprise Edition 이 아닌 버전에서는 사용해야 함
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
--------------------------------*/

-- apply index to the view
CREATE UNIQUE CLUSTERED INDEX 
    ucidx_product_id 
ON production.product_master(product_id);

-- test
SELECT 
    * 
FROM
    production.product_master
    WITH (NOEXPAND) -- Enterprise Edition 이 아닌 버전에서는 사용해야 함
ORDER BY
    product_name;
GO 

/*-------------------------------
-- I/O 확인
-- Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'product_master'. Scan count 1, logical reads 6, physical reads 1, read-ahead reads 11, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

-- 위에서 알 수 있듯이, underlying table 에 대한 scanning 을 하지 않고, 바로 indexed view 로부터 값을 가져온다.
--------------------------------*/