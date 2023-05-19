/*********************************
exception handling
*********************************/
/* ------- error hanling 이 없는 sp ------ */
ALTER PROCEDURE spDivideTwoNumber (
    @Number1 INT
    , @Number2 INT
    )
AS
BEGIN
    DECLARE @Result INT

    SET @Result = 0
    SET @Result = @Number1 / @Number2

    PRINT 'RESULT IS :' + CAST(@Result AS VARCHAR)
END

-- test
EXEC spDivideTwoNumber 100
    , 0 -- 결과를 보면 예상되는 대로 error 가 발생되지만, 적절히 error 에 대해 handling 하지는 않고 있다.

-- NOTE: 다른 프로그래밍 언어와는 다르게, SQL 에서 error 발생해도 
-- 그 다음 구문이 계속 실행된다는 점이다. (결과 RESULT 가 보여지고 있다)
/* ------- error hanling 적용 ------ */
-------------------------------------------------
-- 1. RaiseError()
-------------------------------------------------
-- 다음과 같이 error handling 코드를 삽입하여 수정 
ALTER PROCEDURE spDivideTwoNumber 
	@Number1 INT
    , @Number2 INT
AS
BEGIN
    DECLARE @Result INT

    SET @Result = 0

    IF (@Number2 = 0)
    BEGIN
        RAISERROR (
                'Second Number Cannot be zero'
                , 16 -- 0-10: info   /11 -20:error  /21-30: critical
                , 1
                ) -- system error message 를 리턴하는 함수
            -- RAISERROR('Error Message', ErrorSeverity, ErrorState)
            -- Error Severity 는 16 번 Error State 는 1 번으로 setting 하는 이유
            -- Error Severity: When we are returning any custom errors in SQL Server, 
				-- we need to set the ErrorSeverity level as 16, 
				-- which indicates this is a general error and this error can be corrected by the user. 
				-- In our example, the error can be corrected by the user by giving a nonzero value for the second parameter. 
            -- Error State: The ErrorState is also an integer value between 1 and 255. 
			-- The RAISERROR() function can only generate custom errors if you set the Error State value between 1 to 127.
    END
    ELSE
    BEGIN
        SET @Result = @Number1 / @Number2

        PRINT 'RESULT IS : ' + CAST(@Result AS VARCHAR)
    END
END

-- test
EXEC spDivideTwoNumber 100, 0

-------------------------------------------------
-- RaiseError() 추가
-------------------------------------------------
--TIP: 추가로 message_id 와 message text 확인
select * from sys.messages


-- TIP: 사용자 정의 메시지를 추가 (위의 table 에 값을 입력)
sys.sp_addmessage  @msgnum = 50001, 
				   @severity = 11, 
				   @msgtext = 'Because of something....you cannot do it'

-- test
RAISERROR(50001, 11, 1)

-- 삭제
sys.sp_dropmessage  @msgnum = 50001

-- 한글 지정
-- ref: https://learn.microsoft.com/ko-kr/sql/relational-databases/system-stored-procedures/sp-addmessage-transact-sql?view=sql-server-ver16

-- MS SQL Error code
-- ref: https://thankyeon.tistory.com/71


-------------------------------------------------
-- @@error  전역 변수 이용하기
-------------------------------------------------
ALTER PROCEDURE spDivideTwoNumber @Number1 INT
    , @Number2 INT
AS
BEGIN
    DECLARE @Result INT

    SET @Result = 0

    IF (@Number2 = 0)
    BEGIN
        RAISERROR (
                'Second Number Cannot be zero'
                , 16
                , 1
                )
    END
    ELSE
    BEGIN
        SET @Result = @Number1 / @Number2
    END

    IF (@@ERROR <> 0) -- 추가적으로 Error 발생 상황을 핸들링
    BEGIN
        PRINT 'Error Occurred'
    END
    ELSE
    BEGIN
        PRINT 'RESULT IS :' + CAST(@Result AS VARCHAR)
    END
END

-- test
EXEC spDivideTwoNumber 100
    , 0

-----------------------------------------------------------
-- RaiseError, @@error 그리고 transaction 을 이용하여 sp 생성
------------------------------------------------------------
-- prep
CREATE TABLE test.Product (
    ProductId INT PRIMARY KEY
    , Name VARCHAR(50)
    , Price INT
    , QuantityAvailable INT
    )
GO

