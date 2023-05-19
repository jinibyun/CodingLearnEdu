/*********************************
stored procedures
Business Logic 을 정의, 실행 (단독 실행)
*********************************/

/*
used to group one or more Transact-SQL statements into logical units

pros: fast
cons: hard to debug
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

-- 생성 후에 /programmability 항목에서 확인할 수도 있고, 
-- view 의 구문을 확인했던 것처럼 sp_helptext 를 이용할 수도 있다.

sp_helptext 'uspProductList'

-- test
exec uspProductList

-- delete
DROP PROCEDURE uspProductList;

--------------------------------------
-- stored procedure with parameter (NOTE: View 는 Parameter 를 정의할 수 없다)
--------------------------------------
CREATE PROCEDURE uspFindProducts
@min_list_price DECIMAL
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
    @min_list_price AS DECIMAL,
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
        list_price >= @min_list_price AND -- &&
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
    @min_list_price AS DECIMAL = 0 -- 값을 넘기지 않으면 이 기본 값을 적용
    ,
    @max_list_price AS DECIMAL = 999999
    ,
    @name AS VARCHAR(max) -- 8000 byte
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
END

--test
EXECUTE uspFindProducts @name = 'Trek'; -- 명시적으로 파라미터 이름을 적음

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
        (@max_list_price IS NULL OR list_price <= @max_list_price) AND -- A or B
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

CREATE PROC uspGetProductList(
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
ALTER PROCEDURE uspFindProductByModel (
    @model_year SMALLINT, -- input 용
    @product_count INT OUTPUT -- output 용 파라미터
) AS
BEGIN
    SELECT 
        product_name,
        list_price
    FROM
        production.products
    WHERE
        model_year = @model_year;

    SELECT @product_count = @@ROWCOUNT; -- @@ 의 전역 변수. 영향 받은 레코드 수를 SQL 서버가 저장하게 된다.
	-- return (select @@ROWCOUNT)
END;

DECLARE @count INT;
exec @count = uspFindProductByModel @model_year = 2018
select @count
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
	-- sp 실행시 예상치 못한 오류 발생시 처리 하는 구문
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

select * from sales.persons
select * from sales.deals

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
ALTER PROC usp_delete_person(
    @person_id INT
) AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        -- 두 개 이상의 table 에 insert, update, delete 작업을 했을 때는 "반드시 필수적으로" transaction 작업을
		-- 동반해야 한다.

        delete from cart;

		update productInventory
		
		
		insert into delivery

		insert into payment

		select @customerId = cusomterId = from customer wher..

		
		update customerPoint
		...

        COMMIT TRANSACTION;  -- 위에서 진행한 모든 변경사항을 실제 DB 에 적용
    END TRY
    BEGIN CATCH
        -- report exception (SP 내에서 다른 SP 호출 가능하다.)
        EXEC usp_report_error;
        
        -- XACT_STATE() function: Begin Transaction 과 함께 실행된 SQL 구문의 Transaction 상태 조회
        -- -1: uncommittable transaction is pending   /  
		-- 1: committable transaction is pending   / 
		-- 0: no transactions is pending


		ROLLBACK TRANSACTION; -- 위에서 진행한 "모든" 변경사항을 취소
        -- Test if the transaction is uncommittable.  
        IF (XACT_STATE()) = -1  
        BEGIN  
            PRINT  N'The transaction is in an uncommittable state.' +  
                    'Rolling back transaction.'  
            ROLLBACK TRANSACTION;  
        END;  
        
        ----Test if the transaction is committable.  
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


/************************************************
Assignment 2

다음 CTE 구문은 2018 년도 영업 사원 실적을 보여주는 CTE 쿼리 구문이다. sp 작성시 이 쿼리 구문을 이용하고, 수정한다.

2018 년도라고 하는 year 값과 영업 사원의 이름 값을 파라미터로 정의해서 
그 두 가지 파라미터 값을 받아 동적으로 결과 값을 리턴하는 stored procedure 를 작성한다.

필요시에 이름 값 비교는 like pattern matching 을 이용한다. where name like '%길동%'

CREATE PROCEDURE uspGetSalesAmountByYearAndName
@year int, @name varchar(100)
AS
BEGIN
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
		year = @year and staff like '%' + @name + '%'
END;

-- test
exec uspGetSalesAmountByYearAndName 2018, 'Kali'

*************************************************/

/************************************************
Assignment 3

앞서, 기본 코스에서 Update...Set...From 이라는 Update 구문을 배웠었다.
sp 생성하기 앞서 관련 table들 생성 여부와 상관 없이 (새롭게 DB 를 셋업한 상태라고 가정하고) 다음의 준비 과정을 거친다.
우선 prep 0, 1, 2 과정을 반드시 진행한 후에 stored procedure 를 작성한다.

그 후에 다음의 update set from 구문을 stored procedure 로 구성한다. 
단 별개의 조건을 진행하는데 모든 staff 에 대해서 일괄적으로 진행하는 것이 아니라 
개별 staff 에 대해서 update 가 가능하도록 구성한다. 즉 staff_id 를 parameter 로 한다. 
뿐만아니라 얼마나 실제 금액이 인상됐는지 그 인상 금액을 output keyword  로 return 한다. 
그리고 특별히 데이타 변경 구문에서는 try catch 구문을 활용하여 error handling 을 진행한다. 
앞서 배웠던 begin tran, commit/rollback tran을 모두 적용한다.
마지막으로 작성한 stored procedure 를 호출하는 code 도 작성한다.

create proc uspUpdateCommission
@staff_id int,
@howmuch DECIMAL(10, 2) output
as
begin
	begin try
		begin tran -- begin transaction 을 줄여서 사용
			UPDATE
				sales.commissions
			SET
				sales.commissions.commission = 
					c.base_amount * t.percentage
			FROM 
				sales.commissions c
				INNER JOIN sales.targets t
					ON c.target_id = t.target_id
					AND c.staff_id = @staff_id

			select @howmuch = commission from sales.commissions where staff_id = @staff_id

		commit tran
	end try
	begin catch
		rollback tran
		exec usp_report_error
	end catch
end

-- test
declare @staff_id int 
set @staff_id = 1
declare @result DECIMAL(10, 2)

-- before
select commission from sales.commissions where staff_id = @staff_id
-- after
exec uspUpdateCommission @staff_id, @result output
select @result


select * from sales.targets
select * from sales.commissions
-- prep 0
Drop table if exists sales.targets;
Drop table if exists sales.commissions;

-- prep 1
CREATE TABLE sales.targets
(
    target_id  INT	PRIMARY KEY, 
    percentage DECIMAL(4, 2) 
        NOT NULL DEFAULT 0
);

INSERT INTO 
    sales.targets(target_id, percentage)
VALUES
    (1,0.2),
    (2,0.3),
    (3,0.5),
    (4,0.6),
    (5,0.8);

-- prep 2
CREATE TABLE sales.commissions
(
    staff_id    INT PRIMARY KEY, 
    target_id   INT, 
    base_amount DECIMAL(10, 2) 
        NOT NULL DEFAULT 0, 
    commission  DECIMAL(10, 2) 
        NOT NULL DEFAULT 0, 
    FOREIGN KEY(target_id) 
        REFERENCES sales.targets(target_id), 
    FOREIGN KEY(staff_id) 
        REFERENCES sales.staffs(staff_id),
);

INSERT INTO 
    sales.commissions(staff_id, base_amount, target_id)
VALUES
    (1,100000,2),
    (2,120000,1),
    (3,80000,3),
    (4,900000,4),
    (5,950000,5);
-- test
select * from sales.commissions

************************************************/