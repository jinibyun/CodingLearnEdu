using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace csharp_adonet.basic
{
    public class _17_storedProcedure_dataset : basicProcesses
    {
        /*
         prep

        USE Student
        GO

        CREATE TABLE Employee(
         Id INT IDENTITY(1000,1) PRIMARY KEY,
         Name VARCHAR(100),
         Email VARCHAR(50),
         Mobile VARCHAR(50),
         Age INT,
         Department VARCHAR(50)
        )
        GO

        INSERT INTO Employee VALUES ('Anurag','Anurag@dotnettutorial.net','1234567890', 25, 'IT')
        INSERT INTO Employee VALUES ('Priyanka','Priyanka@dotnettutorial.net','2233445566', 35, 'IT')
        INSERT INTO Employee VALUES ('Preety','Preety@dotnettutorial.net','6655443322', 35, 'IT')
        INSERT INTO Employee VALUES ('Sambit','Sambit@dotnettutorial.net','9876543210', 25, 'IT')
        INSERT INTO Employee VALUES ('Pranaya','Pranaya@dotnettutorial.net','1234567890', 25, 'HR')
        INSERT INTO Employee VALUES ('Pratik','Pratik@dotnettutorial.net','2233445566', 35, 'HR')
        INSERT INTO Employee VALUES ('Santosh','Santosh@dotnettutorial.net','6655443322', 32, 'HR')
        INSERT INTO Employee VALUES ('Rakesh','Rakesh@dotnettutorial.net','9876543210', 27, 'HR')
        GO
         
        CREATE PROCEDURE spGetEmployeesByAgeDept
        (
           @Age INT,
           @Dept VARCHAR(50)
        )
        AS
        BEGIN
             SELECT Id, Name, Email, Mobile, Age, Department
             FROM Employee
             WHERE Age = @Age AND Department = @Dept
        END
        GO

        CREATE PROCEDURE spGetEmployees
        AS
        BEGIN
             SELECT Id, Name, Email, Mobile, Age, Department
             FROM Employee
        END
        GO
         */
        public override void process()
        {
            withoutDataset_withInputParam();
            helperMethodTakeinParameter();
        }

        private void withoutDataset_withInputParam()
        {
            try
            {
                Console.WriteLine("Input parameter -------------");
                
                //Creating the connection object using the ConnectionString
                using (SqlConnection connection = new SqlConnection(ConnectionStringStudent))
                {
                    DataSet ds = new DataSet();
                    
                    SqlCommand sqlCmd = new SqlCommand
                    {
                        CommandText = "spGetEmployeesByAgeDept", 
                        CommandType = CommandType.StoredProcedure, 
                        Connection = connection 
                    };
                    
                    SqlParameter paramAge = new SqlParameter
                    {
                        ParameterName = "@Age", 
                        SqlDbType = SqlDbType.Int, 
                        Value = 25, 
                        Direction = ParameterDirection.Input 
                    };
                    
                    sqlCmd.Parameters.Add(paramAge);
                    sqlCmd.Parameters.AddWithValue("@Dept", "IT");
                    
                    SqlDataAdapter da = new SqlDataAdapter
                    {
                        SelectCommand = sqlCmd
                    };
                    
                    da.Fill(ds);
                    foreach (DataRow row in ds.Tables[0].Rows)
                    {
                        Console.WriteLine(row["Id"] + ",  " + row["Name"] + ",  " + row["Email"] + ",  " + row["Mobile"] + ",  " + row["Age"] + ",  " + row["Age"]);
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Exception Occurred: {ex.Message}");
            }
        }

        private void helperMethodTakeinParameter()
        {
            try
            {
                Console.WriteLine("helperMethodTakeinParameter -------------");
                
                SqlParameter[] paramterList = new SqlParameter[]
                {
                    new SqlParameter("@Age", 25),
                    new SqlParameter("@Dept", "IT")
                };

                //! 아래에 정의한 "ExecuteStoredProcedureReturnDataSet" method 는 별도로 재 사용을 위해서 helper class 에 정의한다고 가정한다.
                DataSet dataSet1 = ExecuteStoredProcedureReturnDataSet(ConnectionStringStudent, "spGetEmployeesByAgeDept", paramterList);
                Console.WriteLine("spGetEmployeesByAgeDept Result:");
                foreach (DataRow row in dataSet1.Tables[0].Rows)
                {
                    Console.WriteLine(row["Id"] + ",  " + row["Name"] + ",  " + row["Email"] + ",  " + row["Mobile"] + ",  " + row["Age"] + ",  " + row["Age"]);
                }
               
                DataSet dataSet2 = ExecuteStoredProcedureReturnDataSet(ConnectionStringStudent, "spGetEmployees");
                Console.WriteLine("\nspGetEmployees Result:");
                foreach (DataRow row in dataSet2.Tables[0].Rows)
                {
                    Console.WriteLine(row["Id"] + ",  " + row["Name"] + ",  " + row["Email"] + ",  " + row["Mobile"] + ",  " + row["Age"] + ",  " + row["Age"]);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Exception Occurred: {ex.Message}");
            }
        }

        public static DataSet ExecuteStoredProcedureReturnDataSet(string connectionString, string procedureName, params SqlParameter[] paramterList)
        {            
            DataSet dataSet = new DataSet();

            using (var sqlConnection = new SqlConnection(connectionString))
            {
                //Create the command object
                using (var command = sqlConnection.CreateCommand())
                {
                    //Create the SqlDataAdapter object by passing command object as a parameter to the constructor
                    using (SqlDataAdapter sda = new SqlDataAdapter(command))
                    {
                        command.CommandType = CommandType.StoredProcedure;
                        command.CommandText = procedureName;
                        if (paramterList != null)
                        {
                            command.Parameters.AddRange(paramterList);
                        }
                        sda.Fill(dataSet);
                    }
                }
            }
            return dataSet;
        }
    }
}
