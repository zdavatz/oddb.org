#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::MedData::TestHospitalPlugin -- oddb.org -- 20.06.2011 -- mhatakeyama@ywesee.com
# ODDB::MedData::TestHospitalPlugin -- oddb.org -- 07.02.2005 -- jlang@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'plugin/hospitals'
gem 'minitest'
require 'minitest/autorun'
require 'flexmock'

module ODDB
	module MedData

class TestHospitalPlugin <Minitest::Test
  include FlexMock::TestCase
  def setup 
    @app = FlexMock.new("app")
    @plugin = ODDB::HospitalPlugin.new(@app)
    @meddata = FlexMock.new('meddata')
    @meddata_server = FlexMock.new
    #@meddata_server.should_receive(:session).and_return { yield @meddata }
    @meddata_server.should_receive(:session).and_yield(@meddata)
    @plugin.meddata_server = @meddata_server
  end
  def test_update_hospital__1
    values = {
      :ean13	=>	'7680123456789'
    }
    @app.should_receive(:hospital) { |ean|
      assert_equal('7680123456789', ean)
      nil
    }
    @app.should_receive(:update) { |ptr, vals, orig|
      assert_equal(values, vals)
      assert_instance_of(Persistence::Pointer, ptr)
      assert_equal([:create], ptr.skeleton)
      assert_equal(:refdata, orig)
    }
    @plugin.update_hospital(values)
  end
  def test_update_hospital__2
    values = {
      :ean13	=>	'1324657675434'
    }
    mock1 = FlexMock.new('hospital_mock')
    mock1.should_receive(:pointer) { "pointer" }
    @app.should_receive(:hospital) { |ean|
      assert_equal('1324657675434', ean)
      mock1
    }
    @app.should_receive(:update) { |ptr, vals, orig|
      assert_equal(values, vals)
      assert_equal("pointer", ptr)
      assert_equal(:refdata, orig)
    }
    @plugin.update_hospital(values)
  end
  def test_hospital_details__1
    template = {
      :ean13				=>	[1,0],
      :name					=>	[1,2],
      :business_unit =>	[1,3],
      :address			=>	[1,4],
      :plz					=>	[1,5],
      :location			=>	[2,5],
      :phone				=>	[1,6],
      :fax					=>	[2,6],
      :canton				=>	[3,5],
      :narcotics			=>	[1,10],
    }
    result = FlexMock.new('result_mock')
    result.should_receive(:ctl) {}
    @meddata.should_receive(:detail).and_return({:name => 'Hospital'})
    retval = @plugin.hospital_details(@meddata, result)
    expected = {
      :name	=> 'Hospital',
    }
    assert_equal(expected, retval)
  end
  def test_update_hospital
    hospital = flexmock('hospital', :pointer => 'pointer')
    flexmock(@app, 
             :hospital => hospital,
             :update   => 'update'
            )
    assert_equal('update', @plugin.update_hospital({:ean13 => '1234567890123'}))
  end
  def stdout_null
    require 'tempfile'
    $stdout = Tempfile.open('stdout')
    yield
    $stdout.close
    $stdout = STDERR
  end
  def test_update
    hospital = flexmock('hospital', :pointer => 'pointer')
    flexmock(@app, 
             :hospital => hospital,
             :update   => 'update'
            )
    result = flexmock('result')
    flexmock(@meddata) do |m|
      m.should_receive(:search).and_yield(result)
      m.should_receive(:detail).and_return({:ean13 => '1234567890123'})
    end
    stdout_null do 
      assert_nil(@plugin.update)
    end
  end
  def test_update__error1
    flexmock(@meddata) do |m|
      m.should_receive(:search).and_raise(StandardError)
    end
    assert_raise(StandardError) do 
      stdout_null do 
        @plugin.update
      end
    end
  end
  def test_update__error2
    flexmock(MedData::EanFactory).new_instances do |med|
      med.should_receive(:clarify).and_raise(StandardError)
    end
    flexmock(@meddata) do |m|
      m.should_receive(:search).and_raise(MedData::OverflowError)
    end
    assert_raise(StandardError) do 
      stdout_null do 
        @plugin.update
      end
    end
  end

end

	end # MedData
end # ODDB
