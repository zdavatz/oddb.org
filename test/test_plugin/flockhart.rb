#!/usr/bin/env ruby
# TestFlockhartPlugin -- oddb -- 25.02.2004 -- maege@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'plugin/flockhart'
require 'util/html_parser'

module ODDB
	module Interaction
		class FlockhartPlugin < Plugin
			attr_reader :parsing_errors
			TARGET = File.expand_path('../../test/data/html/interaction/flockhart', File.dirname(__FILE__))
		end
		class FlockhartWriter < NullWriter
			attr_accessor :cytochromes, :category
			attr_accessor :tobecombined, :type
			attr_accessor :current_category
			attr_reader :current_table, :tablehandlers
			attr_reader :duplicates
		end
		class DetailWriter < NullWriter
			attr_reader :active_agents
		end
		class Cytochrome
			attr_reader :cyt_name
		end
	end
end

class TestFlockhartWriter < Test::Unit::TestCase
	def setup
		@writer = ODDB::Interaction::FlockhartWriter.new 
		@writer2 = ODDB::Interaction::FlockhartWriter.new 
		formatter = ODDB::Interaction::Formatter.new(@writer)
		parser = ODDB::Interaction::Parser.new(formatter)
		target = ODDB::Interaction::FlockhartPlugin::TARGET
		table = "prepared_table.htm"
		@html = File.read([target, table].join("/"))
		parser.feed(@html)
		@writer.cytochromes.store("8/cyto", ODDB::Interaction::Cytochrome.new('cyto'))
		@writer.cytochromes.store("9/3A5", ODDB::Interaction::Cytochrome.new('cyto'))
		@writer.cytochromes.store("9/3A7", ODDB::Interaction::Cytochrome.new('cyto'))
	end
	def test_check_string
		result = @writer2.check_string("test")
		assert_equal(true, result)
		result = @writer2.check_string("test\240test")
		assert_equal(false, result)
	end
	def test_check_string2
		result = @writer2.check_string("=foo")
		assert_equal(false, result)
		result = @writer2.check_string(">bar")
		assert_equal(false, result)
	end
	def test_check_string3
		result = @writer2.check_string("foobar => 5OH")
		assert_equal(true, result)
		result = @writer2.check_string("6OH")
		assert_equal(false, result)
		result = @writer2.check_string("3-OH")
		assert_equal(false, result)
	end
	def test_clear_string
		result = @writer2.clear_string("=foo\2402OH4-OH\240bar")
		assert_equal("foobar", result)
	end
	def test_create_update_objects
		@writer.type = 'inhibitors'
		@writer.create_update_objects('base_name', 'categ', 8, nil)
		cyt = @writer.cytochromes["8/cyto"]
		assert_equal(1, cyt.inhibitors.size)
		assert_equal('categ', cyt.inhibitors.first.category)
	end
	def test_create_update_objects2
		@writer.type = 'inducers'
		@writer.create_update_objects('base_name', nil, 8, nil)
		cyt = @writer.cytochromes["8/cyto"]
		assert_equal(1, cyt.inducers.size)
		assert_equal(nil, cyt.inducers.first.category)
	end
	def test_create_update_objects3
		@writer.type = 'inducers'
		@writer.create_update_objects('base_name', nil, 9, '3A5')
		cyt = @writer.cytochromes["9/3A5"]
		cyt2 = @writer.cytochromes["9/3A7"]
		assert_equal(0, cyt.inducers.size)
		assert_equal(1, cyt2.inducers.size)
	end
	def test_extract_data
		@writer.extract_data
		assert_equal(13, @writer.cytochromes.size)
	end
	def test_extract_data2
		@writer.extract_data
		result = @writer.cytochromes["2/2C8"].substrates
		assert_equal(5, result.size)
		result = @writer.cytochromes["2/2C8"].inducers
		assert_equal(1, result.size)
		expected = ODDB::Interaction::InducerConnection
		assert_equal(expected, result.first.class)
	end
	def test_extract_data3
		@writer.extract_data
		substrates = @writer.cytochromes["5/2D6"].substrates
		result = []
		substrates.each { |sub|
			result << sub if sub.category == 'antipsychotics'	
		}
		assert_equal(4, result.size)
	end
	def test_extract_data4
		@writer.extract_data
		substrates = @writer.cytochromes["0/1A2"].substrates
		substrates.each { |sub|
			@result = sub if sub.name_base==nil
		}
		assert_equal(23, substrates.size)
		substrates.each { |sub|
			@result = sub if sub.name_base.match(/phenacetin/)
		}
		expected = "phenacetin"
		assert_equal(expected, @result.name_base)
	end
	def test_new_fonthandler
		@writer2.category = "start"
		@writer2.new_fonthandler(nil)
		assert_equal(nil, @writer2.category)
		handler = ODDB::HtmlFontHandler.new(Hash["color","#FF0000"])
		@writer2.new_fonthandler(handler)
		assert_equal("start", @writer2.category)
	end
	def test_parse_array
		arr = ["one*/*/*two", "foo*/*/*bar", "asterix*/*/*obelix"]
		result = @writer2.parse_array(arr)
		expected = {
			"one"			=>	"two",
			"foo"			=>	"bar",
			"asterix"	=>	"obelix",
		}	
		assert_equal(expected, result)
	end
	def test_parse_cyt_string
		@writer2.parse_cyt_string("inhibitors@/@/@foo", 5)
		result = @writer2.cytochromes
		assert_equal(1, result.size)
		assert_equal('inhibitors', @writer2.type)
		@writer2.parse_cyt_string("inducers@/@/@bar", 6)
		result = @writer2.cytochromes
		assert_equal(2, result.size)
		assert_equal('inducers', @writer2.type)
		@writer2.parse_cyt_string("inhibitors@/@/@foo", 5)
		result = @writer2.cytochromes
		assert_equal(2, result.size)
	end
	def test_parse_cyt_string2
		@writer2.parse_cyt_string("inhibitors@/@/@3A4,5,7", 5)
		result = @writer2.cytochromes
		assert_equal(2, result.size)
		assert_equal('inhibitors', @writer2.type)
	end
	def test_parse_cyt_string3
		@writer2.parse_cyt_string("inhibitors@/@/@3A457", 5)
		result = @writer2.cytochromes
		assert_equal(2, result.size)
		assert_equal('inhibitors', @writer2.type)
		assert_equal("3A5-7", @writer2.cytochromes["5/3A5-7"].cyt_name)
	end
	def test_parse_string
		string = "foo*/*/*nil&/&/&bar*/*/*nil"
		result = @writer2.parse_string(string)
		expected = {
			"foo"	=> nil,
			"bar"	=> nil,
		}
		assert_equal(expected, result)
	end
	def test_parse_string2
		string = "foo*/*/*nil&/&/&bar-/-/-3A4*/*/*nil"
		result1 = @writer2.parse_string(string)
		result2 = @writer2.duplicates
		expected1 = {
			"bar-/-/-3A4"	=> nil,
		}
		expected2 = ["foo*/*/*nil"]
		assert_equal(expected1, result1)
		assert_equal(expected2, result2)
	end
	def test_send_flowing_data
		@writer.send_flowing_data(@html)
		#puts @writer.tablehandlers[0].inspect
	end
	def test_send_image
		@writer2.send_image('foo.jpg')
		assert_equal(nil, @writer2.current_table)
		@writer2.send_image('substrates.jpg')
		assert_equal("substrates", @writer2.current_table)
	end
	def test_write_substance_string
		result = @writer2.write_substance_string("instanz")
		expected = "instanz*/*/*nil&/&/&"
		assert_equal(expected, result)
	end
	def test_write_substance_strng2
		@writer2.current_category = "kat"
		result = @writer2.write_substance_string("instanz")
		expected = "instanz*/*/*kat&/&/&"
		assert_equal(expected, result)
	end
