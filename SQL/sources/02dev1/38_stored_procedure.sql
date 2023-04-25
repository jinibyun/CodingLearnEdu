/*********************************
stored procedures
*********************************/
/*
used to group one or more Transact-SQL statements into logical units

pros: fast
cons: hart to debug
*/

--------------------------------------
-- basic
--------------------------------------
CREATE PROCEDURE uspProductList
AS
BEGIN
    SELECT
        product_name,
        list_price
    FROM
        production.products
    ORDER BY 
        product_name;
END;

-- 생성 후에 /programmability 항목에서 확인할 수도 있고, view 의 구문을 확인했던 것처럼 sp_helptext 를 이용할 수도 있다.

-- test
Exec uspProductList

-- delete
DROP PROCEDURE uspProductList;

--------------------------------------
-- stored procedure with parameter (참고: View 는 Parameter 를 정의할 수 없다)
--------------------------------------
CREATE PROCEDURE uspFindProducts
    @min_list_price AS DECIMAL
-- 파라미터 변수도 마찬가지로 @을 붙여야 한다.
AS
BEGIN
    SELECT
        product_name,
        list_price
    FROM
        production.products
    WHERE
        list_price >= @min_list_price
    ORDER BY
        list_price;
END;


-- test
EXEC uspFindProducts 100;
EXEC uspFindProducts 200;


-- Another example (change above sp using alter statement)
ALTER PROCEDURE uspFindProducts(
    @min_list_price AS DECIMAL
    ,
    @max_list_price AS DECIMAL
)
AS
BEGIN
    SELECT
        product_name,
        list_price
    FROM
        production.products
    WHERE
        list_price >= @min_list_price AND
        list_price <= @max_list_price
    ORDER BY
        list_price;
END;

-- test
EXECUTE uspFindProducts 900, 1000;


--------------------------------------
-- stored procedure with optional parameter
--------------------------------------
ALTER PROCEDURE uspFindProducts(
    @min_list_price AS DECIMAL = 0
    ,
    @max_list_price AS DECIMAL = 999999
    ,
    @name AS VARCHAR(max)
)
AS
BEGIN
    SELECT
        product_name,
        list_price
    FROM
        production.products
    WHERE
        list_price >= @min_list_price AND
        list_price <= @max_list_price AND
        product_name LIKE '%' + @name + '%'
    ORDER BY
        list_price;
END;

--test
EXECUTE uspFindProducts @name = 'Trek';

EXECUTE uspFindProducts @min_list_price = 6000, @name = 'Trek';


--------------------------------------
-- stored procedure with optional parameter witn "null" value
-- 이유: 앞선 sp 에서 명확하게 max 값을 지정하고 있는데, 사용하는 입장에선 두 가지 기능을 가능하게 하려 한다.
-- 1. max 값을 입력하면 지정되어 있는 max 값을 비교
-- 2. max 값을 null 로 지정하면 지정되어 있는 max 값과 비교하지 않고 제한 없이 값을 리턴 
--------------------------------------

ALTER PROCEDURE uspFindProducts(
    @min_list_price AS DECIMAL = 0
    ,
    @max_list_price AS DECIMAL = NULL
    ,
    @name AS VARCHAR(max)
)
AS
BEGIN
    SELECT
        product_name,
        list_price
    FROM
        production.products
    WHERE
        list_price >= @min_list_price AND
        (@max_list_price IS NULL OR list_price <= @max_list_price) AND
        product_name LIKE '%' + @name + '%'
    ORDER BY
        list_price;
END;

-- test
EXECUTE uspFindProducts  @min_list_price = 500, @name = 'Haro';



--------------------------------------
-- stored procedure with variable
--------------------------------------
-- TIP: SQL 변수에 대해서는 앞서 학습했던 file - "36_control_statement.sql" 을 참조한다.

CREATE  PROC uspGetProductList(
    @model_year SMALLINT
)
AS
BEGIN
    DECLARE @product_list VARCHAR(MAX);

    SET @product_list = '';

    SELECT
        @product_list = @product_list + product_name 
                        + CHAR(10)
    FROM
        production.products
    WHERE
        model_year = @model_year
    ORDER BY 
        product_name;

    PRINT @product_list;
END;

--test
EXEC uspGetProductList 2018


