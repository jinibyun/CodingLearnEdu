/*********************************
cube
*********************************/
-- better version of grouping set. generate multiple grouping sets

/*------------------------------- 
SELECT
    d1,
    d2,
    d3,
    aggregate_function (c4)
FROM
    table_name
GROUP BY
    CUBE (d1, d2, d3);          

is same as ---->> "generate" 2 의 n square...

SELECT
    d1,
    d2,
    d3,
    aggregate_function (c4)
FROM
    table_name
GROUP BY
    GROUPING SETS (
        (d1,d2,d3), 
        (d1,d2),
        (d1,d3),
        (d2,d3),
        (d1),
        (d2),
        (d3), 
        ()
     );
--------------------------------*/

--------------------------------------
-- cube example
--------------------------------------
SELECT
    brand,
    category,
    SUM (sales) sales
FROM
    sales.sales_summary
GROUP BY
    CUBE(brand, category);


