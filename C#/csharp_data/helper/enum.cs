using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace csharp_adonet.helper
{
    public enum menuEnum
    {
        // ado.net
        quit = -1,
        createTable = 1,
        insertRecord,
        retrieveRecord,
        deleteRecord,
        connectionString,
        insertRecordwithParameter,
        executeScalar,
        dataReader,
        dataAdapter,
        dataAdapterWithStoredProc,
        dataTable,
        dataTableWithDataSet,
        sqlWithDataSet,
        storedProcedure,
        storedProcedureDataSet,
        dataView,
        transaction,
        bulkInsertUpdate,
        bulkInsertWithBCP,
        xmlHandling,
        // linq
        queryOrMethod,
        linqOperator
    }
}
