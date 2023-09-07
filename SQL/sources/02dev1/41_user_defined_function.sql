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
RETURNS TABLE -- "반드시" RETURNS 키워드로 리턴 해야 한다.
AS
RETURN -- 실제 return
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
---------------------------------------------------
-- another example
ALTER FUNCTION udfContacts()
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
--------------------------------------


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


/************************************************
Assignment 4

앞서 진행했던 Assingment 1 (View 생성) 했던 부분을 Function 으로 만들어서 table value 를 return 한다.
단, 파라미터를 정의할 수 없는 view 와는 다르게 함수는 parameter 를 정할 수 있다. @model_year 를 파라미터로 정하고 production.products 의 model_year 와 비교해서 일치하는 것만 리턴 할 수 있도록 한다.
************************************************/
create function production.udfGetAvgPriceOfBrand(@model_year smallint)
RETURNS TABLE
as
	RETURN
		select t1.brand_name, avg(t2.list_price) as 'brand_avgPrice'
		from production.brands t1 inner join production.products t2
		on t1.brand_id = t2.brand_id
		where t2.model_year = @model_year
		group by t1.brand_name

select *
from production.udfGetAvgPriceOfBrand(2018)
/************************************************
Assignment 5


다음의 query 는 주문 상황별 숫자를 리턴하는 쿼리이다.
여기에서 알고 싶은 것은 주문이 completed 가 되지 않는 다른 상황에 있는 숫자의 합을 function 으로 구성해 보기. 파라미터는 년도로 지정할 것.
참고로 아래의 쿼리 구문을 그대로 이용하지 않아도 상관 없다. 그대로 이용하지 않는 것이 더 간단하다.

create function sales.udfNotCompletedSalesCount(@year smallint)
RETURNS INT
as
begin
	declare @cnt int
	select @cnt = sum(t1.order_count) from
	(
		SELECT    
			CASE order_status
				WHEN 1 THEN 'Pending'
				WHEN 2 THEN 'Processing'
				WHEN 3 THEN 'Rejected'
				WHEN 4 THEN 'Completed'
			END AS order_status, 
			COUNT(order_id) order_count
		FROM    
			sales.orders
		WHERE 
			YEAR(order_date) = @year
		GROUP BY 
			order_status
	) t1
	where t1.order_status != 'Completed'

	return @cnt
end;

-- test
select sales.udfNotCompletedSalesCount(2018);
************************************************/


1. sp: business logic   function: utility
2. sp: 단독 실행 가능    function: 반드시 DML 구문과 함께 사용