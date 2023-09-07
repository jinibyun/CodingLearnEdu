using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace csharp_adonet.basic
{
    public class _15_sqlWithDataSet : basicProcesses
    {
        /*
         prep

        CREATE DATABASE ShoppingCartDB;
        GO

        USE ShoppingCartDB;
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

        CREATE TABLE Orders(
         ID INT PRIMARY KEY,
         CustomerId INT,
         Amount INT
        )
        GO

        INSERT INTO Orders VALUES (10011, 103, 20000)
        INSERT INTO Orders VALUES (10012, 101, 30000)
        INSERT INTO Orders VALUES (10013, 102, 25000)
        GO
         */
        public override void process()
        {
            singleTable();
            multipleTable();
            copyCloneTable();
        }

        private void singleTable()
        {
            try
            {
                Console.WriteLine("Single Table -------------");               
                using (SqlConnection connection = new SqlConnection(ConnectionStringShoppingCart))
                {
                    SqlDataAdapter dataAdapter = new SqlDataAdapter("select * from customers", connection);
                    
                    DataSet dataSet = new DataSet();
                    
                    dataAdapter.Fill(dataSet);
                    
                    foreach (DataRow row in dataSet.Tables[0].Rows)
                    {
                        Console.WriteLine(row["Id"] + ",  " + row["Name"] + ",  " + row["Mobile"]);
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Exception Occurred: {ex.Message}");
            }
        }

        private void multipleTable()
        {
            try
            {
                Console.WriteLine("Multiple Table -------------");                
                using (SqlConnection connection = new SqlConnection(ConnectionStringShoppingCart))
                {
                    SqlDataAdapter dataAdapter = new SqlDataAdapter("select * from customers; select * from orders", connection);
                    DataSet dataSet = new DataSet();
                    
                    dataAdapter.Fill(dataSet);
                    
                    Console.WriteLine("Table 1 Data");
                    
                    foreach (DataRow row in dataSet.Tables[0].Rows)
                    {
                        Console.WriteLine(row["Id"] + ",  " + row["Name"] + ",  " + row["Mobile"]);
                    }
                    Console.WriteLine();
                    
                    Console.WriteLine("Table 2 Data");
                    
                    foreach (DataRow row in dataSet.Tables[1].Rows)
                    {
                        Console.WriteLine(row[0] + ",  " + row[1] + ",  " + row[2]);
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Exception Occurred: {ex.Message}");
            }
        }

        private void copyCloneTable()
        {
            try
            {
                Console.WriteLine("Copy and Clone Table -------------");

                using (SqlConnection connection = new SqlConnection(ConnectionStringStudent))
                {
                    SqlDataAdapter da = new SqlDataAdapter("select * from student3", connection);
                    DataSet originalDataSet = new DataSet();
                    da.Fill(originalDataSet);
                    Console.WriteLine("Original Data Set:");
                    foreach (DataRow row in originalDataSet.Tables[0].Rows)
                    {
                        Console.WriteLine(row["Name"] + ",  " + row["Email"] + ",  " + row["Mobile"]);
                    }
                    Console.WriteLine();
                    Console.WriteLine("Copy Data Set:");
                    
                    DataSet copyDataSet = originalDataSet.Copy();
                    if (copyDataSet.Tables != null)
                    {
                        foreach (DataRow row in copyDataSet.Tables[0].Rows)
                        {
                            Console.WriteLine(row["Name"] + ",  " + row["Email"] + ",  " + row["Mobile"]);
                        }
                    }
                    Console.WriteLine();
                    Console.WriteLine("Clone Data Set");
                    

                    DataSet cloneDataSet = originalDataSet.Clone();
                    if (cloneDataSet.Tables[0].Rows.Count > 0)
                    {
                        foreach (DataRow row in cloneDataSet.Tables[0].Rows)
                        {
                            Console.WriteLine(row["Name"] + ",  " + row["Email"] + ",  " + row["Mobile"]);
                        }
                    }
                    else
                    {
                        Console.WriteLine("Clone Data Set is Empty");
                        Console.WriteLine("Adding Data to Clone Data Set Table");
                        cloneDataSet.Tables[0].Rows.Add(101, "Test1", "Test1@dotnettutorial.net", "1234567890");
                        cloneDataSet.Tables[0].Rows.Add(101, "Test2", "Test1@dotnettutorial.net", "1234567890");
                        foreach (DataRow row in cloneDataSet.Tables[0].Rows)
                        {
                            Console.WriteLine(row["Name"] + ",  " + row["Email"] + ",  " + row["Mobile"]);
                        }
                    }
                    Console.WriteLine();
                    
                    copyDataSet.Clear();
                    if (copyDataSet.Tables[0].Rows.Count > 0)
                    {
                        foreach (DataRow row in copyDataSet.Tables[0].Rows)
                        {
                            Console.WriteLine(row["Name"] + ",  " + row["Email"] + ",  " + row["Mobile"]);
                        }
                    }
                    else
                    {
                        Console.WriteLine("After Clear No Data is Their...");
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Exception Occurred: {ex.Message}");
            }

        }
    }
}
