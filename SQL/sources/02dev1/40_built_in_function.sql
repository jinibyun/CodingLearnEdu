/*********************************
built-in function
*********************************/
-- TIP. 함수를 접근할 때는 View 혹은 SP 와는 다르게 사용자 정의 함수, 시스템 함수로 나누어 접근한다.

--------------------------------------
-- A. System Function (= built-in)
-- 아래에는 자주 사용하는 함수만 정리
-- B. User Defined function 은 40_user_defined_function.sql 참조
--------------------------------------

--------------------------------------
-- 1. Aggregate Function
--------------------------------------
-- 하나 이상의 값을 종합하여 계산 후 결과 값으로 하나의 결과 값을 리턴. 
-- 대부분의 경우 Group By 절과 함께 사용된다.

-- avg
SELECT
    brand_name,
    --CAST(ROUND(AVG(list_price),2) AS DEC(10,2))
    AVG(list_price) avg_product_price
FROM
    production.products p
    INNER JOIN production.brands c ON c.brand_id = p.brand_id
GROUP BY
    brand_name
HAVING
    AVG(list_price) > 500
ORDER BY
    avg_product_price;

-- count
SELECT 
    brand_name,
    COUNT(*) product_count
FROM
    production.products p
    INNER JOIN production.brands c 
    ON c.brand_id = p.brand_id
GROUP BY 
    brand_name
HAVING
    COUNT(*) > 20
ORDER BY
    product_count DESC;

-- max
SELECT
    brand_name,
    MAX(list_price) max_list_price
FROM
    production.products p
    INNER JOIN production.brands b
        ON b.brand_id = p.brand_id 
GROUP BY
    brand_name
HAVING 
    MAX(list_price) > 1000
ORDER BY
    max_list_price DESC;

-- min
-- min 은 max 와 같은 개념이기 때문에 여기서는 예제 생략

-- sum
SELECT
    product_name,
    SUM(quantity) total_stocks
FROM
    production.stocks s
    INNER JOIN production.products p
        ON p.product_id = s.product_id
GROUP BY
    product_name
HAVING
    SUM(quantity) > 100
ORDER BY
    total_stocks DESC;


--------------------------------------
-- 2. Date Function
--------------------------------------
-- getdate()
SELECT GETDATE() 'current_date_time';

SELECT CONVERT(DATE, GETDATE()) currentDate; -- convert :  type 변환 함수 (cast 함수와 같음)

-- datepart()
SELECT DATEPART(year, shipped_date) [year], 
       DATEPART(quarter, shipped_date) [quarter], 
       DATEPART(month, shipped_date) [month], 
       DATEPART(day, shipped_date) [day], 
       SUM(quantity * list_price) gross_sales
FROM sales.orders o
     INNER JOIN sales.order_items i ON i.order_id = o.order_id
WHERE shipped_date IS NOT NULL
GROUP BY DATEPART(year, shipped_date), 
         DATEPART(quarter, shipped_date), 
         DATEPART(month, shipped_date), 
         DATEPART(day, shipped_date)
ORDER BY [year] DESC;

-- Day, Month and Year
SELECT 
    DAY(shipped_date) [day], 
    SUM(list_price * quantity) gross_sales
FROM 
    sales.orders o
    INNER JOIN sales.order_items i ON i.order_id = o.order_id
WHERE 
    shipped_date IS NOT NULL
    AND YEAR(shipped_date) = 2017
    AND MONTH(shipped_date) = 2
GROUP BY 
    DAY(shipped_date)
ORDER BY [day];    



declare @i int = 10
select case 
	     when @i > 10 then 'big number'
		 when @i = -1 then 'negative number'
		 else 'small number'
	   end

-- Datediff()
SELECT
    order_id, 
    required_date, 
    shipped_date,
	--DATEDIFF(day, required_date, shipped_date)
    CASE -- select 구문안에 사용하는 if
        WHEN DATEDIFF(day, required_date, shipped_date) < 0 THEN 'Late'
        ELSE 'OnTime'
    END shipment
FROM 
    sales.orders
WHERE 
    shipped_date IS NOT NULL
ORDER BY 
    required_date;

-- DateAdd()
SELECT 
    order_id, 
    customer_id, 
    order_date,
    DATEADD(day, 2, order_date) estimated_shipped_date
