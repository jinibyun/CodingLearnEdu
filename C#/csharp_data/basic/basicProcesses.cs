using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace csharp_adonet.basic
{
    public abstract class basicProcesses
    {
        protected string ConnectionStringStudent = ConfigurationManager.ConnectionStrings["ConnectionStringStudent"].ConnectionString;
        protected string ConnectionStringShoppingCart = ConfigurationManager.ConnectionStrings["ConnectionStringShoppingCart"].ConnectionString;
        protected string ConnectionStringBank = ConfigurationManager.ConnectionStrings["ConnectionStringBankDB"].ConnectionString;
        public abstract void process();
    }
}
