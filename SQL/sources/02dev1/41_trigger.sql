/*********************************
trigger: DB 에서 이뤄지는 하나의 Action 에 반응하여 다른 Action 이 자동으로 발생. 첫 번 째 Action 의 후에만 발생하는 것이 아니라, 설정에 따라 "전 혹은 후" 에 발생 가능
*********************************/

-- 3 types
-- 1. DML triggers: INSERT, UPDATE, and DELETE events
-- 2. DDL triggers: CREATE, ALTER, and DROP statements. DDL 관련 stored procedures 도 이에 해당
-- 3. Logon triggers: LOGON events  (로그인 tracking과 session 수 제한 하기 위해서 사용. 예제는 생략)

Creating a trigger in SQL Server – show you how to create a trigger in response to insert and delete events.

--------------------------------------
-- 1. DML Trigger
--------------------------------------

-- prep
CREATE TABLE production.product_audits(
    change_id INT IDENTITY PRIMARY KEY,
    product_id INT NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    brand_id INT NOT NULL,
    category_id INT NOT NULL,
    model_year SMALLINT NOT NULL,
    list_price DEC(10,2) NOT NULL,
    updated_at DATETIME NOT NULL,
    operation CHAR(3) NOT NULL,
    CHECK(operation = 'INS' or operation='DEL')
);

-- create "After" trigger
-- 아래 trigger 의 역할은 production.products 테이블에서 어떤 레코드가 삽입, 삭제 될때마다 그 레코들을 production.product_audits table 에 기록한다
CREATE TRIGGER production.trg_product_audit
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
        'INS'
    FROM
        inserted i    -- 주의: INSERTED 라고 하는 시스템 임시 table 이용
    UNION ALL
    SELECT
        d.product_id,
        product_name,
        brand_id,
        category_id,
        model_year,
        d.list_price,
        GETDATE(),
        'DEL'
    FROM
        deleted d;  -- 주의: DELETED 라고 하는 시스템 임시 table 이용
END

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
FOR	-- event type: DDL event. 예를 들어 CREATE_TABLE, ALTER_TABLE, etc . 밑에 정의한 세 가지 action 모두 subsribe 하고 있다.
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
        EVENTDATA(), -- 특별한 함수로써, server 혹은 database 에서 발생하는 정보를 return 한다. 이 함수는 특별히 ddl trigger 혹은 logon trigger 에서만 사용가능
        USER
    );
END;
GO

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
-- 예제에서는 Disable 만 보여주고 있으나 Enable 은 정확히 반대의 개념이기 때문에 Disable 을 Enable 로 바꾸어 추가 실습할 수 있다.
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
EXEC sp_helptext 'sales.trg_members_delete' ;

/* ------- tirgger 들 확인 ------ */
SELECT  
    name,
    is_instead_of_trigger
FROM 
    sys.triggers  -- 숨겨진 system table
WHERE 
    type = 'TR';


