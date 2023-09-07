using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace csharp_adonet.basic
{
    public class _05_connectionStringAppSettings : basicProcesses
    {
        public override void process()
        {
            try
            {
                //! install package: System.Configuration.ConfigurationManager 
                //! namespace "System.Configuration" 필요
                //! App.config 생성해서 DB 연결문자열을 저장한다.
                // string ConString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

                //! 별도로 using block 을 사용한 이유 - 역할과 용도
                using (SqlConnection connection = new SqlConnection(ConnectionStringStudent))
                {
                    connection.Open();
                    Console.WriteLine("Connection Established Successfully");
                }

                //! 추가로 Connection Object 의 Property 와 Method 확인
                //? ref: https://learn.microsoft.com/en-us/dotnet/api/system.data.sqlclient.sqlconnection?view=dotnet-plat-ext-7.0

                // 별도로 connection string 에 대해서는 다음의 사이트를 참고할 수 있다.
                //? ref: connectionstrings.com
            }
            catch (Exception e)
            {
                Console.WriteLine("OOPs, something went wrong.\n" + e);
            }
        }
    }
}
