/*********************************
xml 연동: 세 가지 시나리오로 나누어 생각한다

1. xml data type 으로 선언된 칼럼에 xml 형식의 데이타에 대한 조작
2. table에 대한 결과, 즉 table 구조의 데이타를 xml 형식으로 바꾸어서 xml 생성
3. xml 문서를 sql 에서 로딩하여 table 구조의 데이타로 변경
*********************************/
--------------------------------------
-- 1. xml data type
--------------------------------------
-- prep
CREATE TABLE test.xmlDataType
(
        Id int IDENTITY(1,1) PRIMARY KEY,
        testXML XML NOT NULL
);

INSERT INTO test.xmlDataType
(
    testXML
)
VALUES
('<employee empId="11"><name>Sungmin Byun</name><city>Seoul</city><salary>21000 </salary></employee>'),
('<employee empId="12"><name>Ludia Cecil</name><city>Busan</city><salary>11000 </salary></employee>'),
('<employee empId="13"><name>Jack Pep</name><city>Busan</city><salary>27000 </salary></employee>'),
('<employee empId="14"><name>Yuri Hamas</name><city>Daejun</city><salary>31000 </salary></employee>'),
('<employee empId="15"><name>Andrew Pile</name><city>Kwangju</city><salary>39000 </salary></employee>')

-- confirm
select * from test.xmlDataType

/* xml typef 으로 정의된 칼럼에 사용할 수 있는 method  */
--Query(): 전체, 혹은 부분적인 XML fragment 추출
SELECT  testXML.query('/employee/name[1]')AS Employee_Name,
        testXML.query('/employee/city[1]')AS Employee_City,
        testXML.query('/employee/salary[1]')AS Employee_Salary
FROM test.xmlDataType;

-- text() 속성 이용하기
SELECT testXML.query('/employee/name[1]/text()')AS Employee_Name,
testXML.query('/employee/city[1]/text()')AS Employee_City,
testXML.query('/employee/salary[1]/text()')AS Employee_Salary
FROM test.xmlDataType;


--Value():	지정한 XML fragment 에서 value 추출
SELECT testXML.value('(/employee/name)[1]','nvarchar(max)')AS Employee_Name,
testXML.value('(/employee/city)[1]','nvarchar(max)')AS Employee_City,
testXML.value('(/employee/salary)[1]','int')AS Employee_Salary
FROM test.xmlDataType;


--Exist():	XML 레코드 존재 여부. 1 / 0
SELECT testXML.exist('/employee/name[1]')AS Employee_Exist
FROM test.xmlDataType
WHERE Id=3;


--Modify():	XML 구조의 데이타에서 XPath 표현식을 이용해서 특정 값 수정
UPDATE test.xmlDataType
SET testXML.modify('replace value of (/employee/salary/text())[1] with 45000')
WHERE Id=1;

/* XML Data Type 으로 정의해 볼 수 있는 시나리오 */
--1. 입력하는 데이타의 구조가 복잡한 구조이면서 일관성이 부족할 때 XML 형식으로 정의
--2. 계층적인 복잡한 구조의 데이타를 column 으로 하기 난해할 때
--3. B2B 

/* 한계 */
-- XML Datatype 의 칼럼은 ordering 불가능
-- 2 GB 이상 저장 불가능
-- text 형식으로 casting 불가능
-- index 적용 불가능
-- function 의 parameter type 할 수 없음

--------------------------------------
-- 2. 데이타 자료를 XML 형식으로 변환 
--------------------------------------
-- prep
create table test.Car(
  CarId int identity(1,1) primary key,  
  Name varchar(100),  
  Make varchar(100),  
  Model int ,  
  Price int ,  
  Type varchar(20)  
)

insert into test.Car( Name, Make,  Model , Price, Type)
VALUES ('Corrolla','Toyota',2015, 20000,'Sedan'),
('Civic','Honda',2018, 25000,'Sedan'),
('Passo','Toyota',2012, 18000,'Hatchback'),
('Land Cruiser','Toyota',2017, 40000,'SUV'),
('Corrolla','Toyota',2011, 17000,'Sedan'),
('Vitz','Toyota',2014, 15000,'Hatchback'),
('Accord','Honda',2018, 28000,'Sedan'),
('7500','BMW',2015, 50000,'Sedan'),
('Parado','Toyota',2011, 25000,'SUV'),
('C200','Mercedez',2010, 26000,'Sedan'),
('Corrolla','Toyota',2014, 19000,'Sedan'),
('Civic','Honda',2015, 20000,'Sedan')


