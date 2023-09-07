using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace csharp_adonet.helper
{
    public class util
    {
        public static string? AskQuestion(string question)
        {
            System.Console.Write(question);
            return System.Console.ReadLine();
        }

        public static int AskQuestionInt(string question)
        {
            Console.ForegroundColor = ConsoleColor.Green;
            Console.WriteLine(question);
            Console.ForegroundColor = ConsoleColor.White;

            Console.Write("\nPlease enter the menu number:");
            

            bool state = int.TryParse(System.Console.ReadLine(), out int result);
            while (!state)
            {
                System.Console.Write("\n only menu number is allowed\n");
                state = int.TryParse(System.Console.ReadLine(), out result);
            }

            return result;
        }
    }
}
