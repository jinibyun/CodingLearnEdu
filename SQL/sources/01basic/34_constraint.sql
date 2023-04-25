/*********************************
Constraint
*********************************/

-- Primary Key: NN, ND

--------------------------------------
-- PK with identity
--------------------------------------
CREATE TABLE sales.activities (
    activity_id INT PRIMARY KEY IDENTITY,
    activity_name VARCHAR (255) NOT NULL,
    activity_date DATE NOT NULL
);

--------------------------------------
-- multiple PKs
--------------------------------------
CREATE TABLE sales.participants(
    activity_id int,
    customer_id int,
    PRIMARY KEY(activity_id, customer_id)
);

--------------------------------------
--adding PK to column
--------------------------------------
-- prep
CREATE TABLE sales.events(
    event_id INT NOT NULL,
    event_name VARCHAR(255),
    start_date DATE NOT NULL,
    duration DEC(5,2)
);

-- applying PK using alter statement
ALTER TABLE sales.events 
ADD PRIMARY KEY(event_id);

--------------------------------------
-- Foreign Key: NN, ND
--------------------------------------
-- NOTE: can be null

-- parent table
CREATE TABLE procurement.vendor_groups (
    group_id INT IDENTITY PRIMARY KEY,
    group_name VARCHAR (100) NOT NULL
);

-- child table
CREATE TABLE procurement.vendors (
        vendor_id INT IDENTITY PRIMARY KEY,
        vendor_name VARCHAR(100) NOT NULL,
        group_id INT NOT NULL,
        CONSTRAINT fk_group FOREIGN KEY (group_id) 
        REFERENCES procurement.vendor_groups(group_id)
);

-- test
INSERT INTO procurement.vendor_groups(group_name)
VALUES('Third-Party Vendors'),
      ('Interco Vendors'),
      ('One-time Vendors');

INSERT INTO procurement.vendors(vendor_name, group_id)
VALUES('XYZ Corp',4);

-- error (참조 무결성: Referential Integrity)
-- The INSERT statement conflicted with the FOREIGN KEY constraint "fk_group". The conflict occurred in database "BikeStores", table "procurement.vendor_groups", column 'group_id'.

/*-------------------------------
Referential Action: define the referential actions when the row in the parent table is updated or deleted as follows:

-- 기본 구문
-- FOREIGN KEY (foreign_key_columns)
--     REFERENCES parent_table(parent_key_columns)
--     ON UPDATE action 
--     ON DELETE action;

-- 1. when parent table's record is deleted, in child table there are four cases
-- "ON DELETE NO ACTION": default. 에러 발생
-- "ON DELETE CASCADE": 지워지는 paraent record 관련된 child table 레코드 자동 삭제 
-- "ON DELETE SET NULL": 지워지는 paraent record 관련된 child table 레코드 값을 Null 로 변경 (FK 칼럼이 Null 로 되어 있어야 함)
-- "ON DELETE SET DEFAULT": 지워지는 paraent record 관련된 child table 레코드 값을 default 로 지정된 값으로 변경 (FK 칼럼에 Default 속성이 지정되어 있어야 함)

-- 2. when parent table's record is updated, in child table there are four cases (위의 경우와 동일. delete 가 아니라 update 되는 것만 차이가 있음)
-- "ON UPDATE NO ACTION": 
-- "ON UPDATE CASCADE": 
-- "ON UPDATE SET NULL": 
-- "ON UPDATE SET DEFAULT": 
--------------------------------*/

--------------------------------------
-- NOT NULL
--------------------------------------
-- 앞에서 여러 경우를 들어 이미 설명했음


--------------------------------------
-- Unique
--------------------------------------
-- prep
CREATE SCHEMA hr;
GO

CREATE TABLE hr.persons(
    person_id INT IDENTITY PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE -- 다른 방식으로 UNIQUE(email) 게 정의할 수도 있음
);

