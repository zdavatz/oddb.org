#!/usr/bin/env ruby
# encoding: utf-8
# OneDirSuite -- oddb -- 09.04.2012 -- yasaka@ywesee.com
# OneDirSuite -- oddb -- 08.02.2011 -- mhatakeyama@ywesee.com

require 'test/unit'

$: << File.expand_path(File.dirname(__FILE__))

Dir.open(File.dirname(__FILE__)) do |dir|
  dir.sort.each { |file|
    if /.*\.rb$/o.match(file)&&file!='suite.rb'
      require file 
    end
  }
end
