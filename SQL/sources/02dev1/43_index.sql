/*********************************
index: table 과 view 의 data 조회 성능 향상을 위한 특별한 형식의 데이타 구조 
세 가지 종류의 index: clustered index 와 non-clustered index 그리고 unique index
(여기에서는 주로 사용하는 clustered index 와 non-clusterd index 를 연습한다.)

*********************************/

/* ------ Index 의 개념에 대해 우선 "Index개념.xlsx" file 을 통해 개념을 익히도록 한다. ------- */

--------------------------------------
-- 1. clustered index
--------------------------------------
-- 1.1 without index
-- prep
-- PK 설정이 되어 있지 않은 table 생성 후 데이타 입력
CREATE TABLE production.parts(
    part_id   INT NOT NULL, 
    part_name VARCHAR(100)
);

INSERT INTO 
    production.parts(part_id, part_name)
VALUES
    (1,'Frame'),
    (2,'Head Tube'),
    (3,'Handlebar Grip'),
    (4,'Shock Absorber'),
    (5,'Fork');

-- test
-- query 결과 값이 중요한 것이 아니라, Estimated Plan (Ctrl + L) 을 확인하면 100 % table scan 한 것을 확인
SELECT 
    part_id, 
    part_name
FROM 
    production.parts
WHERE 
    part_id = 5;

-- NOTE: data 양이 많으면 100 % table scanning 은 조회 성능을 저하시킨다.

/* --------- clustered index -----------*/
-- key 값을 바탕으로 정렬하여 데이타를 저장 시킨다 (참고로 clustered table 이라고도 불린다)
-- 하나의 table 에 단 하나의 clustered index 생성 가능
-- B-Tree node: root node (index) - more than on intermedate node(index) - more than one leaf node (data)
-- table 에 PK 를 생성해서 정의하는 순간 "자동으로" clustered index 생성


-- 1.2 with index
-- prep
CREATE TABLE production.part_prices(
    part_id int,
    valid_from date,
    price decimal(18,4) not null,
    PRIMARY KEY(part_id, valid_from) 
);

-- 참고: 아래와 같이 만약 table 구조를 수정하여 새로운 칼럼을 PK 에 포함 시킨다면, 그 부분에 대해서는 별도의 non-clustered index 가 생성된다.
ALTER TABLE production.parts
ADD PRIMARY KEY(part_id);

-- 1.3 apply index to table with no PK
CREATE CLUSTERED INDEX ix_parts_id -- 주의: 만약에 Clustered 라는 말이 생략되면 non clustered index 가 생성된다.
ON production.parts (part_id);  


-- 1.4 see the result of applying index using estimated plan
-- "Index seek" (테이블 스캔이 아님) 
SELECT 
    part_id, 
    part_name
FROM 
    production.parts
WHERE 
    part_id = 5;


--------------------------------------
-- 2. non clustered index
--------------------------------------
-- clustered index 와는 달리 a nonclustered index 는 Data Page 를 그대로 둔 상태에서, 별도로 leaf page 와 root page 를 구성한다. 
-- 이 때 clustered index 와 마찬가지로 B Tree 를 구성한다.

SELECT 
    customer_id, 
    city
FROM 
    sales.customers
WHERE 
    city = 'Atwater';
-- estimated plan 을 보면 clustered index 을 타긴 하지만, city 칼럼이 적용되지 않았다.


-- non clustered index 생성
CREATE INDEX ix_customers_city -- [NONCLUSTERED] 라는 말을 생략 가능
ON sales.customers(city);

-- test
SELECT 
    customer_id, 
    city
FROM 
    sales.customers
WHERE 
    city = 'Atwater';

-- estimated plan 을 보면 city 칼럼이 적용된 것을 확인할 수 있다.
  

/* --------- multiple columns 에 non clustered index 적용 -------- */
CREATE INDEX ix_customers_name 
ON sales.customers(last_name, first_name); -- NOTE: multiple columns 를 가지고 non clustered index 생성시, 주의할 점은 칼럼의 정의 "순서" 가 중요함. 자주 사용하는 칼럼을 앞에 두고 정의 한다.

-- test
SELECT 
    customer_id, 
    first_name, 
    last_name
FROM 
    sales.customers
WHERE 
    last_name = 'Berg' AND 
    first_name = 'Monika';

-- TIP: index 를 확인할 때는 항상 estimated plan 을 사용한다.

