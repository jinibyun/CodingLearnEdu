/*********************************
limiting top n
*********************************/

--------------------------------------
-- top 10 most expensive products
--------------------------------------
SELECT TOP 10
    product_name, 
    list_price
FROM
    production.products
ORDER BY 
    list_price DESC;

--------------------------------------
-- PERCENT to specify the number of products: round up
--------------------------------------
SELECT TOP 1 PERCENT
    product_name, 
    list_price
FROM
    production.products
ORDER BY 
    list_price DESC;

--------------------------------------
-- WITH TIES: get extra value which is same as third one
--------------------------------------
SELECT TOP 3 WITH TIES
    product_name, 
    list_price
FROM
    production.products
ORDER BY 
    list_price DESC;