--------------------------------------
-- stored procedure with output parameter
--------------------------------------
CREATE PROCEDURE uspFindProductByModel (
    @model_year SMALLINT,
    @product_count INT OUTPUT
) AS
BEGIN
    SELECT 
        product_name,
        list_price
    FROM
        production.products
    WHERE
        model_year = @model_year;

    SELECT @product_count = @@ROWCOUNT;
END;


-- test
DECLARE @count INT;

EXEC uspFindProductByModel
    @model_year = 2018,
    @product_count = @count OUTPUT;

SELECT @count AS 'Number of products found';


--------------------------------------
--stored procedure with TRY...CATCH
--------------------------------------
CREATE PROC usp_divide(
    @a decimal,
    @b decimal,
    @c decimal output
) AS
BEGIN
    BEGIN TRY
        SET @c = @a / @b;
    END TRY
    BEGIN CATCH
        SELECT  
            ERROR_NUMBER() AS ErrorNumber  
            ,ERROR_SEVERITY() AS ErrorSeverity  
            ,ERROR_STATE() AS ErrorState  
            ,ERROR_PROCEDURE() AS ErrorProcedure  
            ,ERROR_LINE() AS ErrorLine  
            ,ERROR_MESSAGE() AS ErrorMessage;  
    END CATCH
END;

-- test
DECLARE @r2 decimal;
EXEC usp_divide 10, 0, @r2 output;
PRINT @r2;



--------------------------------------
--stored procedure with TRY...CATCH and "transaction"
--------------------------------------

-- prep
CREATE TABLE sales.persons
(
    person_id  INT
    PRIMARY KEY IDENTITY, 
    first_name NVARCHAR(100) NOT NULL, 
    last_name  NVARCHAR(100) NOT NULL
);

CREATE TABLE sales.deals
(
    deal_id   INT
    PRIMARY KEY IDENTITY, 
    person_id INT NOT NULL, 
    deal_note NVARCHAR(100), 
    FOREIGN KEY(person_id) REFERENCES sales.persons(
    person_id)
);

insert into 
    sales.persons(first_name, last_name)
values
    ('John','Doe'),
    ('Jane','Doe');

insert into 
    sales.deals(person_id, deal_note)
values
    (1,'Deal for John Doe');


-- TIP: 별도로 에러가 발생할 때 그 에러 처리를 위한 stored procedure 를 별도로 구성한다.
CREATE PROC usp_report_error
AS
    SELECT   
        ERROR_NUMBER() AS ErrorNumber  
        ,ERROR_SEVERITY() AS ErrorSeverity  
        ,ERROR_STATE() AS ErrorState  
        ,ERROR_LINE () AS ErrorLine  
        ,ERROR_PROCEDURE() AS ErrorProcedure  
        ,ERROR_MESSAGE() AS ErrorMessage;  
GO


-- 그리고 다음과 같이 위에 생성한 두 가지 table 에 작업할 stored proc 를 생성한다.
CREATE PROC usp_delete_person(
    @person_id INT
) AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DELETE FROM sales.persons 
        WHERE person_id = @person_id;
        
        COMMIT TRANSACTION;  
    END TRY
    BEGIN CATCH
        -- report exception (SP 내에서 다른 SP 호출 가능하다.)
        EXEC usp_report_error;
        
        -- XACT_STATE() function: Begin Transaction 과 함께 실행된 SQL 구문의 Transaction 상태 조회
        -- -1: uncommittable transaction is pending   /  1: committable transaction is pending   / 0: no transactions is pending



        -- Test if the transaction is uncommittable.  
        IF (XACT_STATE()) = -1  
        BEGIN  
            PRINT  N'The transaction is in an uncommittable state.' +  
                    'Rolling back transaction.'  
            ROLLBACK TRANSACTION;  
        END;  
        
        -- Test if the transaction is committable.  
        IF (XACT_STATE()) = 1  
        BEGIN  
            PRINT N'The transaction is committable.' +  
                'Committing transaction.'  
            COMMIT TRANSACTION;     
        END;  
    END CATCH
END;
GO


-- test
EXEC usp_delete_person 2; -- 에러 발생하지 않는다.
EXEC usp_delete_person 1; -- 에러 발생한다.

