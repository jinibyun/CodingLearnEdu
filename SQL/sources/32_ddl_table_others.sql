/*********************************
drop table, rename table, truncate table and temporary table
*********************************/
-- NOTE: always good idea put "IF EXISTS"
DROP TABLE IF EXISTS sales.revenues;

--------------------------------------
-- NOTE: Think about PK and FK relationship before deleting
--------------------------------------

-- prep
-- 1
CREATE TABLE procurement.supplier_groups (
    group_id INT IDENTITY PRIMARY KEY,
    group_name VARCHAR (50) NOT NULL
);

-- 2
CREATE TABLE procurement.suppliers (
    supplier_id INT IDENTITY PRIMARY KEY,
    supplier_name VARCHAR (50) NOT NULL,
    group_id INT NOT NULL,
    FOREIGN KEY (group_id) REFERENCES procurement.supplier_groups (group_id)
);

-- 3. 
DROP TABLE procurement.supplier_groups;

--4. Error Message
-- Could not drop object 'procurement.supplier_groups' because it is referenced by a FOREIGN KEY constraint.
-- Total execution time: 00:00:00.002

--------------------------------------
-- truncate table
--------------------------------------
-- difference between identity and truncate table

--------------------------------------
-- rename table
--------------------------------------

-- prep
CREATE TABLE sales.contr (
    contract_no INT IDENTITY PRIMARY KEY,
    start_date DATE NOT NULL,
    expired_date DATE,
    customer_id INT,
    amount DECIMAL (10, 2)
); 

-- error
EXEC sp_rename 'sales.contr', 'contracts';
-- Caution: Changing any part of an object name could break scripts and stored procedures.
-- Total execution time: 00:00:00.321

--------------------------------------
-- select into.. from
--------------------------------------

--------------------------------------
-- temporary table
--------------------------------------

/*-------------------------------
1. Datatype
2. #table_name 
    2.1 위의 select into 구문과 함께 사용할 수 있다.    
    2.2 create table 구문과 함께 사용할 수 있다
--------------------------------*/
-- 여기에서는 일단 위의 2 번 째 방법을 통해 알아본다.

--------------------------------------
-- 2.1 의 방법
--------------------------------------
SELECT
    product_name,
    list_price
INTO #trek_products --- temporary table
FROM
    production.products
WHERE
    brand_id = 9;

-- confirm
select * from #trek_products

--------------------------------------
-- 2.2 의 방법
--------------------------------------
CREATE TABLE #haro_products (
    product_name VARCHAR(MAX),
    list_price DEC(10,2)
);

--
INSERT INTO #haro_products
SELECT
    product_name,
    list_price
FROM 
    production.products
WHERE
    brand_id = 2;

-- confirm
SELECT
    *
FROM
    #haro_products;


--------------------------------------
-- global temp table: "accessible across connections"
--------------------------------------
CREATE TABLE ##heller_products (
    product_name VARCHAR(MAX),
    list_price DEC(10,2)
);

INSERT INTO ##heller_products
SELECT
    product_name,
    list_price
FROM 
    production.products
WHERE
    brand_id = 3;

/*-------------------------------
remove - 자동으로 없어짐. 다음과 같은 조건일 때.
SQL Server drops a temporary table automatically when you close the connection that created it.
SQL Server drops a global temporary table once the connection that created it closed 
and the queries against this table from other connections completes.

수동으로 바로 없애려면 drop table 구문으로 진행할 수 있음
--------------------------------*/