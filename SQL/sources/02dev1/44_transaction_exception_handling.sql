/*********************************
transaction
*********************************/
-- 가장 기본적인 부분에 대해서는 "26_modifying_transaction.sql" 에서 진행을 했고, 여기에서는 좀 더 나가서 깊이 있게 설명하기로 한다.

/*------- Transaction Types -------*/
-- 1. Auto Commit Transaction (default)
-- 2. Implicit Transaction
-- 3. Explicit Transaction

-- prep
CREATE TABLE test.Customer
(
    CustomerID INT PRIMARY KEY,
    CustomerCode VARCHAR(10),
    CustomerName VARCHAR(50)
)


--------------------------------------
-- 1. clustered index
--------------------------------------
-- 1.1 without index
-- prep
-- PK 설정이 되어 있지 않은 table 생성 후 데이타 입력
