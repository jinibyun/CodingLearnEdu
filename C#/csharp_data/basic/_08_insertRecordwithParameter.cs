using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace csharp_adonet.basic
{
    public class _08_insertRecordwithParameter : basicProcesses
    {
        public override void process()
        {
            SqlConnection con = null;
            try
            {
                // Creating Connection  
                con = new SqlConnection(ConnectionStringStudent);

                // writing sql query  
                //! Sql inject 에 노출 되어 있어서 SqlParameter object 를 사용한다. (앞서 _02_insertRecord 에서 작업한 것을 수정)
                SqlCommand cm = new SqlCommand("insert into student (id, name, email, join_date) values (@id, @name, @email, @join_date)", con);
                
                cm.Parameters.Add("@id", SqlDbType.Int).Value = 101;
                //SqlParameter param1 = cm.Parameters.Add(new SqlParameter("@id", SqlDbType.Int));
                //param1.Value = id;
                cm.Parameters.Add("@name", SqlDbType.VarChar).Value = "name";
                cm.Parameters.Add("@email", SqlDbType.VarChar).Value = "email@email.com";
                cm.Parameters.Add("@join_date", SqlDbType.Date).Value = "2023-12-31";

                // Opening Connection  
                con.Open();

                // Executing the SQL query  
                cm.ExecuteNonQuery();

                // Displaying a message  
                Console.WriteLine("Record Inserted Successfully");

                //? ref: https://learn.microsoft.com/en-us/dotnet/api/system.data.sqlclient.sqlcommand?view=dotnet-plat-ext-7.0
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
