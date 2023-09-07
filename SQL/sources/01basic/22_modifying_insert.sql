/*********************************
insert
*********************************/

-- prep
CREATE TABLE sales.promotions (
    promotion_id INT PRIMARY KEY IDENTITY (1, 1),
    promotion_name VARCHAR (255) NOT NULL,
    discount NUMERIC (3, 2) DEFAULT 0,
    start_date DATE NOT NULL,
    expired_date DATE NOT NULL
); 

--------------------------------------
-- basic insert
--------------------------------------
-- note: column with identity cannot be inserted
INSERT INTO sales.promotions (
	--	promotion_id, 안되는 이유: identity  속성을 가진 칼럼은 SQL 서버가 자동으로 번호를 입력하기 때문.
    promotion_name,
    discount,
    start_date,
    expired_date
)
VALUES
    (
        '2018 Summer Promotion',
        0.15,
        '20180601',
        '20180901'
    );

select * from sales.promotions
--------------------------------------
-- inserted table 응용
--------------------------------------
INSERT INTO sales.promotions (
    promotion_name,
    discount,
    start_date,
    expired_date
) OUTPUT inserted.promotion_id, -- inserted 라고 하는 "특별한" 시스템 테이블 (자료 입력 전에 임시로 저장되는 table. 자료 입력 후에 자동으로 비워짐)
 inserted.promotion_name,
 inserted.discount,
 inserted.start_date,
 inserted.expired_date
VALUES
    (
        '2018 Winter Promotion',
        0.2,
        '20181201',
        '20190101'
    );

--------------------------------------
-- insert with multiple values
--------------------------------------
INSERT INTO sales.promotions (
    promotion_name,
    discount,
    start_date,
    expired_date
)
VALUES
    (
        '2019 Summer Promotion',
        0.15,
        '20190601',
        '20190901'
    ),
    (
        '2019 Fall Promotion',
        0.20,
        '20191001',
        '20191101'
    ),
    (
        '2019 Winter Promotion',
        0.25,
        '20191201',
        '20200101'
    );

--------------------------------------
-- insert into select: 다른 테이블의 자료를 조회해서 삽입하기
--------------------------------------
-- prep
CREATE TABLE sales.addresses (
    address_id INT IDENTITY PRIMARY KEY,
    street VARCHAR (255) NOT NULL,
    city VARCHAR (50),
    state VARCHAR (25),
    zip_code VARCHAR (5)
);   

--------------------------------------
-- insert into select
--------------------------------------
INSERT INTO sales.addresses (street, city, state, zip_code) 
	SELECT
		street,
		city,
		state,
		zip_code
	FROM
		sales.customers
	ORDER BY
		first_name,
		last_name; 

		select * from sales.addresses