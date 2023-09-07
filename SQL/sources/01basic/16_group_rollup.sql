/*********************************
rollup
*********************************/

/*-------------------------------
rollup : similar to cube. It does not create all possible grouping sets based on the dimension columns
hierarchy among the dimension columns and only generates grouping sets based on this hierarchy
often used to generate subtotals and totals for reporting purposes
--------------------------------*/

/*-------------------------------
compare

CUBE (d1,d2,d3) -->>
(d1, d2, d3)
(d1, d2)
(d2, d3)
(d1, d3)
(d1)
(d2)
(d3)
()


ROLLUP(d1,d2,d3) -->> assuming the hierarchy d1 > d2 > d3
(d1, d2, d3)
(d1, d2)
(d1)
()

 --------------------------------*/


--------------------------------------
-- grouping assuming brand > category
--------------------------------------
SELECT
    brand,
    category,
    SUM (sales) sales
FROM
    sales.sales_summary
GROUP BY
    ROLLUP(brand, category);

-- (brand,category)
-- (brand)
-- ()