-- test
INSERT INTO hr.persons(first_name, last_name, email)
VALUES('John','Doe','j.doe@bike.stores');

INSERT INTO hr.persons(first_name, last_name, email)
VALUES('John','Doe','j.doe@bike.stores');

-- error
-- Violation of UNIQUE KEY constraint 'UQ__persons__AB6E616417240E4E'..... (뒤는 생략)

-- PK 와 UNIQUE 의 차이점
-- PK 는 NN, ND 이지만, UNIQUE 는 ND. 즉 Null 을 허용한다
-- 특별히 다음 예제에서 보여지는 것처럼 Unique 를 이용해서 grouping 을 할 수 있다

--------------------------------------
-- Unique for multiple columns
--------------------------------------
CREATE TABLE hr.person_skills (
    id INT IDENTITY PRIMARY KEY,
    person_id int,
    skill_id int,
    updated_at DATETIME,
    CONSTRAINT unique_personId_skillId UNIQUE (person_id, skill_id) -- 편의상 constraint 이름 "unique_personId_skillId" 지정 가능
);

--------------------------------------
-- Adding Unique constraints to existing tables
--------------------------------------
-- prep
CREATE TABLE hr.persons (
    person_id INT IDENTITY PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(20),
);  

-- apply
ALTER TABLE hr.persons
ADD CONSTRAINT unique_email UNIQUE(email);

ALTER TABLE hr.persons
ADD CONSTRAINT unique_phone UNIQUE(phone); 

-- delete
ALTER TABLE hr.persons
DROP CONSTRAINT unique_phone;

--------------------------------------
-- Check
--------------------------------------
-- specify the values in a column that must satisfy a Boolean expression.

-- prep
CREATE SCHEMA test;
GO

CREATE TABLE test.products(
    product_id INT IDENTITY PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    unit_price DEC(10,2) CONSTRAINT positive_price CHECK(unit_price > 0) -- 편의상 CONSTRAINT positive_price 을 통해 이름 지정
);

-- test
INSERT INTO test.products(product_name, unit_price)
VALUES ('Awesome Free Bike', 0);

-- error
-- The INSERT statement conflicted with the CHECK constraint "positive_price". The conflict occurred in database "BikeStores", table "test.products", column 'unit_price'.


-- NOTE: NULL 은 check 로 check 할 수 없음
INSERT INTO test.products(product_name, unit_price)
VALUES ('Another Awesome Bike', NULL);

--------------------------------------
-- apply check with multiple columns
--------------------------------------
CREATE TABLE test.products(
    product_id INT IDENTITY PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    unit_price DEC(10,2) CHECK(unit_price > 0),
    discounted_price DEC(10,2) CHECK(discounted_price > 0),
    CHECK(discounted_price < unit_price) -- 칼럼에 직접 적용하지 않고 별도로 check 조건 지정 가능
);

-- 다음과 같이 독립적으로 정의 가능
CREATE TABLE test.products(
    product_id INT IDENTITY PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    unit_price DEC(10,2),
    discounted_price DEC(10,2),
    CHECK(unit_price > 0),
    CHECK(discounted_price > 0),
    CONSTRAINT valid_prices CHECK(discounted_price > unit_price)
);

--------------------------------------
-- apply check with existing table
--------------------------------------
-- prep
CREATE TABLE test.products(
    product_id INT IDENTITY PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    unit_price DEC(10,2) NOT NULL
);

-- apply
ALTER TABLE test.products
ADD CONSTRAINT positive_price CHECK(unit_price > 0);

-- apply check adding new column
ALTER TABLE test.products
ADD discounted_price DEC(10,2)
CHECK(discounted_price > 0);

-- apply separate Check
ALTER TABLE test.products
ADD CONSTRAINT valid_price 
CHECK(unit_price > discounted_price);

-- disable: insert 혹은 update 시에 check 를 disable 시키는 option (drop 이 아님)
ALTER TABLE test.products
NO CHECK CONSTRAINT valid_price;




