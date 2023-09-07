/*********************************
trigger: DB 에서 이뤄지는 하나의 Action 에 반응 하여 다른 Action 이 자동으로 발생. 
Audit
*********************************/

-- 3 types
-- 1. DML triggers: INSERT, UPDATE, and DELETE events
-- 2. DDL triggers: CREATE, ALTER, and DROP statements. DDL 관련 stored procedures 도 이에 해당
-- 3. Logon triggers: LOGON events  (로그인 tracking과 session 수 제한 하기 위해서 사용. 예제는 생략)


-- 3 특징 (stored procedure 혹은 function 과 비슷해 보이지만 그것들과 구별되게 해 주는 관점에서 
-- 보면 이해하기 용이해진다)
-- 1. SP 과는 다르게 사용자가 직접 호출해서 실행할 수 없다
-- 2. View 와 마찬가지로 parameter 정의 불가능
-- 3. Trigger 안에서는 Commit/Rollback transction 사용 불가능


-- 주 용도
-- 1. Audit
-- 2. Business Rule

--------------------------------------
-- 1. DML Trigger
--------------------------------------

-- prep
DROP TABLE if exists production.product_audits

CREATE TABLE production.product_audits(
    change_id INT IDENTITY PRIMARY KEY,
    product_id INT NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    brand_id INT NOT NULL,
    category_id INT NOT NULL,
    model_year SMALLINT NOT NULL,
    list_price DEC(10,2) NOT NULL,
    updated_at DATETIME NOT NULL,
	updated_by VARCHAR(100) NOT NULL,
    operation CHAR(3) NOT NULL,
    CHECK(operation = 'INS' or operation='DEL')
);

select SUSER_SNAME() -- session 이름

-- create "After" trigger
-- 아래 trigger 의 역할은 production.products 테이블에서 
-- 어떤 레코드가 삽입, 삭제 될때마다 바로 "직후"(After) 
-- 그 레코들을 production.product_audits table 에 기록한다
ALTER TRIGGER production.trg_product_audit
ON production.products
AFTER INSERT, DELETE -- "After" . 여기에 사용할 수 있는 option 은 INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO production.product_audits(
        product_id, 
        product_name,
        brand_id,
        category_id,
        model_year,
        list_price, 
        updated_at, 
		updated_by,
        operation
    )
    SELECT
        i.product_id,
        product_name,
        brand_id,
        category_id,
        model_year,
        i.list_price,
        GETDATE(),
		SUSER_SNAME(),
        'INS'
    FROM
        inserted i    -- 주의: INSERTED 라고 하는 "시스템 임시 table" 이용: Data가 입력이 되기 직전에 이 system table 에 자료가 입력이 된다.
    UNION ALL -- 레코드와 레코드 의 결합
    SELECT
        d.product_id,
        product_name,
        brand_id,
        category_id,
        model_year,
        d.list_price,
        GETDATE(),
		SUSER_SNAME(),
        'DEL'
    FROM
        deleted d;  -- 주의: DELETED 라고 하는 "시스템 임시 table" 이용
END

select * from production.product_audits
-- test
-- test 1. 자료 입력
INSERT INTO production.products(
    product_name, 
    brand_id, 
    category_id, 
    model_year, 
    list_price
)
VALUES (
    'Test product',
    1,
    1,
    2018,
    599
);

--test 2. 자료 입력 후 audit table 확인
SELECT 
    * 
FROM 
    production.product_audits;


-- test 3: 자료 삭제
DELETE FROM 
    production.products
WHERE 
    product_id = 322;

-- test 4: 자료 삭제 후 audit table 확인
SELECT 
    * 
FROM 
    production.product_audits;


/*-------- 참고 사항 -------- */
/* DML Trigger 의 세부 용도 중 두 가지 (두 가지 type)
1. FOR or AFTER [INSERT, UPDATE, DELETE]: 위의 예제에서 처럼 어떤 table 의 
insert/update/delete 작업 직후 연달아 자동으로 일어나게끔 할 때 사용.
2. INSTEAD OF [INSERT, UPDATE, DELETE]: After 타입과는 반대로, 
"INSTEAD OF 트리거" 는 실제 insert/update/delete 작업을 대체하는 다른 action 을 정의할 때 사용. 
여기에서 예제는 생략
*/

--------------------------------------
-- 2. DDL Trigger
--------------------------------------
-- 주 용도
-- table, view ,sp, function 등 주요 sql object 구조 변경 추적

-- prep
CREATE TABLE index_logs ( -- 주의: trigger 이름을 정의할 때 별도로 schema 이름을 부여하지 않는다. 모든 object 에 범용으로 접근해서 적용가능하게 하기 위해서임
    log_id INT IDENTITY PRIMARY KEY,
    event_data XML NOT NULL,
    changed_by SYSNAME NOT NULL
);
GO

