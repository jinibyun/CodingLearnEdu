using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace csharp_adonet.basic
{
    public class _09_executeScalar : basicProcesses
    {
        public override void process()
        {
            try
            {
                using (SqlConnection connection = new SqlConnection(ConnectionStringStudent))
                {
                    // Creating SqlCommand objcet 
                    SqlCommand cmd = new SqlCommand("select count(id) from student", connection);

                    // Opening Connection  
                    connection.Open();

                    // Executing the SQL query  
                    // Since the return type of ExecuteScalar() is object, we are type casting to int datatype
                    int TotalRows = (int)cmd.ExecuteScalar();

                    Console.WriteLine("TotalRows in Student Table :  " + TotalRows);
                }
            }
            catch (Exception e)
            {
                Console.WriteLine("OOPs, something went wrong." + e);
            }
        }
    }
}
