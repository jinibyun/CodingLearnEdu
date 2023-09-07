using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace csharp_adonet.dataclass
{
    public class Employee
    {
        public int ID { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public int Salary { get; set; }
        public static List<Employee> GetEmployees()
        {
            List<Employee> employees = new List<Employee>
            {
                new Employee {ID = 101, FirstName = "Jini", LastName = "Byun", Salary = 120000 },
                new Employee {ID = 102, FirstName = "Priyanka", LastName = "Dewangan", Salary = 70000 },
                new Employee {ID = 103, FirstName = "Jane", LastName = "Rose", Salary = 80000 },
                new Employee {ID = 104, FirstName = "James", LastName = "Harden", Salary = 90000 },
                new Employee {ID = 105, FirstName = "Yuri", LastName = "Satapathy", Salary = 100000 },
                new Employee {ID = 106, FirstName = "Mike", LastName = "James", Salary = 160000 }
            };
            return employees;
        }
    }
}
