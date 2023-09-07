using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace csharp_adonet.basic
{
    public class _16_storedProcedure : basicProcesses
    {
        /*
         prep

        USE Student
        GO

        CREATE PROCEDURE spGetStudentById
        (
           @Id INT
        )
        AS
        BEGIN
             SELECT Id, Name, Email, Mobile
             FROM Student3
             WHERE Id = @Id
        END
        GO

        CREATE TABLE Student4(
                  Id INT IDENTITY(1,1) PRIMARY KEY,
                  Name VARCHAR(100),
                  Email VARCHAR(50),
                  Mobile VARCHAR(50)
             )
        GO

        CREATE PROCEDURE spCreateStudent
        (
            @Name VARCHAR(100),
            @Email VARCHAR(50),
            @Mobile VARCHAR(50),
            @Id int Out  
        )
        AS
        BEGIN
             INSERT INTO Student4 VALUES (@Name,@Email,@Mobile)
             SELECT @Id = SCOPE_IDENTITY()  
        END
        GO
         */
        public override void process()
        {
            withoutDataset_withoutParam();
            withoutDataset_withInputParam();
            withoutDataset_withInputOutParam();
            // withDataset_withoutParam();
            // withDataset_withParam();
        }

        private void withoutDataset_withoutParam()
        {
            try
            {
                Console.WriteLine("No parameter -------------");
                //! 이미 앞에서 작성한 spGetStudents 를 이용하기로 한다.
                                
                //Create the SqlConnection object
                using (SqlConnection connection = new SqlConnection(ConnectionStringStudent))
                {
                    SqlCommand cmd = new SqlCommand("spGetStudents", connection)
                    {
                        CommandType = CommandType.StoredProcedure
                    };

                    connection.Open();

                    SqlDataReader sdr = cmd.ExecuteReader();

                    while (sdr.Read())
                    {
                        Console.WriteLine(sdr["Id"] + ",  " + sdr["Name"] + ",  " + sdr["Email"] + ",  " + sdr["Mobile"]);
                    }
                    sdr.Close();
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Exception Occurred: {ex.Message}");
            }
        }

        private void withoutDataset_withInputParam()
        {
            try
            {
                Console.WriteLine("Input parameter -------------");
               
                using (SqlConnection connection = new SqlConnection(ConnectionStringStudent))
                {
                    
                    SqlCommand cmd = new SqlCommand()
                    {
                        CommandText = "spGetStudentById", //Specify the Stored procedure name
                        Connection = connection, //Specify the connection object where the stored procedure is going to execute
                        CommandType = CommandType.StoredProcedure //Specify the command type as Stored Procedure
                    };
                    
                    SqlParameter param1 = new SqlParameter
                    {
                        ParameterName = "@Id", //Parameter name defined in stored procedure
                        SqlDbType = SqlDbType.Int, //Data Type of Parameter
                        Value = 101, //Value passes to the paramtere
                        Direction = ParameterDirection.Input //Specify the parameter as input
                    };
                    
                    cmd.Parameters.Add(param1);
                    
                    connection.Open();
                    
                    SqlDataReader sdr = cmd.ExecuteReader();
                    
                    while (sdr.Read())
                    {                    
                        Console.WriteLine(sdr["Id"] + ",  " + sdr["Name"] + ",  " + sdr["Email"] + ",  " + sdr["Mobile"]);                        
                    }

                    sdr.Close();
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Exception Occurred: {ex.Message}");
            }
        }

        private void withoutDataset_withInputOutParam()
        {
            try
            {
                Console.WriteLine("Input parameter and output parameter -------------");
               
                using (SqlConnection connection = new SqlConnection(ConnectionStringStudent))
                {
                    SqlCommand cmd = new SqlCommand()
                    {
                        CommandText = "spCreateStudent",
                        Connection = connection,
                        CommandType = CommandType.StoredProcedure
                    };
                    
                    SqlParameter param1 = new SqlParameter
                    {
                        ParameterName = "@Name", //Parameter name defined in stored procedure
                        SqlDbType = SqlDbType.NVarChar, //Data Type of Parameter
                        Value = "Test", //Set the value
                        Direction = ParameterDirection.Input //Specify the parameter as input
                    };
                    cmd.Parameters.Add(param1);

                    //! 다음과 같은 방법이 더 간단할 수 있다.
                    cmd.Parameters.AddWithValue("@Email", "Test@dotnettutorial.net");
                    cmd.Parameters.AddWithValue("@Mobile", "1234567890");
                    
                    //Set Output Parameter
                    SqlParameter outParameter = new SqlParameter
                    {
                        ParameterName = "@Id", 
                        SqlDbType = SqlDbType.Int, 
                        Direction = ParameterDirection.Output 
                        //! value 속성에 값을 넣을 수는 없다.
                    };
                    
                    cmd.Parameters.Add(outParameter);
                    connection.Open();
                    cmd.ExecuteNonQuery();
                    
                    Console.WriteLine("Newely Generated Student ID : " + outParameter.Value.ToString());
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Exception Occurred: {ex.Message}");
            }
        }
    }
}
