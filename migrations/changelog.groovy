databaseChangeLog {

/**********************************************************************************************************
  Example for adding new entries: 

  changeSet (author: "devname", id: "ddl/filename.sql") {
    sqlFile ("path": "ddl/filename.sql", "endDelimiter": "\n/\\s*\n|\n/\\s*\$")
  }

***********************************************************************************************************/


  include (file: "changelog-processing-log.groovy", relativeToChangelogFile: "true")
  include (file: "changelog-transaction-log.groovy", relativeToChangelogFile: "true")
  include (file: "changelog-module-config.groovy", relativeToChangelogFile: "true")
  
/*  changeSet (author: "jlooney", id: "ddl/BLAH.sql", runOnChange: false) {
    sqlFile ("path": "BLAH.sql", "endDelimiter": "\n/\\s*\n|\n/\\s*\$")
  }
*/
}
