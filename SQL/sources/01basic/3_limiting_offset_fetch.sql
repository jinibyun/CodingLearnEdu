/*********************************
limiting fetch
*********************************/

--------------------------------------
-- To skip the first 10 products and return the rest
--------------------------------------
SELECT product_name
    , list_price
FROM production.products
ORDER BY list_price
    , product_name OFFSET 10 ROWS;

--------------------------------------
-- To skip the first 10 products and select the next 10 products
--------------------------------------
SELECT product_name
    , list_price
FROM production.products
ORDER BY list_price
    , product_name OFFSET 10 ROWS

FETCH NEXT 10 ROWS ONLY;

--------------------------------------
-- top 10 most expensive products
--------------------------------------
SELECT product_name
    , list_price
FROM production.products
ORDER BY list_price DESC
    , product_name OFFSET 0 ROWS

FETCH FIRST 10 ROWS ONLY;

/************************************************
Assignment 1

주문 table (sales.orders) 로 부터 order_id, order_status, customer_id 를 조회하는데
order id 별로 정렬해서 (역정렬: descending) 가져오고 100 개의 Data 만을 조회한다. 

이 때 OFFSET 문법을 이용해서 작성한다.
*************************************************/
