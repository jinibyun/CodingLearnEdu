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