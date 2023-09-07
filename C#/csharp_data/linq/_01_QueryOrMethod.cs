using csharp_adonet.basic;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace csharp_adonet.linq
{
    public class _01_QueryOrMethod : basicProcesses
    {
        public override void process()
        {
            Console.WriteLine("Linq query");
            var QuerySyntax = getData();
            foreach (var item in QuerySyntax)
            {
                Console.Write(item + " ");
            }

            Console.WriteLine();
            Console.WriteLine("Linq method");

            var QuerySyntax2 = getData2();
            foreach (var item in QuerySyntax2)
            {
                Console.Write(item + " ");
            }

            Console.WriteLine();
        }

        private IEnumerable<int> getData()
        {
            //! all the collection classes (both generic and non-generic) implement the IEnumerable interface
            //! IEnumerable has a GetEnumerator() method under the hood
            //Step1: Data Source
            List<int> integerList = new List<int>()
            {
                1, 2, 3, 4, 5, 6, 7, 8, 9, 10
            };
            //Step2: Query
            //LINQ Query using Query Syntax to fetch all numbers which are > 5
            var QuerySyntax = from obj in integerList //Data Source
                              where obj > 5 //Condition
                              select obj; //Selection

            return QuerySyntax;            
        }

        private IEnumerable<int> getData2()
        {            
            List<int> integerList = new List<int>()
            {
                1, 2, 3, 4, 5, 6, 7, 8, 9, 10
            };
            
            var QuerySyntax = integerList.Where(obj => obj > 5).ToList();
            return QuerySyntax;
        }
    }
}
