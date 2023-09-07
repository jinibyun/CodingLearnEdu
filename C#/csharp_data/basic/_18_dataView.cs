using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace csharp_adonet.basic
{
    public class _18_dataView : basicProcesses
    {
        public override void process()
        {           
            try
            {
                //! DataViwe 를 이용함으로 해서 특별히 sorting 과 filtering 에 장점을 갖는다.                
                using (SqlConnection connection = new SqlConnection(ConnectionStringStudent))
                {
                    SqlDataAdapter dataAdapter = new SqlDataAdapter("SELECT Id, Name, Email, Mobile, Age, Department FROM EMPLOYEE", connection);
                    
                    DataTable EmployeeDataTable = new DataTable();

                    dataAdapter.Fill(EmployeeDataTable);
 
                    DataView dataView1 = EmployeeDataTable.DefaultView;

                    dataView1.RowFilter = "Age > 25";
                    Console.WriteLine($"DataView with Filter: {dataView1.RowFilter}");
                    foreach (DataRowView rowView in dataView1)
                    {
                        DataRow row = rowView.Row;
                        Console.WriteLine($"Id: {row["Id"]}, Age: {row["Age"]}, Department: {row["Department"]}");
                    }

                    //Creating DataView instance using DataView constructor
                    DataView dataView2 = new DataView(EmployeeDataTable);

                    //Applying Multiple Filter
                    dataView2.RowFilter = "Age > 25 AND Department = 'HR'";
                    Console.WriteLine($"\nDataView with Filter: {dataView2.RowFilter}");
                    foreach (DataRowView rowView in dataView2)
                    {
                        DataRow row = rowView.Row;
                        Console.WriteLine($"Id: {row["Id"]}, Name: {row["Name"]}, Age: {row["Age"]}, Department: {row["Department"]}");
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
