/*********************************
delete
*********************************/

-- prep
SELECT * -- table 생성
INTO production.product_history
FROM
    production.products;

select * from production.product_history
WHERE
    model_year = 2017;
--------------------------------------
-- delete statement. 주의: log 를 지우는 것은 아니다
--------------------------------------
DELETE FROM 
    production.product_history
WHERE
    model_year = 2017;

-- data file (.mdf) 뿐만 아니라 로그파일 (.ldf) 에 있는 자료까지 삭제
truncate table production.product_history


