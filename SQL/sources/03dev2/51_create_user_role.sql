/*********************************
user and role: 
*********************************/
-- 크게 나누어 Authentication 과 Authorization 두 가지로 나누어 생각
-- 이 장에서는 다른 사용자로 접근해서 테스트 할 필요가 있기 때문에 SSMS 를 별도로 하나 더 열어두고 (아직 로그인 하지 않고) 테스트 한다.
-- 그리고 사전에 SQL 서버의 보안 사항을 체크해서 (SQL Server Login 계정이 가능하도록 설정해 두어야 한다.)

-------------------------------
-- Authentication: create login and user
-------------------------------
/* ------ create login -------- */
-- 기본적인 password 규칙: 대소문자 구별. 8 - 128 문자열. a-z, A-Z, 0-9, 그외 ' 를 제외한 대부분의 특수문자 사용가능
CREATE LOGIN testUser1_new
WITH PASSWORD='qwerasdf!!';

-- NOTE: 계정을 생성했다고해도 아직 어떤 DB 에 접근할 수 있는 것은 아니다.

-- 모든 login 정보 확인
SELECT
  sp.name AS login,
  sp.type_desc AS login_type,
  CASE
    WHEN sp.is_disabled = 1 THEN 'Disabled'
    ELSE 'Enabled'
  END AS status,
  sl.password_hash,
  sp.create_date,
  sp.modify_date
FROM sys.server_principals sp
LEFT JOIN sys.sql_logins sl
  ON sp.principal_id = sl.principal_id
WHERE sp.type NOT IN ('G', 'R')
ORDER BY create_date DESC;

-- create login 의 다른 옵션들
/*
CREATE LOGIN login_name
WITH PASSWORD = password MUST_CHANGE, -- 두 번 째 로그인 부터 패스워드 반드시 수정해야 함
CHECK_POLICY = {ON | OFF}; -- 윈도우 비밀번호 정책을 sql server login 에 적용
CHECK_EXPIRATION = {ON | OFF}; -- 패스워드 만료일 지정 
*/
-- 위도우의 도메인 acccount 로 부터 sql login 생성
/*
CREATE LOGIN domain_name\login_name
FROM WINDOWS;
*/

-- NOTE: 계정을 생성한 후에 "별도로" 지금 실행하고 있는 DB 에 CREATE USER 를 해 주어야 한다.
CREATE USER testUser1_new
FOR LOGIN testUser1_new; -- 이미 생성한 login 을 통해 해당 DB 에서 접근하도록 user 생성. 여기에서는 같은 이름 사용했음

-- NOTE: testUser1 는 로그인해서 DB 에 접근은 할 수 있지만, 아직 DB 에 있는 table 과 같은 resource 에 접근할 수 있는 것은 아니다.
-- 결과: 다른 SSMS 를 연 상태에서 테스트를 해 보면 connection 은 정상적으로 만들어 졌지만, BikeStores DB 의 table 조차 확인할 수 없다.

/* LOGIN 관련 기타 다른 Action */
Use BikeStores

-- Login 비활성화
ALTER LOGIN testUser1
DISABLE;

-- Login 활성화
ALTER LOGIN testUser1
ENABLE;

-- Login 이름 바꾸기 (testUser1 을 testUser101 으로)
ALTER LOGIN testUser1
WITH NAME = testUser101;

-- 패스워드 바꾸기
ALTER LOGIN testUser1_new
WITH PASSWORD = 'qwerasdf!!!!';

-- 만약 로그인이 login lock 에 걸려서 더 이상 로그인 할 수 없는 경우 (몇 번의 연속된 실패) lock 을 풀어주는 옵션
ALTER LOGIN testUser1_new
WITH PASSWORD='qwerasdf!!!!!!'
UNLOCK;

-- 로그인 지우기
DROP LOGIN testUser1_new;

-- TIP: 일반적으로 사용자 생성 하고, 그 사용자를 이용해서 로그인을 생성하는데, 이때 로그인 자체를 삭제하게 되면 사용자와 로그인 사이에 mapping 이 끊어지게 된다.
-- 이때 "Orphaned User" 들을 검색하는 쿼리
create login testUser2
with password ='qwerasdf!!'

use BikeStores;
CREATE USER testUser2
FOR LOGIN testUser2;

drop login testUser2


SELECT
  dp.type_desc,
  dp.sid,
  dp.name AS user_name
FROM sys.database_principals AS dp
LEFT JOIN sys.server_principals AS sp
  ON dp.sid = sp.sid
WHERE sp.sid IS NULL
AND dp.authentication_type_desc = 'INSTANCE';

