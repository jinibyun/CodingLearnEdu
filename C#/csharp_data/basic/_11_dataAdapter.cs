using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace csharp_adonet.basic
{
    public class _11_dataAdapter : basicProcesses
    {
        /*
         prep

        CREATE TABLE Student3(
         Id INT PRIMARY KEY,
         Name VARCHAR(100),
         Email VARCHAR(50),
         Mobile VARCHAR(50)
        )
        GO

        INSERT INTO Student3 VALUES (101, 'Anurag', 'Anurag@dotnettutorial.net', '1234567890')
        INSERT INTO Student3 VALUES (102, 'Priyanka', 'Priyanka@dotnettutorial.net', '2233445566')
        INSERT INTO Student3 VALUES (103, 'Preety', 'Preety@dotnettutorial.net', '6655443322')
        INSERT INTO Student3 VALUES (104, 'Sambit', 'Sambit@dotnettutorial.net', '9876543210')
        GO
         */
        public override void process()
        {           
            try
            {
                using (SqlConnection connection = new SqlConnection(ConnectionStringStudent))
                {
                    // SqlDataAdapter 는 내부적으로 SqlCommand 를 참조한다.
                    SqlDataAdapter da = new SqlDataAdapter("select * from student3", connection);
                    
                    // 그 후에 다음과 같이 DataTable 이라는 object 사용
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    
                    //! Fille method 역할 (핵심은: 연결과 비연결을 자동으로 진행한다)
                    //1. Open the connection 
                    //2. Execute Command
                    //3. Retrieve the Result
                    //4. Fill/Store the Retrieve Result in the Data table
                    //5. Close the connection

                    Console.WriteLine("Using Data Table");
                    //Active and Open connection is not required
                    //dt.Rows: Gets the collection of rows that belong to this table
                    
                    foreach (DataRow row in dt.Rows)
                    {                      
                        Console.WriteLine(row["Name"] + ",  " + row["Email"] + ",  " + row["Mobile"]);                        
                    }
                    Console.WriteLine("---------------");
                    
                    //Using DataSet (메모리 상의 database)
                    DataSet ds = new DataSet();
                    da.Fill(ds, "student");
                    Console.WriteLine("Using Data Set");
                    
                    foreach (DataRow row in ds.Tables["student"].Rows)
                    {
                        Console.WriteLine(row["Name"] + ",  " + row["Email"] + ",  " + row["Mobile"]);
                    }
                }
            }
            catch (Exception e)
            {
                Console.WriteLine("OOPs, something went wrong.\n" + e.Message);
            }
        }
    }
}
