#!/usr/bin/env ruby
# TestFlockhartPlugin -- oddb -- 25.02.2004 -- mhuggler@ywesee.com

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
			attr_accessor :current_category, :auc_factor
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
		table = "prepared_table.asp"
		@html = File.read([target, table].join("/"))
		parser.feed(@html)
		@writer.cytochromes.store("8/cyto", ODDB::Interaction::Cytochrome.new('cyto'))
		@writer.cytochromes.store("9/3A5", ODDB::Interaction::Cytochrome.new('cyto'))
		@writer.cytochromes.store("9/3A7", ODDB::Interaction::Cytochrome.new('cyto'))
	end
	def test_check_string
		result = @writer2.check_string("test")
		assert_equal(true, result)
		result = @writer2.check_string("test\302\240test")
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
		@writer.create_update_objects('base_name', {:category => 'categ'}, 8, nil)
		cyt = @writer.cytochromes["8/cyto"]
		assert_equal(1, cyt.inhibitors.size)
		assert_equal('categ', cyt.inhibitors.first.category)
	end
	def test_create_update_objects2
		@writer.type = 'inducers'
		@writer.create_update_objects('base_name', {}, 8, nil)
		cyt = @writer.cytochromes["8/cyto"]
		assert_equal(1, cyt.inducers.size)
		assert_equal(nil, cyt.inducers.first.category)
	end
	def test_create_update_objects3
		@writer.type = 'inducers'
		@writer.create_update_objects('base_name', {}, 9, '3A5')
		cyt = @writer.cytochromes["9/3A5"]
		cyt2 = @writer.cytochromes["9/3A7"]
		assert_equal(0, cyt.inducers.size)
		assert_equal(1, cyt2.inducers.size)
	end
	def test_extract_data
		@writer.extract_data
		assert_equal(12, @writer.cytochromes.size)
	end
	def test_extract_data2
		@writer.extract_data
		result = @writer.cytochromes["2/2C8"].substrates
		assert_equal(6, result.size)
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
		assert_equal(37, result.size)
	end
	def test_extract_data4
		@writer.extract_data
		substrates = @writer.cytochromes["0/1A2"].substrates
		substrates.each { |sub|
			@result = sub if sub.name==nil
		}
		assert_equal(24, substrates.size)
		substrates.each { |sub|
			@result = sub if sub.name.match(/phenacetin/)
		}
		expected = "phenacetin"
		assert_equal(expected, @result.name)
	end
	def test_new_fonthandler
		@writer2.category = "start"
		@writer2.new_font(nil)
		assert_equal(nil, @writer2.category)
		@writer2.new_font([0,0,1,0])
		assert_equal("start", @writer2.category)
	end
	def test_parse_array
		arr = ["one*/*/*two*/*/*3", "foo*/*/*bar*/*/*1.25", "asterix*/*/*obelix*/*/*1.75"]
		result = @writer2.parse_array(arr)
		expected = {
			"one"			=>	{:category => "two", :auc_factor => "3"},
			"foo"			=>	{:category => "bar", :auc_factor => "1.25"},
			"asterix"	=>	{:category => "obelix", :auc_factor => "1.75"},
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
		string = "foo*/*/**/*/*&/&/&bar*/*/**/*/*"
		result = @writer2.parse_string(string)
		expected = {
			"foo"	=> {:category => nil, :auc_factor => nil},
			"bar"	=> {:category => nil, :auc_factor => nil},
		}
		assert_equal(expected, result)
	end
	def test_parse_string2
		string = "foo*/*/*nil&/&/&bar-/-/-3A4*/*/*nil"
		result1 = @writer2.parse_string(string)
		result2 = @writer2.duplicates
		expected1 = {
			"bar-/-/-3A4"	=> {:auc_factor=>nil, :category=>"nil"},
		}
		expected2 = ["foo*/*/*nil"]
		assert_equal(expected1, result1)
		assert_equal(expected2, result2)
	end
	def test_send_image
		@writer2.send_image('red.jpg')
		assert_equal("5", @writer2.auc_factor)
	end
	def test_write_substance_string
		result = @writer2.write_substance_string("instanz")
		expected = "instanz*/*/**/*/*&/&/&"
		assert_equal(expected, result)
	end
	def test_write_substance_strng2
		@writer2.current_category = "kat"
		@writer2.auc_factor = "5"
		result = @writer2.write_substance_string("instanz")
		expected = "instanz*/*/*kat*/*/*5&/&/&"
		assert_equal(expected, result)
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
		assert_equal(24, result['1A2'].substrates.size)
		assert_equal(24, result['2D6'].inhibitors.size)
	end
	def test_parse_table
		result = @plugin.parse_table
		assert_equal(9, result.size)
		assert_equal(24, result['1A2'].substrates.size)
    inhs = result['1A2'].inhibitors
    assert_equal(9, inhs.size)
    inh = inhs.find { |i| i.name == 'fluvoxamine' }
    assert_equal("5", inh.auc_factor)
	end
	def test_parse_table__categories
		result = @plugin.parse_table
    subs = result['2C9'].substrates
    assert_equal(5, subs.collect { |sub| sub.category }.uniq.size)
	end
end
