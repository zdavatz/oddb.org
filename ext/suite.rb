#!/usr/bin/env ruby
# encoding: utf-8
# suite.rb -- oddb.org/ext -- 09.04.2012 -- yasaka@ywesee.com
# suite.rb -- oddb.org/ext -- 23.06.2011 -- mhatakeyama@ywesee.com 

gem 'minitest'
require 'minitest/autorun'
require File.join(File.expand_path(File.dirname(File.dirname(__FILE__))), 'test','suite.rb')

current_dir = (File.expand_path(File.dirname(__FILE__)))

# IsolatedTests run_tests(["#{current_dir}/export/test/test_oddbdat.rb"])

require "#{current_dir}/swissreg/test/test_swissreg.rb"

require "#{current_dir}/fiparse/test/test_patinfo_hpricot.rb"
require "#{current_dir}/fiparse/test/test_fachinfo_hpricot.rb"
require "#{current_dir}/meddata/test/test_session.rb"
require "#{current_dir}/meddata/test/test_result.rb"
require "#{current_dir}/meddata/test/test_meddata.rb"
require "#{current_dir}/meddata/test/test_ean_factory.rb"
require "#{current_dir}/meddata/test/test_meddparser.rb"
require "#{current_dir}/fiparse/test/test_fachinfo_writer.rb"
require "#{current_dir}/fiparse/test/test_fiwriter.rb"
require "#{current_dir}/export/test/test_csv_exporter.rb"
require "#{current_dir}/readonly/test/test_readonly_server.rb"
require "#{current_dir}/swissindex/test/test_swissindex.rb"
require "#{current_dir}/chapterparse/test/test_writer.rb"
require "#{current_dir}/chapterparse/test/test_parser.rb"
require "#{current_dir}/chapterparse/test/test_integrate.rb"



