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
             :doctor_by_origin => doctor,
             :update           => 'update'
            )
    flexmock(@config, 
             :empty_ids => nil,
             :pointer   => 'pointer'
            )
    @plugin = ODDB::Doctors::MedregDoctorPlugin.new(@app, [7601000813282])
    flexmock(@plugin, :get_latest=> Test_Personen_XLSX)
    flexmock(@plugin, :get_doctor_data => {})
    flexmock(@plugin, :puts => nil)
    res = @plugin.update
    $stdout.puts "res was #{res.inspect}"
    assert_equal(1, res)
  end
  def test_update
    doctor = flexmock('doctor', :pointer => 'pointer')
    flexmock(@app, 
             :doctor_by_origin => doctor,
             :update           => 'update'
            )
    flexmock(@config, 
             :empty_ids => nil,
             :pointer   => 'pointer'
            )
    flexmock(@plugin, :get_doctor_data => {})
    flexmock(@plugin, :puts => nil)
    res = @plugin.update
    $stdout.puts "res was #{res.inspect}"
    assert_equal(27, res)
  end if false
  def test_store_doctor
    skip 'test_store_doctor'
  end
  def test_delete_doctor
    skip 'test_delete_doctor'
 end
  def test_report
    flexmock(@app, :"doctors.size" => 'doctors.size')
    expected = "Doctors update \n\nNumber of doctors: doctors.size\nNew doctors: 0\nDeleted doctors: 0\n"
    assert_equal(expected, @plugin.report)
  end
  def test_get_doctor_data
    skip "get_doctor_data"
  end
  def test_fix_doctors
    skip "fix_doctor"
  end
  def test_fix_doctors__runtime_error
    skip "fix_doctors__runtime_error"
  end
  def test_fix_duplicate_eans
    skip "fix_duplicate_eans"
  end
end
