using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace csharp_adonet.basic
{
    public class _12_dataAdapter_storedProc : basicProcesses
    {
        /*
         prep

        CREATE PROCEDURE spGetStudents
        AS
        BEGIN
         SELECT Id, Name, Email, Mobile 
         FROM Student3
        END
         */
        public override void process()
        {           
            try
            {
                using (SqlConnection connection = new SqlConnection(ConnectionStringStudent))
                {

                    SqlDataAdapter da = new SqlDataAdapter("spGetStudents", connection);
                    da.SelectCommand.CommandType = CommandType.StoredProcedure; // 반드시 CommandType 을 CommandType.StoredProcedure 로 지정해야 한다.

                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    foreach (DataRow row in dt.Rows)
                    {
                        Console.WriteLine(row["Name"] + ",  " + row["Email"] + ",  " + row["Mobile"]);
                    }
                }    
            }
            catch (Exception e)
            {
                Console.WriteLine("OOPs, something went wrong.\n" + e.Message);
            }
        }
    }
}
