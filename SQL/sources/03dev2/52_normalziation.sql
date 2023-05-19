/*****************************************************
테이블 정규화(Normalization) 비 정규화 (Denormalization)
******************************************************/

-- Data Integrity (무결성) : data 의 중복성이 나타나지 않고 (혹은 최소화 되고) 참조가 부족해서 확인할 수 없는 데이타의 입력을 허용하지 않으면, redundancy (즉 null value) 를 최소화 한 상태.

-- 우선 아래의 예제에서는 자주 범하기 쉬운 Table Design 을 Data Integrity 의 관점에서 알아보기로 한다.

-- ===================================================================
-- 1단계의 Normalzation
-- ===================================================================
-------------------------
-- 1 table design 실수 
-- 중복성이 예상되는 칼럼에 제약 조건을 걸지 않아, 중복성을 허용하는 오류
-------------------------
-- prep
CREATE TABLE test.BadDesign_Customer_new(
    CustomerId INT IDENTITY (1, 1), -- NN/ ND
    Name VARCHAR(200),
    Email VARCHAR(200),
    PhoneNumber VARCHAR(200),
    Product VARCHAR(200)
)

-- test
INSERT INTO test.BadDesign_Customer_new
  select 'aaa', 'aaa@gmail.com', '010-1234-1234', 'Mobile' UNION ALL
  select 'bbb', 'aaa@gmail.com', '010-1234-1234', 'Mobile'

-- 결과
select * from test.BadDesign_Customer_new

-- 분석: Email 과 Phone Number 는 PK 는 아니지만, 고유한 데이타 속성을 가지기 때문에, Unique 한 속성을 부여할 수 있었다.
-- PK 가 생략 되어 있기 때문에 table scan 이 들어가서 성능이 늦어진다. 

-- 해결: 여기서는 일단 중복성 제거에 중점을 둔다.
TRUNCATE table test.BadDesign_Customer_new
select * from test.BadDesign_Customer_new

ALTER TABLE test.BadDesign_Customer_new 
ADD CONSTRAINT UK_BadDesign_Customer_Email2 UNIQUE (Email); 

ALTER TABLE test.BadDesign_Customer_new  
ADD CONSTRAINT UK_BadDesign_Customer_PhoneNumber2 UNIQUE (PhoneNumber);

-- test
INSERT INTO test.BadDesign_Customer_new
  select 'aaa', 'aaa@gmail.com', '010-1234-1234', 'Mobile' UNION ALL
  select 'bbb', 'aaa@gmail.com', '010-1234-1234', 'Mobile'

-- 결과: 중복된 데이타가 들어가지 않음

-------------------------
-- 2 table design 실수 
-- 하나의 column 에 여러 개의 데이타를 , 혹은 | 를 사용하여 입력: redundancy 문제
-------------------------
-- test
TRUNCATE table test.BadDesign_Customer_new

INSERT INTO test.BadDesign_Customer_new
  select 'aaa', 'aaa@gmail.com', '010-1234-1234', 'Mobile, Laptop, Tablet' UNION ALL
  select 'bbb', 'bbb@gmail.com', '010-1234-9876', 'Mobile, Mobile, Desktop'

-- 결과
select * from test.BadDesign_Customer_new

-- 분석: Product 라는 하나의 칼럼에 여러 값을 조회하게 되면 그 하나의 칼럼에 중복되는 데이타가 들어가지 않게 하는 확신할 수 없고, 각 개별 column 으로 값이 되어 있지 않기 때문에 추후 분석 하는 부분이 어렵게 된다. 칼럼이 저장하는 데이타는 최소화 되어야 한다.

