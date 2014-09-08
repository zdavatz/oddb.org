#!/usr/bin/env ruby
require File.expand_path(File.join(File.dirname(__FILE__), 'common.rb'))
FilesToBackup.each {
  |file|
    backup = backupName(file)
    next unless File.exists?(backup)
    if  File.exists?(file) and FileUtils.compare_file(file, backupName(file))
      puts "nothing to do for #{file}"
    else
      FileUtils.mv(backup, file, :verbose => true, :preserve => true)
    end
}
