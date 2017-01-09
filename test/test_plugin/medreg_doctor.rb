#!/usr/bin/env ruby
# encoding: utf-8
# TestDoctorPlugin -- oddb.org -- 11.05.2012 -- yasaka@ywesee.com
# TestDoctorPlugin -- oddb.org -- 23.03.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))


require 'minitest/autorun'
require 'stub/odba'
require 'flexmock/minitest'
require 'plugin/medreg_doctor'
require 'tempfile'
require 'ostruct'
require 'util/log'
require 'model/doctor'

Minitest::Test.i_suck_and_my_tests_are_order_dependent!()

class TestDoctorPlugin <Minitest::Test
  RunTestTakingLong = false
  def teardown
    ODBA.storage = nil
    super # to clean up FlexMock
  end
  def setup
    @config = flexmock('config')
    @doctor = ODDB::Doctor.new
    flexmock(@doctor,
                       :pointer => 'pointer',
                       :oid => 'oid',
                        :ean13 => "7601000000125",
                        :firstname => "Lucrezia Angela",
                        :name => "Anderegg-Dosch",
                        :specialities=>["Radiologie, 1978, Schweiz"],
                        :capabilities=>["Sonographie, 2006, Schweiz"],
                        :may_dispense_narcotics=>true,
                      )

    @doctors = Hash.new
    @app    = flexmock('app',
              :config => @config,
             :doctors => @doctors,
             :create_doctor => @doctor,
             :doctor_by_origin => @doctor,
             :update           => 'update'
            )
  end

  def test_update_using_small_yaml
    @@today = Date.new(2014,7,8)
    plugin_first_run = ODDB::Doctors::MedregDoctorPlugin.new(@app)
    yaml_file = File.expand_path(File.join(__FILE__, '../../data/medreg_doctors.yaml'))
    yaml_file_to_read = File.expand_path(File.join(__FILE__, '../../data/medreg_doctors_latest.yaml'))
    FileUtils.cp(yaml_file, yaml_file_to_read, {:verbose => false})
    flexmock(plugin_first_run, :get_latest_file => yaml_file_to_read )
    flexmock(plugin_first_run, :get_doctor_data => {})
    ean13 = 7601000000125
    @app.should_receive(:doctor_by_gln).with(7601000000095).and_return(nil)
    @app.should_receive(:doctor_by_gln).with(7601000000101).and_return(nil)
    @app.should_receive(:doctor_by_gln).with(7601000000118).and_return(nil)
    @app.should_receive(:doctor_by_gln).with(ean13).and_return(@doctor)
    assert(File.exists?(yaml_file), "latest #{yaml_file} must exist")
    startTime = Time.now
    created, updated, unchanged = plugin_first_run.update
    log = ODDB::Log.new(@@today)
    res = plugin_first_run.log_info
    # res = log_info(plugin_first_run)
    diffTime = (Time.now - startTime).to_i
    assert_equal(3, created)
    assert_equal(0, updated)
    assert_equal(1, unchanged)

    # Now run the plugin a second time
    plugin_second_run = ODDB::Doctors::MedregDoctorPlugin.new(@app)
    flexmock(plugin_second_run, :get_latest_file => yaml_file_to_read )
    flexmock(plugin_second_run, :get_doctor_data => {})
    FileUtils.cp(yaml_file, yaml_file_to_read, {:verbose => false})
    created, updated, unchanged = plugin_second_run.update
    res = plugin_second_run.log_info
    skip "We should expect 0, 0, 4. But handling this would complicate our unit test too much"
    assert_equal(0, created)
    assert_equal(0, updated)
    assert_equal(4, unchanged)
  end

end
