/*********************************
Basic Query
*********************************/
-- SQL: Structured "Query" Language
--------------------------------------
--------------------------------------

select first_name
    , last_name
FROM sales.customers -- table 
GO -- ; 와 같이 하나의 명령 단위를 구분하는 구분자 (생략도 할 수 있음)

--------------------------------------
-- multiple
--------------------------------------
SELECT first_name
    , last_name
    , email
FROM sales.customers;

--------------------------------------
-- all
--------------------------------------
SELECT * -- 모든 칼럼
FROM sales.customers;

--------------------------------------
-- where 조건
--------------------------------------
SELECT *
FROM sales.customers
where STATE = 'CA'; -- where 는 if 의 의미. sql 구문에서 문자열 처리는 홑따옴표.

--------------------------------------
-- where and order by
--------------------------------------
SELECT *
FROM sales.customers
WHERE STATE = 'CA'
ORDER BY first_name; -- 정렬: 기본 정렬 값: 오름차순 (Ascending)

--------------------------------------
-- grouping
--------------------------------------
SELECT city
    , COUNT(*)
FROM sales.customers
WHERE STATE = 'CA'
GROUP BY city
ORDER BY city;

--------------------------------------
-- grouping and condition
--------------------------------------
SELECT city
    , COUNT(*)
FROM sales.customers
WHERE STATE = 'CA'
GROUP BY city
HAVING COUNT(*) > 10
ORDER BY city;