-- 이에 대한 해결책은 다음의 두 가지로 진행한다.
-- 1
-- CREATE LOGIN new_login_name
-- WITH PASSWORD = 'qwerasdf!!',
-- 	 SID = 0xC48461C284AE024EB42149BFDBCD18A8; -- 이 SID 는 위킈 쿼리에 대한 결과로 알 수 있다
-- 2
-- ALTER USER orphaned_user 
-- WITH LOGIN = login_name;


/* USER 관련 기타 다른 Action  */
-- User 이를 바꾸기
ALTER USER testUser1 -- 주의: 여기에서는 로그인의 이름을 바꾸는 것이 아니라 User 이름을 바꾸는 것이다.
WITH NAME = testUser101;

-- 기본 schema 정보 바꾸기
ALTER USER testUser1_new
WITH DEFAULT_SCHEMA = sales; -- 참고: 기본적으로 사용자 생성시 모든 사용자의 기본 schema 는 dbo 가 된다.

-- Login 정보와 User 정보를 mapping 하는 방법
Use BikeStores

CREATE LOGIN Tom -- 새로운 Login 생성
WITH PASSWORD = 'qwerasdf!!';

-- 새롭게 생긴 login 을 이미 있는 User 와 mapping
ALTER USER testUser1
WITH LOGIN = Tom;

-- 사용자 지우기
DROP USER testUser101

-- 주의: 만약 어떤 리소스에 대한 접근을 허락된 상태라면 바로 지워지지 않는다.
-- test
CREATE LOGIN anthony_new
WITH PASSWORD ='qwerasdf!!';

CREATE USER anthony_new
FOR LOGIN anthony_new;

CREATE SCHEMA report_new -- 스키마를 생성하면서 tony 에게 소유권 지정
AUTHORIZATION anthony_new;

CREATE TABLE report_new.daily_sales (
	Id INT IDENTITY PRIMARY KEY,
	Day DATE NOT NULL,
	Amount DECIMAL(10,2) NOT NULL DEFAULT 0
);

-- 실행
DROP USER anthony_new;

-- 에러 발생
-- Msg 15138, Level 16, State 1, Line 1
-- The database principal owns a schema in the database, and cannot be dropped.

-- 해결
-- 우선 tonly 에게 할당된 스키마 권한을 다른 사람에게 양도해야 함
-- 예)
ALTER AUTHORIZATION 
ON SCHEMA::report_new 
TO dbo; -- sql 서버의 내부 기본 사용자

-- 다시 실행
DROP USER anthony_new; -- 이번에는 성공적으로 제거된다.


-------------------------------
-- Authorization: Grant, Revoke
-------------------------------
-- 위에서 기본적으로 생성한 Authentication 을 바탕으로 자료에 대한 접근 권한을 주는 것을 Autorization 이라고 하며
-- 이를 GRANT 와 REVOKE 구문으로 진행 한다.
/* 
기본 구문

GRANT permissions
ON securable TO principal; -- securable 은 리소스를 의미, principal 은 사용자
*/

/* GRANT */
-- prep
-- 1. DB 생성, table 생성, 자료 입력
USE master;
GO

DROP DATABASE IF EXISTS HR;
GO

CREATE DATABASE HR;
GO

USE HR;

CREATE TABLE People (
  Id int IDENTITY PRIMARY KEY,
  FirstName varchar(50) NOT NULL,
  LastName varchar(50) NOT NULL
);

INSERT INTO People (FirstName, LastName)
  VALUES ('John', 'Doe'),
  ('Jane', 'Doe'),
  ('Upton', 'Luis'),
  ('Dach', 'Keon');

-- 2. 로그인 생성
CREATE LOGIN peter_new
WITH PASSWORD='qwerasdf!!';

-- 3. 유저 생성
USE HR;

CREATE USER peter_new
FOR LOGIN peter_new;

-- test
-- peter 로 로그인 해서 DB 접근하지만, DB 자료 볼 수 없음을 확인

-- 4. 다시 admin 으로 접근해서 다음을 실행 (별도오 SSMS 에서 Property 를 통해 확인할 수 있다)
GRANT SELECT 
ON People TO peter_new;

-- test
-- peter 로 로그인 해서 DB 접근해서 table 자료 확인
SELECT * FROM People;

-- test
-- peter 로 로그인 해서 table 입력할 수 "없음" 을 확인
INSERT INTO People(FirstName, LastName)
VALUES('Tony','Blair');

DELETE FROM People -- 마찬가지로 할 수 "없음" 을 확인 (The INSERT permission was denied on the object 'People', database 'HR', schema 'dbo'.)
WHERE Id = 1;


-- 5. 다시 admin으로 접근해서 다음을 실행
GRANT INSERT, DELETE, UPDATE
ON People TO peter_new;

-- test
-- peter 로 로그인 해서 아래의 두 구문이 "정상적으로" 실행되고 있음을 확인
INSERT INTO People(FirstName, LastName)
VALUES('Tony','Blair');

DELETE FROM People -- 마찬가지로 할 수 "없음" 을 확인
WHERE Id = 1;

