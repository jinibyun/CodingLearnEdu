using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace csharp_adonet.basic
{
    public class _19_transaction : basicProcesses
    {
        /*
         Prep

        CREATE DATABASE BankDB;
        GO

        USE BankDB;
        GO

        CREATE TABLE Accounts
        (
             AccountNumber VARCHAR(60) PRIMARY KEY,
             CustomerName VARCHAR(60),
             Balance int
        );
        GO

        INSERT INTO Accounts VALUES('Account1', 'James', 1000);
        INSERT INTO Accounts VALUES('Account2', 'Smith', 1000);
        GO
         */
        public override void process()
        {
            try
            {
                Console.WriteLine("----- Before Transaction -----");
                
                //! 변경 전 데이타 확인
                GetAccountsData();
                //! transaction
                MoneyTransfer();
                
                Console.WriteLine("----- After Transaction -----");
                //! 변경 후 데이타 확인
                GetAccountsData();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Exception Occurred: {ex.Message}");
            }
        }

        private void MoneyTransfer()
        {           
            //Creating the connection object
            using (SqlConnection connection = new SqlConnection(ConnectionStringBank))
            {
                connection.Open();
                
                //! Transaction 시작
                SqlTransaction transaction = connection.BeginTransaction();
                try
                {       
                    //! transaction 과 연결
                    SqlCommand cmd = new SqlCommand("UPDATE Accounts SET Balance = Balance - 500 WHERE AccountNumber = 'Account1'", connection, transaction);                    
                    cmd.ExecuteNonQuery();

                    //! transaction 과 연결
                    cmd = new SqlCommand("UPDATE Accounts SET Balance = Balance + 500 WHERE AccountNumber = 'Account2'", connection, transaction);                    
                    cmd.ExecuteNonQuery();
                    
                    //! transaction 실행
                    transaction.Commit();
                    Console.WriteLine("Transaction Committed");
                }
                catch (Exception ex) { 
                    transaction.Rollback();
                    Console.WriteLine("Transaction Rollback");
                }
            }
        }
        private void GetAccountsData()
        {            
            //Create the connection object
            using (SqlConnection connection = new SqlConnection(ConnectionStringBank))
            {
                connection.Open();
                SqlCommand cmd = new SqlCommand("Select * from Accounts", connection);
                SqlDataReader sdr = cmd.ExecuteReader();
                while (sdr.Read())
                {
                    Console.WriteLine(sdr["AccountNumber"] + ",  " + sdr["CustomerName"] + ",  " + sdr["Balance"]);
                }
            }
        }
    }
}
