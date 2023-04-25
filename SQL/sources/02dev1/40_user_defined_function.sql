/*********************************
user-defined function
*********************************/
-- TIP. 함수를 접근할 때는 View 혹은 SP 와는 다르게 사용자 정의 함수, 시스템 함수로 나누어 접근한다.

--------------------------------------
-- 1. Table variable
--------------------------------------
-- 주의할 점
-- 한 번 정의된 table variable 을 alter 구문으로 수정할 수 는 없다.
-- table variable 쿼리시에 별도의 execution plan 을 적용할 수 없으므로, 성능 향상을 적용할 수는 없다.
-- 다른 table 과 join 시에 반드시 table alias 를 사용해야 한다.
-- TABLE datatype 을 이용해서 stored procedure 의 input 혹은 output parameter 를 정의할 수는 없지만 "사용자 정의 함수" 에서는 table variable 을 리턴할 수 있다. 
begin 
    DECLARE @product_table TABLE (
        product_name VARCHAR(MAX) NOT NULL,
        brand_id INT NOT NULL,
        list_price DEC(11,2) NOT NULL
    );

    INSERT INTO @product_table
    SELECT
        product_name,
        brand_id,
        list_price
    FROM
        production.products
    WHERE
        category_id = 1;

    SELECT
        *
    FROM
        @product_table;
end

--------------------------------------
-- 2. Function returing table value
-- Function 의 리턴 값을 두 가지로 나누어 생각한다. table value 혹은 scalar value (단일 값)
--------------------------------------
-- 2-1. table-valued function
-- sql 함수 정의하고, 그 안에서 table variable 리턴하기
CREATE FUNCTION udfProductInYear (
    @model_year INT
)
RETURNS TABLE
AS
RETURN
    SELECT 
        product_name,
        model_year,
        list_price
    FROM
        production.products
    WHERE
        model_year = @model_year;


-- test
-- NOTE: SP 는 단독으로 exec 구문을 이용해서 실행했으나, 함수는 다음과 같이 DML 구문안에서 호출이 되어야 한다. 단독으로 실행될 수 없다.
-- 이때 함수가 단일 값을 리턴하느냐 혹은 테이블 값을 리턴하느냐에 따라, select, from, where 각 구문에 알맞게 사용되어야 한다.
SELECT 
    * 
FROM 
    udfProductInYear(2017);

-- another example
CREATE FUNCTION udfContacts()
    RETURNS @contacts TABLE ( 
        first_name VARCHAR(50),
        last_name VARCHAR(50),
        email VARCHAR(255),
        phone VARCHAR(25),
        contact_type VARCHAR(20)
    )
AS
BEGIN
    -- 두 가지 이상의 DML 구문을 이용
    INSERT INTO @contacts
    SELECT 
        first_name, 
        last_name, 
        email, 
        phone,
        'Staff'
    FROM
        sales.staffs;

    INSERT INTO @contacts
    SELECT 
        first_name, 
        last_name, 
        email, 
        phone,
        'Customer'
    FROM
        sales.customers;

    RETURN;
END;


-- test
SELECT 
    * 
FROM
    udfContacts();


-- 2-2. scalar function

CREATE FUNCTION sales.udfNetSale(
    @quantity INT,
    @list_price DEC(10,2),
    @discount DEC(4,2)
)
RETURNS DEC(10,2)
AS 
BEGIN
    RETURN @quantity * @list_price * (1 - @discount);
END;

-- test
SELECT 
    sales.udfNetSale(10,100,0.1) net_sale; -- table valued function 과는 틀리게 from 절이 아닌, select 절에 사용되고 있다

-- test
SELECT 
    order_id, 
    SUM(sales.udfNetSale(quantity, list_price, discount)) net_amount
FROM 
    sales.order_items
GROUP BY 
    order_id
ORDER BY
    net_amount DESC;

-- 주의할 점: scalar function 을 이용하여 Data 를 update 할 수는 없다.