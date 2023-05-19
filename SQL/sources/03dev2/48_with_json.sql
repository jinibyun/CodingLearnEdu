/*********************************
json 연동
*********************************/
-- 사용 면에서 xml 에 대한 light weight 버전이라고 봐도 무방하다
-- 특별히 별도의 json 이라고 하는 타입은 존재하지 않고, nvarchar type 으로 정의한 column 이 저장하게 된다
-- 기본적으로 SQL 에서는 json 문자열 혹은 외부 파일을 지원하는 기본함수들이 있다.

-------------------------
-- 1. json 연동 함수 */
-------------------------

-- IsJson()
DECLARE @JSONData AS NVARCHAR(4000)
SET @JSONData = N'{
    "EmployeeInfo":{
        "FirstName":"Jignesh",
        "LastName":"Trivedi",
        "Code":"CCEEDD",
        "Addresses":[
            { "Address":"Test 0", "City":"Gandhinagar", "State":"Gujarat"},
            { "Address":"Test 1", "City":"Gandhinagar", "State":"Gujarat"}
        ]
    }
}'

SELECT  ISJSON(@JSONData) -- Json 인지 확인

-- Json_Value()
SELECT JSON_VALUE(@JSONData,'$.EmployeeInfo.FirstName'); -- $ 의 최상위 object 를 가르킴
SELECT JSON_VALUE(@JSONData,'$.EmployeeInfo.Addresses[0].Address');

-- '$' - reference entire JSON object
-- '$.Property1' - reference property1 in JSON object
-- '$[2]' - reference 2nd element in JSON array
-- '$.Property1.property2[4].property3' - reference nested property in JSON object
DECLARE @JSONData AS NVARCHAR(4000)
SET @JSONData = N'{
    "EmployeeInfo":{
        "FirstName":"Jignesh",
        "LastName":"Trivedi",
        "Code":"CCEEDD",
        "Addresses":[
            { "Address":"Test 0", "City":"Gandhinagar", "State":"Gujarat"},
            { "Address":"Test 1", "City":"Gandhinagar", "State":"Gujarat"}
        ]
    }
}'
SELECT JSON_VALUE(@JSONData,'strict $.EmployeeInfo.Addresses[0].Address1') -- 여기에서 strict 의 의미: 지정한 값을 잘 못 지정했을 경우, 에러를 "일부러" 발생케 하는 것. 쓰지 않으면 null 을 리턴


-- Json_Query()
-- Json 문자열로 부터 데이타 혹은 객체를 배열로 구성해서 리턴
DECLARE @JSONData AS NVARCHAR(4000)
SET @JSONData = N'{
    "EmployeeInfo":{
        "FirstName":"Jignesh",
        "LastName":"Trivedi",
        "Code":"CCEEDD",
        "Addresses":[
            { "Address":"Test 0", "City":"Gandhinagar", "State":"Gujarat"},
            { "Address":"Test 1", "City":"Gandhinagar", "State":"Gujarat"}
        ]
    }
}'

SELECT JSON_QUERY(@JSONData,'$.EmployeeInfo.Addresses')
SELECT JSON_QUERY(@JSONData,'$.EmployeeInfo.Addresses[1]')

-- 중복되었을 경우는 다음과 같이 첫 번 째 값만 리턴
DECLARE @JSONData AS NVARCHAR(4000)
SET @JSONData = N'{
    "EmployeeInfo":{
        "FirstName":"Jignesh",
        "LastName":"Trivedi",
        "FirstName":"Tejas",
        "Code":"CCEEDD
    }
}'

SELECT JSON_VALUE(@JSONData,'$.EmployeeInfo.FirstName')


-- Json_Modify()
DECLARE @JSONData AS NVARCHAR(4000)
SET @JSONData = N'{
    "EmployeeInfo":{
        "FirstName":"aaaa",
        "LastName":"Trivedi",
        "Code":"CCEEDD",
        "Addresses":[
            { "Address":"Test 0", "City":"Gandhinagar", "State":"Gujarat"},
            { "Address":"Test 1", "City":"Gandhinagar", "State":"Gujarat"}
        ]
    }
}'
--SET @JSONData = JSON_MODIFY(@JSONData,'$.EmployeeInfo.FirstName', 'bbbb') -- update
--SELECT JSON_VALUE(@JSONData,'$.EmployeeInfo.FirstName') -- test

