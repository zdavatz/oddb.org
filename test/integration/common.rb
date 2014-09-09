#!/usr/bin/env ruby
# encoding:utf-8
require 'fileutils'

IKSNRS_TO_EXTRACT = [ '17233', '32917', '57435',]
IntegrationDir = File.expand_path(File.dirname(__FILE__))
TopDir = File.expand_path(File.join(__FILE__, '..', '..', '..'))
ProductionDirs = [ 'etc', 'data', 'log' ]
DBTestName    = 'oddb_org_integration_test'
DbDefinition  = File.join(TopDir, 'etc', 'db_connection.rb')
ServiceDir    = '/service'
CreateDictonaryScript = File.join(IntegrationDir, 'data', 'create_dictionaries.sql')
XmlDataDir    = File.join(TopDir, 'data', 'xml')
XlsDataDir     = File.join(TopDir, 'data', 'xls')
FilesToBackup = [ DbDefinition,
                  File.join(XlsDataDir, 'Präparateliste-latest.xlsx'),
                  File.join(XlsDataDir, 'Packungen-latest.xlsx'),
                  File.join(XmlDataDir, 'AipsDownload_latest.xml'),
                  File.join(XmlDataDir, 'XMLSwissindexPharma-DE-latest.xml'),
                  File.join(XmlDataDir, 'XMLPublications-latest.zip'),
                  ]
FilesToInstall = {
    File.join(IntegrationDir, 'XMLPublications-current.zip')    => XmlDataDir,
    File.join(IntegrationDir, 'AipsDownload_current.xml')  => XmlDataDir,
    File.join(IntegrationDir, 'Packungen-current.xlsx')    => XlsDataDir,
    File.join(IntegrationDir, 'AipsDownload_previous.xml') => XmlDataDir,
    File.join(IntegrationDir, 'Packungen-previous.xlsx')   => XlsDataDir,
  }

def backupName(filename)
  filename += '.before_integration_test'
end
if __FILE__ == $0
  puts TopDir
  puts IntegrationDir
  puts ProductionDirs
end