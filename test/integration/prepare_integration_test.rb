#!/usr/bin/env ruby
require File.expand_path(File.join(File.dirname(__FILE__), "common.rb"))
content = IO.readlines(DbDefinition)

FilesToInstall.each { |file, destDir|
  if File.exist?(file)
    FileUtils.cp(file, destDir, verbose: true, preserve: true)
  else
    puts "Skip cp non-exisiting file #{file} => #{destDir}"
  end
}

require File.expand_path(File.join(File.dirname(__FILE__), "common.rb"))
ProductionDirs.each { |dir|
  file = File.join(TopDir, dir)
  backup = backupName(file)
  if File.exist?(backup)
    puts "Sorry backup #{backup} already exists. Skipping!!"
    exit 2
  else
    FileUtils.mv(file, backup, verbose: true)
  end
}

storageRegExp = /^ODBA.storage.dbi/
FileUtils.makedirs(File.dirname(DbDefinition), verbose: true)
File.open(DbDefinition, "w+") { |f|
  content.each { |line|
    if storageRegExp.match(line)
      f.puts "ODBA.storage.dbi = ODBA::ConnectionPool.new('DBI:Pg:#{DBTestName}', 'postgres', '')"
    else
      f.puts line
    end
  }
}

cmds = [
  "sudo svc -d #{ServiceDir}/ch.oddb*",
  "sudo -u postgres dropdb #{DBTestName}",
  "sudo -u postgres createdb -E UTF8 -T template0 #{DBTestName}",
  "sudo -u apache psql #{DBTestName} -f #{CreateDictonaryScript}",
  "sudo -u apache jobs/rebuild_indices",
  "sudo svc -u #{ServiceDir}/ch.oddb*"
]

puts "Skip executing cmds:" unless File.exist?(ServiceDir)
cmds.each { |cmd|
  puts "  " + cmd
  system(cmd) if File.exist?(ServiceDir)
}
