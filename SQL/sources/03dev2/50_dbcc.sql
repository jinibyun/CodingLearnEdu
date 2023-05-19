/*********************************
dbcc - database console command
*********************************/
-- DB, DB 안의 객체들에 대한 개발 혹은 "관리"시에 편리한 기능들을 제공하는 일종의 Utility Tool

-- Data 자체에 대한 Performance 에는 영향을 주지 않는다.
-- sysadmin 혹은 database owner 권한이 필요하다

-- 사용할 수 있는 명령어 확인
DBCC HELP ('?');

-- 예 : 한 명령어에 대해 구체적인 파라미터를 알아볼 때
DBCC HELP (CHECKDB);

-- ref: https://learn.microsoft.com/en-us/sql/t-sql/database-console-commands/dbcc-tracestatus-transact-sql?view=sql-server-ver16
-- 각 명령어에 대한 자세한 사항은 위의 사이트에서 확인할 수 있다.

/* ------ 자주 사용되는 부분 중심으로 몇 가지 확인 ------ */
----------------------------
-- 1 DBCC SQLPERF(LOGSPACE)
----------------------------
DBCC SQLPERF (LOGSPACE); -- 로그 size check

-- 활용
-- prep
CREATE TABLE test.tblLogMon(
	DatabaseName VARCHAR(250),
	LogSize_MB DECIMAL(22,4),
	LogSpaceUsed DECIMAL(5,2),
	Status TINYINT,
	RecordStamp DATETIME DEFAULT GETDATE()
)


INSERT INTO test.tblLogMon (DatabaseName,LogSize_MB,LogSpaceUsed,Status) 
EXEC ('DBCC SQLPERF(LOGSPACE)') -- 이 때의 Exec 함수는 SP 를 실행하는 명령어가 아니라 문자열을 실행하는 함수의 역할을 한다.

-- 해당 DB 의 logspace size 를 체크할 수 있다.
SELECT *
FROM test.tblLogMon
WHERE DatabaseName = 'BikeStores'
	AND LogSpaceUsed > 75.00 -- 적절한 값을 두어 체크할 수 있다.
ORDER BY RecordStamp DESC

--------------------------
-- 2 DBCC SHOW_STATISTICS
--------------------------
sp_helpindex '[sales].[Customers]'; -- table 에 적용된 index 확인

DBCC SHOW_STATISTICS ('[sales].[Customers]','ix_cust_email'); -- 좀 더 자세하게 해당 인덱스의 사항 확인

-- 세 가지 result return
-- ref: https://blog.devart.com/how-to-use-sql-server-dbcc-show_statistics.html 를 통해 결과 분석

---------------------------------------
-- 3 DBCC SHRINKFILE : Disk Compression
-- 주의: DB 의 속성에 AutoShrink 기능을 On 해 두면 성능에 영향을 주기 
-- 때문에 그대로 Off (기본 값)을 두고 필요시에만 진행한다.
-- DBCC SHRINKDATABASE(databasename) 와는 다르게 개별 파일 (mdf) 혹은 ldf 에 대해 파일 단위로 size compression 한다.
---------------------------------------
-- prep: 확인
SELECT * FROM sys.database_files -- system DB 외의 파일에 대한 정보 제공

-- 확인
SELECT TYPE_DESC, NAME, size, max_size, growth, is_percent_growth, physical_name , 1 + size*8./1024
FROM sys.database_files WHERE name = N'BikeStores';
-- 주의: 여기에서 size 는 index에서 배웠었던 page (1 page 는 8K : 8192 bytes) 의 개념.
-- 여기에서 size 를 mb 로 바꾸면
-- size * 8 * 1024 / 1024 ===>> 을 통해서 byte 계산을 하면 총 byte 를 얻을 수 있다. 추가로 size * 8 * 1024 / (1024 * 1024)  로 하게 되면 MB 를 얻을 수 있다.

-- page size 를 가지고 MB 로 전환
SELECT size*8./1024 FROM sys.database_files 


-- 실제 사용 (이 부분도 stored procedure 로 구성해서 작업할 수 있다.)
DECLARE @FileName sysname = N'BikeStores';
DECLARE @TargetSize INT = (SELECT 1 + size*8./1024 FROM sys.database_files WHERE name = @FileName); -- MB
DECLARE @Factor FLOAT = 0.999; -- factor 는 상황에 따라 바꿀 수 있다.
 
WHILE @TargetSize > 0
BEGIN
    SET @TargetSize *= @Factor;
    
    DBCC SHRINKFILE(@FileName, @TargetSize); -- 실제 file의 size를 줄이는 작업

    DECLARE @msg VARCHAR(200) = CONCAT('Shrink file completed. Target Size: ', 
         @TargetSize, ' MB. Timestamp: ', CURRENT_TIMESTAMP); -- CURRENT_TIMESTAMP: 현재 시간을 출력 (GetDate 와 같음)
    RAISERROR(@msg, 1, 1) WITH NOWAIT; -- RAISE 에러의 두 번 째 파라미터: 0-10: info   / 11 -20:error  / 21-30: critical
	--print @msg
    WAITFOR DELAY '00:00:01'; -- 각 while 구문이 실행될 때마다 시간의 차이를 두고 실행 (현재 DB 가 사용되고 있다는 점 주의. 예를 들어 현재 사용되고 있는 DB 에 영향을 최소화 하기 위해서는 1시간, 2 시간 간격..(예를 들어) 진행할 수 있다.) 여기에서는 database 가 idle 되거나 혹은 관리 모드에 있다고 가정하고 시간을 1 초로 지정한 것임.
