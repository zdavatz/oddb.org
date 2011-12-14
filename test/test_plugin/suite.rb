#!/usr/bin/env ruby
# encoding: utf-8
# OneDirSuite -- oddb -- 08.02.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path(File.dirname(__FILE__))

Dir.open(File.dirname(__FILE__)) do |dir|
  dir.sort.each do |file|
    if /.*\.rb$/o.match(file)&&file!='suite.rb'
      require file 
    end
  end
end
