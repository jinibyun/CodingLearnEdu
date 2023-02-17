/*********************************
delete
*********************************/

-- prep
SELECT * 
INTO production.product_history
FROM
    production.products;

--------------------------------------
-- delete statement. 주의: log 를 지우는 것은 아니다
--------------------------------------
DELETE FROM 
    production.product_history
WHERE
    model_year = 2017;

