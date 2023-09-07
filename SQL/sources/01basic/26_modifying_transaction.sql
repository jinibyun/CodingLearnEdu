/*********************************
transaction
*********************************/
-- single unit of work that typically contains multiple T-SQL statements.

-- prep
DROP TABLE invoice_items
DROP TABLE invoices

CREATE TABLE invoices (
  id int PRIMARY KEY,
  customer_id int NOT NULL,
  total decimal(10, 2) NOT NULL DEFAULT 0 CHECK (total >= 0)
);

CREATE TABLE invoice_items (
  id int,
  invoice_id int NOT NULL,
  item_name varchar(100) NOT NULL,
  amount decimal(10, 2) NOT NULL CHECK (amount >= 0),
  tax decimal(4, 2) NOT NULL CHECK (tax >= 0),
  PRIMARY KEY (id, invoice_id),
  FOREIGN KEY (invoice_id) REFERENCES invoices (id)
	ON UPDATE CASCADE
	ON DELETE CASCADE
);

--------------------------------------
-- applying transcation : explain with @@error and rollback transaction as well
--------------------------------------
BEGIN TRANSACTION; -- 이 구문과 함께 아래의 수정, 삭제, 입력 구문을 실행하게 되면 관련 프로세스가 트랜잭션이라는 프로세스 범위 안에서 실행되기 때문에, 100% 실행, 100% 취소 둘 중의 하나가 보장된다.

	-- 1
	INSERT INTO invoices (id, customer_id, total)
	VALUES (1, 100, 0);

if @@error != 0 -- @@ 전역 변수 (시스템의 변수)    @@error: 시스템 에러 번호 리턴 . 만약 0 이라면 에러가 없다는 의미이다. 그러므로 여기에서는 != 같지 않다라는 표현을 사용했기 때문에 어떤 에러가 발생했다는 의미이다
	ROLLBACK TRANSACTION;
else
	COMMIT TRANSACTION;

select * from invoices;
select * from invoice_items;

/************************************************
Assignment 9

위의 begin tran, commit tran 그리고 rollback tran 을 이용하여 다음의 insert 구문과 update 구문을 정의한다.

```
INSERT INTO sales.promotions (
    promotion_name,
    discount,
    start_date,
    expired_date
)
VALUES
    (
        '2023 Summer Promotion',
        0.15,
        '20230601',
        '20230901'
    ),
    (
        '2023 Fall Promotion',
        0.20,
        '20231001',
        '20231101'
    ),
    (
        '2023 Winter Promotion',
        0.25,
        '20231201',
        '20230101'
    );
```


```
update sales.promotions
set discount = discount + 1.00
where start_date > '20221231'
``` 
*************************************************/

begin tran -- begin transaction 대신에 begin tran 으로 적어도 무방
    INSERT INTO sales.promotions (
    promotion_name,
    discount,
    start_date,
    expired_date
    )
    VALUES
        (
            '2023 Summer Promotion',
            0.15,
            '20230601',
            '20230901'
        ),
        (
            '2023 Fall Promotion',
            0.20,
            '20231001',
            '20231101'
        ),
        (
            '2023 Winter Promotion',
            0.25,
            '20231201',
            '20230101'
        );

    update sales.promotions
    set discount = discount + 1.00

if @@error <> 0
    Rollback tran
else
    Commit tran
