/*********************************
ddl: data definition language
*********************************/
-- CREATE, DROP, ALTER

--------------------------------------
-- create DB
--------------------------------------
CREATE DATABASE TestDb;


-- confirm 
SELECT   -- or EXEC sp_databases;
    name
FROM 
    master.sys.databases
ORDER BY 
    name;

--------------------------------------
-- drop DB
--------------------------------------
DROP DATABASE IF EXISTS TestDb; -- IF EXISTS : checking

/*-------------------------------
schema : A schema is associated with a username which is known as the schema owner, 
who is the owner of the logically related database objects.

built-in schema: dbo, guest, sys, and INFORMATION_SCHEMA
check with SSMS (not this tool)
--------------------------------*/


--------------------------------------
-- create schema
--------------------------------------
CREATE SCHEMA customer_services;
GO


CREATE TABLE customer_services.jobs(
    job_id INT PRIMARY KEY IDENTITY,
    customer_id INT NOT NULL,
    description VARCHAR(200),
    created_at DATETIME2 NOT NULL
);

--------------------------------------
-- alter schema
--------------------------------------
-- prep
--1
CREATE TABLE dbo.offices -- "default" schema is dbo
(
    office_id      INT
    PRIMARY KEY IDENTITY, 
    office_name    NVARCHAR(40) NOT NULL, 
    office_address NVARCHAR(255) NOT NULL, 
    phone          VARCHAR(20),
);

--2
INSERT INTO 
    dbo.offices(office_name, office_address)
VALUES
    ('Silicon Valley','400 North 1st Street, San Jose, CA 95130'),
    ('Sacramento','1070 River Dr., Sacramento, CA 95820');

--3 sp 는 아직 배우지 않았지만...
CREATE PROC usp_get_office_by_id(
    @id INT
) AS
BEGIN
    SELECT 
        * 
    FROM 
        offices
    WHERE 
        office_id = @id;
END;

--4. 위의 세 가지 진행 모두 dbo 라는 기본 schema 안에서 이뤄지고 있음. 그러므로 아래와 같은 실행 문제 없음
exec usp_get_office_by_id 2

--5. 만약 schema 를 다음과 같이 수정한다면...
ALTER SCHEMA sales TRANSFER OBJECT::dbo.offices; 

--6. 그리고 위의 #4 번과 같이 실행하면
exec usp_get_office_by_id 1

--7. 다음과 같은 에러 발생
/* Invalid object name 'dbo.offices'.
Total execution time: 00:00:00.001
*/

--8. 해결책: 다시 dbo.offices 의 스키마를 되돌리던가, 아니면 stored proc 의 schema 를 같은 sales 로 이동하던가 (여기서는 두 번째의 방법)
ALTER PROC usp_get_office_by_id(
    @id INT
) AS
BEGIN
    SELECT 
        * 
    FROM 
        sales.offices
    WHERE 
        office_id = @id;
END;

-- 다시 실행
exec usp_get_office_by_id 1

--------------------------------------
-- drop schema
-- NOTE: 속해 있는 개체들이 있다면 지울 수 없음
--------------------------------------

-- prep
CREATE SCHEMA logistics;
GO

CREATE TABLE logistics.deliveries
(
    order_id        INT
    PRIMARY KEY, 
    delivery_date   DATE NOT NULL, 
    delivery_status TINYINT NOT NULL
);

-- test
DROP SCHEMA logistics;

-- error 발생
/* Cannot drop schema 'logistics' because it is being referenced by object 'deliveries'.
Total execution time: 00:00:00.002 */


