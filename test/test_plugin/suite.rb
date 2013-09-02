#!/usr/bin/env ruby
# encoding: utf-8
# OneDirSuite -- oddb -- 08.02.2011 -- yasaka@ywesee.com
# OneDirSuite -- oddb -- 08.02.2011 -- mhatakeyama@ywesee.com

require 'test/unit'

$: << File.expand_path(File.dirname(__FILE__))

puts "Skipping bsv_xml csv_export"

Dir.open(File.dirname(__FILE__)) do |dir|
  dir.sort.each do |file|
    if /.*\.rb$/o.match(file)&&file!='suite.rb'
      if /bsv_xml|csv_export/.match(file)
          puts "Skipping file #{file}"
          next
      end
          puts "require file #{file}"
      require file 
    end
  end
end
