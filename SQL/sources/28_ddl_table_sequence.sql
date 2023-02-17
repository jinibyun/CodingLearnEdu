/*********************************
table
*********************************/

CREATE TABLE sales.visits (
    visit_id INT PRIMARY KEY IDENTITY (1, 1),
    first_name VARCHAR (50) NOT NULL,
    last_name VARCHAR (50) NOT NULL,
    visited_at DATETIME,
    phone VARCHAR(20),
    store_id INT NOT NULL,
    FOREIGN KEY (store_id) REFERENCES sales.stores (store_id)
);

--------------------------------------
-- identity
--------------------------------------
CREATE SCHEMA hr;

CREATE TABLE hr.person (
    person_id INT IDENTITY(1,1) PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    gender CHAR(1) NOT NULL
);

INSERT INTO hr.person(first_name, last_name, gender)
OUTPUT inserted.person_id
VALUES('John','Doe', 'M');

--------------------------------------
-- sequence : 일련번호 생성 개체
--------------------------------------
CREATE SEQUENCE item_counter
    AS INT
    START WITH 10
    INCREMENT BY 10;

-- use
SELECT NEXT VALUE FOR item_counter; -- 한 번 씩 실행할 때마다, 10 씩 늘어나는 value 리턴

--------------------------------------
-- create sequence and apply with table insertion
--------------------------------------
--1
CREATE SCHEMA procurement;
GO

--2
CREATE TABLE procurement.purchase_orders(
    order_id INT PRIMARY KEY,
    vendor_id int NOT NULL,
    order_date date NOT NULL
);

--3
CREATE SEQUENCE procurement.order_number 
AS INT
START WITH 1
INCREMENT BY 1;

--4
INSERT INTO procurement.purchase_orders
    (order_id,
    vendor_id,
    order_date)
VALUES
    (NEXT VALUE FOR procurement.order_number,1,'2019-04-30');


INSERT INTO procurement.purchase_orders
    (order_id,
    vendor_id,
    order_date)
VALUES
    (NEXT VALUE FOR procurement.order_number,2,'2019-05-01');

--5. confirm
select * from procurement.purchase_orders

--------------------------------------
-- create sequence and apply with "multiple" table definition
--------------------------------------
--1
CREATE SEQUENCE procurement.receipt_no
START WITH 1
INCREMENT BY 1;

--2
CREATE TABLE procurement.goods_receipts
(
    receipt_id   INT	PRIMARY KEY 
        DEFAULT (NEXT VALUE FOR procurement.receipt_no), -- NEXT VALUE FOR
    order_id     INT NOT NULL, 
    full_receipt BIT NOT NULL,
    receipt_date DATE NOT NULL,
    note NVARCHAR(100),
);


CREATE TABLE procurement.invoice_receipts
(
    receipt_id   INT PRIMARY KEY
        DEFAULT (NEXT VALUE FOR procurement.receipt_no), -- NEXT VALUE FOR
    order_id     INT NOT NULL, 
    is_late      BIT NOT NULL,
    receipt_date DATE NOT NULL,
    note NVARCHAR(100)
);

--3. data insertion: identity 속성과 마찬가지로 사용자는 "receipt_id" 칼럼의 값을 정할 수 없다.
INSERT INTO procurement.goods_receipts(
    order_id, 
    full_receipt,
    receipt_date,
    note
)
VALUES(
    1,
    1,
    '2019-05-12',
    'Goods receipt completed at warehouse'
);
INSERT INTO procurement.goods_receipts(
    order_id, 
    full_receipt,
    receipt_date,
    note
)
VALUES(
    1,
    0,
    '2019-05-12',
    'Goods receipt has not completed at warehouse'
);

INSERT INTO procurement.invoice_receipts(
    order_id, 
    is_late,
    receipt_date,
    note
)
VALUES(
    1,
    0,
    '2019-05-13',
    'Invoice duly received'
);
INSERT INTO procurement.invoice_receipts(
    order_id, 
    is_late,
    receipt_date,
    note
)
VALUES(
    2,
    0,
    '2019-05-15',
    'Invoice duly received'
);


--4. confirm
SELECT * FROM procurement.goods_receipts;
SELECT * FROM procurement.invoice_receipts;

/*-------------------------------
identity 와 sequence 의 차이점

----------------------------------------------------------------------------------------
특징	                                                    Identity	Sequence Object
----------------------------------------------------------------------------------------
Allow specifying minimum and/or maximum increment values	No	        Yes
Allow resetting the increment value	                        No	        Yes
Allow caching increment value generating	                No	        Yes
Allow specifying starting increment value	                Yes	        Yes
Allow specifying increment value	                        Yes	        Yes
Allow using in multiple tables	                            No	        Yes
---------------------------------------------------------------------------------------

-- sequence object 사용 고려 사항 (identity 대신에)
-- 여러 table 에 걸쳐서 증가하는 일련 번호가 필요할 경우
-- 일련 번호의 한계치에 도달했을 때 다시 처음부터 일련번호를 시작할 경우
--------------------------------*/

