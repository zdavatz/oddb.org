#!/usr/bin/env ruby
# encoding: utf-8
# TestCompanyPlugin -- oddb.org -- 11.05.2012 -- yasaka@ywesee.com
# TestCompanyPlugin -- oddb.org -- 23.03.2011 -- mhatakeyama@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'plugin/medreg_company'
require 'tempfile'

# stub Address2
module ODDB
  class Address2
    def initialize
      return {}
    end
  end
end
class TestCompanyPlugin <Minitest::Test
  include FlexMock::TestCase
  Test_Companies_XLSX = File.expand_path(File.join(__FILE__, '../../data/xlsx/companies_20141014.xlsx'))
  def setup
    @config  = flexmock('config',
             :empty_ids => nil,
             :pointer   => 'pointer'
            )
    @config  = flexmock('config')
    @company = flexmock('company', :pointer => 'pointer')
    @app     = flexmock('appX',
              :config => @config,
              :companies => [@company],          
              :company_by_gln => nil,
              :company_by_origin => @company,
              :update           => 'update'
            )
    @plugin = ODDB::Companies::MedregCompanyPlugin.new(@app)
    flexmock(@plugin, :get_latest_file => [true, Test_Companies_XLSX])
  end

  def test_update_7601002026444
    @plugin = ODDB::Companies::MedregCompanyPlugin.new(@app, [7601002026444])
    flexmock(@plugin, :get_latest_file => [true, Test_Companies_XLSX])
    flexmock(@plugin, :get_company_data => {})
    flexmock(@plugin, :puts => nil)
    startTime = Time.now
    csv_file = ODDB::Companies::Companies_YAML 
    FileUtils.rm_f(csv_file) if File.exists?(csv_file)
    created, updated, deleted, skipped = @plugin.update
    diffTime = (Time.now - startTime).to_i
    # $stdout.puts "result: created #{created} deleted #{deleted} skipped #{skipped} in #{diffTime} seconds"
    assert_equal(1, created)
    assert_equal(0, updated)
    assert_equal(0, deleted)
    assert_equal(0, skipped)
    assert(File.exists?(csv_file), "file #{csv_file} must be created")
  end

  def test_update_all
    @plugin = ODDB::Companies::MedregCompanyPlugin.new(@app)
    flexmock(@plugin, :get_latest_file => [true, Test_Companies_XLSX])
    flexmock(@plugin, :get_company_data => {})
    flexmock(@plugin, :puts => nil)
    startTime = Time.now
    csv_file = ODDB::Companies::Companies_YAML 
    FileUtils.rm_f(csv_file) if File.exists?(csv_file)
    created, updated, deleted, skipped = @plugin.update
    diffTime = (Time.now - startTime).to_i
    # $stdout.puts "result: created #{created} deleted #{deleted} skipped #{skipped} in #{diffTime} seconds"
    assert_equal(3, created)
    assert_equal(0, updated)
    assert_equal(0, deleted)
    assert_equal(1, skipped)
    assert(File.exists?(csv_file), "file #{csv_file} must be created")
  end

  def test_get_latest_file
    current  = File.expand_path(File.join(__FILE__, "../../../data/xls/companies_#{Time.now.strftime('%Y.%m.%d')}.xlsx"))
    FileUtils.rm_f(current) if File.exists?(current)
    @plugin = ODDB::Companies::MedregCompanyPlugin.new(@app)
    res = @plugin.get_latest_file
    assert(res[0], 'needs_update must be true')
    assert(res[1].match(/latest/), 'filename must match latest')
    assert(File.exists?(res[1]), 'companies_latest.xls must exist')
    assert(File.size(Test_Companies_XLSX) <File.size(res[1]))
  end
end
