using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace csharp_adonet.basic
{
    public class _20_bulkInsertUpdate : basicProcesses
    {
        /*
         Prep

        Use Student
        GO

        CREATE TABLE Employee2(
         Id INT PRIMARY KEY,
         Name VARCHAR(100),
         Email VARCHAR(50),
         Mobile VARCHAR(50),
        )
        GO

        CREATE TYPE EmployeeType AS TABLE(
                Id INT NULL,
                Name VARCHAR(100) NULL,
                Email VARCHAR(50) NULL,
                Mobile VARCHAR(50) NULL
        )
        GO

        CREATE PROCEDURE SP_Bulk_Insert_Update_Employees
                @Employees EmployeeType READONLY
        AS
        BEGIN
                SET NOCOUNT ON;
 
                MERGE INTO Employee2 E1
                USING @Employees E2
                ON E1.Id=E2.Id
                WHEN MATCHED THEN
                UPDATE SET 
                    E1.Name = E2.Name,
                    E1.Email = E2.Email,
                    E1.Mobile = E2.Mobile
                WHEN NOT MATCHED THEN
                INSERT VALUES(E2.Id, E2.Name, E2.Email, E2.Mobile);
        END
        GO
         */
        public override void process()
        {
            try
            {
                //Creating Data Table in "memory"
                DataTable EmployeeDataTable = new DataTable("Employees");

                DataColumn Id = new DataColumn("Id");
                EmployeeDataTable.Columns.Add(Id);
                DataColumn Name = new DataColumn("Name");
                EmployeeDataTable.Columns.Add(Name);
                DataColumn Email = new DataColumn("Email");
                EmployeeDataTable.Columns.Add(Email);
                DataColumn Mobile = new DataColumn("Mobile");
                EmployeeDataTable.Columns.Add(Mobile);

                EmployeeDataTable.Rows.Add(101, "ABC", "ABC@dotnettutorials.net", "12345");
                EmployeeDataTable.Rows.Add(102, "PQR", "PQR@dotnettutorials.net", "11223");
                EmployeeDataTable.Rows.Add(103, "XYZ", "XYZ@dotnettutorials.net", "23432");
                EmployeeDataTable.Rows.Add(106, "A", "A@dotnettutorials.net", "12345");
                EmployeeDataTable.Rows.Add(107, "B", "B@dotnettutorials.net", "23456");
                EmployeeDataTable.Rows.Add(108, "C", "C@dotnettutorials.net", "34567");
                EmployeeDataTable.Rows.Add(109, "D", "D@dotnettutorials.net", "45678");
                EmployeeDataTable.Rows.Add(110, "E", "E@dotnettutorials.net", "56789");
                EmployeeDataTable.Rows.Add(111, "F", "F@dotnettutorials.net", "67890");

                // connection object
                using (SqlConnection connection = new SqlConnection(ConnectionStringStudent))
                {
                    using (SqlCommand cmd = new SqlCommand("SP_Bulk_Insert_Update_Employees", connection))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@Employees", EmployeeDataTable);

                        connection.Open();

                        cmd.ExecuteNonQuery();
                    }
                }
                Console.WriteLine("BULK INSERT UPDATE Successful");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Exception Occurred: {ex.Message}");
            }


        }
    }
}
