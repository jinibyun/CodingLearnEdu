/*********************************
cursor: select 결과셋에 대해 별도로 레코드 단위로 looping 을 돌리면서 별도의 프로세싱을 진행
*********************************/
-- 용도: 존재하는 레코드 셋을 cursor 를 이용하여 data 를 가져와서 한 레코드가 가지고 있는 값들에 대해 추가적으로 처리하고자 할 때 사용
-- data adjustment 용도로 많이 사용되고 있음

-- 생성
DECLARE
    @product_name VARCHAR(MAX),
    @list_price   DECIMAL;

DECLARE cursor_product CURSOR -- cursor type 의 변수 선언 (record set 을 저장하기 위함)
FOR SELECT -- 이 결과 값을 저장
        product_name,
        list_price
    FROM
        production.products;

OPEN cursor_product; -- 아래의 close 와 함께 사용되고 있음을 주의

	FETCH NEXT FROM cursor_product INTO @product_name, @list_price;-- 하나의 레코드를 가져와서 변수에 대입

	WHILE @@FETCH_STATUS = 0 -- @@FETCH_STATUS = 0 의 의미는 별 이상 없이 레코드를 가져왔음을 의미
	BEGIN
			PRINT @product_name + CAST(@list_price AS varchar); -- 이 부분에서 일반적으로 복잡한 로직이 들어갈 수 있다. 예를 들어 값을 변경한다던가 혹은 다른 테이블에 값을 대입한다던가 하는 작업들.

			FETCH NEXT FROM cursor_product INTO @product_name, @list_price; -- 다음 레코드를 가져와서 변수에 대입
	END;

CLOSE cursor_product;

DEALLOCATE cursor_product; -- 반드시 명시적으로 cursor type 으로 할당된 메모리를 회수해야 한다.

-- test
-- 위의 구문을 직접 실행

-- 참고: 보통 sp 안에 정의해서 사용하는 것이 일반적


/****** 추가: 다른 cursor 예제 ******/
-- 기존에 매번 select 작업으로 order_status 번호를 통해 status 상태를 별도로 쿼리 했던 부분을
-- 이번에는 물리적으로 칼럼을 추가해서 cursor 를 이용해 칼럼 자체의 value 를 update 해 보기
-- 참고로 매번 select 했던 작업은 아래와 같다.
alter table sales.orders
add order_status_text varchar(20) null

select * from sales.orders

-- test
DECLARE
    @order_id int,
    @order_status  tinyint;

DECLARE cursor_upd_order_status CURSOR -- cursor type 의 변수 선언 (record set 을 저장하기 위함)
FOR SELECT
		order_id,
        order_status
    FROM
        sales.orders;

OPEN cursor_upd_order_status;

	FETCH NEXT FROM cursor_upd_order_status INTO @order_id, @order_status;

	WHILE @@FETCH_STATUS = 0
	BEGIN
			update sales.orders
			set order_status_text = 
				(
					SELECT    
					CASE @order_status
						WHEN 1 THEN 'Pending'
						WHEN 2 THEN 'Processing'
						WHEN 3 THEN 'Rejected'
						WHEN 4 THEN 'Completed'
					END
				)
			where order_id = @order_id
			FETCH NEXT FROM cursor_upd_order_status INTO @order_id, @order_status;
	END;

CLOSE cursor_upd_order_status;

DEALLOCATE cursor_upd_order_status;

-- 확인
select distinct order_status_text from sales.orders
where order_status <> 4


-- prep
-- sales.orders table 에 order_status_text 라는 칼럼 추가
alter table sales.orders
add order_status_text varchar(20) null

-- cursor 작성
DECLARE @order_id int
DECLARE @order_status tinyint

DECLARE cursor_upd_order_status_text CURSOR
FOR 
    SELECT 
        order_id,
        order_status
    FROM
        sales.orders;

OPEN cursor_upd_order_status_text;

FETCH NEXT FROM cursor_upd_order_status_text INTO @order_id, @order_status
WHILE @@FETCH_STATUS = 0 -- @@FETCH_STATUS = 0 의 의미는 별 이상 없이 레코드를 가져왔음을 의미
BEGIN
        update sales.orders
        set order_status_text = 
            (
                SELECT    
                CASE @order_status
                    WHEN 1 THEN 'Pending'
                    WHEN 2 THEN 'Processing'
                    WHEN 3 THEN 'Rejected'
                    WHEN 4 THEN 'Completed'
                END
            )
        where order_id = @order_id

        FETCH NEXT FROM cursor_upd_order_status_text INTO @order_id, @order_status
END;

CLOSE cursor_upd_order_status_text;

DEALLOCATE cursor_upd_order_status_text;

-- test (최종적으로 update 가 되었는지 확인 한다)
select * from sales.orders


/************************************************
Assignment 7

--prep 1
CREATE TABLE  test.students
(  
    Id INT ,  
    RollNo INT ,  
    EnrollmentNo NVARCHAR(15) ,  
    Name NVARCHAR(50) ,  
    Branch NVARCHAR(50) ,  
    University NVARCHAR(50)  
)  

 char : ----------->> 1 byte: 영문 1 글자, 2 byte: 영문 이외의 글자 : 8000 byte
nchar :u"n"icode--->> 1 byte: 모든 글자 1 byte  ------>> 2 byte    : 4000 byte (4000 * 2)

-- prep 2
INSERT  INTO test.students 
        ( Id, RollNo, EnrollmentNo, Name, Branch, University )  
VALUES  ( 1, 1, N'', N'Nikunj Satasiya', N'CE', N'RK University' ),  
        ( 2, 2, N'', N'Hiren Dobariya', N'CE', N'RK University' ),  
        ( 3, 3, N'', N'Sapna Patel', N'IT', N'RK University' ),  
        ( 4, 4, N'', N'Vivek Ghadiya', N'CE', N'RK University' ),  
        ( 5, 5, N'', N'Pritesh Dudhat', N'CE', N'RK University' ),  
        ( 5, 5, N'', N'Hardik Goriya', N'EC', N'RK University' ),  
        ( 6, 6, N'', N'Sneh Patel', N'ME', N'RK University' )

-- confirm (EnrollmentNo column 이 비어있는 것을 확인)
select * from test.students

-- cursor 를 통해 EnrollmentNo 를 update 하는데 규칙은
-- "IT" + 년도 마지막 자리 두 자리 수 (예를 들어 2023 년도의 23) + branch column 값 + '000' + RollNo 를 각 레코드로부터 얻어서 Update 하기



*************************************************/
