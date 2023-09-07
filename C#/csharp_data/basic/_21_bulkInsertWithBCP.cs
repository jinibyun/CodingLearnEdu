using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace csharp_adonet.basic
{
    public class _21_bulkInsertWithBCP : basicProcesses
    {
        /*
         Prep

         USE STUDENT
         GO

         CREATE TABLE [dbo].[Censis](
          [Suburb] [varchar](200) NULL,
          [NotStated] [int] NULL,
          [NotApplicable] [int] NULL,
          [Fishing] [int] NULL,
          [Mining] [int] NULL,
          [Manufacturing] [int] NULL,
          [Electricity] [int] NULL,
          [Construction] [int] NULL
        )
        GO

        반드시 c:\temp\ 밑에 table1.csv 를 미리 준비해둔다.

         */
        public override void process()
        {
            try
            {
                // 1. read csv into datatable
                DataTable dt = new DataTable();
                string line = null;
                int i = 0;

                using (StreamReader sr = File.OpenText(@"c:\temp\table1.csv"))
                {
                    while ((line = sr.ReadLine()) != null)
                    {
                        string[] data = line.Split(',');
                        if (data.Length > 0)
                        {
                            if (i == 0)
                            {
                                foreach (var item in data)
                                {
                                    dt.Columns.Add(new DataColumn());
                                }
                                i++;
                            }
                            DataRow row = dt.NewRow();
                            row.ItemArray = data;
                            dt.Rows.Add(row);
                        }
                    }
                }


                // 2. datatable into sql table
                using (var connection = new SqlConnection(ConnectionStringStudent))
                {
                    connection.Open();
                    using (SqlBulkCopy copy = new SqlBulkCopy(connection))
                    {
                        copy.ColumnMappings.Add(0, 0);
                        copy.ColumnMappings.Add(1, 1);
                        copy.ColumnMappings.Add(2, 2);
                        copy.ColumnMappings.Add(3, 3);
                        copy.ColumnMappings.Add(4, 4);
                        copy.DestinationTableName = "Censis";

                        try
                        {
                            copy.WriteToServer(dt);
                            Console.WriteLine("Successful");
                        }
                        catch (Exception ex)
                        {
                            Console.WriteLine(ex.Message);
                        }

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