-- 1. For XML AUTO
SELECT * FROM test.Car
FOR XML AUTO -- 데이타 조회 결과를 얻어서 각 칼럼 값을 조합하여 XML Data 형식으로 (계층적인 구조) 전환한다.

-- test: 결과 xml 을 클릭해서 기본적인 xml 구조와 데이타를 확인한다.

-- 2. For XML PATH
SELECT * FROM test.Car
FOR XML PATH ('Car') -- ('Car") 를 생략하게 되면 상위 element 의 이름이 row 로 자동 지정되기 때문에 이를 바꾸기 위해 추가 지정

-- test: 결과 xml 을 클릭해서 기본적인 xml 구조와 데이타를 확인한다.

/*
두 가지 구조를 비교
1. FOR XML AUTO 는 element 와 attribute 의 조합으로 구성
2. FOR XML PATH 는 상위 element 와 하위 element 의 조합으로 구성
*/

--3. 주의: 위의 1, 2 번의 결과 모두 well-formed xml document 는 아니다.
SELECT * FROM test.Car
FOR XML PATH ('Car'), ROOT('Cars')

-- 4. For XML PATH 데이타 구조 조정
-- 필요시에 다음과 같이 세부적으로 데이타의 구조 조정 가능
SELECT  CarId as [@CarID],  -- @ 표시는 xml path 표현에서는 attribute 를 의미한다.
    Name  AS [CarInfo/Name],  -- 새로운 구조 생성 가능: CarInfo 라는 새로운 상위 element 를 생성해서 그 아래 하위 element 로 표현
    Make [CarInfo/Make],  
    Model [CarInfo/Model],  
    Price,  
    Type
FROM test.Car 
FOR XML PATH ('Car'), ROOT('Cars')

-- 위의 코드를 좀더 구체적으로 element 와 element 관계를 element 와 attribute 의 관계로 구성하기
SELECT  CarId as [@CarID],  
    Name  AS [CarInfo/@Name],  
    Make [CarInfo/@Make],  
    Model [CarInfo/Model],  
    Price,  
    Type
FROM test.Car 
FOR XML PATH ('Car'), ROOT('Cars')


--------------------------------------
-- NOTE: 이 3 번 실습을 하기에 앞서, 우선 아래의 #4, #5 를 우선 학습한다.

-- 3. XML 문서로 부터 SQL table 구조의 레코드 생성
-- OpenRowSet 은 외부의 file 을 SQL 의 메모리로 로딩
-- OpenXML 은 메모리에 로딩되어 있는 XML 파일을 table 구조로 표현
-- 이 두 가지를 이용하여 생성
--------------------------------------
-- prep
-- 아래의 결과로 생성된 xml 문서를 적절한 이름으로 저장한다. (예: C:\cars.xml)
SELECT  CarId as [@CarID],  
    Name  AS [CarInfo/@Name],  
    Make [CarInfo/@Make],  
    Model [CarInfo/Model],  
    Price,  
    Type
FROM test.Car 
FOR XML PATH ('Car'), ROOT('Cars')


-- 참고: OpenRowSet () 이라는 함수는 외부의 데이타 (예, Access, Excel, text, xml 등) 를 SQL 의 메모리로 로딩하는 함수
-- ref: https://learn.microsoft.com/en-us/sql/t-sql/functions/openrowset-transact-sql?view=sql-server-ver16

-- OpenRowSet 을 이용하여 생성
DECLARE @cars xml
 
SELECT @cars = C
FROM OPENROWSET (BULK 'C:\Cars.xml', SINGLE_BLOB) AS Cars(C) -- OpenRowSet function 은 XML Data 를 binary format 로 바꿔서 메모리에 로드
    
SELECT @cars -- 중간 확인: xml Data

-- 메모리에 로드된 xml Data 에 대한 handling 을 하기 위해서 (이 과정이 skip 되면 안됨)  
DECLARE @hdoc int
EXEC sp_xml_preparedocument @hdoc OUTPUT, @cars

-- 위에서 얻은 handling 정보를 가지로 OPENXML 함수 이용
-- 파라미터: handler, xpath 표현식, 추가 정보 (1: attribute  2:element)
-- 확인을 하게 되면 계층적인 XML 구조가 SQL 의 table 구조로 바뀌었음을 볼 수 있다
SELECT *
FROM OPENXML (@hdoc, '/Cars/Car/CarInfo' , 1)
WITH(
    Name VARCHAR(100),
    Make VARCHAR(100)
    )
    
-- 핸들링을 없앰으로 해서 메모리에서 해제 (deallocate)   
EXEC sp_xml_removedocument @hdoc

/* 참고
element 를 얻기위해서는 다음과 같이 OPENXML 부분 수정
...
FROM OPENXML (@hdoc, '/Cars/Car' , 2)
WITH(
    CarInfo INT,
    Price INT,
    Type VARCHAR(100)
    )
...
*/

--------------------------------------
-- 4. OpenRowSet 을 이용하여 외부의 XML file 을 직접 XML Data type 의 칼럼에 입력
--------------------------------------
-- prep
-- 다음의 XML file 을 저장한다. (예: C:\customerOrder.xml)
/*
  <ROOT>
  <Customers>
  <Customer CustomerName="Arshad Ali" CustomerID="C001">
  <Orders>
  <Order OrderDate="2012-07-04T00:00:00" OrderID="10248">
  <OrderDetail Quantity="5" ProductID="10"/>
  <OrderDetail Quantity="12" ProductID="11"/>
  <OrderDetail Quantity="10" ProductID="42"/>
  </Order>
  </Orders>
  <Address> Address line 1, 2, 3</Address>
  </Customer>
  <Customer CustomerName="Paul Henriot" CustomerID="C002">
  <Orders>
  <Order OrderDate="2011-07-04T00:00:00" OrderID="10245">
  <OrderDetail Quantity="12" ProductID="11"/>
  <OrderDetail Quantity="10" ProductID="42"/>
  </Order>
  </Orders>
  <Address> Address line 5, 6, 7</Address>
  </Customer>
  <Customer CustomerName="Carlos Gonzlez" CustomerID="C003">
  <Orders>
  <Order OrderDate="2012-08-16T00:00:00" OrderID="10283">
  <OrderDetail Quantity="3" ProductID="72"/>
  </Order>
  </Orders>
  <Address> Address line 1, 4, 5</Address>
  </Customer>
  </Customers>
  </ROOT>
*/
-- prep
CREATE TABLE test.XMLwithOpenXML
(
  Id INT IDENTITY PRIMARY KEY,
  XMLData XML,
  LoadedDateTime DATETIME
)


-- 실행
INSERT INTO test.XMLwithOpenXML(XMLData, LoadedDateTime)
SELECT CONVERT(XML, BulkColumn) AS BulkColumn, GETDATE() 
FROM OPENROWSET(BULK 'C:\customerOrder.xml', SINGLE_BLOB) AS x;

-- test
SELECT * FROM test.XMLwithOpenXML

--------------------------------------
-- 5. OpenXML 을 이용하여 4 번에서 저장된 XML data를 가져오는데, 부분적인 정보만 table 형식으로 가져온다
--------------------------------------
-- 1
DECLARE @XML AS XML, @hDoc AS INT, @SQL NVARCHAR (MAX)

SELECT @XML = XMLData FROM test.XMLwithOpenXML

EXEC sp_xml_preparedocument @hDoc OUTPUT, @XML

    SELECT CustomerID, CustomerName, Address
    FROM OPENXML(@hDoc, 'ROOT/Customers/Customer')
    WITH 
    (
    CustomerID [varchar](50) '@CustomerID',
    CustomerName [varchar](100) '@CustomerName',
    Address [varchar](100) 'Address'
    )

EXEC sp_xml_removedocument @hDoc

-- 2
DECLARE @XML AS XML, @hDoc AS INT, @SQL NVARCHAR (MAX)

SELECT @XML = XMLData FROM test.XMLwithOpenXML

EXEC sp_xml_preparedocument @hDoc OUTPUT, @XML

SELECT CustomerID, CustomerName, Address, OrderID, OrderDate
FROM OPENXML(@hDoc, 'ROOT/Customers/Customer/Orders/Order')
WITH 
(
  CustomerID [varchar](50) '../../@CustomerID',
  CustomerName [varchar](100) '../../@CustomerName',
  Address [varchar](100) '../../Address',
  OrderID [varchar](1000) '@OrderID',
  OrderDate datetime '@OrderDate'
)

EXEC sp_xml_removedocument @hDoc
GO
/************************************************
Assignment 11

위에서 개별로 (#4, #5) 각각 OpenRowSet 과 OpenXML 을 하나로 합쳐서 작업한다. 단 OpenXML 시에 기존에 어떤 table 로 부터 자료를 가져오은 것이 아니라, OpenRowSet 으로 얻은 메모리상의 자료를 가지고 작업한다. (실제 table 로 부터 자료를 가지고 오는 것이 아니라는 의미이다)
참고로  stored procedure 를 구성해서 이를 구성하도록 한다.

최종 결과는 #5에서 보여지는 결과와 같아야 한다.


*************************************************/