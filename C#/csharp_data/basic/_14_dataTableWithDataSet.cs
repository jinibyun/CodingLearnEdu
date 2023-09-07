using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace csharp_adonet.basic
{
    public class _14_dataTableWithDataSet : basicProcesses
    {
        public override void process()
        {
            try
            {
                DataTable Customer = new DataTable("Customer");
                
                DataColumn CustomerId = new DataColumn("ID", typeof(Int32));
                Customer.Columns.Add(CustomerId);
                DataColumn CustomerName = new DataColumn("Name", typeof(string));
                Customer.Columns.Add(CustomerName);
                DataColumn CustomerMobile = new DataColumn("Mobile", typeof(string));
                Customer.Columns.Add(CustomerMobile);
                
                Customer.Rows.Add(101, "Anurag", "2233445566");
                Customer.Rows.Add(202, "Manoj", "1234567890");
                
                DataTable Orders = new DataTable("Orders");
                
                DataColumn OrderId = new DataColumn("ID", typeof(System.Int32));
                Orders.Columns.Add(OrderId);
                DataColumn CustId = new DataColumn("CustomerId", typeof(Int32));
                Orders.Columns.Add(CustId);
                DataColumn OrderAmount = new DataColumn("Amount", typeof(int));
                Orders.Columns.Add(OrderAmount);
                
                Orders.Rows.Add(10001, 101, 20000);
                Orders.Rows.Add(10002, 102, 30000);
               
                DataSet dataSet = new DataSet();

                // 생성했던 DataTable 들을 memory 상의 DB 인 DataSet 에 추가
                dataSet.Tables.Add(Customer);
                dataSet.Tables.Add(Orders);
                
                Console.WriteLine("Customer Table Data: ");

                //Fetching DataTable
                foreach (DataRow row in dataSet.Tables[0].Rows) { 
                    Console.WriteLine(row["ID"] + ",  " + row["Name"] + ",  " + row["Mobile"]);
                }
                Console.WriteLine();

                //Fetching Orders Data Table Data
                Console.WriteLine("Orders Table Data: ");
                //Fetching DataTable from the DataSet using the table name
                foreach (DataRow row in dataSet.Tables["Orders"].Rows)
                {
                    Console.WriteLine(row["ID"] + ",  " + row["CustomerId"] + ",  " + row["Amount"]);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Exception Occurred: {ex.Message}");
            }
        }
    }
}
