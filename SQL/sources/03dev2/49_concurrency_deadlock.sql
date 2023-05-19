/*********************************
Concurrency
*********************************/
-- 두 개 이상의 프로세스가 동시에 하나의 리소스 (예를 들어 Table) 에 접근했을 때 발생할 수 있는 문제점

-- prep
/* ---- 가정 ---- */
CREATE TABLE test.Concurrency
(
    CustomerID INT PRIMARY KEY,
    CustomerCode VARCHAR(10),
    CustomerName VARCHAR(50)
);

INSERT INTO test.Concurrency VALUES (1, 'Code_1', 'Ramesh');
INSERT INTO test.Concurrency VALUES (2, 'Code_2', 'Suresh');
INSERT INTO test.Concurrency VALUES (3, 'Code_3', 'David');
INSERT INTO test.Concurrency VALUES (4, 'Code_4', 'John');

-- 우선 "발생할 가능성이 있는" 동시 접속 문제점을 이해한다.
-- 예) 아래와 같은 프로세스가 진행된다고 가정해 본다.
/* ---- 현상 ---- */
begin TRAN
    update test.Concurrency set CustomerCode = 'Code_101' where CustomerID =1
    ---->>>>>>>>> A
    -- 가정: 약 4 초간의 long running process 가 진행된다고 가정
    WAITFOR delay '00:00:04'
    ---->>>>>>>>> B
    update test.Concurrency set CustomerCode = 'Code_1001' where CustomerID =1
    ---->>>>>>>>> C
    -- 가정: 약 2 초간의 long running process 가 진행된다고 가정
    WAITFOR delay '00:00:02'
rollback tran
---->>>>>>>>> D


/* ---- 분석 ---- */
-- 위의 프로세스가 진행되는 동안 다른 프로세스에서 동시에 test.Concurrency 테이블의 CustomerID =1 정보를 조회하게 되는 경우
-- A, B: Code_101
-- C: Code_1001
-- D: Code_1

/* ---- 결과 ---- */
-- 데이타에 대한 일관성을 확보할 수 없다. 추가로 생각해야 하는 부분은 "일관성"과 "성능"은 서로 배치되어 있다고 보면 된다.

/* ---- 가능성 있는 해결책 ---- */
-- 동시 접근성을 막고 모든 프로세스를 독립적으로 실행하게끔 하면 되지만, 이 때 발생하는 것은 "성능" 자체를 확보할 수 없다.

/* ---- 가능성 있는 해결책에 대한 결과 ---- */
-- 심각한 Performance 문제 유발

/* ---- 해결책 ---- */
-- 일관성을 유지하면서 성능을 확보하는 것
-- Transaction 의 isolation 레벨을 지정하는 것. 즉 그 레벨의 지정에 따라 "데이터 일관성" 과 "성능" 이라는 두 가지 상반된 개념에 대한 "Balance" 를 유지하는 것이다.

-- transaction isolation 
-- ref: https://learn.microsoft.com/en-us/sql/t-sql/statements/set-transaction-isolation-level-transact-sql?view=sql-server-ver16

/* --- 지정할 수 있는 isolation level 에 대한 간략한 설명 (이 설명은 위의 MS 의 내용을 기준으로 작성했음) --- */
-- 지정 방법

/* SET TRANSACTION ISOLATION LEVEL
    { READ UNCOMMITTED
    | READ COMMITTED
    | REPEATABLE READ
    | SNAPSHOT
    | SERIALIZABLE
    }
*/
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


