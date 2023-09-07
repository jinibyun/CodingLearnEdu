using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace csharp_adonet.basic
{
    public class _03_retrieveRecord : basicProcesses
    {
        public override void process()
        {
            SqlConnection con = null;
            try
            {
                // Creating Connection  
                con = new SqlConnection(ConnectionStringStudent);

                // writing sql query  
                SqlCommand cm = new SqlCommand("Select * from student", con);

                // Opening Connection  
                con.Open();

                // Executing the SQL query  
                SqlDataReader sdr = cm.ExecuteReader();

                // Iterating Data  
                while (sdr.Read())
                {
                    // Displaying Record  
                    //TODO: Type 화 된 class 구조롤 만들 수 있다.
                    Console.WriteLine(sdr["id"] + " " + sdr["name"] + " " + sdr["email"]);
                }
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
