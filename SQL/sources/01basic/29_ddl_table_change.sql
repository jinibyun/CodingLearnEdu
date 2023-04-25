/*********************************
alter table
*********************************/
-- prep
CREATE TABLE sales.quotations (
    quotation_no INT IDENTITY PRIMARY KEY,
    valid_from DATE NOT NULL,
    valid_to DATE NOT NULL
);

--------------------------------------
-- add single column
--------------------------------------
ALTER TABLE sales.quotations 
ADD description VARCHAR (255) NOT NULL;

--------------------------------------
-- add multiple column
--------------------------------------
ALTER TABLE sales.quotations 
    ADD 
        amount DECIMAL (10, 2) NOT NULL,
        customer_name VARCHAR (50) NOT NULL;

--------------------------------------
-- alter table alter column
--------------------------------------
-- Modify the data type
-- Change the size
-- Add a NOT NULL constraint

-- prep
CREATE TABLE t1 (c INT);

INSERT INTO t1
VALUES
    (1),
    (2),
    (3);

--------------------------------------
-- column type change
--------------------------------------
ALTER TABLE t1 ALTER COLUMN c VARCHAR (2);

-- test
INSERT INTO t1
VALUES ('@');

-- error
ALTER TABLE t1 ALTER COLUMN c INT;

-- Conversion failed when converting the varchar value '@' to data type int.
-- The statement has been terminated.
-- Total execution time: 00:00:00.016

--------------------------------------
-- column size change
--------------------------------------
-- prep
CREATE TABLE t2 (c VARCHAR(10));

INSERT INTO t2
VALUES
    ('SQL Server'),
    ('Modify'),
    ('Column')

-- change size
ALTER TABLE t2 ALTER COLUMN c VARCHAR (50);

--------------------------------------
-- alter table drop column
--------------------------------------
-- prep
CREATE TABLE sales.price_lists(
    product_id int,
    valid_from DATE,
    price DEC(10,2) NOT NULL CONSTRAINT ck_positive_price CHECK(price >= 0),
    discount DEC(10,2) NOT NULL,
    surcharge DEC(10,2) NOT NULL,
    note VARCHAR(255),
    PRIMARY KEY(product_id, valid_from)
); 

--------------------------------------
-- drop column
--------------------------------------
ALTER TABLE sales.price_lists
DROP COLUMN note;

-- note:
ALTER TABLE sales.price_lists
DROP COLUMN price;

-- error
-- The object 'ck_positive_price' is dependent on column 'price'.
-- Msg 4922, Level 16, State 9, Line 1
-- ALTER TABLE DROP COLUMN price failed because one or more objects access this column.


-- resolution: 제약 조건을 먼저 삭제 한다. 그후에 위의 price column 을 지우면 실행된다
ALTER TABLE sales.price_lists
DROP CONSTRAINT ck_positive_price;