-- 트랜잭션 레벨 지정에 대한 이론적인 개념 해설
/* 
1. READ UNCOMMITTED 
    - 트랜잭션이 시작하고 나서 변경되었지만, 아직 완벽하게 commit 되지 않는 임시의 데이타를 읽는다.
    - exlucive locks 옵션을 걸었다 하더라도 그에 영향 받지 않는다.
    - 완전 실행된 data 변경 후의 data 를 읽어내는 것이 아니므로 이를 "dirty read" 라고 한다.
    - isolcation level 에서 가장 제약 조건이 약한 세팅

2.  READ COMMITTED (기본 Transaction Level Setting)
    - 1번에서 발생할 수 있는 "dirty read" 문제를 해결한다. 즉 트랜잭션이 시작한 후에 commit 되지 않은 데이타를 읽을 수는 없다.
    - 같은 트랜잭션 내에서 2개 이상의 같은 작업을 하는 statement 가 있다고 가정을 해 보자. 이 때 첫 번 째 쿼리의 결과와 두 번 째 쿼리의 결과가 다르게 나올 수 있다. 이를 "nonrepeatable read" 라 한다. 다른 경우는 위와 같은 시나리오에서 이 동안 다른 트랜잭션이 첫 번 째 쿼리와 두 번 째 쿼리사이에서 데이타를 변경하는 작업을 하게 되면 서로 다른 결과가 나오는데 (결과가 나오긴 하는데) 이때 "phantom read" 가 발생한다고 한다.

        (그래서 다음과 같은 Database option 과 함께 사용된다.)
        2.1. READ_COMMITTED_SNAPSHOT - OFF (기본 세팅)
            현재 진행되고 있는 해당 레코드를 수정하고 있다면 트랜잭션이 진행되는 동안 해당 레코들에 대해 추가로 다른 트랜잭션이 레코드를 읽는 행위 자체를 막는다. 이를 shared lock 을 이용한다고 하는데 기본적으로 Azure 환경이 아닌 곳에서는 별도의 세팅을 하지 않으면 off 되어 있다.

        2.2 READ_COMMITTED_SNAPSHOT  - ON (Azure 환경에서는 이 세팅이 기본)
            각 레코드에 대해 별도로 변경하는 레코드 자체의 copy ,즉 snapshot (서로 다른 버전의 레코드)를 이용하게 해서 shared lock 을 사용하지 않고 내부적으로 이 snapshot 을 이용해서 진행하게 된다.
            
3. REPEATABLE READ
    - 즉 트랜잭션이 시작한 후에 commit 되지 않은 데이타를 읽을 수는 없다. (위의 READ COMMITTED 와 동일) 추가로 만약 트랜잭션이 그 데이타를 다시 접근해서 읽으려고 하면, 그 때도 그 트랜잭션내에서만 읽고 다른 곳에서는 수정할 수 없게끔 하는 좀 더 restirct 한 레벨. 필요할 때만 사용하는 것이 권장.
    

4. snapshot
    데이타 조회시 데이타 자체의 copy version 인 snapshot 을 통하게 해서, 서로 다른 버전의 record 라 할지라도 lock 하지 않고 읽을 수 있도록 한다. (성능)
    트랜잭션에서 변경을 시작하기 전에 이미 commite 된 데이타 변경에 대한 것을 snap 을 통해 비교해서 진행한다. 현재 트랜잭션이 시작하고 난 후에 다른 트랜잭션에서 만들어진 변경사항은 보이지 않게 된다. 일관성을 유지하게끔 한다.

5. SERIALIZABLE
    - 트랜잭션이 시작한 후에 commit 되지 않은 데이타를 읽을 수는 없다.
    - 트랜잭션이 진행되는 동안 끝나기 전까지는 해당 트랜잭션이 사용하고 있는 statement 에 해당되는 테이블에 어떤 레코드도 삽입할 수 없다.
    - 가장 restirct 가 강한 transaction level 이다.

*/

/* 코드에서 사용 하는 예제
이와 같이 코드를 실행하기 전에 지정해서 실행하게끔 할 수 있다.
 */
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;  
BEGIN TRANSACTION  
    SELECT *   
        FROM some table;  
    GO  
    SELECT *   
        FROM some table;  
    GO  
COMMIT TRANSACTION;