--SET @JSONData = JSON_MODIFY(@JSONData,'$.EmployeeInfo.MiddleName', 'G') -- insert
--SELECT JSON_VALUE(@JSONData,'$.EmployeeInfo.MiddleName') -- test

SET @JSONData = JSON_MODIFY(@JSONData,'append $.EmployeeInfo.Addresses', JSON_QUERY('{"Address":"Test 2", "City":"Bhavnagar", "State":"Gujarat"}','$')) -- append
select @JSONData


SET @JSONData = JSON_MODIFY(JSON_MODIFY(@JSONData,'$.EmployeeInfo.FirstName', 'Ramesh'),'$.EmployeeInfo.LastName','Oza') -- multiple update

SET @JSONData = JSON_MODIFY(@JSONData,'$.EmployeeInfo.FirstName', NULL) -- deleting
select @JSONData
------------------------
-- for json: 
-- xml 핸들링 부분에서 For Xml 과 같은 역할. 현재 table 구조적인 데이타를 json 구조로 바꾸어 줄때 사용
------------------------
--prep

CREATE TABLE [test].[Addresses](
    [Id] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [EmployeeId] [int] NULL,
    [Address] [varchar](250) NULL,
    [City] [varchar](50) NULL,
    [State] [varchar](50) NULL
);

create TABLE [test].[EmployeeInfo](
    [Id] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [Code] [varchar](50) NULL,
    [FirstName] [varchar](50) NULL,
    [LastName] [varchar](50) NULL,
);

INSERT [test].[Addresses] ([EmployeeId], [Address], [City], [State]) 
VALUES (1, N'Test 0', N'Seoul', N'Special'),
(1, N'Test 1', N'Daegu', N'Kyoungbuk'),
(3, N'Test 2', N'Kwanju', N'Junnam'),
(4, N'Test 3', N'Inchon', N'Kyeonggi');

INSERT [test].[EmployeeInfo] ([Code], [FirstName], [LastName]) 
VALUES (N'ABCD', N'Jiwoo', N'Byun'),
       (N'XYZ', N'Jiwon', N'Byun');

-- for json 실행
SELECT * FROM [test].[EmployeeInfo] e
INNER JOIN [test].[Addresses] Addresses ON e.Id = Addresses.EmployeeId
WHERE e.Id = 1
FOR JSON AUTO -- Auto 의 의미 : 테이블의 상, 하 개념이 json 으로 전한 될 때 자동으로 nested json 구조로 만들어진다는 의미

-- for json path
SELECT Id, Code, FirstName, LastName,
    (SELECT Id, Address, City, State
    FROM [test].[Addresses] a
    WHERE a.EmployeeId = e.Id
    FOR JSON AUTO
    ) as Addresses
FROM [test].[EmployeeInfo] e
WHERE e.Id =1
FOR JSON PATH, ROOT ('EmployeeInfo') -- Path 의 의미: 생성된 json 에 추가적인 구조를 붙이는데, 생성된 json 을 value 로 하고 새로운 키로 맵핑을 시키겠다는 의미.


------------------------
-- OpenJson
-- OpenXML 과 마찬가지로 메모리에 로딩되어 있는 JSON 파일을 table 구조로 표현
------------------------
DECLARE @JSONData AS NVARCHAR(4000)
SET @JSONData = N'{
        "FirstName":"Jignesh",
        "LastName":"Trivedi",
        "Code":"CCEEDD",
		"IsValid" : true,
        "Addresses":[
            { "Address":"Test 0", "City":"Gandhinagar", "State":"Gujarat"},
            { "Address":"Test 1", "City":"Gandhinagar", "State":"Gujarat"}
        ]
    }'
-- 참고
-- type cloumn: 0 : null / 1: string / 2: int / 3: true,false / 4: array  / 5: object

SELECT * FROM OPENJSON(@JSONData)

