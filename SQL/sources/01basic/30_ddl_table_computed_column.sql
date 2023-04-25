/*********************************
computed column
*********************************/
-- computed columns to reuse the calculation logic in multiple queries

-- prep
--1
CREATE TABLE persons
(
    person_id  INT PRIMARY KEY IDENTITY, 
    first_name NVARCHAR(100) NOT NULL, 
    last_name  NVARCHAR(100) NOT NULL, 
    dob        DATE
);

--2
INSERT INTO 
    persons(first_name, last_name, dob)
VALUES
    ('John','Doe','1990-05-01'),
    ('Jane','Doe','1995-03-01');
--3
SELECT
    person_id,
    first_name + ' ' + last_name AS full_name,
    dob
FROM
    persons
ORDER BY
    full_name;

--------------------------------------
-- 매번 query 에서 사용하는 것을 개선하기 위해...
--------------------------------------
ALTER TABLE persons
ADD full_name AS (first_name + ' ' + last_name);

-- test
SELECT 
    person_id, 
    full_name, 
    dob
FROM 
    persons
ORDER BY 
    full_name;

--------------------------------------
-- anoter example: 태어난 년을 가지고 나이 계산
--------------------------------------
ALTER TABLE persons
ADD age_in_years 
    AS (CONVERT(INT,CONVERT(CHAR(8),GETDATE(),112))-CONVERT(CHAR(8),dob,112))/10000;

-- test
SELECT 
    person_id, 
    full_name, 
    age_in_years
FROM 
    persons
ORDER BY 
    age_in_years DESC;




