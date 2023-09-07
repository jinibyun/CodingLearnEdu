using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace csharp_adonet.basic
{
    public class _22_xmlHandling : basicProcesses
    {
        /*
         Prep

        USE Student
        GO

        CREATE TABLE DepartmentsXML
        (
             ID INT PRIMARY KEY,
             Name VARCHAR(50),
             Location VARCHAR(50)
        )
        GO

        CREATE TABLE EmployeesXML
        (
             ID INT PRIMARY KEY,
             Name VARCHAR(50),
             Gender VARCHAR(50),
             DepartmentId INT FOREIGN KEY REFERENCES DepartmentsXML(Id)
        )
        GO

        반드시 c:\temp\ 밑에 example.xml 를 미리 준비해둔다.

         */
        public override void process()
        {
            try
            {
                using (SqlConnection connection = new SqlConnection(ConnectionStringStudent))
                {                 
                    DataSet dataSet = new DataSet();
                 
                    string XMLFilePath = @"C:\Temp\example.xml";
                    dataSet.ReadXml(XMLFilePath);
                    
                    DataTable DepartmentsDataTable = dataSet.Tables["Department"];
                    DataTable EmployeesDataTable = dataSet.Tables["Employee"];

                    Console.WriteLine("====before database connection =====");
                    Console.WriteLine("Departments List:");
                    foreach (DataRow row in DepartmentsDataTable.Rows)
                    {
                        Console.WriteLine($"ID: {row["ID"]}, Name: {row["Name"]}, Location: {row["Location"]}");
                    }
                    
                    Console.WriteLine("\nEmployees List:");
                    foreach (DataRow row in EmployeesDataTable.Rows)
                    {
                        Console.WriteLine($"ID: {row["ID"]}, Name: {row["Name"]}, Gender: {row["Gender"]},  DepartmentId: {row["DepartmentId"]}");
                    }
                    Console.WriteLine("====after database connection =====");
                    connection.Open();
                    
                    using (SqlBulkCopy sqlBulkCopy = new SqlBulkCopy(connection))
                    {                        
                        sqlBulkCopy.DestinationTableName = "DepartmentsXML";
                        
                        sqlBulkCopy.ColumnMappings.Add("ID", "ID");
                        sqlBulkCopy.ColumnMappings.Add("Name", "Name");
                        sqlBulkCopy.ColumnMappings.Add("Location", "Location");
                        
                        sqlBulkCopy.WriteToServer(DepartmentsDataTable);
                    }
                    
                    using (SqlBulkCopy sqlBulkCopy = new SqlBulkCopy(connection))
                    {                        
                        sqlBulkCopy.DestinationTableName = "EmployeesXML";
                        
                        sqlBulkCopy.ColumnMappings.Add("ID", "ID");
                        sqlBulkCopy.ColumnMappings.Add("Name", "Name");
                        sqlBulkCopy.ColumnMappings.Add("Gender", "Gender");
                        sqlBulkCopy.ColumnMappings.Add("DepartmentId", "DepartmentId");
                        
                        sqlBulkCopy.WriteToServer(EmployeesDataTable);
                    }
                    Console.WriteLine($"Successfully inserted");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Exception Occurred: {ex.Message}");
            }
        }
    }
}
