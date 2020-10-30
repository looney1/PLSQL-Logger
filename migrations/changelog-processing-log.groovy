databaseChangeLog {

//  changeSet (author: "jdoe", id: "script.sql", runOnChange: true, runAlways: true) {
//    sqlFile ("path": "preops/script.sql", "endDelimiter": "\n/\\s*\n|\n/\\s*\$", "stripComments": true)
//  }
  changeSet (author: "jlooney", id: "ddl/processing_log_ddl.sql", runOnChange: false) {
    sqlFile ("path": "ddl/processing_log_ddl.sql", "endDelimiter": "\n/\\s*\n|\n/\\s*\$")
  }    
  changeSet (author: "jlooney", id: "package-specs/logger_pkg.pks", runOnChange: true) {
    sqlFile ("path": "package-specs/logger_pkg.pks", "endDelimiter": "\n/\\s*\n|\n/\\s*\$")
  }    
  changeSet (author: "jlooney", id: "package-bodies/logger_pkg.pkb", runOnChange: true) {
    sqlFile ("path": "package-bodies/logger_pkg.pkb", "endDelimiter": "\n/\\s*\n|\n/\\s*\$")
  }  
  changeSet (author: "jlooney", id: "views/processing_log_vw_ddl.sql", runOnChange: true) {
    sqlFile ("path": "views/processing_log_vw_ddl.sql", "endDelimiter": "\n/\\s*\n|\n/\\s*\$")
  }  

}