--------------------------------------
-- 3. 쓰임새와 용도 그리고 비교 정리
--------------------------------------
/*
===============
Clustered index
===============
1. 테이블 데이터가 자주 업데이트 되지 않는 경우 (왜냐하면 조회시에는 월등한 성능을 기대하지만, 입력시에는 별도로 데이타 page 에 대한 재정렬 작업을 해 주어야 하므로)
2. 항상 정렬 된 방식으로 데이터를 반환해야하는 경우
3. 테이블은 정렬되어있기 때문에 ORDER BY 절을 활용해 모든 테이블 데이터를 스캔하지 않고 원하는 데이터를 조회할 수 있다.
4. 읽기 작업이 월등히 많은 경우, 이때 매우 빠르다.

===================
Non clustered index
===================
1. where절이나 Join 절과 같이 조건문을 활용하여 테이블을 필터링 하고자할 때
2. 데이터가 자주 업데이트 될 때
3. 특정 컬럼이 쿼리에서 자주사용 될 때

===================
그 밖의 고려사항
===================
Clustered 인덱스는 테이블당 오직 한개만 존재한다. 반면에 Non-Clustered 형은 테이블 당 여러개의 인덱스를 생성할 수 있다.
Clustered 인덱스는 오직 테이블을 정렬한다. 그러므로 별도의 공간을 필요로하지 않는다. Non-Clustered 인덱스는 저장되는 별도의 공간(약 10%)이 필요하다.
Clustered 인덱스는 통상적으로 데이터를 찾는데 추가적인 스텝을 거치지 않기 때문에 Non-Clustered 인덱스보다 속도가 빠르다.
Clustered 인덱스는 데이터를 삽입할 때, 모든 테이블에 존재하는 데이터들의 순서를 유지해야하므로 많은 비용이 발생한다. Non-Clustered는 별도의 공간에 인덱스를 생성해야하기 때문에 추가작업이 필요하다.
*/


--------------------------------------
-- 4. rename index
--------------------------------------
EXEC sp_rename 
        N'sales.customers.ix_customers_city',
        N'ix_cust_city' ,
        N'INDEX';


--------------------------------------
-- 5. disable/enable index
--------------------------------------
-- 1. disable
ALTER INDEX ix_cust_city 
ON sales.customers 
DISABLE;

-- table 과 관련되 모든 index 들을 한 번에 disable
ALTER INDEX ALL ON sales.customers
DISABLE; -- 이유: 대용량의 데이타를 Update 하기 전에 overhead 를 피하기 위해 일부러 이렇게 index 를 잠시 disable 해 둔다.

-- test
select * from sales.customers
-- 주의: 한번 disable 하고 나면 다음과 같이 table 자체에 대한 scanning 조차 이뤄지지 않게 된다. result: The query processor is unable to produce a plan because the index 'PK__customer__CD65CB855363011F' on table or view 'customers' is disabled.

-- 2. enable
ALTER INDEX ALL ON sales.customers
REBUILD; -- 이유: 대용량의 데이타를 Update 하기 전에 overhead 를 피하기 위해 일부러 이렇게 index 를 잠시 disable 해 둔 것을 다시 사용하기 위해 진행

-- test
select * from sales.customers



----------------------------------------------------------------------
-- 6. Performance 향상을 위해 Index 사용시 추가적으로 고려해서 적용할 사항
-- Included Columns, Filtered Indexes
----------------------------------------------------------------------
/* ------ 6-1. Included Columns ------ */

CREATE INDEX ix_cust_email 
ON sales.customers(email);

-- test
SELECT    
    customer_id, 
    email
FROM    
    sales.customers
WHERE 
    email = 'aide.franco@msn.com'; -- 아무 문제 없이 ix_cust_email non-clustered index 100% 가 확인


-- test
SELECT    
	first_name,
	last_name, 
	email
FROM    
	sales.customers
WHERE email = 'aide.franco@msn.com'; -- ix_cust_email non-clustered index 가 50%, 나머지 50% 는 key look 으로 50% 를 차지 한다.

-- 이를 개선하기 위해 (즉 ix_cust_email non-clustered index 로 하여금 100% index seek 을 하게 하기 위해)
DROP INDEX ix_cust_email 
ON sales.customers;


CREATE INDEX ix_cust_email_inc
ON sales.customers(email)
INCLUDE(first_name,last_name); -- 이 두 가지 조회 되는 column을 포함시키면, 100% 해당 index 로 검색되는 결과셋에서 오직 해당 index seek 만 적용된다.

-- test
SELECT    
	first_name,
	last_name, 
	email
FROM    
	sales.customers
WHERE email = 'aide.franco@msn.com'; -- ix_cust_email non-clustered index 가 100% 진행된 것을 확인할 수 있다.


/* ------ 6-2. Filtered Index ------ */
-- NOTE
-- Non clustered index 의 단점을 보면 크게 봐서 두 가지가 있다. 별도의 data copy 에 대한 공간 차지와 관리적인 부분이 있다. 이를 조금이나마 해결하기 위해 filtered index 를 사용하게 된다.

CREATE INDEX ix_cust_phone
ON sales.customers(phone)
INCLUDE (first_name, last_name) -- included 와 함께 사용할 때 더 효과적
WHERE phone IS NOT NULL; -- 적용. 즉 not null 일때만 index 를 적용한다는 의미


-- test
SELECT    
    first_name,
    last_name, 
    phone
FROM    
    sales.customers
WHERE phone = '(281) 363-3309';


