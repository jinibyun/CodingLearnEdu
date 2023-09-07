/*********************************
transaction
*********************************/
-- 가장 기본적인 부분에 대해서는 "26_modifying_transaction.sql" 에서 진행을 했고, 여기에서는 좀 더 나가서 "Explicit Transaction" 을 기준으로 깊이 있게 설명하기로 한다.

/*------- Transaction Types -------*/
-- 1. Auto Commit Transaction : 자동으로 Error 를 발생해서, 데이터 변경을 취소. 
-- 하지만, 두 가지 이상의 DML 에 대해서 모든 변경을 실행/취소 할 수 있는 것은 아니다.
-- 2. Implicit Transaction : SET IMPLICIT_TRANSACTIONS ON/OFF 를 이용해서 암묵적인 transaction 을 시작할 수 있다.
-- 3. Explicit Transaction : 주로 이 방법을 통해 진행

-----------------------
-- Explicit Transaction
-----------------------
-- prep
CREATE SCHEMA test;

CREATE TABLE test.Customer
(
    CustomerID INT PRIMARY KEY,
    CustomerCode VARCHAR(10),
    CustomerName VARCHAR(50)
)

-- explicit transaction using sp
CREATE PROC SPAddCustommer
@customerId int,
@customerCode varchar(10),
@customerName varchar(50)
AS
BEGIN
   BEGIN TRAN
      INSERT INTO test.Customer VALUES(@customerId, @customerCode, @customerName)
	  ---
	  ---
	  ---
      IF(@@ERROR != 0) -- @@Error : 전역 변수
      BEGIN
		-- LOGGING
         ROLLBACK TRANSACTION
      END
      ELSE
      BEGIN
         COMMIT TRANSACTION
      END  
END

-- test
exec SPAddCustommer 1, 'CODE_3', 'Pam';
exec SPAddCustommer 2, 'CODE_4', 'Sara';

-- confirm
select * from test.Customer


-----------------------
-- Nested Transaction
-----------------------
/* 
기본 구조 
BEGIN TRANSACTION T1
      DML 구문.....
      BEGIN TRANSACTION T2
            DML 구문..... 
            PRINT @@TRANCOUNT  -- @@TranCount 전역변수: 2  아직 commit/rollback 되지 않은 open 되어 있는 transcation 숫자 리턴
      COMMIT TRANSACTION T2 -- NOTE: 아직 완전히 물리적으로 T2 가 실행된 것은 아니다. 제일 바깥에 있는 outer transaction 이 commit 될 때 물리적으로 변경사항이 반영된다. 다른 표현으로 하면 outer transaction 이 모든 변경사항을 "최종" 결정한다.

      PRINT @@TRANCOUNT -- @@TranCount 전역변수: 1
COMMIT TRANSACTION T1 

-- "제일 바깥에 있는 transaction" 은 inner transaction commit 사항도 기억하고 
"함께 물리적으로 DB 에 적용"한다.

PRINT @@TRANCOUNT -- @@TranCount 전역변수: 0
*/

-- prep
delete from test.Customer;

-- test: open 되어 있는 transaction 숫자 확인
BEGIN TRANSACTION T1
      
	  INSERT INTO test.Customer VALUES (14, 'Code_10', 'Ramesh')
      INSERT INTO test.Customer VALUES (16, 'Code_11', 'Suresh')

      BEGIN TRANSACTION T2
            INSERT INTO test.Customer VALUES (17, 'Code_12', 'Priyanka')
            INSERT INTO test.Customer VALUES (23, 'Code_13', 'Preety')   

            PRINT @@TRANCOUNT --2
      COMMIT TRANSACTION T2
      PRINT @@TRANCOUNT --1
COMMIT TRANSACTION T1
PRINT @@TRANCOUNT -- 0


-------------------------------------------------
-- Partial Rollback
-------------------------------------------------
-- prep
delete from test.Customer;


