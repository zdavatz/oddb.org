#!/usr/bin/env ruby
# TestEMH -- oddb -- 20.10.2003 -- maege@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))
$: << File.expand_path("../src", File.dirname(__FILE__))

require 'test/unit'
require 'emh'
require 'util/html_parser'

class TestEMHPlugin < Test::Unit::TestCase
	class StubHttp < Net::HTTP
		def post
		end
	end
end
module ODDB
	class EMHWriter < NullWriter
		attr_accessor :tablehandlers
		attr_reader :type
	end
	class HtmlTableHandler
		class Row
			attr_reader :cells
		end
	end
	class EMHPlugin < Plugin
		CSV_PATH = File.expand_path('data/csv/emh_addresses.csv', File.dirname(__FILE__))
		RANGE = 35310..35320
		#RANGE = ['10']
	end
	class EMHSession < HttpSession
		HTTP_CLASS = TestEMHPlugin::StubHttp
		def post(path, hash)
			resp = TestMedwinSession::StubResp.new
			path = File.expand_path('data/html/medwin_19999.html', File.dirname(__FILE__))
			resp.body = File.read(path)
			resp
		end
	end
end

class TestEMHMedwinWriter < Test::Unit::TestCase
	def setup
		path = File.expand_path('data/html/medwin.html', File.dirname(__FILE__))
		html = File.read(path)
		@writer = ODDB::EMHMedwinWriter.new
		formatter = ODDB::EMHFormatter.new(@writer)
		parser = ODDB::HtmlParser.new(formatter)
		parser.feed(html)
	end
	def test_extract_data
		expected = [
			"_ctl12", "_ctl2", "_ctl13", "_ctl3",	"_ctl14",
			"_ctl4", "_ctl5",	"_ctl15",	"_ctl6", "_ctl16",
			"_ctl7", "_ctl8",	"_ctl9", "_ctl10", "_ctl11"
		] 
		expected2 = [
			["Spycher", "Olivier", "Moutier"],
			["Altersheim bim Spycher", "\240", "Roggwil BE"],
			["Spycher", "Peter", "Liebefeld"],
			["Br\303\244gger-Spycher", "Christian", "Bazenheid"],
			["Spycher", "Reto", "Bern"],
			["Spycher", "Alfred", "Scuol"],
			["Spycher", "Barbara", "Schliern b. K\303\266niz"],
			["Spycher", "Rodolphe", "Gen\303\250ve"],
			["Spycher", "Beat", "G\303\274mligen"],
			["Spycher-Braendli", "Christa Barbara", "Bern"],
			["Spycher", "Claudia", "Solothurn"],
			["Spycher", "Heinz", "Eschenz"],
			["Spycher", "Jonathan", "Wabern"],
			["Spycher", "Martina", "Basel"],
			["Spycher", "Max A.", "Z\303\274rich"]
		] 
		result_keys = []
		result_values = []
		data = @writer.extract_data	
		data.each { |key, value|
			result_keys.push(key)
			result_values.push(value)
		}
		assert_equal(expected, result_keys)
		assert_equal(expected2, result_values)
	end