/* transaction isolation level 과 발생할 수 있는 concurrency 문제점 정리 */
/*
--------------------------------------------------------------------------------------------
Isolation level	    |    Dirty Read  |	Lost Update  |	Non repeatable reads  |	Phantom read
--------------------------------------------------------------------------------------------
Read Uncommitted	        Yes	            Yes	                Yes	                Yes
Read committed	            No	            Yes	                Yes	                Yes
Repeatable read	            No	            No	                No	                Yes
Snapshot	                No	            No	                No	                No
Serializable	            No	            No	                No	                No
*/

/*********************************
Deadlock
*********************************/
--When deadlocks occur in SQL Server, then SQL Server chooses one of the processes (transactions) as the "deadlock victim" and then rolls back that process. As a result, other processes can move forward. The process that is chosen as the "deadlock victim" will give the following error.

-- prep
CREATE TABLE test.TableA
(
    ID INT,
    Name NVARCHAR(50)
)
Go

INSERT INTO test.TableA values (101, 'Anurag')
INSERT INTO test.TableA values (102, 'Mohanty')
INSERT INTO test.TableA values (103, 'Pranaya')
INSERT INTO test.TableA values (104, 'Rout')
INSERT INTO test.TableA values (105, 'Sambit')
Go

CREATE TABLE test.TableB
(
    ID INT,
    Name NVARCHAR(50)
)
Go

INSERT INTO test.TableB values (1001, 'Priyanka')
INSERT INTO test.TableB values (1002, 'Dewagan')
INSERT INTO test.TableB values (1003, 'Preety')
Go

-- 주의: 다음 두 개의 transaction 을 "별도의 query 창" 을 열어 놓고 실행한다.

-- transaction 1
BEGIN TRANSACTION
    UPDATE test.TableA SET Name = 'Anurag From Transaction1' WHERE Id = 101

    WAITFOR DELAY '00:00:15'

    UPDATE test.TableB SET Name = 'Priyanka From Transaction1' WHERE Id = 1001
COMMIT TRANSACTION

-- transaction 2
BEGIN TRANSACTION
    UPDATE test.TableB SET Name = 'Priyanka From Transaction2' WHERE Id = 1001

    WAITFOR DELAY '00:00:15'

    UPDATE test.TableA SET Name = 'Anurag From Transaction2' WHERE Id = 101
Commit Transaction

-- test
-- 둘 중의 하나는 다음과 같은 메시지를 보게 된다.
-- Msg 1205, Level 13, State 45, Line 16
-- Transaction (Process ID 79) was deadlocked on lock resources with another process and has been chosen as the deadlock victim. Rerun the transaction.


-- deadlock priority 를 사용자가 바꾸는 방법 (LOW: -10, NORMAL: 0,  and HIGH: 10 )
-- Highest 를 지정하게 되면 그 만큼 victim 이 될 확률이 낮다는 의미

-- test (위와 마찬가지로 별도로 다른 query 창에서 실행)
-- Transaction 1
BEGIN TRANSACTION
    UPDATE test.TableA Set Name = Name + ' From Transaction 1' 
    WHERE Id IN (101, 102, 103, 104, 105)

    WAITFOR DELAY '00:00:15'

    UPDATE test.TableB Set Name = Name + ' From Transaction 1' 
    WHERE Id IN (1001, 1002)

COMMIT TRANSACTION


-- Transaction 2
SET DEADLOCK_PRIORITY HIGH -- HIGH 로 지정하게 되면 그 만큼 victim 이 될 확률을 낮춘다. (Priority 를 High 하게 준다는 의미이다)
GO
BEGIN TRANSACTION
    UPDATE test.TableB Set Name = Name + ' From Transaction 2' 
    WHERE Id IN (1001, 1002)

    WAITFOR DELAY '00:00:15'

    UPDATE test.TableA Set Name = Name + ' From Transaction 2' 
    WHERE Id IN (101, 102, 103, 104, 105)

