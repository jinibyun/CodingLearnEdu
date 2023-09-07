using csharp_adonet.basic;
using csharp_adonet.helper;
using csharp_adonet.linq;

System.Console.ForegroundColor = ConsoleColor.Yellow;
Console.WriteLine("----- Database Programming with C# START -----\n");
System.Console.ForegroundColor = ConsoleColor.White;

Console.WriteLine("Type -1 for quit\n");


basicProcesses program = null;
bool flag = true;
while (flag)
{
    menuEnum choice = acceptChoices();
    switch (choice)
    {
        // ----------------- ado.net -----------------
        case menuEnum.createTable:
            program = new _01_createTable();
            break;
        case menuEnum.insertRecord:
            program = new _02_insertRecord();
            break;
        case menuEnum.retrieveRecord:
            program = new _03_retrieveRecord();
            break;
        case menuEnum.deleteRecord:
            program = new _04_deletetRecord();
            break;
        case menuEnum.connectionString:
            program = new _05_connectionStringAppSettings();
            break;
        case menuEnum.insertRecordwithParameter:
            program = new _08_insertRecordwithParameter();
            break;
        case menuEnum.executeScalar:
            program = new _09_executeScalar();
            break;
        case menuEnum.dataReader:
            program = new _10_dataReader();
            break;
        case menuEnum.dataAdapter:
            program = new _11_dataAdapter();
            break;
        case menuEnum.dataAdapterWithStoredProc:
            program = new _12_dataAdapter_storedProc();
            break;
        case menuEnum.dataTable:
            program = new _13_dataTable();
            break;
        case menuEnum.dataTableWithDataSet:
            program = new _14_dataTableWithDataSet();
            break;
        case menuEnum.sqlWithDataSet:
            program = new _15_sqlWithDataSet();
            break;
        case menuEnum.storedProcedure:
            program = new _16_storedProcedure();
            break;
        case menuEnum.storedProcedureDataSet:
            program = new _17_storedProcedure_dataset();
            break;
        case menuEnum.dataView:
            program = new _18_dataView();
            break;
        case menuEnum.transaction:
            program = new _19_transaction();
            break;
        case menuEnum.bulkInsertUpdate:
            program = new _20_bulkInsertUpdate();
            break;
        case menuEnum.bulkInsertWithBCP:
            program = new _21_bulkInsertWithBCP();
            break;
        case menuEnum.xmlHandling:
            program = new _22_xmlHandling();
            break;
        // ----------------- linq -----------------
        case menuEnum.queryOrMethod:
            program = new _01_QueryOrMethod();
            break;
        case menuEnum.linqOperator:
            program = new _02_LinqOperator();
            break;
        case menuEnum.quit:
            flag = false;
            break;
        default:
            Console.WriteLine("\nInvalid input. Please try again \n");
            break;
    }

    if (program != null)
    {
        Console.WriteLine("======Result Start======");
        Console.ForegroundColor = ConsoleColor.Cyan;
        program.process();
        Console.ForegroundColor = ConsoleColor.White;
        Console.WriteLine("======Result End======\n");
    }
}

Console.WriteLine("\n----- Database Programming with C# END  -----");


menuEnum acceptChoices()
{
    var dict = Enum.GetValues(typeof(menuEnum))
               .Cast<menuEnum>()
               .ToDictionary(t => (int)t, t => t.ToString());

    var msgs = dict.Select(x =>
    {
        return $"{x.Key}. {x.Value}";
    });
    
    var result = string.Join("\n", msgs.ToArray());


    return (menuEnum)util.AskQuestionInt(result);
}


