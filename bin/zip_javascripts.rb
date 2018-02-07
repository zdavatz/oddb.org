#!/usr/bin/env ruby
require 'pry'
require 'fileutils'

directory = ARGV[0] || '/var/www/oddb.org/doc/resources/dojo'

unless File.directory?(directory) && File.readable?(directory)
  raise "Directory #{directory} not found or not readable"
end

files = Dir.glob(File.join(directory, '**/*.js')).find_all{ |x| x.match(/\/[a-z]+\.js$/i)}.sort.uniq

puts files[0..5].join("\n"  )
puts "Found #{files.size} to zip"
files.each do |file|
  backup = "#{file}.compressed" 
  next if File.exist?(backup)
  FileUtils.cp(file, backup, preserve: true, verbose: true)
  cmd = "gzip #{file} ; mv #{file}.gz #{file}"
  system cmd
end
             

                 
                 