/* REVOKE */
/*
기본 구문
REVOKE permissions
ON securable
FROM principal;
*/
REVOKE DELETE
ON People
FROM peter_new;

-- test (Peter 로 접근해서)
DELETE FROM People -- 마찬가지로 할 수 "없음" 을 확인 (The DELETE permission was denied on the object 'People', database 'HR', schema 'dbo'.)
WHERE Id = 1;


REVOKE SELECT, INSERT
ON People
FROM peter_new;

-- test (Peter 로 접근해서)
select * from People -- 마찬가지로 할 수 "없음" 을 확인 ( The SELECT permission was denied on the object 'People', database 'HR', schema 'dbo'.)



------------------------------------
-- Role: Group of permission
------------------------------------
-- 일반적인 시나리오
-- user -->> role -->> permission(s): 즉 개별로 user 을 permission 에 매핑 시키는 것이 아니라, permission 들을 가지고 있는 role 에 매핑
-- 이미 SQL server 에서 생성된 role 이 있고, 사용자가 정의해서 별도로 role 을 생성할 수 있다.
-- 위에서 진행했던 grant 작업은 user 를 개별적인 permission 에 매핑 시켰었던 작업이다
-- Server 수준, 혹은 Database 수준에서 지정 가능하다.

/* ------- 시스템 role -------- */
-- 다음의 ref 는 Database 수준에서 정의된 system role 이다.
-- ref: https://learn.microsoft.com/en-us/sql/relational-databases/security/authentication-access/database-level-roles?view=sql-server-ver16

use BikeStores;

CREATE LOGIN tiger_new
WITH PASSWORD='qwerasdf!!';

CREATE USER tiger_new
FOR LOGIN tiger_new;

-- 현재 까지는 tiger 에 어떤 grant 작업을 하지 않았기 때문에 tiger 가 접속을 할 수는 있어도 어떤 object 에 대한 접근을 진행할 수 없다.
ALTER ROLE db_datareader -- 기본적인 db_datareader 라는 그룹에 tiger 를 포함 시킨다. (이미 db_datareader 라는 그룹, 즉 role 은 일정한 permission 들을 포함하고 있다)
ADD MEMBER tiger_new;

-- test
-- DB 에 포함된 table 과 view 에 대해 읽기 작업 가능
-- tiger 로 접속해서 simple query 를 던져 본다.
SELECT * FROM sales.orders;

-- 참고로 위의 role 에 추가하는 기능은 다음의 의미를 갖는다.
-- GRANT SELECT 
-- ON DATABASE::BikeStores -- :: 뒤에 DB 를 명시하는 구문도 참고. (클래스 타입:: 값)
-- TO tiger;

-- 사용할 수 있는 클래스 타입
-- LOGIN
-- DATABASE
-- OBJECT
-- ROLE
-- SCHEMA
-- USER

/* ------- 사용자 정의 role -------- */
-- 1
CREATE LOGIN mary_new
WITH PASSWORD='qwerasdf!!';

-- 2
USE BikeStores;

CREATE USER mary_new 
FOR LOGIN mary_new;

-- 3 사용자 정의 role 생성
CREATE ROLE sales_report_new;

-- 4 생성한 (아직 어떠한 permission 도 매핑되어 있지 않은 sales_report) role 에 클래스:: 구문  을 이영하여 매핑
GRANT SELECT -- 추가로 SELECT, INSERT, UPDATE, DELETE 지정 가능
ON SCHEMA::Sales 
TO sales_report_new;

-- 5. 마지막으로 매핑된 role 에 사용자 추가
ALTER ROLE sales_report_new
ADD MEMBER mary_new;

-- 6. test (mary 로 접근)
-- 결과: mary 로 오직 sales 라는 schema 로 정의된 table 만 보게 된다.


-- TIP. Role 정보 확인
SELECT
  name,
  principal_id,
  type,
  type_desc,
  owning_principal_id
FROM sys.database_principals
WHERE name in ('sales_report_new', 'db_datareader');


/* role 생성 / 삭제, member 추가, member 삭제 */

-- role 생성
CREATE ROLE production;

-- role 이름 변경
ALTER ROLE production
WITH NAME = production_new;

-- 멤버 추가
ALTER ROLE manufacturing 
ADD MEMBER tiger; -- tiger 는 이미 생성한 user

-- 확인: Database role 에 포함된 user list 출력
SELECT
  r.name role_name,
  r.type role_type,
  r.type_desc role_type_desc,
  m.name member_name,
  m.type member_type,
  m.type_desc meber_type_desc
FROM sys.database_principals r
INNER JOIN sys.database_role_members rm ON rm.role_principal_id = r.principal_id
INNER JOIN sys.database_principals m ON m.principal_id = rm.member_principal_id
WHERE r.name ='sales_report_new';