-- 해결 (NOTE: 아직 100% 라고 할 수 없다. 일단 Data Redundancy 를 일으키지만, 위에서 야기하는 중복성과 조회, 분석 부분은 해결했다고 할 수 있다.
Alter TABLE test.BadDesign_Customer
Add  Product1 varchar(100) null, Product2 varchar(100) null, Product3 varchar(100) null;

Alter table test.BadDesign_Customer
Drop column Product;

update test.BadDesign_Customer set Product1 = 'Mobile', Product2='Laptop', Product3 ='Tablet' where email = 'aaa@gmail.com';
update test.BadDesign_Customer set Product1 = 'Mobile', Product2='Mobile' where email = 'bbb@gmail.com';

-- 결과
select * from test.BadDesign_Customer_new

-- 분석: 각 개별 column 으로 값으로 최소화 하는 데는 성공했지만, 칼럼의 모든 값에 일정한 값이 입력된 것은 아니다. 이를 "redundant data" 라고 부른다. 만약 Product 4, 5, 6... 계속 추가 하게 되면 redundancy 는 증가할 수 밖에 없다.

-------------------------
-- 3 table design 실수 
-- one to one 관계에만 머물 수 있는 문제
-------------------------
-- 위 2 번의 해결책은 앞서 언급했듯이 또다른 문제를 야기 한다. redundancy. 즉 이는 하나의 테이블 안에서 모든 데이타를 저장하려고 하는데서 그 이유를 찾을 수 있다

-- 문제점은 이미 #2 에서 확인했다

-- 해결책
-- 위의 테이블을 둘러 나누어야 한다.

--1. product 만 저장할 수 있는 다음과 같은 테이블 생성
CREATE TABLE test.BadDesign_Product_new(
        [ProductId] [int] PRIMARY KEY,
        [ModelId] [int] UNIQUE,
        [ProductName] [nvarchar](50) NOT NULL,
        [ProductCost] [money] NOT NULL, 
        [ModelName] [nvarchar](50) NULL,
        [ManufacturerName] [nvarchar](50) NOT NULL
);

-- 2. 기존의 customer table 수정
-- 간단하게 하기 위해...
DROP TABLE test.BadDesign_Customer_new;

CREATE TABLE test.BadDesign_Customer_new(
    CustomerId INT PRIMARY KEY,
    Name VARCHAR(200) ,
    Email VARCHAR(200) UNIQUE,
    PhoneNumber VARCHAR(200) UNIQUE,
    ProductId INT FOREIGN KEY REFERENCES test.BadDesign_Product_new(ProductId), -- 참조하게 한다.
    ModelId INT FOREIGN KEY REFERENCES test.BadDesign_Product_new(ModelId) -- 참조하게 한다.
);



select * from test.BadDesign_Product_new
-- 3. 입력
INSERT INTO test.BadDesign_Product_new
VALUES (1,10001, 'Mobile', 1500000, 'Samsung', 'Samsung'), 
       (2,10002, 'Tablet', 7900000, 'Apple', 'Apple');

INSERT INTO test.BadDesign_Customer_new
  select 1, 'aaa', 'aaa@gmail.com', '010-1234-1234', 1, 10001 UNION ALL
  select 2, 'bbb', 'bbb@gmail.com', '010-1234-9876', 2, 10002

-- 확인
select * from test.BadDesign_Customer -- Redundancy 문제가 해결됐음을 볼 수 있다. 하지만 또 다른 문제가 발생할 "수" 도 있다. Customer 는 같은 Product 을 두 개 이상을 구입할 수 없게된다. one to one relationship 이기 때문이다.

-- 참고로 이 시점 부터는 ERD 를 편의상 이용하기로 한다. 특별히 관계를 맺고 끊고 하는데 있어서 시간을 아끼기 위해.

/* 해결: many to many  */
-- 편의상 GUI
-- 관계 삭제
ALTER TABLE test.BadDesign_Customer
DROP CONSTRAINT FK__BadDesign__Produ__3C89F72A;

ALTER TABLE test.BadDesign_Customer
DROP CONSTRAINT  FK__BadDesign__Produ__1FB8AE52

ALTER TABLE test.BadDesign_Customer_new
DROP COLUMN ProductId;

ALTER TABLE test.BadDesign_Customer
DROP COLUMN ModelId;

-- many to many 해결을 위해 새로운 테이블 작성: 주의 사실 이 테이블 자체는 중복될 수 밖에 없다.
CREATE TABLE test.BadDesign_ProductCustomerMapping_new(
 [ProductCustomerId] INT PRIMARY KEY,
 [CustomerId] INT FOREIGN KEY REFERENCES test.BadDesign_Customer_new(CustomerId),
 [ModelId] INT FOREIGN KEY REFERENCES test.BadDesign_Product_new(ModelId),
        [ProductId] INT FOREIGN KEY REFERENCES test.BadDesign_Product_new(ProductId)
);

-- ===================================================================
-- 2단계의 Normalzation
-- ===================================================================

-------------------------
-- 4 table design 실수 
-- 하나의 table 내에서 관계있는 칼럼들끼리 묶여 있는 지 않을 때.
-------------------------
sp_help 'test.BadDesign_Product_new' -- table 구조 확인
-- 지금 현재까지는 PK 를 제외한 나머지 칼럼 들이 각각 ProductId, Model Id 에 따라 값을 알 수 있을 정도로 테이블 구조가 되어 있다. 하지만 ProductId 와 Model ID 는 엄격하게 서로 다른 boundary 에 속하는 집합이라고 할 수 있는데, 그것을 여기에 함께 사용하고 있다는 얘기가 된다. table 은 "관련" 있는 데이타들에 대한 최소한의 묶음이어야 한다.

-- 해결 (non-key columns are fully dependent on the primary key column.)
CREATE TABLE test.BadDesign_Model_new(
    [ModelId] [int] PRIMARY KEY,
    [ModelName] [nvarchar](50) NULL,
    [ManufacturerName] [nvarchar](50) NULL,
    [Country] [nvarchar](50) NULL,
    [City] [nvarchar](50) NULL
);

-- TIP: 관계의 복잡성 때문에 구문 보다는 ERD (Entity Relationship Diagram) 를 이용한다.
Alter table test.BadDesign_Product
Drop column ModelId;

Alter table test.BadDesign_Product
Drop column ModelName;

Alter table test.BadDesign_Product
Drop column ManufacturerName;

DROP TABLE test.BadDesign_ProductCustomerMapping;

CREATE TABLE test.BadDesign_ProductCustomerMapping(
 [ProductCustomerId] INT PRIMARY KEY,
 [CustomerId] INT FOREIGN KEY REFERENCES test.BadDesign_Customer(CustomerId),
 [ModelId] INT FOREIGN KEY REFERENCES test.BadDesign_Model(ModelId),
    [ProductId] INT FOREIGN KEY REFERENCES test.BadDesign_Product(ProductId)
);

/************ 위의 네 가지 문제점을 해결한 상태가 바로 1, 2 단계의 Normalization 이라고 한다. **********/

-- ===================================================================
-- 3단계의 Normalzation
-- 관계있는 column 들 끼리 묶여 있다고 해도, 종속적 의존성이 보일때

-- key 가 되지 않은 칼럼 들끼리의 종속성
-- ===================================================================
-- duplication 
-- redundancy
-- many to many
-- column dependancy

-------------------------
-- 5 table design 실수 
-- 종속적 의존성
-------------------------
-- Model table 의 city 와 country 를 하나의 table 묶어 두는 것은 (transitive dependencies) 좋은 디자인 이 아니다.

-- 해결
CREATE TABLE [test.BadDesign_Country_new](
    [CountryId] [int] Primary Key,
    [CountryName] [nvarchar](50)
);

CREATE TABLE [test.BadDesign_City_new](
 [CityId] [int] Primary Key,
 [CityName] [nvarchar](50),
 [CountryId] INT FOREIGN KEY REFERENCES [test.BadDesign_Country_new](CountryId) 
);


-- ERD 로 진행해도 좋다. (의존성 때문에 일일이 구문으로 삭제가 시간이 걸리므로)
ALTER TABLE test.BadDesign_Model DROP COLUMN Country;
ALTER TABLE test.BadDesign_Model DROP COLUMN City;

ALTER TABLE test.BadDesign_Model ADD CountryId INT;
ALTER TABLE test.BadDesign_Model
ADD FOREIGN KEY (CountryId) REFERENCES  [test.BadDesign_Country](CountryId);


/*최종적으로 ERD 를 보면서 데이타 전반에 걸친 구조를 확인하는 게 좋다.*/


/************************************
Assignment 17 정규화 진행

-- 0. Background 가 되는 업무 규칙
한 한생의 여러 코스를 선택할 수 있고, 한 코스는 여러 학생에 의해 선택될 수 있다.
한 코스당 할당 되는 강사의 수는 여럿일 수 있고, 한 강사는 하나의 코스만을 선택하도록 한다.
그래서 전체 데이타를 가지고 있는 단 하나의 table 이 있다고 가정한다. 
추후 Major 와 Grade 부분은 확장될 수 있으나, 여기에서는 복잡성 때문에 Course 와 Student 그리고 Instructor 중심으로 table 들을 design 해 본다.

이러한 table 이 있다고 가정한다.

Student_Grade_Report (StudentNo, StudentName, Major, CourseNo, CourseName, Grade, InstructorNo, InstructorName, InstructorLocation)

-- 1 단계, 2 단계, 그리고 3 단계의 Normalzation 을 생각해 보고, 가능한 한 순서대로 디자인 해 본다. (SSMS 의 Design tool 을 편의상 사용하면 좋다.)

-- 1 단계의 NF (Normal Form) 을 다음과 같은 순서로 진행한다.
  -- 1-1. 첫 번 째: duplication 을 제거 하기 위해 PK, Unique 를 적용해 본다.
		
		StudentNo, CourseNo: PK 속성 부여

  -- 1-2. 두 번 째: redundancy 를 제거 하기 위해, 테이블을 나누어 필요시 관계 설정한다. (편의상 여기서는 plain 하게만 작업했다.)
		Student (PK, UNIQUE 확인)
		Course (PK, UNIQUE 확인)
		Instructor (PK, UNIQUE 확인)
		
          
  -- 1.3  세 번 째: 테이블과 테이블의 관계가 many to many 라면 1 to many 의 관계로 바꾼다.
          Student (PK, UNIQUE 확인): StudentNo, StudentName, Major
		  Course (PK, UNIQUE 확인): CourseNo, CourseName, Grade
		  StudentCourse (PK, FK (student 와 course 동시 참조) )
		  Instructor (PK, UNIQUE 확인 , FK (course 참조) ): InstructorNo, InstructorName, InstructorLocation

-- 2 단계의 NF (Normal Form) 을 다음과 같은 순서로 진행한다.
  -- 2.1 하나의 table 내에서 관계있는 칼럼들끼리 묶여 있는 지 경우를 찾아 본다.
          Student (PK, UNIQUE 확인): StudentNo, StudentName, Major
		  Course (PK, UNIQUE 확인): CourseNo, CourseName, Grade
		  StudentCourse (PK, FK (student 와 course 동시 참조) )
		  Instructor (PK, UNIQUE 확인 , FK (course 참조) ): InstructorNo, InstructorName, InstructorLocation

-- 3 단계의 NF (Normal Form) 을 다음과 같은 순서로 진행한다. (키가 아닌 칼럼들끼리의 종속성 제거)
  --3.1 2 단계 까지 진행한 상태, 즉 duplicateion, redundancy, many to many, 그리고 밀접한 관련 있는 업무들만을 묶은 집합을 table 화 한 상태라면, 각 테이블의 키가 아닌 칼럼들을 서로 비교하여 종속성이 있는 지 확인하고, 이를 수정하여 필요로 한다면 별도의 table 로 구성한다.



        
*************************************/