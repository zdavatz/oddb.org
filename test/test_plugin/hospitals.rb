#!/usr/bin/env ruby
# -- oddb -- 07.02.2005 -- jlang@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'plugin/hospitals'
require 'test/unit'
require 'mock'

module ODDB
	module MedData
		class HospitalPluginTest < Test::Unit::TestCase
def setup 
	@app = Mock.new("app")
	@plugin = ODDB::HospitalPlugin.new(@app)
	@meddata = Mock.new('meddata')
	@plugin.meddata_server = @meddata
end
def teardown
	@meddata.__verify
	@app.__verify
end
def test_update_hospital__1
	values = {
		:ean13	=>	'7680123456789'
	}
	@app.__next(:hospital) { |ean|
		assert_equal('7680123456789', ean)
		nil
	}
	@app.__next(:update) { |ptr, vals|
		assert_equal(values, vals)
		assert_instance_of(Persistence::Pointer, ptr)
		assert_equal([:create], ptr.skeleton)
	}
	@plugin.update_hospital(values)
end
def test_update_hospital__2
	values = {
		:ean13	=>	'1324657675434'
	}
	mock1 = Mock.new('hospital_mock')
	mock1.__next(:pointer) { "pointer" }
	@app.__next(:hospital) { |ean|
		assert_equal('1324657675434', ean)
		mock1
	}
	@app.__next(:update) { |ptr, vals|
		assert_equal(values, vals)
		assert_equal("pointer", ptr)
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
	result = Mock.new('result_mock')
	result.__next(:session) {}
	result.__next(:ctl) {}
	@meddata.__next(:detail) { |result, templ| 
		assert_equal(template, templ)
		{
			:name	=> 'Hospital',
		}
	}
	retval = @plugin.hospital_details(result)
	expected = {
		:name	=> 'Hospital',
		#:business_area => :hospital,
	}
	assert_equal(expected, retval)
end
		end
	end
end