END;

-- test
-- size 가 줄어든 것을 확인할 수 있다.
SELECT 1 + size*8./1024 FROM sys.database_files;


--------------------------
-- DBCC MEMORYSTATUS 
--------------------------
-- byte 단위로 value 를 보여줌


--------------------------
-- DBCC opentran 
--------------------------
-- prep
CREATE TABLE sales.promotions (
    promotion_id INT PRIMARY KEY IDENTITY (1, 1),
    promotion_name VARCHAR (255) NOT NULL,
    discount NUMERIC (3, 2) DEFAULT 0,
    start_date DATE NOT NULL,
    expired_date DATE NOT NULL
); 

-- 실행
begin TRAN
    INSERT INTO sales.promotions (
    promotion_name,
    discount,
    start_date,
    expired_date
)
VALUES
    (
        '2018 Summer Promotion',
        0.15,
        '20180601',
        '20180901'
    );

dbcc opentran ('BikeStores'); -- open 되어 있는 transaction


ROLLBACK TRAN -- 다시 취소 시키고 

-- 확인
dbcc opentran ('BikeStores');


/*******************************************
Assingment 15 코드 분석 ( DBCC INDEXDEFRAG 에 관한)

다음의 쿼리 구문은 기본적으로 DBCC INDEXDEFRAG 를 이용해 DB 안의 모든 table 에 적용된 index 를 찾아 defragment 를 하는 로직이다.
이를 실행하기 전에 먼저 분석해 본다.

-- ref: https://learn.microsoft.com/en-us/sql/t-sql/database-console-commands/dbcc-indexdefrag-transact-sql?view=sql-server-ver16

SET NOCOUNT ON;
DECLARE @tablename VARCHAR(255);
DECLARE @execstr   VARCHAR(400);
DECLARE @objectid  INT;
DECLARE @indexid   INT;
DECLARE @frag      DECIMAL;
DECLARE @maxfrag   DECIMAL;
  
-- 사용자의 임의 값 지정
SELECT @maxfrag = 30.0;
  
-- 커선 선언
DECLARE tables CURSOR FOR
   SELECT TABLE_SCHEMA + '.' + TABLE_NAME
   FROM INFORMATION_SCHEMA.TABLES
   WHERE TABLE_TYPE = 'BASE TABLE';
  
-- 세션 table 생성
CREATE TABLE #fraglist (
   ObjectName CHAR(255),
   ObjectId INT,
   IndexName CHAR(255),
   IndexId INT,
   Lvl INT,
   CountPages INT,
   CountRows INT,
   MinRecSize INT,
   MaxRecSize INT,
   AvgRecSize INT,
   ForRecCount INT,
   Extents INT,
   ExtentSwitches INT,
   AvgFreeBytes INT,
   AvgPageDensity INT,
   ScanDensity DECIMAL,
   BestCount INT,
   ActualCount INT,
   LogicalFrag DECIMAL,
   ExtentFrag DECIMAL);
  
-- 커서 오픈
OPEN tables;
  
-- 커서 루핑
FETCH NEXT
   FROM tables
   INTO @tablename;
  

WHILE @@FETCH_STATUS = 0
BEGIN
   -- DBCC SHOWCONTIG 를 이용해 값 입력
   INSERT INTO #fraglist
   EXEC ('DBCC SHOWCONTIG (''' + @tablename + ''')
      WITH FAST, TABLERESULTS, ALL_INDEXES, NO_INFOMSGS');
   FETCH NEXT
      FROM tables
      INTO @tablename;
END;
  
-- 커서 닫음
CLOSE tables;
DEALLOCATE tables;
  
--select * from #fraglist

-- defragment 할 인덱스 리스트를 조회
DECLARE indexes CURSOR FOR
   SELECT ObjectName, ObjectId, IndexId, LogicalFrag
   FROM #fraglist
   WHERE LogicalFrag >= @maxfrag
      AND INDEXPROPERTY (ObjectId, IndexName, 'IndexDepth') > 0;
  
-- 새로운 커서 
OPEN indexes;
  
-- 커서 루핑
FETCH NEXT
   FROM indexes
   INTO @tablename, @objectid, @indexid, @frag;
  
WHILE @@FETCH_STATUS = 0
BEGIN
   PRINT 'Executing DBCC INDEXDEFRAG (0, ' + RTRIM(@tablename) + ',
      ' + RTRIM(@indexid) + ') - fragmentation currently '
       + RTRIM(CONVERT(varchar(15),@frag)) + '%';
   SELECT @execstr = 'DBCC INDEXDEFRAG (0, ' + RTRIM(@objectid) + ',
       ' + RTRIM(@indexid) + ')';
   EXEC (@execstr); -- 핵심이 되는 DBCC INDEXDEFRAG 을 통해 Defragmentation
  
   FETCH NEXT
      FROM indexes
      INTO @tablename, @objectid, @indexid, @frag;
END;
  
-- 커서 해제
CLOSE indexes;
DEALLOCATE indexes;
  
-- Delete the temporary table.
DROP TABLE #fraglist;
GO
********************************************/