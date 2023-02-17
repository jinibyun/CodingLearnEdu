/*********************************
self join
*********************************/
-- query hierarchical data or compare rows within the same table

--------------------------------------
-- hieracrhical
--------------------------------------
SELECT
    e.first_name + ' ' + e.last_name employee,
    m.first_name + ' ' + m.last_name manager
FROM
    sales.staffs e
INNER JOIN sales.staffs m ON m.staff_id = e.manager_id -- change INNER to outer and see the difference
ORDER BY
    manager;

--------------------------------------
-- compare rows within a table
--------------------------------------
SELECT
    c1.city,
    c1.first_name + ' ' + c1.last_name customer_1,
    c2.first_name + ' ' + c2.last_name customer_2
FROM
    sales.customers c1
INNER JOIN sales.customers c2 ON c1.customer_id <> c2.customer_id -- doesn’t compare the same customer
AND c1.city = c2.city
ORDER BY
    city,
    customer_1,
    customer_2;


