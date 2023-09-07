/*********************************
control statement : 조건문, 반복문
*********************************/
-- 제어문을 하기에 앞서 잠시 SQL 의 변수에 대해 실습을 한다.

--------------------------------------
-- Variable
--------------------------------------
-- declaring single
DECLARE @model_year SMALLINT; -- 변수 선언 키워드  . @: 로컬 변수

-- declaring multiple
DECLARE @model_year SMALLINT, 
        @product_name VARCHAR(MAX);

-- assinging
SET @model_year = 2018;
SELECT @model_year

-- apply variable to query
DECLARE @model_year SMALLINT;

SET @model_year = 2017;

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

-- 복잡한 프로세스

SET NOCOUNT OFF; -- 기본 값

--------------------------------------
-- selecting a record into a variable
-- set 을 사용하지 않고도, 직접 query 결과 값을 변수에 대입
--------------------------------------
DECLARE 
    @product_name VARCHAR(MAX), -- 8000
    @list_price DECIMAL(10,2);

SELECT 
    @product_name = product_name,
    @list_price = list_price
FROM
    production.products
WHERE
    product_id = 100;
--result
SELECT @product_name , @list_price ;

--------------------------------------
-- IF Statement
--------------------------------------
-- BEGIN -- END Statement

BEGIN -- block
    DECLARE @sales INT; -- statement

    SELECT 
        @sales = SUM(list_price * quantity)
    FROM
        sales.order_items i
        INNER JOIN sales.orders o ON o.order_id = i.order_id
    WHERE
        YEAR(order_date) = 2018;

    SELECT @sales;

    IF @sales > 1000000
	begin
	    PRINT 'Great! The sales amount in 2018 is greater than 1,000,000';
	end
	else
	begin
	    PRINT 'Test';
	end
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
    DECLARE @x INT = 10, -- 선언과 초기화 가능
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
-- While Statement 반복문. (For 구문은 없음)
--------------------------------------
DECLARE @counter INT = 1;

WHILE @counter <= 5
BEGIN
    PRINT @counter;
    SET @counter += 1;
END

--------------------------------------
-- with "break" : while 구문을 벗어 난다.
--------------------------------------
DECLARE @counter INT = 0;

WHILE @counter <= 5
BEGIN
    SET @counter = @counter + 1;
    IF @counter = 3 -- == 는 없음
	Begin
        BREAK; -- while loop 을 벗어남
	End
    PRINT @counter;
END


--------------------------------------
-- with "continue": continue 밑에 있는 로직을 따지지 않고, 바로 while 구문의 조건으로 이동한다.
--------------------------------------
DECLARE @counter INT = 0;

WHILE @counter < 5
BEGIN
    SET @counter = @counter + 1;
    IF @counter = 3
        CONTINUE; -- while loop 을 벗어나지 않고, 다시 while 조건 구문으로 	
    PRINT @counter;
END