-- 생성
CREATE TRIGGER trg_index_changes
ON DATABASE -- Database 혹은 Server
FOR	-- event type: DDL event. 
-- 예를 들어 CREATE_TABLE, ALTER_TABLE, etc . 밑에 정의한 세 가지 action 모두 subsribe 하고 있다.
    CREATE_INDEX,
    ALTER_INDEX, 
    DROP_INDEX
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO index_logs (
        event_data,
        changed_by
    )
    VALUES (
        EVENTDATA(), 
		-- 특별한 함수로써, 
		-- server 혹은 database 에서 발생하는 정보를 return 한다. 
		-- 이 함수는 특별히 ddl trigger 혹은 logon trigger 에서만 사용가능
        USER -- 기본 schema 정보
    );
END;

-- test: 위에 생성한 trigger 가 index 와 관련 있기 때문에 다음과 같이 간단히 두 개의 index 생성
CREATE NONCLUSTERED INDEX nidx_fname
ON sales.customers(first_name);
GO

CREATE NONCLUSTERED INDEX nidx_lname
ON sales.customers(last_name);
GO

-- test: 결과 확인 (event_data 칼럼. xml 형식으로 보여준다)
SELECT 
    *
FROM
    index_logs;


--------------------------------------
-- 3. Disable/Enable Trigger
-- 예제에서는 Disable 만 보여주고 있으나 
-- Enable 은 정확히 반대의 개념이기 때문에 Disable 을 Enable 로 바꾸어 추가 실습할 수 있다.
--------------------------------------

/* ------ 3-1. Disable Trigger: (하나의 trigger 를 중심으로) ------*/
-- prep
CREATE TABLE sales.members (
    member_id INT IDENTITY PRIMARY KEY,
    customer_id INT NOT NULL,
    member_level CHAR(10) NOT NULL
);

-- trigger 생성
CREATE TRIGGER sales.trg_members_insert
ON sales.members
AFTER INSERT
AS
BEGIN
    PRINT 'A new member has been inserted';
END;

-- test
INSERT INTO sales.members(customer_id, member_level)
VALUES(1,'Silver');

-- 결과: 간단하게 message 에 출력 확인


-- disable trigger
DISABLE TRIGGER sales.trg_members_insert 
ON sales.members;


-- test
INSERT INTO sales.members(customer_id, member_level)
VALUES(1,'Silver');

-- 결과: 간단하게 message 에 출력 확인이 "안" 되고 있음을 확인. (Disable 시켰기 때문)


/* ------ 3-2. Disable Trigger: (테이블에 있는 모든 trigger 를 disable) ------ */
-- prep
CREATE TRIGGER sales.trg_members_delete
ON sales.members
AFTER DELETE
AS
BEGIN
    PRINT 'A new member has been deleted';
END;

-- disable
DISABLE TRIGGER ALL ON sales.members;

-- 확인: sales.members 의 구조를 GUI 화면에서 확인 - 모든 관계된 trigger disable 

/* ------ 3-3. Enable Trigger: (테이블에 있는 모든 trigger 를 Enable) ------ */
-- 위의 Disable 을 Enable 로 바꾸어 실습할 수 있다. 개념만 반대일 뿐 쓰이는 syntax 는 동일하다.
-- enable
ENABLE TRIGGER ALL ON sales.members;

--------------------------------------
-- 4. TIP: Trigger 구문 확인과 DB 에 존재하는 triggers 들을 한 번 에 확인
--------------------------------------

/* ------- 구문 확인 ------ */
SELECT 
    definition   
FROM 
    sys.sql_modules  
WHERE 
    object_id = OBJECT_ID('sales.trg_members_delete'); 

-- 다른 방법
sp_helptext 'sales.trg_members_delete' ;

/* ------- tirgger 들 확인 ------ */
SELECT  
    name,
    is_instead_of_trigger
FROM 
    sys.triggers  -- 숨겨진 system table
WHERE 
    type = 'TR';


