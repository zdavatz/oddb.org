#!/usr/bin/env ruby
require File.expand_path(File.join(File.dirname(__FILE__), 'common.rb'))
ProductionDirs.each {
   |dir|
    file = File.join(TopDir, dir)
    backup = backupName(file)
    puts "backup #{backup} ->  #{file}"
    next unless File.exist?(backup)
    if  File.exist?(file) and FileUtils.compare_file(file, backupName(file))
      puts "nothing to do for #{file}"
    else
      FileUtils.mv(backup, file, :verbose => true)
    end
  }
