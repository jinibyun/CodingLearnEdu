/*********************************
transaction
*********************************/
-- single unit of work that typically contains multiple T-SQL statements.

-- prep
CREATE TABLE invoices (
  id int IDENTITY PRIMARY KEY,
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
BEGIN TRANSACTION;

INSERT INTO invoices (customer_id, total)
VALUES (100, 0);

INSERT INTO invoice_items (id, invoice_id, item_name, amount, tax)
VALUES (10, 1, 'Keyboard', 70, 0.08),
       (20, 1, 'Mouse', 50, 0.08);

UPDATE invoices
SET total = (SELECT
  SUM(amount * (1 + tax))
FROM invoice_items
WHERE invoice_id = 1);

COMMIT;

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