COMMIT TRANSACTION

------------------------------------------
-- Deadlock Logging in SQL Server Error Log
-- 기존의 Sql server log 에 Deadlock 이 발생 시 로깅데이터를 남기는 방법
-- 반드시 아래와 같이 DBCC 를 이용해 TraceOn 을 사용해야 한다.
------------------------------------------
-- To enable the trace flag
DBCC Traceon(1222, -1) -- -1 의 의미는 global

-- To check the status of the trace flag
DBCC TraceStatus(1222, -1) 

-- To disable the trace flag
DBCC Traceoff(1222, -1)

-- test
-- 일단 위의 traceon 기능을 이용해서 켜둔다.
DBCC Traceon(1222, -1) 

-- 그 후에 바로 앞서 진행했던 transaction 1, 2 를 서로 다른 query 창을 열어 실행해서 deadlock message 를 만난다.

-- 최종적으로 메시지를 확인한다
EXECUTE sp_readerrorlog  -- 메시지의 Text 결과 셋에서 deadlock-list 항목을 찾는다. 기본적으로 isolation level 은 추적할 수 없으나, 앞서 배웠듯이 기본 값인 "Read Committted" 가 적용된다. 특별히 inputbuf 이라는 항목은 바로 deadlock 으로 인해 rollback 되어 실행되지 못한 프로세스를 말한다.

-------------------------------
-- deadlock 해결책 
-------------------------------
--위에서 발견한 문제점을 바탕으로 tableA 와 tableB 에서 일어나는 프로세스의 순서를 다음과 같이 일치 시킨다.
BEGIN TRANSACTION
    UPDATE test.TableA SET Name = 'Anurag From Transaction 1' 
        WHERE Id = 101
    
    WAITFOR DELAY '00:00:10'
    
    UPDATE test.TableB SET Name = 'Priyanka From Transaction 2' 
    WHERE Id = 1001
COMMIT TRANSACTION

BEGIN TRANSACTION
    UPDATE test.TableA SET Name = 'Anurag From Transaction 2' 
    WHERE Id = 101
    
    WAITFOR DELAY '00:00:10'

    UPDATE test.TableB SET Name = 'Priyanka From Transaction 2' 
    WHERE Id = 1001

COMMIT TRANSACTION

----------------------------------------------------------------------
-- deadlock 를 발견해 내는 또 다른 방법  (EXECUTE sp_readerrorlog 이외에)
----------------------------------------------------------------------
-- Tools > Sql Profiler 를 켜면 별도의 인증 창이 나오고, 이를 이용한다.
-- "use the template section" 항목에서 standard 가 아닌 blank 로 지정한 후 Run 버튼 클릭.
-- 항목을 추가하라는 추가 메시지가 나오면 다음과 같이 Locks > deadlock graph 항목을 선택 후 Run 클릭

--test (별도의 Query 창)
-- Transaction 1
BEGIN TRANSACTION
    UPDATE test.TableA Set Name = Name + ' From Transaction 1' 
    WHERE Id IN (101, 102, 103, 104, 105)

    WAITFOR DELAY '00:00:15'

    UPDATE test.TableB Set Name = Name + ' From Transaction 1' 
    WHERE Id IN (1001, 1002)

COMMIT TRANSACTION


-- Transaction 2
SET DEADLOCK_PRIORITY HIGH -- HIGH 로 지정하게 되면 그 만큼 victim 이 될 확률을 낮춘다
GO
BEGIN TRANSACTION
    UPDATE test.TableB Set Name = Name + ' From Transaction 2' 
    WHERE Id IN (1001, 1002)

    WAITFOR DELAY '00:00:15'

    UPDATE test.TableA Set Name = Name + ' From Transaction 2' 
    WHERE Id IN (101, 102, 103, 104, 105)

COMMIT TRANSACTION

