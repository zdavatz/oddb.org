#!/usr/bin/env ruby
require File.expand_path(File.join(File.dirname(__FILE__), 'common.rb'))
FilesToInstall.each {
  |file, destDir|
  if File.exists?(file)
    FileUtils.cp(file, destDir, :verbose => true, :preserve => true) 
  else
    puts "Skip cp non-exisiting file #{file} => #{destDir}"
  end
}

FilesToBackup.each {
  |file|
    next unless File.exists?(file)
    backup = backupName(file)
    if File.exists?(backup) and FileUtils.compare_file(file, backup)
      puts "nothing to do for #{file} -> #{backup}"
    else
      FileUtils.cp(file, backup, :verbose => true, :preserve => true)
    end
}

content = IO.readlines(DbDefinition)
storageRegExp = /^ODBA.storage.dbi/
File.open(DbDefinition, 'w+') { 
  |f|
  content.each{
               |line|
              if storageRegExp.match(line)
                f.puts  "ODBA.storage.dbi = ODBA::ConnectionPool.new('DBI:Pg:#{DBTestName}', 'postgres', '')"
              else
                f.puts line
              end
               }
}

cmds = [ 
    "sudo svc -d #{ServiceDir}/ch.oddb*",
    "sudo -u postgres dropdb #{DBTestName}",
    "sudo -u postgres createdb -E UTF8 -T template0 #{DBTestName}",
    "sudo -u apache psql oddb.org.ruby21x -f #{CreateDictonaryScript}",
    "sudo -u apache jobs/rebuild_indices",
    "sudo svc -u #{ServiceDir}/ch.oddb*"
]

puts "Skip executing cmds:" unless File.exists?(ServiceDir)
cmds.each { |cmd| puts "  "+cmd; system(cmd) if File.exists?(ServiceDir) }