-- 미리 생성될 테이블의 column 을 지정할 수 있다.
DECLARE @JSONData AS NVARCHAR(4000)
--SET @JSONData = N'{
--        "FirstName":"Jignesh",
--        "LastName":"Trivedi",
--        "Code":"CCEEDD",
--        "Addresses":[
--            { "Address":"Test 0", "City":"Gandhinagar", "State":"Gujarat"},
--            { "Address":"Test 1", "City":"Gandhinagar", "State":"Gujarat"}
--        ]
--    }'
SET @JSONData = N'{
        "FirstName":"Jignesh",
        "LastName":"Trivedi",
        "Code":"CCEEDD"
    }'

SELECT * FROM OPENJSON(@JSONData)
WITH (FirstName VARCHAR(50), -- json 의 key 를 column 화
LastName VARCHAR(50),
Code VARCHAR(50))

-- 좀 더 detail 하게 child object 도
DECLARE @JSONData AS NVARCHAR(4000)
SET @JSONData = N'{
        "FirstName":"Jignesh",
        "LastName":"Trivedi",
        "Code":"CCEEDD",
        "Addresses":[
            { "Address":"Test 0", "City":"Bhavnagar", "State":"Gujarat"},
            { "Address":"Test 1", "City":"Gandhinagar", "State":"Gujarat"}
        ]
    }'

SELECT
FirstName, LastName, Address, City, State
    FROM OPENJSON(@JSONData)
    WITH (FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Code VARCHAR(50),
    Addresses NVARCHAR(max) as json -- as json 의 의미: specify JSON objects or arrays which are contained in the JSON text.  주의: 반드시 Nvarchar(max) 여야 한다.
) as B
cross apply openjson (B.Addresses)
with
(
    Address VARCHAR(50),
    City VARCHAR(50),
    State VARCHAR(50)
)

-- More
DECLARE @json NVarChar(2048) = N'{
  "brand": "BMW",
  "year": 2019,
  "price": 1234.6,
  "color": "red",
  "owner": null
  }'
 
SELECT * FROM OpenJson(@json)
WITH (CarBrand VARCHAR(100) '$.brand',
    CarModel INT '$.year',
    CarPrice MONEY '$.price',
    CarColor VARCHAR(100) '$.color',
    CarOwner NVARCHAR(200) '$.owner'
)


--------------------------------
-- Open Json with file loading
-- xml 과 마찬가지로 우선 OpenRowSet 을 이용한다.
--------------------------------
-- prep
-- 다음의 파일을 저장 (예: C:\testJson.json)
-- {
--     "EmployeeInfo":{
--         "FirstName":"Jignesh",
--         "LastName":"Trivedi",
--         "Code":"CCEEDD",
--         "Addresses":[
--             { "Address":"Test 0", "City":"Gandhinagar", "State":"Gujarat"},
--             { "Address":"Test 1", "City":"Gandhinagar", "State":"Gujarat"}
--         ]
--     }
-- }

SELECT [value] ,[type],[key]
FROM OPENROWSET (BULK 'C:\testJson.json', SINGLE_CLOB) as JsonFile
CROSS APPLY OPENJSON(BulkColumn)


----------------------------------------------
-- 추가
-- Open Web Api 를 SQL Server 내에서 Call 하여 그 받은 결과 값을 OPENJSON 을 이용하여 Tabel 에 입력하기
----------------------------------------------
-- 참고로 Oepn Web Api 필요한 부분에 대한 리스트 확인
-- ref: https://github.com/public-apis/public-apis#programming

-- 로그인 없이, 편하게 사용할 수 있는 대표적인 site
-- 1. https://jsonplaceholder.typicode.com/
-- 2. https://random-data-api.com/documentation

-- 수업에서는 위의 2 번 째 부분을 활용해서 작업하기로 한다.
-- endpoint: https://random-data-api.com/api/v2/beers?size=100

-- prep: 우선 OLE automation procedures (기본적으로  disable 되어 있는 이 부분을 활성화 해야 한다)
sp_configure 'show advanced options', 1;
GO

RECONFIGURE;
GO

sp_configure 'Ole Automation Procedures', 1;
GO

RECONFIGURE;
GO

