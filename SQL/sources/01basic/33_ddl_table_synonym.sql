/*********************************
synonym
*********************************/

/*------------------------------- 
synonym: a synonym is an alias or alternative name for a database object such as a table, 
view, stored procedure, user-defined function, and sequence.

일종의 단축 키 생성하는 것과 같이 object 에 접근해서 편이성을 준다.
--------------------------------*/

CREATE SYNONYM orders FOR sales.orders;

-- confirm
SELECT * FROM orders;


--------------------------------*/
-- from another db
--------------------------------*/

-- prep
CREATE DATABASE test;
GO

USE test;
GO

CREATE SCHEMA purchasing;
GO

CREATE TABLE purchasing.suppliers
(
    supplier_id   INT
    PRIMARY KEY IDENTITY, 
    supplier_name NVARCHAR(100) NOT NULL
);

--------------------------------*/
-- synonym 생성
-- 다시 원래 DB 로 이동
--------------------------------*/
use BikeStores

CREATE SYNONYM suppliers 
FOR test.purchasing.suppliers;

-- test
select * from test.purchasing.suppliers

-- synonym 을 생성했기 때문에 아래와 같이 alias 로 접근 가능하다 
select * from suppliers

/*-------------------------------
benefit of synonym

1. 개체 접근 편이성 (DB 와 DB 사이에서)
2. 개체의 이름을 수정할 필요가 있을 때, 원본의 이름은 그대로 두고 synonym 만 생성함으로써, 
기존 이름을 사용하고 있는 application 은 그대로 에러 없이 수정하게 하고 새로운 이름을 사용하는 부분은 추가로 구현하게 할 수 있음
3. 개체 이름이 복잡하다면 개발의 편이성을 위해 단순화 할 수 있게 할 수 있음
--------------------------------*/

/************************************************
Assignment 11

Assingment 10 을 작성했다면, TestDB2.production.Orders 테이블이 생성됐을 것이다.
이에 대한 synonym 을 "BikeStores 라는 DB 에서" 만든 후 그 synonym 이름으로 query를 던지도록 한다.

synonym 의 이름은 productionOrders 라고 한다. 별도로 schema 정보는 붙이지 않는다.

*************************************************/