/************************************************
Assignment 6
DML trigger 코드를 분석, 이해 해서 전체 로직에 대한 다이어그램을 그려보기

create schema test

-- prep 0
CREATE TABLE test.Employees
(
    EmployeeID integer NOT NULL IDENTITY(1, 1) ,
    EmployeeName VARCHAR(50) ,
    EmployeeAddress VARCHAR(50) ,
    MonthSalary NUMERIC(10, 2)
    PRIMARY KEY CLUSTERED (EmployeeID)
);

-- prep 1
CREATE TABLE test.EmployeesAudit
(
    AuditID INTEGER NOT NULL IDENTITY(1, 1) ,
    EmployeeID INTEGER ,
    EmployeeName VARCHAR(50) ,
    EmployeeAddress VARCHAR(50) ,
    MonthSalary NUMERIC(10, 2) ,
    ModifiedBy VARCHAR(128) ,
    ModifiedDate DATETIME ,
    Operation CHAR(1) -- 'I' for insert, 'U' for Update and 'D' for Delete
    PRIMARY KEY CLUSTERED ( AuditID )
);


-- prep 2
INSERT INTO test.Employees
        ( EmployeeName ,
          EmployeeAddress ,
          MonthSalary
        )
SELECT 'Mark Smith', 'Ocean Dr 1234', 10000
UNION ALL
SELECT 'Joe Wright', 'Evergreen 1234', 10000
UNION ALL
SELECT 'John Doe', 'International Dr 1234', 10000
UNION ALL
SELECT 'Peter Rodriguez', '74 Street 1234', 10000
GO			

select * from test.Employees
select * from test.EmployeesAudit
-- trigger 작성
-- 우선 이 trigger 작성의 목표는 test.Employees 를 수정하고 있는 사용자를 Audit 하기 위함이다.

CREATE TRIGGER test.TR_Audit_Employees2 
ON test.Employees
FOR INSERT, UPDATE, DELETE -- FOR 혹은 AFTER 
AS
	
    DECLARE @login_name VARCHAR(128)

    -- 아래의 쿼리는 현재 접속한 사용자의 사용자 ID 를 조회
    SELECT  @login_name = login_name
    FROM    sys.dm_exec_sessions 
	-- sys.dm_exec_sessions 라는 내부 뷰를 통해 SQL 서버에 접속해 있는 모든 사용자 정보를 조회할 수 있다.
    WHERE   session_id = @@SPID -- @@SPID: 현재 접속한 사용자에게 SQL 서버가 부여한 ID 를 리턴
	
	-- select SUSER_SNAME()

    IF EXISTS ( SELECT 0 FROM Deleted ) -- select 0 from table 표현: 
										--레코드의 값이 있으면 첫 번째 칼럼 값을 모두 0 으로 처리해서 리턴. 
										--즉 레코드 값이 있는지 없는지를 체크할 때 사용
        BEGIN
            IF EXISTS ( SELECT 0 FROM Inserted ) -- 즉 여기서는 DELETED 와 INSERTED 모두 레코드가 있다는 의미: 다시 말하면 UPDATE 작업이 이뤄지고 있는 경우를 체크
                BEGIN
                    INSERT  INTO test.EmployeesAudit
                            ( EmployeeID ,
                              EmployeeName ,
                              EmployeeAddress ,
                              MonthSalary ,
                              ModifiedBy ,
                              ModifiedDate ,
                              Operation
                            )
                            SELECT  D.EmployeeID ,
                                    D.EmployeeName ,
                                    D.EmployeeAddress ,
                                    D.MonthSalary ,
                                    @login_name ,
                                    GETDATE() ,
                                    'U'
                            FROM    Deleted D
                END
            ELSE -- DELETE 의 경우 체크
                BEGIN
                    INSERT  INTO test.EmployeesAudit
                            ( EmployeeID ,
                              EmployeeName ,
                              EmployeeAddress ,
                              MonthSalary ,
                              ModifiedBy ,
                              ModifiedDate ,
                              Operation
                            )
                            SELECT  D.EmployeeID ,
                                    D.EmployeeName ,
                                    D.EmployeeAddress ,
                                    D.MonthSalary ,
                                    @login_name ,
                                    GETDATE() ,
                                    'D'
                            FROM    Deleted D
                END  
        END
    ELSE -- DELETE 에 관계된 작업이 아닌 경우. 
		 -- 즉 UPDATE (INSERT + DELETE) 혹은 DELETE 가 아닌 경우, 다시 말해 INSERT 인 경우
        BEGIN
            INSERT  INTO test.EmployeesAudit
                    ( EmployeeID ,
                      EmployeeName ,
                      EmployeeAddress ,
                      MonthSalary ,
                      ModifiedBy ,
                      ModifiedDate ,
                      Operation
                    )
                    SELECT  I.EmployeeID ,
                            I.EmployeeName ,
                            I.EmployeeAddress ,
                            I.MonthSalary ,
                            @login_name ,
                            GETDATE() ,
                            'I'
                    FROM    Inserted I
        END
GO

-- test

select * from test.Employees

-- 
INSERT INTO test.Employees
        ( EmployeeName ,
          EmployeeAddress ,
          MonthSalary
        )
SELECT 'Sungmin Smith', 'Ocean Dr 1234', 10000

--
delete from test.Employees where EmployeeID =1

--
update test.Employees set EmployeeName ='update something' where EmployeeId = 2

select * from test.EmployeesAudit

************************************************/
