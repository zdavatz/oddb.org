#!/usr/bin/env ruby
# encoding: utf-8
# TestDoctorPlugin -- oddb -- 22.09.2004 -- jlang@ywesee.com

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'plugin/doctors'
gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'flexmock/test_unit'

module ODDB
	module Doctors
    class DoctorPlugin < Plugin
      attr_reader :empty_id
      PARSER = FlexMock.new("PARSER") 
    end
		class TestDoctorPlugin <Minitest::Test
      include FlexMock::TestCase
			def setup
        @config = flexmock('config', :config => 'config')
        @app = flexmock('application_setup', :config => @config) #, :doctor_by_origin => 'doctor_by_origin')
        @app.should_receive(:doctor_by_origin)
        @plugin = DoctorPlugin.new(@app)
				@hash =  {
					:exam						=>"1970", 
					:firstname			=>"Happy Camper", 
					:language				=>"deutsch", 
					:name						=>"Testdoctor", 
					:addresses			=> [],
					:praxis					=>"Ja", 
					:salutation			=>"Herrn", 
					:skills					=>	"SuperLabor RTZ",
					:specialities		=>	"GrossLap Medizin", 
					:abilities			=>	"Mangel- und Seisemedizin", 
					:title					=>"Dr. med.", 
				}
			end
			def test_get_doctor_data
        DoctorPlugin::PARSER.should_receive(:doc_data_add_ean).with(5).and_return(5)
				assert_equal(5, @plugin.get_doctor_data(5))
			end
			def test_store_doctor
				doc_id = 14478
        @app.should_receive(:doctor_by_origin).and_return { |origin_db, origin_id| 
					assert_equal(:ch, origin_db)
					assert_equal(14478, origin_id)
					nil
				}
        @plugin = DoctorPlugin.new(@app)
				doctor = flexmock('doctor')
        doctor.should_receive(:docpointer)
				@app.should_receive(:update).returns { |pointer, update_hash|
					test_p = Persistence::Pointer.new(:doctor)
					expected = {
						:exam				=>	'1970',
						:firstname	=>	'Happy Camper',
						:language		=>	'deutsch',
						:name				=>	'Testdoctor',
						:addresses  =>  [],
						:praxis			=>	true,
						:specialities	=>	["GrossLap Medizin"], 
						#:abilities		=>	["Mangel- und Seisemedizin"], 
						#:skills			=>	["SuperLabor RTZ"],
						:title			=>	'Dr. med.',
						:salutation =>	'Herrn',
						:origin_id	=> 14478,
						:origin_db  => :ch,
					}
					assert_equal(expected, update_hash)
          assert_equal(test_p.creator, pointer)
          assert_equal(test_p.creator, pointer)
					doctor
				}
        @app.should_receive(:update)
				res = @plugin.store_doctor(doc_id, @hash)
				assert_equal(doctor, res)
			end
			def test_store_doctor__update
				doc_id = 14478
        doctor = flexmock('doctor')
        @app.should_receive(:doctor_by_origin).with(String, Integer).returns  { |origin, origin_id| 
          assert_equal(:ch, origin)
          assert_equal(14478, origin_id)
          doctor
        } 
        @app.should_receive(:update).returns { |pointer, update_hash|
					expected = {
						:exam				=>	'1970',
						:title			=>	'Dr. med.',
						:salutation =>	'Herrn',
						:title			=>"Dr. med.", 
						:language		=>"deutsch", 
						:addresses	=> [],
						:specialities	=>	["GrossLap Medizin"], 
						:praxis			=> true, 
						:firstname	=> "Happy Camper", 
						:name				=> "Testdoctor", 
						:origin_id	=> doctor,
						#:abilities		=>	["Mangel- und Seisemedizin"], 
						:origin_db  => :ch,
						#:skills			=>	["SuperLabor RTZ"],					
					}	
					assert_equal(expected, update_hash)
					assert_instance_of(ODDB::Persistence::Pointer, pointer)
				}
				@plugin.store_doctor(doctor , @hash)
			end
			def test_merge_addresses
				input	= [
					{
						:plz		=>	'6500',
						:city		=>	'Bellinzona',
						:fon		=>	'091 811 91 11',
						:fax		=>	'091 811 91 60',
						:lines	=>	[
							'Ospedale San Giovanni',
							'Soleggio',
							'6500 Bellinzona',
							'',
						],
					},
					{
						:plz		=>  '6597',
						:city   =>  'Agarone',
						:fon		=>	'092 64 11 41',
						:fax    =>  '',
						:lines	=>	[
							'Clinica Sassariente',
							'6597 Agarone',
							'',
						],
					},
					{
						:plz		=>  '6500',
						:city   =>  'Bellinzona',
						:fon		=>	'091 811 91 09',
						:fax    =>  '091 811 87 99',
						:lines  => [
							"Ospedale San Giovanni",
							"Soleggio",
							"6500 Bellinzona",
							"",
						],
					},
					{
						:plz		=>  '6500',
						:city   =>  'Bellinzona',
						:fon		=>	'091 811 91 11',
						:fax    =>  '',
						:lines  => [
							"Ospedale San Giovanni",
							"Soleggio",
							"6500 Bellinzona",
							"",
						],
					},
				]
				expected = [
					{
						:plz		=>	'6500',
						:city		=>	'Bellinzona',
						:fon		=>	[
							'091 811 91 11',
							'091 811 91 09',
						],
						:fax		=>	[
							'091 811 91 60',
							'091 811 87 99',
						],
						:lines	=>	[
							'Ospedale San Giovanni',
							'Soleggio',
							'6500 Bellinzona',
							'',
						],
					},
					{
						:plz		=>  '6597',
						:city   =>  'Agarone',
						:fon		=>	['092 64 11 41'],
						:fax    =>  [],
						:lines	=>	[
							'Clinica Sassariente',
							'6597 Agarone',
							'',
						],
					},
				]
				result = @plugin.merge_addresses(input)
				assert_equal(expected, result)
			end
			def test_prepare_addresses
				input = {
					:addresses	=>	{
						:plz		=>  '6500',
						:city   =>  'Bellinzona',
						:fon		=>	'091 811 91 09',
						:fax    =>  '091 811 87 99',
						:lines  => [
							"Ospedale San Giovanni",
							"Soleggio",
							"6500 Bellinzona",
							"",
						],
						:type	=> :work,
					}
				}
				result = nil
				result = @plugin.prepare_addresses(input)
				assert_instance_of(Array, result)
				assert_equal(1, result.size)
				addr = result.first
				assert_equal('6500', addr.plz)
				assert_equal('Bellinzona', addr.city)
				assert_equal(['091 811 91 09'], addr.fon)
				assert_equal(['091 811 87 99'], addr.fax)
				assert_equal(:work, addr.type)
			end
			def test_prepare_addresses__2
				input = {
					:addresses	=>	[
						{
							:plz		=>  '6500',
							:city   =>  'Bellinzona',
							:fax    =>  '',
							:fon		=>	'091 820 91 11',
							:lines	=>	[
								'Egregio Prof.',
								'Claudio Marone',
								'Studio medico',
								'Ospedale San Giovanni',
								'6500 Bellinzona',
								'',
							],
							:type	=> :praxis,
						},
						{
							:plz		=>  '6500',
							:city   =>  'Bellinzona',
							:fon		=>	'091 811 91 09',
							:fax    =>  '091 811 87 99',
							:lines  => [
								"Ospedale San Giovanni",
								"Soleggio",
								"6500 Bellinzona",
								"",
							],
							:type	=> :work,
						},
					]
				}
				result = nil
				result = @plugin.prepare_addresses(input)
				assert_instance_of(Array, result)
				assert_equal(2, result.size)
				assert_equal(:praxis, result.first.type)
				assert_equal(:work, result.last.type)
			end
		end
	end
end
