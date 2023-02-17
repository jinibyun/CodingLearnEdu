/*********************************
control statement
*********************************/
-- 제어문을 하기에 앞서 잠시 SQL 의 변수에 대해 실습을 한다.

--------------------------------------
-- Variable
--------------------------------------
-- declaring single
DECLARE @model_year AS SMALLINT;

-- declaring multiple
DECLARE @model_year SMALLINT, 
        @product_name VARCHAR(MAX);


-- assinging
SET @model_year = 2018;


-- apply variable to query
DECLARE @model_year SMALLINT;

SET @model_year = 2018;

SELECT
    product_name,
    model_year,
    list_price 
FROM 
    production.products
WHERE 
    model_year = @model_year
ORDER BY
    product_name;

--------------------------------------
-- storing query result to a variable
--------------------------------------
DECLARE @product_count INT;

SET @product_count = (
    SELECT 
        COUNT(*) 
    FROM 
        production.products 
);

-- result
SELECT @product_count;
SET NOCOUNT ON;    --  별도의 쿼리에서 제공하는 count 값을 off 할 때 사용

--------------------------------------
-- selecting a record into a variable
--------------------------------------
DECLARE 
    @product_name VARCHAR(MAX),
    @list_price DECIMAL(10,2);

SELECT 
    @product_name = product_name,
    @list_price = list_price
FROM
    production.products
WHERE
    product_id = 100;
--result
SELECT 
    @product_name AS product_name, 
    @list_price AS list_price;

--------------------------------------
-- IF Statement
--------------------------------------
BEGIN
    DECLARE @sales INT;

    SELECT 
        @sales = SUM(list_price * quantity)
    FROM
        sales.order_items i
        INNER JOIN sales.orders o ON o.order_id = i.order_id
    WHERE
        YEAR(order_date) = 2018;

    SELECT @sales;

    IF @sales > 1000000
    BEGIN
        PRINT 'Great! The sales amount in 2018 is greater than 1,000,000';
    END
END

--------------------------------------
-- another
--------------------------------------
BEGIN
    DECLARE @sales INT;

    SELECT 
        @sales = SUM(list_price * quantity)
    FROM
        sales.order_items i
        INNER JOIN sales.orders o ON o.order_id = i.order_id
    WHERE
        YEAR(order_date) = 2017;

    SELECT @sales;

    IF @sales > 10000000
    BEGIN
        PRINT 'Great! The sales amount in 2018 is greater than 10,000,000';
    END
    ELSE
    BEGIN
        PRINT 'Sales amount in 2017 did not reach 10,000,000';
    END
END

--------------------------------------
-- nested
--------------------------------------
BEGIN
    DECLARE @x INT = 10,
            @y INT = 20;

    IF (@x > 0)
    BEGIN
        IF (@x < @y)
            PRINT 'x > 0 and x < y';
        ELSE
            PRINT 'x > 0 and x >= y';
    END			
END


--------------------------------------
-- While Statement 
--------------------------------------
DECLARE @counter INT = 1;

WHILE @counter <= 5
BEGIN
    PRINT @counter;
    SET @counter = @counter + 1;
END

--------------------------------------
-- with break
--------------------------------------
DECLARE @counter INT = 0;

WHILE @counter <= 5
BEGIN
    SET @counter = @counter + 1;
    IF @counter = 4
        BREAK;
    PRINT @counter;
END

--------------------------------------
-- with continue
--------------------------------------
DECLARE @counter INT = 0;

WHILE @counter < 5
BEGIN
    SET @counter = @counter + 1;
    IF @counter = 3
        CONTINUE;	
    PRINT @counter;
END