end
class TestEMHWriter < Test::Unit::TestCase
	def setup
		path = File.expand_path('data/html/table.html', File.dirname(__FILE__))
		html = File.read(path)
		path2 = File.expand_path('data/html/35316.html', File.dirname(__FILE__))
		html2 = File.read(path2)
		@writer = ODDB::EMHWriter.new
		formatter = ODDB::EMHFormatter.new(@writer)
		parser = ODDB::HtmlParser.new(formatter)
		parser.feed(html)
		@writer2 = ODDB::EMHWriter.new
		formatter2 = ODDB::EMHFormatter.new(@writer2)
		parser2 = ODDB::HtmlParser.new(formatter2)
		parser2.feed(html2)
	end
	def test_check_string
		result = @writer.check_string("Name:", "work")
		assert_equal(:name, result)
		result = @writer.check_string("Name:", "prax")
		assert_equal(:name, result)
		result = @writer.check_string("Name:", nil)
		assert_equal(:name, result)
		result = @writer.check_string("Adresse:", "work")
		assert_equal(:work_address, result)
		result = @writer.check_string("Telefon:", "prax")
		assert_equal(:prax_fon, result)
		result = @writer.check_string("Telefax:", "work")
		assert_equal(:work_fax, result)
		result = @writer.check_string("Email:", "prax")
		assert_equal(:prax_email, result)
	end
	def test_extract_data
		expected = [
			'cell 1 row 1',
			'cell 2 row 1',
			['cell 3 row 1 line 1', 'cell 3 row 1 line 2', ''],
			['cell 4 row 1 line 1', 'cell 4 row 1 line 2', ''],
			'cell 1 row 2',
			'cell 2 row 2',
			'cell 3 row 2',
			[
			'cell 4 row 2 line 1', 
			'cell 4 row 2 line 2',
			'cell 4 row 2 line 3',
			'cell 4 row 2 line 4',
			'',
			],
			'Praxis-Adresse',
		] 
		result = []
		data = @writer.extract_data	
		data.each { |row| 
			row.cells.each { |th|
				result << th.cdata
			}
		}
		assert_equal(expected, result)
		assert_equal('prax', @writer.type)
	end
	def test_extract_data2
			expected = [
				"Anrede:",
				"Herrn",
				"Titel:",
				"Dr. med.",
				"Name:",
				"Spycher",
				"Vorname:",
				"Olivier",
				"Praxis-Adresse",
				["Adresse:", ""],
				["Monsieur le Docteur",
				"Olivier Spycher",
				"49, rue de Beausite",
				"2740 Moutier",
				""],
				["Telefon:", "Telefax:", ""],
				["032 494 38 92", ""],
				"Email:",
				"olivier.spycher@hjbe.ch",
				"Adresse Arbeitsort (Chefarzt)",
				["Adresse:", ""],
				["H\364pital du Jura bernois",
				"Service de m\351decine interne",
				"Rue Beausite",
				"2740 Moutier",
				""],
				["Telefon:", "Telefax:", ""],
				["032 494 39 43", ""],
				"Email:",
				"olivier.spycher@hjbe.ch",
				"\240\240\240",
				"Facharzttitel: \240",
				"Innere Medizin",
				"Facharzttitel: \240",
				"Intensivmedizin",
				"Facharzttitel: \240",
				"Kardiologie",
				"\240\240\240",
				"Korrespondenzsprache:",
				"franz\366sisch",
				"Staatsexamensjahr:",
				"1990",
				"Praxis",
				"Ja",
				"",
				"",
				"",
			] 
		result = []
		data = @writer2.extract_data	
		data.each { |row| 
			row.cells.each { |th|
				result << th.cdata
			}
		}
		assert_equal(expected, result)
		assert_equal(nil, @writer.type)
	end
	def test_get_key
		result = @writer.get_key("Praxis")
		assert_equal(:praxis, result)
		result = @writer.get_key("Name:")
		assert_equal(:name, result)
		result = @writer.get_key("Mitglied")
		assert_equal(:member, result)
		result = @writer.get_key("Telefon:")
		assert_equal(nil, result)
	end
	def test_get_plz_city
		result = @writer.get_plz_city(["abcd", "8400 Winterthur", "abc"])
		assert_equal(['8400', 'Winterthur'], result)
	end
	def test_handle_data
		data = {
			'Anrede:'	=>	'gender_value:',
			'Anrede'	=>	'gender_value',
			'test'		=>	'test_value',
			"Vorname:    \240"	=>	'surname_value',
			['Telefon:', 'Telefax:']		=>	['phone_value', 'fax_value'],
			'Adresse:'=>	['address_line1', 'address_line2', 'address_line3', 'address_line4']
		}
		data.each_pair { |key, value|
			@writer.handle_data(key, value, 'work')
		}
		expected = {
			:surname	=>	'surname_value',
			:work_fon	=>	'phone_value',
			:work_fax	=>	'fax_value',
			:gender		=>	'gender_value:',
			:work_address	=>	['address_line1', 'address_line2', 'address_line3', 'address_line4'],
		}
		assert_equal(expected, @writer.collected_values)
	end
