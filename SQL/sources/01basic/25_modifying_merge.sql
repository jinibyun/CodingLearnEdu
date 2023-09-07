/*********************************
merge (insert , update, delete 구문을 한 번에 정의해서 사용)
*********************************/
-- perform three actions(insert, update, delete) "at the same time"


-- prep: source: category_staging  / target: category
CREATE TABLE sales.category (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(255) NOT NULL,
    amount DECIMAL(10 , 2 )
);

INSERT INTO sales.category(category_id, category_name, amount)
VALUES(1,'Children Bicycles',15000),
    (2,'Comfort Bicycles',25000),
    (3,'Cruisers Bicycles',13000),
    (4,'Cyclocross Bicycles',10000);


CREATE TABLE sales.category_staging (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(255) NOT NULL,
    amount DECIMAL(10 , 2 )
);

-- (참고) staging 이라는 naming convention 은 일반적으로 source table 에 붙인다.
INSERT INTO sales.category_staging(category_id, category_name, amount)
VALUES(1,'Children Bicycles',15000),
    (3,'Cruisers Bicycles',13000),
    (4,'Cyclocross Bicycles',20000),
    (5,'Electric Bikes',10000),
    (6,'Mountain Bikes',10000);

--------------------------------------
-- doing merge against "target" table which is "category" table
--------------------------------------
MERGE sales.category t -- target table
    USING sales.category_staging s -- source table
ON (s.category_id = t.category_id) -- on condition must be defined
-- when 은 일종의 query 구문 안의 if
WHEN MATCHED -- merge condition: MATCHED, NOT MATCHED (BY TARGET), NOT MATCHED BY SOURCE
    THEN UPDATE SET 
        t.category_name = s.category_name,
        t.amount = s.amount
WHEN NOT MATCHED BY TARGET -- BASED ON SOURCE
    THEN INSERT (category_id, category_name, amount)
         VALUES (s.category_id, s.category_name, s.amount)
WHEN NOT MATCHED BY SOURCE -- BASED ON TARGET
    THEN DELETE;