FROM 
    sales.orders
WHERE 
    shipped_date IS NULL
ORDER BY 
    estimated_shipped_date DESC;


--------------------------------------
-- 3. String Function
--------------------------------------
-- charindex()

-- searching
DECLARE @haystack VARCHAR(100);  
SET @haystack = 'This is a haystack';  
SELECT CHARINDEX('hays', @haystack);  

-- left()
SELECT
	LEFT(product_name, 2) initial,  
	COUNT(product_name) product_count
FROM 
	production.products
GROUP BY
	left(product_name, 2)
ORDER BY 
	initial;

-- len()
SELECT
    product_name,
    LEN(product_name) product_name_length
FROM
    production.products
ORDER BY
    LEN(product_name) DESC;


-- lower()
SELECT 
    first_name, 
    last_name, 
    CONCAT_WS( -- 문자열 결합은 직접  + 기호를 이용할 수도 있다.
        ' ', 
        LOWER(first_name), 
        LOWER(last_name)
    ) full_name_lowercase,
	LOWER(first_name) + ' ' + LOWER(last_name) newName
FROM 
    sales.customers
ORDER BY 
    first_name, 
    last_name;

-- upper() 는 위의 lower() 와 반대로 대문자로 출력

-- STRING_SPLIT(): 칼럼에 포함되어 있는 값을 구분자로 나누어서 나뉘어진 값 
-- 들을 새롭게 메모리에 table 형식의 칼럼 레코드 값으로 입력한다
-- 1
SELECT 
    value  
FROM 
    STRING_SPLIT('red,green,,blue', ',');

-- 2
SELECT 
    TRIM(value),
	LEN(TRIM(value)),
	LEN(value)
FROM 
    STRING_SPLIT('    red    ,    green    ,,    blue    ', ',')
WHERE
    TRIM(value) <> ''; -- TRIM: 칼럼 값의 좌우의 빈 공백을 지우는 함수

-- 3
-- prep
CREATE TABLE sales.contacts (
    id INT PRIMARY KEY IDENTITY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phones VARCHAR(500)
);

INSERT INTO 
    sales.contacts(first_name, last_name, phones)
VALUES
    ('John','Doe','(408)-123-3456,(408)-123-3457'),
    ('Jane','Doe','(408)-987-4321,(408)-987-4322,(408)-987-4323');

select * from sales.contacts
-- test

SELECT 
    first_name, 
    last_name,
    value phone
FROM 
    sales.contacts
    CROSS APPLY STRING_SPLIT(phones, ','); 
	-- 참고로 cross apply 는 cross join 과 비슷하지만 table valued function 을 사용할 때는 
	-- cross apply 를 사용해야 한다.

-- ltrim() 
SELECT TRIM(value) part
FROM STRING_SPLIT('Doe,        John', ',');

-- patindex(): 문자열의 위치를 "pat"tern 매칭을 이용하여 찾아낸다.
SELECT LTRIM(value) part
FROM   STRING_SPLIT('Doe, John', ',');

SELECT    
    product_name, 
    PATINDEX('%2018%', product_name) position -- pattern 문자열 (예) %문자열%, [a-Z] , ...
FROM    
    production.products
WHERE 
    product_name LIKE '%2018%'
ORDER BY 
    product_name;

-- replace()
SELECT    
	first_name, 
	last_name, 
	phone, 
	--REPLACE(REPLACE(phone, '(', ''), ')', '') phone_formatted
	REPLACE(phone, '(', ''),
	REPLACE(REPLACE(phone, '(', ''), ')', '')
FROM    
	sales.customers
WHERE phone IS NOT NULL   
ORDER BY 
	first_name, 
	last_name;

-- stuff() and replicate()
DECLARE 
    @ccn VARCHAR(20) = '4882584254460197';
SELECT 
    STUFF(@ccn, 1, 15, 'XXXXXXXXXXXXXXX')


SELECT 
    STUFF(@ccn, 1, 15, REPLICATE('X', LEN(@ccn) - 7))
    credit_card_no;

-- substring()
declare @email varchar(100)
set @email = 'jinibyundfggfggfgg@kakakakaoemail.com'
select CHARINDEX('@', @email)+1 -- 10
select LEN(@email) -- 18 - 9