-- 확인: Profiler 창에서 확인
-- TIP: File – Export – Extract SQL Server Events – Extract Deadlock Events 를 통해 결과를 xml file 로 남길 수 있다.

----------------------------------------------------------------------
-- Deadlock Error Handling - try ....catch...구문 이용
----------------------------------------------------------------------
-- 여기에서는 위의 두 transaction 을 stored proc 으로 구성한다.

-- transaction 1 을 포함하는 sp
CREATE PROCEDURE spTransaction1
AS
BEGIN
    BEGIN TRANSACTION
    BEGIN TRY
        UPDATE test.TableA SET Name = 'Anurag From Transaction 1' 
        WHERE Id = 101

        WAITFOR DELAY '00:00:10'

        UPDATE test.TableB SET Name = 'Priyanka From Transaction 2' 
        WHERE Id = 1001

        -- If both the update statements are succeeded.
            -- Then there is no Deadlock. 
        -- So commit the transaction.
        COMMIT TRANSACTION
        SELECT 'Transaction Completed Successfully'   
    END TRY
    BEGIN CATCH
            -- 참고로 Deadlock error 는 1205 번
            IF(ERROR_NUMBER() = 1205)
            BEGIN
                SELECT 'Deadlock Occurred. The Transaction has failed. Please retry'
            END
            -- Rollback the transaction
            ROLLBACK TRANSACTION
    END CATCH
END

-- transaction 2 을 포함하는 sp
CREATE PROCEDURE spTransaction2
AS
BEGIN
    BEGIN TRANSACTION
    BEGIN TRY
        UPDATE test.TableB SET Name = 'Priyanka From Transaction 2' 
        WHERE Id = 1001
        
        WAITFOR DELAY '00:00:10'
    
        UPDATE test.TableA SET Name = 'Anurag From Transaction 2' 
        WHERE Id = 101

    COMMIT TRANSACTION -- 여기 까지 진행했다는 의미는 deadlock 이 발생하지 않았다는 의미이디ㅏ
    SELECT 'Transaction Completed Successfully'  
  END TRY
  BEGIN CATCH
        -- Check if the error is deadlock error
         IF(ERROR_NUMBER() = 1205)
         BEGIN
             SELECT 'Deadlock Occurred. The Transaction has failed. Please retry'
         END
         -- Rollback the transaction
         ROLLBACK TRANSACTION
  END CATCH
END

-- test (NOTE: 별도의 query 창에서 진행)
exec spTransaction1;
exec spTransaction2;


----------------------------------------------------------------------
-- Deadlock Error Handling 를 통해 catch 가 된다면 이를 Deadlock 에러에 멈추지 않고
-- Retry 를 시키는 발전된 로직 적용
----------------------------------------------------------------------
-- 앞서 생성한 sp 2 개를 다음과 같이 수정한다. (테스트 이기 때문에 실행되는 순서를 바꾸는 것이 아니라, 별도의 처리가 없으면 deadlock 이 일어나도록 순서를 바꾸지는 않았다.)

-- transaction 1
ALTER PROCEDURE spTransaction1
AS
BEGIN
  DECLARE @ErrorMessage NVARCHAR(2000) = '';
  DECLARE @Iteration INT = 0;
  DECLARE @IterationLimit INT = 2; -- 사용자가 retry 숫자 임의 지정

  WHILE(@ErrorMessage IS NOT NULL AND @Iteration < @IterationLimit)  -- null 의 의미는 successful  
  BEGIN
        SET @Iteration += 1;

    BEGIN TRANSACTION
    BEGIN TRY
      UPDATE test.TableA SET Name = 'Anurag From Transaction 1' 
      WHERE Id = 101

      WAITFOR DELAY '00:00:05'

      UPDATE test.TableB SET Name = 'Priyanka From Transaction 2' 
      WHERE Id = 1001

      -- 에러가 발생했을 때만 ErrorMessage 값을 입력하게 됨. 아니면 빈 값
      SET @ErrorMessage = ERROR_MESSAGE()
      COMMIT TRANSACTION
      SELECT 'Transaction Completed Successfully'  
    END TRY
    BEGIN CATCH
      -- Check if the error is deadlock error
       IF(ERROR_NUMBER() = 1205)
       BEGIN
         -- Notify if iteration limit is reached
         IF @Iteration = @IterationLimit
         BEGIN
           SELECT 'Iteration reached; last error: ' + @ErrorMessage
         END
       END
       -- Rollback the transaction
       ROLLBACK TRANSACTION
    END CATCH
  END  -- end of while
