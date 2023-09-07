using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace csharp_adonet.basic
{
    public class _10_dataReader : basicProcesses
    {
        public override void process()
        {
            /*
             prep:
             USE Student;
             GO

             CREATE TABLE Student2(
                  Id INT PRIMARY KEY,
                  Name VARCHAR(100),
                  Email VARCHAR(50),
                  Mobile VARCHAR(50)
             )
             GO

             INSERT INTO Student2 VALUES (101, 'Anurag', 'Anurag@dotnettutorial.net', '1234567890')
             INSERT INTO Student2 VALUES (102, 'Priyanka', 'Priyanka@dotnettutorial.net', '2233445566')
             INSERT INTO Student2 VALUES (103, 'Preety', 'Preety@dotnettutorial.net', '6655443322')
             INSERT INTO Student2 VALUES (104, 'Sambit', 'Sambit@dotnettutorial.net', '9876543210')
             GO

             CREATE TABLE Customers(
                  ID INT PRIMARY KEY,
                  Name VARCHAR(100),
                  Mobile VARCHAR(50)
             )
             GO
             INSERT INTO Customers VALUES (101, 'Anurag', '1234567890')
             INSERT INTO Customers VALUES (102, 'Priyanka', '2233445566')
             INSERT INTO Customers VALUES (103, 'Preety', '6655443322')
             GO
              */
            try
            {
                using (SqlConnection connection = new SqlConnection(ConnectionStringStudent))
                {
                    SqlCommand cmd = new SqlCommand("select Name, Email, Mobile from student2", connection);

                    connection.Open();

                    SqlDataReader sdr = cmd.ExecuteReader();

                    //! DataReader 를 통해 가져오기 전에 다음과 같이 close 를 호출하게 되면 에러 발생
                    // connection.Close();

                    //Reading Data from Reader will give runtime error as the connection is closed
                    while (sdr.Read())
                    {
                        Console.WriteLine(sdr[0] + ",  " + sdr[1] + ",  " + sdr[2]);
                    }

                    //! 반드시 DataReader 작업 후에는 Close 를 통해 닫아 주어야 한다. 하나 혹은 두 개 이상의 레코드를 가져오는 모든 작업에 적용
                    sdr.Close();

                    //To retrieve the second result set from SqlDataReader object, use the NextResult(). 
                    //The NextResult() method returns true and advances to the next result-set.
                    cmd.CommandText = "SELECT * FROM Customers";
                    sdr = cmd.ExecuteReader();

                    Console.WriteLine("\nSecond Result Set:");
                    //Looping through each record
                    while (sdr.Read())
                    {
                        Console.WriteLine(sdr[0] + ",  " + sdr[1] + ",  " + sdr[2]);
                    }

                    //! 반드시 DataReader 작업 후에는 Close 를 통해 닫아 주어야 한다.
                    sdr.Close();
                }
            }
            catch (Exception e)
            {
                Console.WriteLine("OOPs, something went wrong.\n" + e.Message);
            }
        }
    }
}