select SUBSTRING(
        @email, 
        CHARINDEX('@', @email)+1, 
        LEN(@email)-CHARINDEX('@', @email)
    )


SELECT 
	email,
    SUBSTRING(
        email, 
        CHARINDEX('@', email)+1, 
        LEN(email)-CHARINDEX('@', email)
    )
FROM 
    sales.customers

SELECT 
    SUBSTRING(
        email, 
        CHARINDEX('@', email)+1, 
        LEN(email)-CHARINDEX('@', email)
    ) domain,
    COUNT(*) domain_count
FROM 
    sales.customers
GROUP BY
    SUBSTRING(
        email, 
        CHARINDEX('@', email)+1, 
        LEN(email)-CHARINDEX('@', email)
    );


--------------------------------------
-- 4. System Function
--------------------------------------
-- cast() 기능상 convert() 동일: cast() 를 사용하라고 권유


SELECT CAST('2019-03-14' AS DATETIME) result; -- convert() 와 동일
SELECT CONVERT(DATETIME, '2019-03-14') result; 

SELECT 
    MONTH(order_date) monthOfOrderDate, 
	SUM(quantity * list_price * (1 - discount)),
    CAST(SUM(quantity * list_price * (1 - discount)) AS decimal(18,2)) amount
    
FROM sales.orders o
    INNER JOIN sales.order_items i ON o.order_id = i.order_id
WHERE 
    YEAR(order_date) = 2017
GROUP BY 
    MONTH(order_date)
ORDER BY 
    monthOfOrderDate;

-- TIP: convert() 도 형식만 다를 뿐 cast 와 동일한 역할. Cast() 는 ANSI 구문으로 더 범용적임

-- choose()
SELECT CHOOSE(1, 'First', 'Second', 'Third') Result;

-- select 에서 조건별로 데이타를 가져올 때는 주로 case ...when...then.. 구문을 많이 사용한다.
-- 같은 효과
SELECT
    order_id, 
    order_date, 
    order_status,
    CHOOSE(order_status,
        'Pending', 
        'Processing', 
        'Rejected', 
        'Completed') AS order_status_explain
FROM 
    sales.orders
ORDER BY 
    order_date DESC;


-- try_cast(): cast() 와 역할은 같다. 
-- 하지만 casting 이 실패 했을 시 cast 는 error 를 발생하지만, try_cast() 는 null 을 리턴한다.
SELECT 
    CAST('12.345' AS DateTime)  Result;

SELECT 
    TRY_CAST('12.345' AS DateTime)  Result;


SELECT 
    CASE
        WHEN TRY_CAST('test' AS INT) IS NULL
        THEN 'Cast failed'
        ELSE 'Cast succeeded'
    END AS Result;


--------------------------------------
-- 5. Window Function
-- First_Value(), Last_Value(), Rank() 등 여러 함수 들이 있는데 
-- 여기에서는 그 중에 자주 사용하는 Row_Number() 만을 알아보기로 한다.
--------------------------------------
select *
FROM 
   sales.customers
order by first_name

SELECT 
   ROW_NUMBER() OVER (
	ORDER BY first_name
   ) row_num,
   first_name, 
   last_name, 
   city
FROM 
   sales.customers;


-- 별도의 세부 사항을 Partition 해서 Row_number() 적용
SELECT 
   first_name, 
   last_name, 
   city,
   ROW_NUMBER() OVER (
      PARTITION BY city
      ORDER BY first_name
   ) row_num
FROM 
   sales.customers
ORDER BY 
   city;

-- pagination
create proc usp_GetList
@start int,
@end int
as
begin
	WITH cte_customers AS (
		SELECT 
			ROW_NUMBER() OVER(
				 ORDER BY 
					first_name, 
					last_name
			) row_num, 
			customer_id, 
			first_name, 
			last_name
		 FROM 
			sales.customers
	) 


	SELECT 
		customer_id, 
		first_name, 
		last_name
	FROM 
		cte_customers
	WHERE 
		row_num > @start AND 
		row_num <= @end;

	end

exec usp_GetList 10,20

-- TIP: 참고로 Order by 를 하지 않고, 그대로 Row_number 만 적용하고자 할 때
-- ref: https://stackoverflow.com/questions/44105691/row-number-without-order-by