END;

-- transaction 2
ALTER PROCEDURE spTransaction2
AS
BEGIN

    DECLARE @ErrorMessage NVARCHAR(2000) = '';
    DECLARE @Iteration INT = 0;
    DECLARE @IterationLimit INT = 2;

    WHILE(@ErrorMessage IS NOT NULL AND @Iteration < @IterationLimit)
    BEGIN
        
        SET @Iteration += 1;

        BEGIN TRANSACTION
        BEGIN TRY
            UPDATE test.TableB SET Name = 'Priyanka From Transaction 2'
            WHERE Id = 1001

            WAITFOR DELAY '00:00:05'

            UPDATE test.TableA SET Name = 'Anurag From Transaction 2'
            WHERE Id = 101

            SET @ErrorMessage = ERROR_MESSAGE()

            COMMIT TRANSACTION
            SELECT 'Transaction Completed Successfully'
        END TRY
        BEGIN CATCH
           -- Check if the error is deadlock error
            IF(ERROR_NUMBER() = 1205)
            BEGIN
                -- Notify if iteration limit is reached
                IF @Iteration = @IterationLimit
                BEGIN
                SELECT 'Iteration reached; last error: ' + @ErrorMessage
                END
            END
            -- Rollback the transaction
            ROLLBACK TRANSACTION
        END CATCH
    END -- end of while
END;

-- test (NOTE: 별도의 query 창에서 진행)
exec spTransaction1;
exec spTransaction2;


----------------------------------------------------------------------
-- TIP: Deadlock 을 일으키는 query 추적
----------------------------------------------------------------------
-- 현재 활성화 되어 있는 transaction 확인 하는 쿼리
-- Session Id, Login Name , Database Name, Transaction Begin Time, 그리고 실제 쿼리 구문까지 확인할 수 있다.
SELECT
    [s_tst].[session_id],
    [s_es].[login_name] AS [Login Name],
    DB_NAME (s_tdt.database_id) AS [Database],
    [s_tdt].[database_transaction_begin_time] AS [Begin Time],
    [s_tdt].[database_transaction_log_bytes_used] AS [Log Bytes],
    [s_tdt].[database_transaction_log_bytes_reserved] AS [Log Rsvd],
    [s_est].text AS [Last T-SQL Text],
    [s_eqp].[query_plan] AS [Last Plan]
FROM
    sys.dm_tran_database_transactions [s_tdt]
JOIN
    sys.dm_tran_session_transactions [s_tst]
ON
    [s_tst].[transaction_id] = [s_tdt].[transaction_id]
JOIN
    sys.[dm_exec_sessions] [s_es]
ON
    [s_es].[session_id] = [s_tst].[session_id]
JOIN
    sys.dm_exec_connections [s_ec]
ON
    [s_ec].[session_id] = [s_tst].[session_id]
LEFT OUTER JOIN
    sys.dm_exec_requests [s_er]
ON
    [s_er].[session_id] = [s_tst].[session_id]
CROSS APPLY
    sys.dm_exec_sql_text ([s_ec].[most_recent_sql_handle]) AS [s_est]
OUTER APPLY
    sys.dm_exec_query_plan ([s_er].[plan_handle]) AS [s_eqp]
ORDER BY
    [Begin Time] DESC;
GO
