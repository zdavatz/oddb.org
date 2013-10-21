#!/usr/bin/env ruby
# encoding: utf-8
# OneDirSuite -- oddb -- 09.04.2012 -- yasaka@ywesee.com
# OneDirSuite -- oddb -- 08.02.2011 -- mhatakeyama@ywesee.com

gem 'minitest'
require 'minitest/autorun'
require 'find'

$: << here = File.expand_path(File.dirname(__FILE__))

Find.find(here) { |file|
  if file.match(/\.rb$/) && !file.match(/suite\.rb/)
    require file
  end
}
