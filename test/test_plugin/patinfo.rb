#!/usr/bin/env ruby
# TestPatinfoPlugin -- oddb -- 30.10.2003 -- rwaltert@ywesee.com


$: << File.dirname(__FILE__)
$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))
$: << File.expand_path("../../ext/fiparse/src", File.dirname(__FILE__))

require 'test/unit'
require 'plugin/patinfo'

module ODDB
	class PatinfoPlugin < Plugin
		attr_accessor :iksnrs, :iksnr_documents, :named_documents,									:assigned_documents, :orphaned_documents
		attr_accessor :names, :error_documents, :parse_error_documents
		HTML_PATH = File.expand_path('../data/html/', 
			File.dirname(__FILE__))
		module Parser
			def result=(obj)
				@result = obj
			end
			def parse_patinfo_html(src)
				@result
			end
			module_function :parse_patinfo_html
			module_function :result=
		end
		PARSER = Parser
	end
end

class TestPatinfoPlugin < Test::Unit::TestCase
	class StubSequence
		attr_accessor :name_base, :name_descr, :pointer, :iksnr
	end
	class StubRegistration
		attr_accessor :patinfo, :iksnr
		attr_accessor :pointer, :name_base
		attr_accessor :name_descr, :sequences
	end
	class StubApp
		attr_reader :update_pointers, :update_values
		attr_accessor :registrations, :update_result
		attr_accessor :update_results
		def initialize
			@registrations = {}
			@update_pointers = []
			@update_values = []
		end
		def create(pointer)
		end
		def registration(key)
			@registrations[key]
		end
		def update(pointer, values)
			@update_pointers << pointer
			@update_values << values
			if(@update_results)
				@update_results[values]
			else
				@update_result
			end
		end
	end
	class StubPatinfo
		attr_accessor	:pointer, :name, :iksnrs, :date
		def de
			self
		end
	end
	class StubTextItem
		attr_reader :name
		def initialize(name)
			@name = name
		end
		def method_missing(*args)
			self
		end
	end
	def setup
		@app = StubApp.new
		@plugin = ODDB::PatinfoPlugin.new(@app)
	end
	def test_store_patinfo
		values = {
			'de' => 'Deutsch',
			'fr' => 'Franz',
		}
		@plugin.store_patinfo(values)
		pointer = ODDB::Persistence::Pointer.new(
			[:patinfo]
		)
		creator = ODDB::Persistence::Pointer.new([:create, pointer])
		assert_equal(creator, @app.update_pointers.first)
		assert_equal(values, @app.update_values.first)
	end
	def test_package_languages
		stub = StubPatinfo.new
		stub.date = 'foo'
		stub.iksnrs = "12345 (Swissmedic)."
		ODDB::PatinfoPlugin::Parser.result = stub
		languages = @plugin.package_languages(5050)
		assert_equal(['de'], languages.keys)
		assert_equal(stub, languages['de'])
		assert_equal(['12345'], @plugin.iksnrs)
	end
	def test_package_languages2
		stub = StubPatinfo.new
		stub.iksnrs = "12345 (Swissmedic)."
		ODDB::PatinfoPlugin::Parser.result = stub
		languages = @plugin.package_languages(5050)
		assert_equal({}, languages)
		assert_equal({},@plugin.error_documents)
		assert_equal({},@plugin.iksnr_documents)
		assert_equal(1,@plugin.parse_error_documents.size)
		expected = File.expand_path('../data/html/de/05050.html',
			File.dirname(__FILE__))
		assert_equal(expected, @plugin.parse_error_documents.first)
	end
	def test_parse_patinfo1
		stub = StubPatinfo.new
		stub.date = 'foo'
		ODDB::PatinfoPlugin::Parser.result = stub
		patinfo = @plugin.parse_patinfo('de', 5050)
		assert_equal(stub, patinfo)
	end
	def test_parse_patinfo2
		patinfo = assert_nothing_raised {
			@plugin.parse_patinfo('de', 10000)
		}
		assert_nil(patinfo)
	end
	def test_extract_iksnrs
		patinfo = StubPatinfo.new
		patinfo.iksnrs = "12345 (Swissmedic)."
		assert_equal(['12345'], @plugin.extract_iksnrs(patinfo))
		patinfo.iksnrs = "12345, 98765 (Swissmedic)."
		assert_equal(['12345', '98765'], @plugin.extract_iksnrs(patinfo))
		patinfo.iksnrs = nil
		assert_equal([], @plugin.extract_iksnrs(patinfo))
		patinfo.iksnrs = 'Die Swissmedic ist läss.'
		assert_equal([], @plugin.extract_iksnrs(patinfo))
	end
	def test_package_patinfo1
		patinfo = StubPatinfo.new
		patinfo.date = 'foo'
		patinfo.iksnrs = "12345, 87654 (Swissmedic)."
		ODDB::PatinfoPlugin::Parser.result = patinfo
		@plugin.package_patinfo(5050)
		expected = {
			'12345'	=>	{ 'de'=>patinfo },
			'87654'	=>	{ 'de'=>patinfo },
		}
		assert_equal(expected, @plugin.iksnr_documents)
	end
	def test_package_patinfo2
		patinfo = StubPatinfo.new
		patinfo.date = 'foo'
		patinfo.iksnrs = "12345, 87654 (Swissmedic)."
		@plugin.iksnr_documents = {
			'12345'	=>	{ 'de'=>patinfo },
			'87654'	=>	{ 'de'=>patinfo },
		}
		assert_equal({}, @plugin.error_documents)
		patinfo2 = StubPatinfo.new
		patinfo2.date = 'foo'
		patinfo2.iksnrs = "12345 (Swissmedic)."
		ODDB::PatinfoPlugin::Parser.result = patinfo2
		@plugin.package_patinfo(5050)
		expected = {
			'87654'	=>	{ 'de'=>patinfo },
		}
		assert_equal(expected, @plugin.iksnr_documents)
		errors = {
			'12345'	=> [ 
				{ 'de'	=> patinfo}, 
				{ 'de'	=> patinfo2},
			]
		}
		assert_equal(errors, @plugin.error_documents)
		patinfo3 = StubPatinfo.new
		patinfo3.date = 'foo'
		patinfo3.iksnrs = "12345 (Swissmedic)."
		ODDB::PatinfoPlugin::Parser.result = patinfo3
		@plugin.package_patinfo(5050)
		assert_equal(expected, @plugin.iksnr_documents)
		errors = {
			'12345'	=> [ 
				{ 'de'	=> patinfo}, 
				{ 'de'	=> patinfo2},
				{ 'de'	=> patinfo3},
			]
		}
		assert_equal(errors, @plugin.error_documents)
	end
	def test_package_patinfo3
		patinfo = StubPatinfo.new
		patinfo.date = 'foo'
		patinfo.name = 'Cafergot®'
		ODDB::PatinfoPlugin::Parser.result = patinfo
		@plugin.package_patinfo(5050)
		assert_equal({}, @plugin.iksnr_documents)
		expected = {
			'Cafergot'	=>	{'de'=>patinfo}
		}
		assert_equal(expected, @plugin.named_documents)
	end
	def test_package_patinfo4
		@plugin.named_documents = {
			'Cafergot'	=>	{'de'=>"Schon vorhanden"}
		}
		patinfo = StubPatinfo.new
		patinfo.date = 'foo'
		patinfo.name = 'Cafergot®'
		ODDB::PatinfoPlugin::Parser.result = patinfo
		@plugin.package_patinfo(5050)
		expected = {
			'Cafergot'	=>	[
				{'de'=>"Schon vorhanden"}, 
				{'de'=>patinfo},
			],
		}
		assert_equal({}, @plugin.iksnr_documents)
		assert_equal({}, @plugin.named_documents)
		assert_equal(expected, @plugin.error_documents)
		patinfo1 = StubPatinfo.new
		patinfo1.date = 'foo'
		patinfo1.name = 'Cafergot®'
		ODDB::PatinfoPlugin::Parser.result = patinfo1
		@plugin.package_patinfo(5050)
		expected = {
			'Cafergot'	=>	[
				{'de'=>"Schon vorhanden"}, 
				{'de'=>patinfo},
				{'de'=>patinfo1},
			],
		}
		assert_equal({}, @plugin.iksnr_documents)
		assert_equal({}, @plugin.named_documents)
		assert_equal(expected, @plugin.error_documents)
	end
	def test_patinfo_link_check
		@plugin.named_documents = {
			'name'  => 'value',
			'name2' => 'value2',
		}
		@plugin.iksnr_documents = {
			'12345' => 'value3',
			'678'		=> 'value4',
		}
		@app.registrations = {
			'name' => 'value',
			'678'  =>	'value4',
		}
		error = {
			'name2' => ['value2'],
			'12345'	=> ['value3'],
		}
		@plugin.patinfo_link_check
		assert_equal(error,@plugin.error_documents)
	end
	def test_extract_names1
		pi = StubPatinfo.new
		pi.name = 'Cafergot®'
		result = @plugin.extract_names(pi)
		assert_equal(['Cafergot'], result)
	end
	def test_extract_names2
		pi = StubPatinfo.new
		pi.name = 'Cafergot® 100/200'
		result = @plugin.extract_names(pi)
		assert_equal(['Cafergot 100', 'Cafergot 200'], result)
	end
	def test_extract_names3
		pi = StubPatinfo.new
		pi.name = 'Cafergot® / Cafergot® 200'
		result = @plugin.extract_names(pi)
		assert_equal(['Cafergot', 'Cafergot 200'], result)
	end
	def test_extract_names4
		pi = StubPatinfo.new
		pi.name = 'Ossopan 800'
		result = @plugin.extract_names(pi)
		assert_equal(['Ossopan 800'], result)
	end
	def test_extract_names5
		pi = StubPatinfo.new
		result = @plugin.extract_names(pi)
		assert_equal([], result)
	end
	def test_extract_names6
		pi = StubPatinfo.new
		pi.name = 'Batrafen® Crème/Lösung/Puder'
		result = @plugin.extract_names(pi)
		assert_equal(['Batrafen Crème', 'Batrafen Lösung',
									'Batrafen Puder'], result)
	end
	def test_orphaned_documents
		@plugin.named_documents  = {
			"Aspirin" => "foo",
			"Zyanit"	=> "bar",
		}
		@plugin.iksnr_documents = {
			"12345" =>	"foo1",
			"98765" =>  "bar1",
		}
		@plugin.assigned_documents = ["bar","foo","bar1"]
		
		result  = {
			"12345" =>"foo1",
}
		@plugin.collect_orphaned_documents
		assert_equal(result,@plugin.orphaned_documents)
	end
	def test_sequence_info_by_name1
		@plugin.named_documents = {
			"Aspirin"						=> "foo",
			"Aspirin Tabletten" => "bar"
		}
		seq = StubSequence.new
		seq.name_base = "Aspirin"
		seq.name_descr = "Tabletten"
		result = @plugin.sequence_info_by_name(seq)
    assert_equal("foo", result)
	end
	def test_sequence_info_by_name2
		@plugin.named_documents = {
			"Aspirin Tabletten" => "bar"
		}
		seq = StubSequence.new
		seq.name_base = "Aspirin"
		seq.name_descr = "Tabletten"
		result = @plugin.sequence_info_by_name(seq)
		assert_equal("bar", result)
	end
	def test_sequence_info_by_name3
		@plugin.named_documents = {
			"Aspirin Tabletten" => "bar"
		}
		seq = StubSequence.new
		seq.name_base = "Aspirin"
		seq.name_descr = "Kapsel"
		result = @plugin.sequence_info_by_name(seq)
		assert_equal(nil, result)
	end
	def test_update_registrations1
		# 1. iksnr
		# 2. eindeutiger name
		# 3. 2 iksnr für eine pi
		# 4. keine Identifizierung mit name, aber mit name_descr
		# 5. zwei pi passen auf denselben Namen
		# 6. name und iksnr einer Registration, kombinierter Fehler
		reg1 = StubRegistration.new
		reg2 = StubRegistration.new
		seq1 = StubSequence.new
		seq2 = StubSequence.new
		seq3 = StubSequence.new
		seq1.pointer = "seq1_pointer"
		seq2.pointer = "seq2_pointer"
		seq3.pointer = "seq3_pointer"
		reg1.sequences = { '01'=>seq1, '02'=>seq2 }
		reg2.sequences = { '03'=>seq3 }
		reg1.iksnr = '12345'
		reg1.pointer = 'Reg1Pointer'
		reg2.iksnr = '54321'
		@app.registrations = {
			'12345'	=>	reg1,
			'54321'	=>	reg2,
		}
		@plugin.iksnr_documents = { 
			'12345'	=>	'fi1',
			'67890'	=>	'fi2',
		}
		pipointer = ODDB::Persistence::Pointer.new([:patinfo])
		pi = StubPatinfo.new
		pi.pointer = 'PatinfoPointer'
		@app.update_result = pi
		@plugin.update_registrations
		assert_equal(3, @app.update_pointers.size)
		assert_equal(pipointer.creator, @app.update_pointers.first)
		assert_equal('fi1', @app.update_values.first)
		assert_equal(true, @app.update_pointers.include?('seq1_pointer'))
		assert_equal(true, @app.update_pointers.include?('seq2_pointer'))
		assert_equal({:patinfo => 'PatinfoPointer'}, @app.update_values.at(1))
		assert_equal({:patinfo => 'PatinfoPointer'}, @app.update_values.at(2))
	end
	def test_update_registrations2
		seq1 = StubSequence.new
		seq1.name_base = "Aspirin" 
		seq1.pointer = "seq1_pointer"
		seq2 = StubSequence.new
		seq2.name_base = "Aspirin" 
		seq2.pointer = "seq2_pointer"
		reg1 = StubRegistration.new
		reg1.sequences = { '01'	=>	seq1, '02' => seq2 }
		reg1.iksnr = '12345'
		reg1.pointer = 'Reg1Pointer'
		@app.registrations = {
			'12345'	=>	reg1,
		}
		@plugin.iksnr_documents = { 
			'67890'	=>	'fi2',
		}
		@plugin.named_documents = {
			'Aspirin'	=>	'fi1'
		}
		pipointer = ODDB::Persistence::Pointer.new([:patinfo])
		pi = StubPatinfo.new
		pi.pointer = 'PatinfoPointer'
		@app.update_result = pi
		@plugin.update_registrations
		assert_equal(3, @app.update_pointers.size)
		assert_equal(pipointer.creator, @app.update_pointers.first)
		assert_equal('fi1', @app.update_values.first)
		assert_equal(true, @app.update_pointers.include?('seq1_pointer'))
		assert_equal(true, @app.update_pointers.include?('seq2_pointer'))
		assert_equal({:patinfo => 'PatinfoPointer'}, @app.update_values.at(1))
		assert_equal({:patinfo => 'PatinfoPointer'}, @app.update_values.at(2))
	end
	def test_update_registrations3
		reg1 = StubRegistration.new
		reg2 = StubRegistration.new
		seq1 = StubSequence.new
		seq2 = StubSequence.new
		seq3 = StubSequence.new
		seq4 = StubSequence.new
		seq1.pointer = "seq1_pointer"
		seq2.pointer = "seq2_pointer"
		seq3.pointer = "seq3_pointer"
		seq4.pointer = "seq4_pointer"
		reg1.sequences = { '01'	=>	seq1, '02'	=>	seq2 }
		reg2.sequences = { '01'	=>	seq3, '02'	=>	seq4 }
		reg1.iksnr = '12345'
		reg1.pointer = 'Reg1Pointer'
		reg2.iksnr = '54321'
		reg2.pointer = 'Reg2Pointer'
		@app.registrations = {
			'12345'	=>	reg1,
			'54321'	=>	reg2,
		}
		@plugin.iksnr_documents = { 
			'12345'	=>	'pi1',
			'54321'	=>	'pi1',
		}
		pipointer = ODDB::Persistence::Pointer.new([:patinfo])
		pi = StubPatinfo.new
		pi.pointer = 'PatinfoPointer'
		@app.update_result = pi
		@plugin.update_registrations
		assert_equal(5, @app.update_pointers.size)
		assert_equal(pipointer.creator, @app.update_pointers.first)
		assert_equal('pi1', @app.update_values.first)
		[
			'seq1_pointer',
			'seq2_pointer',
			'seq3_pointer',
			'seq4_pointer',
		].each { |expected|
			assert_equal(true, @app.update_pointers[1,4].include?(expected))
		}
		assert_equal({:patinfo => 'PatinfoPointer'}, @app.update_values.at(1))
		assert_equal({:patinfo => 'PatinfoPointer'}, @app.update_values.at(2))
		assert_equal({:patinfo => 'PatinfoPointer'}, @app.update_values.at(3))
		assert_equal({:patinfo => 'PatinfoPointer'}, @app.update_values.at(4))
	end
	def test_update_registrations4
		seq1 = StubSequence.new
		seq2 = StubSequence.new
		seq1.name_base = "Batrafen"
		seq1.name_descr = "Puder"
		seq2.name_base = "Batrafen"
		seq2.name_descr = "Crème"
		seq1.pointer = 'seq1_pointer'
		seq2.pointer = 'seq2_pointer'
		reg1 = StubRegistration.new
		reg1.iksnr = '12345'
		reg1.pointer = 'Reg1Pointer'
		reg1.sequences = {
			'01'	=>	seq1,
			'02'	=>	seq2,
		}
		@app.registrations = {
			'12345'	=>	reg1,
		}
		@plugin.named_documents = {
			'Batrafen Puder'	=>	'pi1',
			'Batrafen Crème'	=>	'pi1',
		}
		pipointer = ODDB::Persistence::Pointer.new([:patinfo])
		pi = StubPatinfo.new
		pi.pointer = 'PatinfoPointer'
		@app.update_result = pi
		@plugin.update_registrations
		assert_equal(3, @app.update_pointers.size)
		assert_equal(pipointer.creator, @app.update_pointers.first)
		assert_equal('pi1', @app.update_values.first)
		[
			'seq1_pointer',
			'seq2_pointer',
		].each { |expected|
			assert_equal(true, @app.update_pointers[1,2].include?(expected))
		}
		assert_equal({:patinfo => 'PatinfoPointer'}, @app.update_values.at(1))
		assert_equal({:patinfo => 'PatinfoPointer'}, @app.update_values.at(2))
	end
	def test_update_registrations5
		seq1 = StubSequence.new
		seq2 = StubSequence.new
		seq1.name_base = "Batrafen"
		seq1.name_descr = "Puder"
		seq2.name_base = "Batrafen"
		seq2.name_descr = "Crème"
		seq1.pointer = 'seq1_pointer'
		seq2.pointer = 'seq2_pointer'
		reg1 = StubRegistration.new
		reg1.iksnr = '12345'
		reg1.pointer = 'Reg1Pointer'
		reg1.sequences = {
			'01'	=>	seq1,
			'02'	=>	seq2,
		}
		@app.registrations = {
			'12345'	=>	reg1,
		}
		@plugin.named_documents = {
			'Batrafen Puder'	=>	'pi1',
			'Batrafen Crème'	=>	'pi2',
		}
		pipointer = ODDB::Persistence::Pointer.new([:patinfo])
		pi1 = StubPatinfo.new
		pi1.pointer = 'PatinfoPointer1'
		pi2 = StubPatinfo.new
		pi2.pointer = 'PatinfoPointer2'
		@app.update_results = { 
			'pi1'	=> pi1,
			'pi2'	=> pi2,
		}
		@plugin.update_registrations
		assert_equal(4, @app.update_pointers.size)
		creators = @app.update_pointers.select{ |item|
			item == pipointer.creator
		}
		assert_equal(2, creators.size)
		['pi1', 'pi2'].each { |expected|
			assert_equal(true, @app.update_values.include?(expected))
		}
		[
			'seq1_pointer',
			'seq2_pointer',
		].each { |expected|
			assert_equal(true, @app.update_pointers.include?(expected))
		}
		[
			'PatinfoPointer1',
			'PatinfoPointer2',
		].each { |expected|
			hash = { :patinfo => expected }
			assert_equal(true, @app.update_values.include?(hash))
		}
	end
	def test_update_registrations6
		seq1 = StubSequence.new
		seq2 = StubSequence.new
		seq3 = StubSequence.new
		seq1.name_base = "Batrafen"
		seq1.name_descr = "Puder"
		seq1.iksnr = "12345"
		seq2.name_base = "Batrafen"
		seq2.name_descr = "Crème"
		seq2.iksnr = "12345"
		seq3.name_base = "Aspirin"
		seq3.name_descr = "Tabletten"
		seq3.iksnr = "98765"
		reg1 = StubRegistration.new
		reg1.iksnr = '12345'
		reg1.pointer = 'Reg1Pointer'
		reg1.sequences = {
			'01'	=>	seq1,
			'02'	=>	seq2,
		}
		reg2 = StubRegistration.new
		reg2.iksnr = '98765'
		seq3.pointer = 'Seq3Pointer'
		reg2.sequences = {
			'01'	=>	seq3,
		}
		@app.registrations = {
			'12345'	=>	reg1,
			'98765'	=>	reg2,
		}
		@plugin.named_documents = {
			'Batrafen Puder'	=>	'fi1',
			'Batrafen Crème'	=>	'fi2',
			'Aspirin'					=>	'fi3',
		}
		pipointer = ODDB::Persistence::Pointer.new([:patinfo])
		pi = StubPatinfo.new
		pi.pointer = 'PatinfoPointer'
		@app.update_result = pi
		@plugin.error_documents = {
			'12345'	=>	["Schon vorhanden"]
		}
		@plugin.update_registrations
		expected = {
			'12345'	=>	[ 'Schon vorhanden', 'fi1', 'fi2' ],
		}
		assert_equal(expected, @plugin.error_documents)
		assert_equal(2, @app.update_pointers.size)
		pointer = ODDB::Persistence::Pointer.new(:patinfo)
		assert_equal(pointer.creator, @app.update_pointers.first)
		assert_equal('Seq3Pointer', @app.update_pointers.last)
		assert_equal('fi3', @app.update_values.first)
		assert_equal({:patinfo => 'PatinfoPointer'}, @app.update_values.last)
	end
	def test_store_orphaned
		key = 'theKey'
		meanings = ["the", "Meanings"]
		@plugin.store_orphaned(key, meanings, :ambiguous)
		assert_equal(1, @app.update_pointers.size)
		pointer = ODDB::Persistence::Pointer.new([:orphaned_patinfo])
		expected = {
			:reason => :ambiguous,
			:key	=>	key,
			:meanings =>	meanings,
		}
		assert_equal([pointer.creator], @app.update_pointers)
		assert_equal([expected], @app.update_values)
	end
	def test_store_orphaned_patinfos
		@plugin.error_documents = {
			"12345" => ["val"]
		}
		@plugin.orphaned_documents = {
			"12234" => "val2"
		}
		@plugin.store_orphaned_patinfos
		assert_equal(2, @app.update_pointers.size)
		pointer = ODDB::Persistence::Pointer.new([:orphaned_patinfo])
		expected1 = {
			:reason	=>	:ambiguous,
			:key		=>	'12345',
			:meanings =>	['val'],
		}
	
		expected2 = {
			:reason	=>	:orphan,
			:key		=>	'12234',
			:meanings =>	['val2'],
		}
		assert_equal(Array.new(2, pointer.creator), @app.update_pointers)
		assert_equal([expected1, expected2], @app.update_values)
	end
	def test_report
		pi1 = StubTextItem.new("Baldrian")
		pi2 = StubTextItem.new("Bachblüten")
		pi3 = StubTextItem.new("Placebo")
		pi4 = StubTextItem.new("Wasser")
		@plugin.error_documents = { 
			"12345"	=>	[
				{	"de"	=>	pi1 },
				{},
				{ "fr"	=>	pi2 },
			],
			nil			=>	[],
		}
		@plugin.orphaned_documents = {
			"Placebo"	=>	{	"de"	=>	pi3	},
			"Fujisawa"=>	pi4,
			nil				=>	nil,
		}
		result = nil
		assert_nothing_raised {
			result = @plugin.report
		}
	end
end
