require 'dbi'

@dbi = DBI.connect('DBI:pg:odba', 'odbauser', 'test')
#@dbi = DBI.connect('DBI:mysql:odba', 'odbauser', 'test')
#puts @dbi.handle.class
#ODBA.storage.DB_TYPE = "mysql"
ODBA.storage.dbi = @dbi