-- web api call 에 주로 사용되는 3 stored procedure
-- 1. sp_OACreate lets you create an instance of an OLE object.
-- 2. sp_OAMethod allows you to call a method of an OLE object.
-- 3. sp_OADestroy will destroy a created OLE object 
-- 생성
DECLARE @URL NVARCHAR(MAX) = 'https://random-data-api.com/api/v2/beers';
Declare @Object as Int;
Declare @ResponseText as Varchar(8000);

-- 1. 생성
Exec sp_OACreate 'MSXML2.XMLHTTP', @Object OUT; -- 주의: @Object 의 타입은 반드시 Int

-- 2. Call
Exec sp_OAMethod @Object, 'open', NULL, 'get',
       @URL,
       'False'
Exec sp_OAMethod @Object, 'send', null
Exec sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT

--select @ResponseText

IF((Select @ResponseText) <> '')
BEGIN
     DECLARE @json NVARCHAR(MAX) = (Select @ResponseText)
     SELECT *
     FROM OPENJSON(@json) -- 앞서 배웠던 OPENJSON 적용
          WITH (
                 id int '$.id',
                 uid varchar(30) '$.uid',
                 brand varchar(30) '$.brand',
                 name varchar(30) '$.name',
                 style varchar(30) '$.style',
                 hop varchar(30) '$.hop',
                 yeast varchar(30) '$.yeast',
                 malts varchar(30) '$.malts',
                 ibu varchar(30) '$.ibu',
                 alcohol varchar(30) '$.alcohol',
                 blg varchar(30) '$.blg'
               );
END
ELSE
BEGIN
     DECLARE @ErroMsg NVARCHAR(30) = 'No data found.';
     Print @ErroMsg;
END

-- 3
Exec sp_OADestroy @Object -- (명시하지 않아도, 자동으로 생성된 내부 객체가 없어지지만, 명시적으로 적어주는 것이 일반적)




/************************************************
Assignment 12 

코드 분석: 다음 OpenJson 함수를 분석하기

DECLARE @json NVarChar(2048) = N'{
"owner": null,
"brand": "BMW",
"year": 2020,
    "status": false,
"color": [ "red", "white", "yellow" ],
 
 
"Model": {
    "name": "BMW M4",
    "Fuel Type": "Petrol",
    "TransmissionType": "Automatic",
    "Turbo Charger": "true",
    "Number of Cylinder": 4
}
}';


SELECT * FROM OpenJson(@json)
WITH (
      CarOwner NVARCHAR(200) '$.owner',
      CarBrand NVARCHAR(200) '$.brand',
      CarModel INT '$.year',
      CarPrice BIT '$.status',
      CarColor NVARCHAR(MAX) '$.color' AS JSON,
      CarColor NVARCHAR(MAX) '$.Model' AS JSON
)




Assignment 13
다음과 같은 Json 이 있다.


DECLARE @json NVARCHAR(MAX);

SET @json = N'[
  {"id": 2, "info": {"name": "John", "surname": "Smith"}, "age": 25},
  {"id": 5, "info": {"name": "Jane", "surname": "Smith"}, "dob": "2005-11-04T12:00:00"}
]';

위의 Json Data 를 OEPNJson 함수를 통하여 다음과 같은 result set 이 보이도록 한다.

---------------------------------------------------------
ID	firstName	  lastName	  age	    dateOfBirth
---------------------------------------------------------
2	  John	      Smith	      25	
5	  Jane	      Smith		            2005-11-04T12:00:00




Assignment 14

다음의 web api endpoint 를 확인한다.
https://jsonplaceholder.typicode.com/posts?userId=1 (여기에서 userId 뒤의 value 는 동적으로 바꿀 수도 있다.)
이 endpoint 를 이용해서 아래에 생성하는 test.Posts_details tabale 에 자료를 입력한다. 
stored procedure 를 구성해서 userId 의 값을 받아올 수 있도록 한다.

-- prep

create table test.Posts_details
(
    userID varchar(30),
    Id varchar(30),
    Post_title varchar(300),
    Post_body  varchar(8000)

)

-- 결과적으로 여기에 값이 나와야 한다
select * from test.Posts_details

*************************************************/