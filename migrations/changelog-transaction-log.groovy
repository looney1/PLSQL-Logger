databaseChangeLog {

//  changeSet (author: "jdoe", id: "script.sql", runOnChange: true, runAlways: true) {
//    sqlFile ("path": "preops/script.sql", "endDelimiter": "\n/\\s*\n|\n/\\s*\$", "stripComments": true)
//  }
  changeSet (author: "jlooney", id: "ddl/transaction_log_ddl.sql", runOnChange: false) {
    sqlFile ("path": "ddl/transaction_log_ddl.sql", "endDelimiter": "\n/\\s*\n|\n/\\s*\$")
  }    
}

