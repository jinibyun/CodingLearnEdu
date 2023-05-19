/*********************************
bcp utility
*********************************/
-- Bulk Copy Program. 
-- BCP is a command-line tool 이고 이를 이용해 file 에 있는 자료를 
-- table 에 한꺼번에 입력하거나 반대로 table 에 있는 자료를 file 로 생성한다. (주로 대용량 데이타 처리)

-- 실행 방법 (Dos command prompt 에서 bcp 입력)
-- >> bcp

/*
usage: bcp {dbtable | query} {in | out | queryout | format} datafile
  [-m maxerrors]            [-f formatfile]          [-e errfile]
  [-F firstrow]             [-L lastrow]             [-b batchsize]
  [-n native type]          [-c character type]      [-w wide character type]
  [-N keep non-text native] [-V file format version] [-q quoted identifier]
  [-C code page specifier]  [-t field terminator]    [-r row terminator]
  [-i inputfile]            [-o outfile]             [-a packetsize]
  [-S server name]          [-U username]            [-P password]
  [-T trusted connection]   [-v version]             [-R regional enable]
  [-k keep null values]     [-E keep identity values][-G Azure Active Directory Authentication]
  [-h "load hints"]         [-x generate xml format file]
  [-d database name]        [-K application intent]  [-l login timeout]
*/

/* --------------------
A. From table to a file
-----------------------*/
-->> bcp database_name.schema_name.table_name out "path_to_file" -c -U user_name -P password
-- -U ... -P 대신에 통합 계정을 사용하는 환경이라면 (특히 개발자 로컬 환경), 이 대신에 -T 옵션을 사용하면 된다.
-- 예) bcp database_name.schema_name.table_name out "path_to_file" -c -T

-- test
-- 우선  C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn 으로 이동한 후에 (bcp 버전이 다를 수 있기 때문에 거기에서 다음을 실행한다.)
>> bcp Bikestores.production.products out "c:\products_2023512.txt" -c -S "JINIDEV\SQLEXPRESS01" -T


/* --------------------
B. From querty to a file
-----------------------*/
>> bcp "select product_name, list_price from bikestores.production.products where model_year=2017" queryout "c:\products_from_query_20230512.txt" -S "JINIDEV\SQLEXPRESS01" -w -T


/* --------------------
C. From file to a table
-----------------------*/
-- 위에서 생성한 products.txt 를 다음의 새로운 table 로 bulk copy

create schema production
-- prep
CREATE TABLE production.products_bcp (
	product_id INT IDENTITY (1, 1) PRIMARY KEY,
	product_name VARCHAR (255) NOT NULL,
	brand_id INT NOT NULL,
	category_id INT NOT NULL,
	model_year SMALLINT NOT NULL,
	list_price DECIMAL (10, 2) NOT NULL
);

drop table production.products_bcp

select * from production.products_bcp
>> bcp Bikestores.production.products_bcp in "c:\products_2023512.txt" -c -S "JINIDEV\SQLEXPRESS01" -T

-- test
select * from production.products_bcp


/************************************************
Assignment 10

(bcp ...out)
1. bcp 를 통해 sales.orders table 에 있는 모든 자료를 txt 파일로 만든다. 파일이름은 C:\sales.txt
bcp Bikestores.sales.orders out "c:\sales_2023512.txt" -c -S "JINIDEV\SQLEXPRESS01" -T

2. 다른 databae 생성한다. : create database BikeStoresSales

3. BikeStoresSales 로 이동하여 : use BikeStoresSales
sales.orders 테이블 생성한다.

select * from sales.orders

(bcp ...in)
4. bcp 를 통해 1 번에서 생성한 sales.txt 를 새로 생성한 BikeStoresSales DB 의 
sales.orders 테이블로 이동한다.


*************************************************/