-- Populate the Product Table with some test data
INSERT INTO test.Product
VALUES (
    101
    , 'Laptop'
    , 1234
    , 100
    )

INSERT INTO test.Product
VALUES (
    102
    , 'Desktop'
    , 3456
    , 50
    )

INSERT INTO test.Product
VALUES (
    103
    , 'Tablet'
    , 5678
    , 35
    )

INSERT INTO test.Product
VALUES (
    104
    , 'Mobile'
    , 7890
    , 25
    )
GO

CREATE TABLE test.ProductSales (
    ProductSalesId INT PRIMARY KEY
    , ProductId INT
    , QuantitySold INT
    )
GO

INSERT INTO test.ProductSales
VALUES (
    1
    , 101
    , 5
    )

INSERT INTO test.ProductSales
VALUES (
    2
    , 102
    , 7
    )

INSERT INTO test.ProductSales
VALUES (
    3
    , 103
    , 5
    )

INSERT INTO test.ProductSales
VALUES (
    4
    , 104
    , 7
    )
GO

select * from test.Product
select * from test.ProductSales
-- sp 생성
CREATE PROCEDURE spSellProduct 
	  @ProductID INT
    , @QuantityToSell INT
AS
BEGIN
    -- 팔려고 하는 상품의 존재 여부 체크
	declare @cnt int
	select @cnt = count(*) from test.Product
	if @cnt < 1
		RAISERROR (
                'no product'
                , 16
                , 1
                )
	else
	begin	
		-- 팔려고 하는 상품의 stock 체크
		DECLARE @StockAvailable INT

		SELECT @StockAvailable = QuantityAvailable
		FROM test.Product
		WHERE ProductId = @ProductId

		-- 상품 체크 validation
		IF (@StockAvailable < @QuantityToSell)
		BEGIN
			-- 참고로 THROW 구문을 사용할 수도 있다.
			RAISERROR (
					'Enough Stock is not available'
					, 16
					, 1
					)
		END
		ELSE -- stock 준비되어 있음
		BEGIN
			BEGIN TRANSACTION

			-- 재고량 update
			UPDATE test.Product
			SET QuantityAvailable = (QuantityAvailable - @QuantityToSell)
			WHERE ProductID = @ProductID

			-- 별도로 Identity 값으로 지정된 것이 아니기 때문에 다음과 같이 Max 값을 얻어야 함
			DECLARE @MaxProductSalesId INT

			SELECT @MaxProductSalesId = CASE 
					WHEN MAX(ProductSalesId) IS NULL
						THEN 0
					ELSE MAX(ProductSalesId)
					END
			FROM test.ProductSales

			SET @MaxProductSalesId = @MaxProductSalesId + 1


			-- ProductSales table 에 값을 입력
			INSERT INTO test.ProductSales (
				ProductSalesId
				, ProductId
				, QuantitySold
				)
			VALUES (
				@MaxProductSalesId
				, @ProductId
				, @QuantityToSell
				)

			-- transaction 의 commit 혹은 rollback 여부를 결정
			IF (@@ERROR <> 0)
			BEGIN
				ROLLBACK TRANSACTION
				PRINT 'Rolled Back the Transaction'
			END
			ELSE
		BEGIN
				COMMIT TRANSACTION
				PRINT 'Committed the Transaction'
			END
		END
	END
END

-- test
exec spSellProduct 101, 500 -- 에러 발생

------------------------------
-- Try...Catch... 구문 이용하기
------------------------------
CREATE PROCEDURE spDivideTwoNumbers @Number1 INT
    , @Number2 INT
AS
BEGIN
    DECLARE @Result INT

    SET @Result = 0

    BEGIN TRY
        SET @Result = @Number1 / @Number2
        PRINT 'RESULT IS : ' + CAST(@Result AS VARCHAR)
    END TRY

    BEGIN CATCH
        -- PRINT 'SECOND NUMBER SHOULD NOT BE ZERO'
        -- error 관련 시스템 함수들: 이 중에서 Error_message 와 Error_Procedure 는 많이 사용되는 함수들
        SELECT  ERROR_NUMBER() as ErrorNumber,
                ERROR_MESSAGE() as ErrorMessage,
                ERROR_PROCEDURE() as ErrorProcedure,
                ERROR_STATE() as ErrorState,
                ERROR_SEVERITY() as ErrorSeverity,
                ERROR_LINE() as ErrorLine
    END CATCH
END

-- test
exec spDivideTwoNumbers 10, 0

