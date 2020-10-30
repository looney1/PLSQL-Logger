databaseChangeLog {

//  changeSet (author: "jdoe", id: "script.sql", runOnChange: true, runAlways: true) {
//    sqlFile ("path": "preops/script.sql", "endDelimiter": "\n/\\s*\n|\n/\\s*\$", "stripComments": true)
//  }
  changeSet (author: "jlooney", id: "ddl/module_config_ddl.sql", runOnChange: false) {
    sqlFile ("path": "ddl/module_config_ddl.sql", "endDelimiter": "\n/\\s*\n|\n/\\s*\$")
  }    
  changeSet (author: "jlooney", id: "package-specs/module_config_dil_pkg.pks", runOnChange: true) {
    sqlFile ("path": "package-specs/logger_pkg.pks", "endDelimiter": "\n/\\s*\n|\n/\\s*\$")
  }    
  changeSet (author: "jlooney", id: "package-bodies/module_config_dil_pkg.pkb", runOnChange: true) {
    sqlFile ("path": "package-bodies/module_config_dil_pkg.pkb", "endDelimiter": "\n/\\s*\n|\n/\\s*\$")
  }  
  changeSet (author: "jlooney", id: "views/module_config_vw_ddl.sql", runOnChange: true) {
    sqlFile ("path": "views/module_config_vw_ddl.sql", "endDelimiter": "\n/\\s*\n|\n/\\s*\$")
  }  

}

