#!/usr/bin/env ruby
# encoding: utf-8
# suite.rb -- oddb.org/ext -- 09.04.2012 -- yasaka@ywesee.com
# suite.rb -- oddb.org/ext -- 23.06.2011 -- mhatakeyama@ywesee.com 

gem 'minitest'
require 'minitest/autorun'
current_dir = (File.expand_path(File.dirname(__FILE__)))

tests2run = [ # we run only a very limited set of tests here
  "#{current_dir}/export/test/test_generics_xls.rb",
  "#{current_dir}/swissreg/test/test_swissreg.rb",
  "#{current_dir}/fiparse/test/test_patinfo_hpricot.rb",
  "#{current_dir}/fiparse/test/test_fachinfo_hpricot.rb",
  "#{current_dir}/meddata/test/test_session.rb",
  "#{current_dir}/meddata/test/test_result.rb",
  "#{current_dir}/meddata/test/test_meddata.rb",
  "#{current_dir}/meddata/test/test_ean_factory.rb",
  "#{current_dir}/meddata/test/test_meddparser.rb",
  "#{current_dir}/fiparse/test/test_fachinfo_writer.rb",
  "#{current_dir}/fiparse/test/test_fiwriter.rb",
  "#{current_dir}/export/test/test_csv_exporter.rb",
  "#{current_dir}/readonly/test/test_readonly_server.rb",
  "#{current_dir}/swissindex/test/test_swissindex.rb",
  "#{current_dir}/chapterparse/test/test_writer.rb",
  "#{current_dir}/chapterparse/test/test_parser.rb",
  "#{current_dir}/chapterparse/test/test_integrate.rb",
]
require File.expand_path(File.join(File.join(File.dirname(__FILE__), '..', 'test', 'helpers.rb')))
runner = OddbTestRunner.new(File.dirname(__FILE__))
runner.run_normal_tests(tests2run)
runner.show_results_and_exit