-- Trasaction 시작시 각 각의 DML 구문의 적당한 자리에 
-- Partial Rollback 이 가능하도록 Save Transaction 을 삽입하여 일종의 Point 정보를 둔다.
BEGIN TRANSACTION 
 SAVE TRANSACTION SavePoint1 -- SAVE TRANSACTION 을 통해 전체 ROLLBACK 이 아닌 부분적인 ROLLBACK (Partial Rollback) 을 가능하게 한다.
     INSERT INTO test.Customer VALUES (1, 'Code_1', 'Ramesh')
     INSERT INTO test.Customer VALUES (2, 'Code_2', 'Suresh')
 SAVE TRANSACTION SavePoint11 -- SAVE TRANSACTION 을 통해 전체 ROLLBACK 이 아닌 부분적인 ROLLBACK (Partial Rollback) 을 가능하게 한다.
     INSERT INTO test.Customer VALUES (1, 'Code_1', 'Ramesh')
     INSERT INTO test.Customer VALUES (2, 'Code_2', 'Suresh')
 SAVE TRANSACTION SavePoint18 -- SAVE TRANSACTION 을 통해 전체 ROLLBACK 이 아닌 부분적인 ROLLBACK (Partial Rollback) 을 가능하게 한다.
     INSERT INTO test.Customer VALUES (1, 'Code_1', 'Ramesh')
     INSERT INTO test.Customer VALUES (2, 'Code_2', 'Suresh')

 SAVE TRANSACTION SavePoint2
     INSERT INTO test.Customer VALUES (3, 'Code_3', 'Priyanka')
     INSERT INTO test.Customer VALUES (4, 'Code_4', 'Preety')
 SAVE TRANSACTION SavePoint3
     INSERT INTO test.Customer VALUES (5, 'Code_5', 'John')
     INSERT INTO test.Customer VALUES (6, 'Code_6', 'David')

-- 이 후에 
Rollback Transaction SavePoint2; 
-- SavePoint2 를 찾아 그 시점부터 시작되는 모든 DML 은 rollback 한다는 의미

delete from test.Customer
select * from test.Customer

-- 마지막으로
Commit Transaction; 

-- test: 결과 확인
select * from test.Customer


-------------------------------------------------
-- Nested Transaction with SavePoint
-------------------------------------------------
-- prep
delete from test.Customer;

BEGIN TRANSACTION T1
    SAVE TRANSACTION SavePoint1
         INSERT INTO test.Customer VALUES (10, 'Code_10', 'Ramesh')
         INSERT INTO test.Customer VALUES (11, 'Code_11', 'Suresh')
 
     BEGIN TRANSACTION T2
          SAVE TRANSACTION SavePoint2
               INSERT INTO test.Customer VALUES (12, 'Code_12', 'Priyanka')
               INSERT INTO test.Customer VALUES (13, 'Code_13', 'Preety')   

     COMMIT TRANSACTION T2 

     ROLLBACK TRANSACTION SavePoint2 -- 마지막 commit 이 이뤄지기 직전 SavePoint2 를 찾아서 그 시점 부터 이뤄졌던 transaction 을 취소

COMMIT TRANSACTION T1 -- 앞서 설명 했듯이, 맨 마지막 COMMIT TRANSCTION 이 실행되어야 비로소 inner transaction 이 실행되는 것이다.

-- test
select * from test.Customer;


/************************************************
Assignment 9
아래의 Partial Transaction 구문 분석해서 필요시 각 구문에 주석 달기




CREATE PROCEDURE SaveTranExample  
    @model_year INT  
AS  
    DECLARE @TranCounter INT;  
    SET @TranCounter = @@TRANCOUNT;  

    IF @TranCounter > 0   -- 이 SP 실행이외에 다른 SP 에 활성화 되어 있는 Transaction 체크      
        SAVE TRANSACTION ProcedureSave; -- partial rollback 을 가능하게 하기 위해.
    ELSE    
        BEGIN TRANSACTION;

    -- 실질적인 변경 작업  
    BEGIN TRY  
        DELETE FROM 
            production.product_history
        WHERE
            model_year = @model_year; 
        
        IF @TranCounter = 0
            COMMIT TRANSACTION;  
    END TRY  
    BEGIN CATCH  
        IF @TranCounter = 0  
            ROLLBACK TRANSACTION;  
        ELSE  
            IF XACT_STATE() <> -1   -- 수행할 수 있는 트랜잭션이 대기하고 있음을 의미
                ROLLBACK TRANSACTION ProcedureSave;  
  
        -- 에러 메시지 출력 
        DECLARE @ErrorMessage NVARCHAR(4000);  
        DECLARE @ErrorSeverity INT;  
        DECLARE @ErrorState INT;  
  
        SELECT @ErrorMessage = ERROR_MESSAGE();  
        SELECT @ErrorSeverity = ERROR_SEVERITY();  
        SELECT @ErrorState = ERROR_STATE();  
  
        --RAISERROR (@ErrorMessage, -- Message text.  
        --           @ErrorSeverity, -- Severity.  
        --           @ErrorState -- State.  
        --           );  
    END CATCH  
GO
*************************************************/