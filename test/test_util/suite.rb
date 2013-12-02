#!/usr/bin/env ruby
# encoding: utf-8
# OneDirSuite -- oddb -- 09.04.2012 -- yasaka@ywesee.com
# OneDirSuite -- oddb -- 08.02.2011 -- mhatakeyama@ywesee.com
require 'simplecov'
SimpleCov.start


gem 'minitest'
require 'minitest/autorun'
$: << File.expand_path(File.dirname(__FILE__))

# TODO: avoid skipping this stuff
# we must run oddbapp and oddbapp_2 separately because we run into a 
# internal limit of minitest.
puts "skipping ipn oddbapp"

Dir.open(File.dirname(__FILE__)) do |dir|
  dir.sort.each do |file|
    if /.*\.rb$/o.match(file)&&file!='suite.rb'
      if /oddbapp/.match(file)
          puts "Skipping file #{file}"
          next
      end
      require file 
    end
  end
end