end
class TestEMHPlugin < Test::Unit::TestCase
	class StubApp
		attr_reader :pointers, :values
		def initialize
			@pointers = []
			@values = []
		end
		def update(pointer, values)
			@pointers << pointer
			@values << values
		end
	end
	def setup
		@app = StubApp.new
		@plugin = ODDB::EMHPlugin.new(@app)
	end
	def test_data_path
		expected = '/medical_adresses/physicians_fmh/detail.cfm?ds1nr=12500'
		assert_equal(expected, @plugin.data_path(12500))
	end
	def test_emh_path
		result = @plugin.emh_path({"a"=>"b", "c"=>"d"})
		expected = "/medical_adresses/physicians_fmh/detail.cfm?a=b&c=d"
		assert_equal(expected, result)
	end
	def test_emh_data_1
		begin
			@plugin.instance_eval <<-EOS
				alias :old_emh_data_body :emh_data_body
				alias :old_parse_emh_data :parse_emh_data
				def parse_emh_data_called
					@parse_emh_data_called
				end
				def emh_data_body(comp)
					"Name:"
				end
				def parse_emh_data(body)
					@parse_emh_data_called = true
				end
			EOS
			@plugin.emh_data(nil)
			assert_equal(true, @plugin.parse_emh_data_called)
		ensure
			@plugin.instance_eval <<-EOS
				alias :emh_data_body :old_emh_data_body 
				alias :parse_emh_data :old_parse_emh_data 
			EOS
		end
	end
	def test_emh_data_2
		begin
			@plugin.instance_eval <<-EOS
				alias :old_emh_data_body :emh_data_body
				alias :old_parse_emh_data :parse_emh_data
				def parse_emh_data_called
					@parse_emh_data_called
				end
				def emh_data_body(comp)
					"false"
				end
				def parse_emh_data(body)
					@parse_emh_data_called = true
				end
			EOS
			@plugin.emh_data(nil)
			assert_equal(nil, @plugin.parse_emh_data_called)
		ensure
			@plugin.instance_eval <<-EOS
				alias :emh_data_body :old_emh_data_body 
				alias :parse_emh_data :old_parse_emh_data 
			EOS
		end
	end
	def test_emh_data_body
		expressions = []
		expressions.push(/\<body bgcolor=\"#FFFFFF\" leftmargin=\"0\" topmargin=\"0\" marginwidth=\"0\" marginheight=\"0\" bgproperties=fixed background=\"..\/new_design\/images\/hg_inhalt.gif\"\>/)
		expressions.push(/\<td bgcolor=\"#006699\"\>\<b\>\<font color=\"#FFFFFF\">&Auml;rzteindex: Details\<\/font\>\<\/b\>\<\/td\>/)
		expressions.push(/\<table width=\"600\"\>/)
		expressions.each { |exp|
			assert(exp.match(@plugin.emh_data_body('19999')), 'Structure of the the online html-page has changed!')
		}
	end
	def test_emh_data_add_ean
		data = @plugin.emh_data_add_ean('19999')
		result = data.has_key?(:ean13)
		assert_equal(true, result)	
	end
	def test_parse_emh_data
		path = File.expand_path('data/html/15403.html', File.dirname(__FILE__))
		html = File.read(path)
		expected = {
			:gender		=>	'Frau',
			:title		=>	'Dr. med.',
			:name			=>	'Davatz',
			:surname	=>	'Ursula',
			:prax_address	=>	["Frau Dr. med.", "Ursula Davatz", "Psychiatrische Praxisgem.", "Mäderstr. 13", "5400 Baden", ""],
			:prax_fon	=>	'056 200 08 10',
			:prax_fax	=>	'056 200 08 18',
			:specialist	=>	'Psychiatrie und Psychotherapie',
			:language	=>	'deutsch',
			:exam			=>	'1969',
			:praxis		=>	'Ja',
			:prax_plz	=>	'5400',
			:prax_city	=>	'Baden',
		}
		result = @plugin.parse_emh_data(html)
		assert_equal(expected, result)
	end
	def test_parse_emh_data2
		path = File.expand_path('data/html/35316.html', File.dirname(__FILE__))
		html = File.read(path)
		expected = {
			:gender		=>	'Herrn',
			:title		=>	'Dr. med.',
			:name			=>	'Spycher',
			:surname	=>	'Olivier',
			:prax_address	=>	["Monsieur le Docteur", "Olivier Spycher", "49, rue de Beausite", "2740 Moutier", ""],
			:prax_fon	=>	'032 494 38 92',
			:prax_fax	=>	'',
			:prax_email		=>	'olivier.spycher@hjbe.ch',
			:work_address => ["Hôpital du Jura bernois", "Service de médecine interne", "Rue Beausite", "2740 Moutier", ""],
			:work_fon	=>	'032 494 39 43',
			:work_fax	=>	'',
			:work_email		=>	'olivier.spycher@hjbe.ch',
			:specialist				=>	['Innere Medizin', 'Intensivmedizin', 'Kardiologie'],
			:language	=>	'französisch',
			:exam			=>	'1990',
			:praxis		=>	'Ja',
			:prax_plz	=>	'2740',
			:work_plz	=>	'2740',
			:prax_city	=>	'Moutier',
			:work_city	=>	'Moutier',
		}
		result = @plugin.parse_emh_data(html)
		assert_equal(expected, result)
	end
	def test_prepare_csv_data
		data = {
			:gender		=>	'Herrn',
			:title		=>	'Dr. med.',
			:name			=>	'Spycher',
			:surname	=>	'Olivier',
			:email		=>	'name@email.ch',
			:prax_address	=>	["Monsieur le Docteur", "Olivier Spycher", "49, rue de Beausite", "2740 Moutier", ""],
			:prax_fon	=>	'032 494 38 92',
			:prax_fax	=>	'',
			:prax_email		=>	'olivier.spycher@hjbe.ch',
			:work_address => ["Hôpital du Jura bernois", "Service de médecine interne", "Rue Beausite", "2740 Moutier", ""],
			:work_fon	=>	'032 494 39 43',
			:work_fax	=>	'',
			:work_email		=>	'olivier.spycher@hjbe.ch',
			:specialist				=>	['Innere Medizin', 'Intensivmedizin', 'Kardiologie'],
			:language	=>	'französisch',
			:exam			=>	'1990',
			:praxis		=>	'Ja',
			:prax_plz	=>	'2740',
			:work_plz	=>	'2740',
			:prax_city	=>	'Moutier',
			:work_city	=>	'Moutier',
		}
		result = @plugin.prepare_csv_data(data)
		expected = [
			"Herrn", "Dr. med.", "Spycher", "Olivier", "name@email.ch", nil, 
			"Ja", "Monsieur le Docteur; Olivier Spycher; 49, rue de Beausite; 2740 Moutier", 
			"032 494 38 92", "", "olivier.spycher@hjbe.ch", 
			"2740", "Moutier", 
			"H\364pital du Jura bernois; Service de m\351decine interne; Rue Beausite; 2740 Moutier", 
			"032 494 39 43", "", "olivier.spycher@hjbe.ch", 
			"2740", "Moutier", "1990", "franz\366sisch", 
			"Innere Medizin; Intensivmedizin; Kardiologie", 
			nil, nil, nil
		]
		assert_equal(expected, result)
	end
	def test_write_csv
=begin
		path = File.expand_path('../data/html/emh/15403.html', File.dirname(__FILE__))
		html = File.read(path)
		result = @plugin.parse_emh_data(html)
		@plugin.write_csv(result)
		path = File.expand_path('../data/csv/emh/test.csv', File.dirname(__FILE__))
		csv = File.read(path)
		#puts csv
=end
	end
	def test_update
		#@plugin.update
	end
end
class TestMedwinSession < Test::Unit::TestCase
	class StubResp
		attr_accessor :body
	end
	class StubCompany
		attr_accessor :name, :pointer, :ean13, :address 
		attr_accessor :plz, :location, :phone, :fax
		def initialize(name, pointer)
			@name = name
			@pointer = pointer
		end
	end
	def setup
		@session = ODDB::EMHSession.new("foo")
	end
	def test_medic_html
		path = File.expand_path('data/html/medwin_19999.html', File.dirname(__FILE__))
		expected = File.read(path)
		result = @session.medic_html({:name => "foo"})
		assert_equal(expected, result)
	end
	def test_handle_resp
		path = File.expand_path('data/html', File.dirname(__FILE__))
		file = "medwin.html"
		html = File.read([path, file].join("/"))
		result = @session.handle_resp(html)
		assert_equal("FooViewState=", result)
	end
end
