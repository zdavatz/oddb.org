#!/usr/bin/env ruby
# TestDoctor -- oddb -- 20.10.2003 -- maege@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))
$: << File.expand_path("../src", File.dirname(__FILE__))

require 'test/unit'
require 'emh'
require 'util/html_parser'

class TestDoctorWriter < Test::Unit::TestCase
	def setup
		@writer = ODDB::DoctorWriter.new
		formatter = ODDB::DoctorFormatter.new(@writer)
		@parser = ODDB::HtmlParser.new(formatter)
	end
	def test_parse__multiple_addresses
		html_path = File.expand_path('data/html/14488.html',
			File.dirname(__FILE__))
		html = File.read(html_path)
		@parser.feed(html)
		@writer.extract_data
		expected = {
			:address	=> [
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
					:type	=> :work,
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
					:type	=> :work,
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
					:type	=> :work,
				},
			],
			:specialist	=>	['Innere Medizin', 'Nephrologie'],
			:language		=>	'italienisch',
			:praxis			=>	"Ja",
			:exam				=>	"1970",
			:salutation	=>  "Herrn",
			:title			=>	"Prof. Dr. med.",
			:firstname	=>	"Claudio",
			:name	=>	"Marone",
			:email	=>	"claudio.marone@eoc.ch",
		}
		result = @writer.collected_values
		expected.each { |key, value|
			assert_equal(value, result[key], "while checking key: #{key}")
		}
		assert_equal(expected, result)
	end
end