end
class TestDetailWriter < Test::Unit::TestCase
	def prepare_test(cytochrome)
		@writer = ODDB::Interaction::DetailWriter.new(cytochrome) 
		formatter = ODDB::HtmlFormatter.new(@writer)
		@parser = ODDB::HtmlParser.new(formatter)
		@target = ODDB::Interaction::FlockhartPlugin::TARGET
	end
	def test_send_flowing_data
		prepare_test("1a2")
		list = "1A2.htm"
		html = File.read([@target, list].join("/"))
		@parser.feed(html)
		result = []
		@writer.extract_data.substrates.each { |conn|
			result << conn
		}
		assert_equal(23, result.size)
	end
	def test_send_flowing_data2
		prepare_test("3a457")
		list = "3A457.htm"
		html = File.read([@target, list].join("/"))
		@parser.feed(html)
		result = []
		@writer.extract_data.substrates.each { |conn|
			result << conn
		}
		assert_equal(66, result.size)
		assert_equal("alfentanil", result.first.name_base)
	end
end
class TestTableLinksWriter < Test::Unit::TestCase
	def setup
		@writer = ODDB::Interaction::TableLinksWriter.new 
		formatter = ODDB::HtmlFormatter.new(@writer)
		parser = ODDB::HtmlParser.new(formatter)
		target = ODDB::Interaction::FlockhartPlugin::TARGET
		list = ODDB::Interaction::FlockhartPlugin::TABLE
		html = File.read([target, list].join("/"))
		parser.feed(html)
	end
	def test_extract_data
		expected = ODDB::Interaction::FlockhartPlugin::LINKS.sort
		@writer.extract_data
		assert_equal(expected, @writer.links.sort)
	end
end
class TestFlockhartPlugin < Test::Unit::TestCase
	class StubApp
		def initialize
		end
	end
	def setup
		app = StubApp.new
		@plugin = ODDB::Interaction::FlockhartPlugin.new(app, false)
	end
	def test_fetch_page
		#@plugin.fetch_page("table.htm")
	end
	def test_get_table_links
		@plugin.get_table_links
		assert_equal({}, @plugin.parsing_errors)
	end
	def test_parse_detail_pages
		result = @plugin.parse_detail_pages
		#assert_equal(10, result.keys.size)
		assert_equal(9, result.keys.size)
		assert_equal(23, result['1A2'].substrates.size)
	end
	def test_parse_table
		result = @plugin.parse_table
		assert_equal(10, result.size)
		assert_equal(23, result['1A2'].substrates.size)
	end
end
