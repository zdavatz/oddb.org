#!/usr/bin/env ruby
# TestDoctorPlugin -- oddb -- 22.09.2004 -- jlang@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'plugin/doctors'
require 'test/unit'
require 'mock'

module ODDB
	module Doctors
		class DoctorPlugin < Plugin
			attr_reader :empty_id
			PARSER = Mock.new('Parser')
		end
		class TestDoctorPlugin < Test::Unit::TestCase
			def setup
				@app = Mock.new('Application')
				@plugin = DoctorPlugin.new(@app)
				@hash =  {
					:exam						=>"1970", 
					:firstname			=>"Happy Camper", 
					:language				=>"deutsch", 
					:name						=>"Testdoctor", 
					:prax_address		=>["Herrn Dr. med.", 
						"Happy Camper Testdoctor", "Arztpraxis", 
						"Seestrasse 45", "3465 Zug", ""], 
					:work_address	=>	["Herrn Dr. med.", 
						"Happy Camper Testdoctor",
						"Workaddress 45", "3465 Zug", ""], 
					:prax_city			=>"Zug",
					:work_city			=>"Zug",
					:prax_fax				=>"", 
					:work_fax				=>"", 
					:prax_fon				=>"01 244 33 33", 
					:work_fon				=>"01 244 33 33", 
					:prax_plz				=>"6743", 
					:work_plz				=>"6743", 
					:praxis					=>"Ja", 
					:salutation			=>"Herrn", 
					:skills					=>	["SuperLabor RTZ"],
					:specialist			=>	["GrossLap Medizin", 
						"Mangel- und Seisemedizin"], 
					:title					=>"Dr. med.", 
					:salutation =>	'Herrn',
				}
			end
			def teardown
				@app.__verify
				DoctorPlugin::PARSER.__verify
			end
			def test_get_doctor_data
				DoctorPlugin::PARSER.__next(:emh_data) { |arg|
					assert_equal(5, arg)
				}
				@plugin.get_doctor_data(5)
			end
			def test_store_doctor
				doc_id = 14478
				@app.__next(:doctor_by_origin) { |origin_db, origin_id| 
					assert_equal(:ch, origin_db)
					assert_equal(14478, origin_id)
					nil
				}
				doctor = Mock.new('Doctor')
				doctor.__next(:pointer) { 'docpointer' }
				@app.__next(:create) { |pointer|
					test_p = Persistence::Pointer.new(:doctor)
					assert_equal(test_p, pointer)
					doctor
				}
				@app.__next(:update) { |pointer, update_hash|
					expected = {
						:exam				=>	'1970',
						:firstname	=>	'Happy Camper',
						:language		=>	'deutsch',
						:name				=>	'Testdoctor',
						:praxis			=>	true,
						:specialist			=>	["GrossLap Medizin", 
							"Mangel- und Seisemedizin"], 
						:title			=>	'Dr. med.',
						:salutation =>	'Herrn',
						:origin_id	=> 14478,
						:origin_db  => :ch,
					}	
					assert_equal(expected, update_hash)
					assert_equal('docpointer', pointer)
				}
				res = @plugin.store_doctor(doc_id, @hash)
				assert_equal(doctor, res)
			end
			def test_store_doctor__update
				doc_id = 14478
				doctor = Mock.new('Doctor')
				@app.__next(:doctor_by_origin) { |origin, origin_id| 
					assert_equal(:ch, origin)
					assert_equal(14478, origin_id)
					doctor
				}
				doctor.__next(:pointer) { 'docpointer' }
				@app.__next(:update) { |pointer, update_hash|
					expected = {
						:exam				=>	'1970',
						:title			=>	'Dr. med.',
						:salutation =>	'Herrn',
						:title			=>"Dr. med.", 
						:language		=>"deutsch", 
						:specialist	=>	["GrossLap Medizin", 
							"Mangel- und Seisemedizin"], 
						:praxis			=> true, 
						:firstname	=> "Happy Camper", 
						:name				=> "Testdoctor", 
						:origin_id	=> 14478,
						:origin_db  => :ch,
					}	
					assert_equal(expected, update_hash)
					assert_equal('docpointer', pointer)
				}
				res = @plugin.store_doctor(doc_id, @hash)
				assert_equal(doctor, res)
			end
			def test_delete_doctor__empty_id
				doc_id = 14478 
				doctor = Mock.new('Doctor')
				@app.__next(:doctors) { {} }
				@plugin.delete_doctor(doc_id)
				assert_equal([doc_id], @plugin.empty_id)
			end
		def test_store_address__praxis
				doc_pointer = Mock.new('DoctorPointer')
				addr_pointer = Mock.new("AddressPointer")
				expected = {
					:city		=>	"Zug",
					:fax		=>	"", 
					:fon		=>	"01 244 33 33", 
					:lines	=>	["Herrn Dr. med.", 
						"Happy Camper Testdoctor",
						"Workaddress 45", "3465 Zug", ""], 
					:plz		=>	'6743',
				}
				doc_pointer.__next(:+) { |addition|
					assert_equal([:address, :praxis], addition)
					addr_pointer
				}
				addr_pointer.__next(:creator) {
					'address_creator_pointer'
				}
				@app.__next(:update) { |creator, values|
					assert_equal('address_creator_pointer', creator)
					assert_equal(expected, values)
				}
				@plugin.store_address(doc_pointer, :praxis, @hash)
				doc_pointer.__verify
				addr_pointer.__verify
			end
			def test_store_address__work
				doc_pointer = Mock.new('DoctorPointer')
				addr_pointer = Mock.new("AddressPointer")
				expected = {
					:city		=>	"Zug",
					:fax		=>	"", 
					:fon		=>	"01 244 33 33", 
					:lines	=>	["Herrn Dr. med.", 
						"Happy Camper Testdoctor",
						"Workaddress 45", "3465 Zug", ""], 
					:plz		=>	'6743',
				}
				doc_pointer.__next(:+) { |addition|
					assert_equal([:address, :work], addition)
					addr_pointer
				}
				addr_pointer.__next(:creator) {
					'address_creator_pointer'
				}
				@app.__next(:update) { |creator, values|
					assert_equal('address_creator_pointer', creator)
					assert_equal(expected, values)
				}

				@plugin.store_address(doc_pointer, :work, @hash)
				doc_pointer.__verify
				addr_pointer.__verify
			end
		end
	end
end
