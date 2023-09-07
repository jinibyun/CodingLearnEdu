using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace csharp_adonet.basic
{
    public class _04_deletetRecord : basicProcesses
    {
        public override void process()
        {
            SqlConnection con = null;
            try
            {
                // Creating Connection  
                con = new SqlConnection(ConnectionStringStudent);
                // writing sql query  
                SqlCommand cm = new SqlCommand("delete from student where id = '101'", con);

                // Opening Connection  
                con.Open();

                // Executing the SQL query  
                cm.ExecuteNonQuery();

                Console.WriteLine("Record Deleted Successfully");
            }
            catch (Exception e)
            {
                Console.WriteLine("OOPs, something went wrong." + e);
            }
            // Closing the connection  
            finally
            {
                con.Close();
            }
        }
    }
}
