#!/usr/bin/env ruby
require 'pry'
require 'fileutils'

directory = ARGV[0] || '/var/www/oddb.org/doc/resources/dojo'

unless File.directory?(directory) && File.readable?(directory)
  raise "Directory #{directory} not found or not readable"
end

def unzip_files(directory, extension)
  search_pattern = File.join(directory, "**/*#{extension}")
  files = Dir.glob(search_pattern)
  puts "Directory #{directory}: Found #{files.size} #{extension}-files to zip"
  files.each do |file|
    next if /uncompressed/i.match(file)
    unless  File.extname(file).eql?(extension)
      puts "Skipping #{file}"
      next
    end
    backup = "#{file}.compressed" 
    next if File.exist?(backup)
    FileUtils.cp(file, backup, preserve: true, verbose: false)
    cmd = "gzip #{file} ; mv #{file}.gz #{file}"
    system cmd
  end
end

unzip_files(directory, '.js')
unzip_files(directory, '.css')
