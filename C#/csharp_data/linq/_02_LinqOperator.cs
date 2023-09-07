using csharp_adonet.basic;
using csharp_adonet.dataclass;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace csharp_adonet.linq
{
    public class _02_LinqOperator : basicProcesses
    {
        public override void process()
        {
            select();
            selectMany();

        }


        private void select()
        {
            Console.WriteLine("----select ----");
            List<Employee> selectMethod = Employee.GetEmployees().
                                          Select(emp => new Employee()
                                          {
                                              FirstName = emp.FirstName,
                                              LastName = emp.LastName,
                                              Salary = emp.Salary
                                          }).ToList();

            foreach (var emp in selectMethod)
            {
                Console.WriteLine($" Name : {emp.FirstName} {emp.LastName} Salary : {emp.Salary} ");
            }
            Console.WriteLine();
        }

        private void selectMany()
        {
            Console.WriteLine("----selectMany using query ----");
            List<string> nameList = new List<string>() { "Jini", "Byun" };

            IEnumerable<char> querySyntax = from str in nameList
                                            from ch in str
                                            select ch;
            foreach (char c in querySyntax)
            {
                Console.Write(c + " ");
            }

            Console.WriteLine("----selectMany using method ----");
            IEnumerable<char> methodSyntax = nameList.SelectMany(x => x);
            foreach (char c in methodSyntax)
            {
                Console.Write(c + " ");
            }

            Console.WriteLine();

            Console.WriteLine("----selectMany using query another ex ----");
            IEnumerable<string> querySyntax2 = from std in Student.GetStudents()
                                               from program in std.Programming
                                               select program;
            
            foreach (string program in querySyntax2)
            {
                Console.WriteLine(program);
            }

            Console.WriteLine();
        }
    }
}
