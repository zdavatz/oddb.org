#!/usr/bin/env ruby
# encoding: utf-8
# TestDoctorPlugin -- oddb.org -- 11.05.2012 -- yasaka@ywesee.com
# TestDoctorPlugin -- oddb.org -- 23.03.2011 -- mhatakeyama@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'plugin/medreg_doctor'
require 'tempfile'

class TestDoctorPlugin <Minitest::Test
  include FlexMock::TestCase
  Test_Personen_XLSX = File.expand_path(File.join(__FILE__, '../../data/xlsx/Personen_20141014.xlsx'))
  def setup
    @config = flexmock('config')
    @app    = flexmock('app', :config => @config)
    @plugin = ODDB::Doctors::MedregDoctorPlugin.new(@app)
    flexmock(@plugin, :get_latest=> Test_Personen_XLSX)
  end
  def test_update_7601000813282
    doctor = flexmock('doctor', :pointer => 'pointer')
    flexmock(@app, 
             :doctors => [doctor],
             :doctor_by_gln => nil,
             :doctor_by_origin => doctor,
             :update           => 'update'
            )
    flexmock(@config, 
             :empty_ids => nil,
             :pointer   => 'pointer'
            )
    @plugin = ODDB::Doctors::MedregDoctorPlugin.new(@app, [7601000813282])
    flexmock(@plugin, :get_latest_file => [ true, Test_Personen_XLSX ] )
    flexmock(@plugin, :get_doctor_data => {})
    flexmock(@plugin, :puts => nil)
    assert(File.exists?(Test_Personen_XLSX))
    startTime = Time.now
    csv_file = ODDB::Doctors::Personen_YAML 
    FileUtils.rm_f(csv_file) if File.exists?(csv_file)
    created, updated, deleted, skipped = @plugin.update
    diffTime = (Time.now - startTime).to_i
    # $stdout.puts "result: created #{created} updated #{updated} deleted #{deleted} skipped #{skipped} in #{diffTime} seconds"
    assert_equal(0, deleted)
    assert_equal(0, skipped)
    assert_equal(1, created)
    assert_equal(0, updated)
    assert(File.exists?(csv_file), "file #{csv_file} must be created")
    expected = "Doctors update \n\nNumber of doctors: 1\nNew doctors: 1\nUpdated doctors: 0\nDeleted doctors: 0\n"
    assert_equal(expected, @plugin.report)
  end
  def test_update_some_glns
    doctor = flexmock('doctor', :pointer => 'pointer')
    flexmock(@app, 
             :doctor_by_gln => nil,
             :doctor_by_origin => doctor,
             :update           => 'update'
            )
    flexmock(@config, 
             :empty_ids => nil,
             :pointer   => 'pointer'
            )
    @plugin = ODDB::Doctors::MedregDoctorPlugin.new(@app, [7601000813282, 7601000254207, 7601000186874, 7601000201522, 7601000295958, 
                                                           7601000157638, 7601000268969, 7601000019080, 7601000239730 ])

    flexmock(@plugin, :get_latest_file => [ true, Test_Personen_XLSX ] )
    flexmock(@plugin, :get_doctor_data => {})
    flexmock(@plugin, :puts => nil)
    assert(File.exists?(Test_Personen_XLSX))
    startTime = Time.now
    csv_file = ODDB::Doctors::Personen_YAML 
    FileUtils.rm_f(csv_file) if File.exists?(csv_file)
    created, updated, deleted, skipped = @plugin.update
    diffTime = (Time.now - startTime).to_i
    # $stdout.puts "result: created #{created} updated #{updated} deleted #{deleted} skipped #{skipped} in #{diffTime} seconds"
    assert_equal(0, deleted)
    assert_equal(0, skipped)
    assert_equal(0, updated)
    assert_equal(8, created)
    assert(File.exists?(csv_file), "file #{csv_file} must be created")
  end

  def test_get_latest_file
    @plugin = ODDB::Doctors::MedregDoctorPlugin.new(@app, [7601000813282])
    needs_update, latest = @plugin.get_latest_file
    # puts "needs_update ist #{needs_update.inspect} latest #{latest}"
  end  
end