-- 멤버 삭제
ALTER ROLE sales_report_new
DROP MEMBER mary_new;

-- test: 다시 위의 '확인' 쿼리를 던져서 확인한다.

-- NOTE: role 을 삭제 한다는 것은 role 에 연관된 member 가 없어야 하고, 연관된 permission 이 없어야 한다는 의미이다.
-- db_datareader, db_datawriter, db_securityadmin 같이 이미 지정된 system role 은 삭제할 수 없다
CREATE ROLE sales_production_new;

DROP ROLE IF EXISTS sales_production_new; -- 삭제 가능
DROP ROLE IF EXISTS sales_report_new; -- 삭제 불가능

-- 앞에서 던졌던 쿼리 이용해서 속해 있는 사용자 알아보기
SELECT
  r.name role_name,
  r.type role_type,
  r.type_desc role_type_desc,
  m.name member_name,
  m.type member_type,
  m.type_desc member_type_desc
FROM sys.database_principals r
INNER JOIN  sys.database_role_members  rm on rm.role_principal_id = r.principal_id
INNER JOIN sys.database_principals m on m.principal_id = rm.member_principal_id
WHERE r.name ='sales_report_new';

-- 레코드가 있다면 멤버 삭제
ALTER ROLE sales_report_new
DROP MEMBER mary_new;

ALTER ROLE sales_report
DROP MEMBER mary;

-- 멤버 삭제 후 실행
DROP ROLE IF EXISTS sales_report; -- 삭제 가능



/*******************************************
Assingment 16

1. Login 계정 생성. 이름은 gunsAndroses 
    create login gunsAndroses_new
    with password = 'qwerasdf!!'
2. 새로운 DB 생성. 이름은 musicDB
    use master;
	create database musicDB_new
3. musicDB 안에서 User 생성: Login 이름과 같은 이름으로
	use musicDB_new;
	create user gunsAndroses_new
	for login gunsAndroses_new;
4. test (로그인 test)
	
5. 관리자가 mucisDB 에서 스키마 생성. 이름은 music. 이 스키마를 생성하면서 gunsAndroses 에게 소유권 지정
	create schema music_new
	AUTHORIZATION gunsAndroses_new;
6. schema 정보를 바탕으로 2-3 개의 간단한 table 생성
	create table music_new.music_genre(id int, name varchar(40));
	create table music_new.music_genre2(id int, name varchar(40));
7. gunsAndroses 로 로그인 후 이 table 을 볼 수 있는 지 확인

8. sql 서버의 내부 기본 사용자인 dbo 에게 music schema 에 대한 권한 양도
	ALTER AUTHORIZATION 
	ON SCHEMA::music_new 
	TO dbo; -- sql 서버의 내부 기본 사용자
9. 아무 table 도 볼 수 없음 확인 (gunsAndroses)
	
10. 권한은 양도 했지만, 별도로 위에서 생성한 table 예를 들어 (music.genre table) 에 별도의 grant 명령을 통해 접근하게 함 (select, insert, update ,delete 모두)
	GRANT select, insert, update ,delete
	ON music_new.music_genre
	TO gunsAndroses_new
11. Revoke 명령을 통해, 10 번에서 부여했던 insert, update, delete 권한 없애고 오직 읽기로만 가능하도록.
	REVOKE insert, update ,delete
	ON music_new.music_genre
	FROM gunsAndroses_new

12. 사용자 정의 role 생성. 이름은 music_role. 위에서 생성한 music schema 에 대한 select, insert ,update, delete 모든 기능을 music_role 이라는 role 에 매핑
	create role  music_role;

	GRANT SELECT, INSERT, UPDATE, DELETE
	ON SCHEMA::music_new 
	TO music_role;


13. 이 새로운 music_role 에 gunsAndroses 추가
	alter role music_role
	add member gunsAndroses_new

14. gunsAndroses 가 insert, update, delete, update 할 수 있는 지 간단히 확인 (구문으로 하지 않고, 편의상 gui 환경으로 해도 무방)
	
15. music_role 에 누가 속해 있는 지 확인
	SELECT
	  r.name role_name,
	  r.type role_type,
	  r.type_desc role_type_desc,
	  m.name member_name,
	  m.type member_type,
	  m.type_desc member_type_desc
	FROM sys.database_principals r
	INNER JOIN  sys.database_role_members  rm on rm.role_principal_id = r.principal_id
	INNER JOIN sys.database_principals m on m.principal_id = rm.member_principal_id
	WHERE r.name ='music_role';
	
16. gunsAndroses 를 music_role 에서 삭제하고, music_role 도 삭제
	alter role music_role
	drop member gunsAndroses_new

17. 최종적으로 gunsAndroses 는 10 번의 상태로 돌아가서 select 권한만 가지게 된 것을 확인
	drop role if exists music_role

********************************************/