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
			@result = sub if sub.name==nil
		}
		assert_equal(23, substrates.size)
		substrates.each { |sub|
			@result = sub if sub.name.match(/phenacetin/)
		}
		expected = "phenacetin"
		assert_equal(expected, @result.name)
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
		assert_equal(25, result.size)
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
    edge1 = result.first
		assert_equal "alfentanil", edge1.name
    assert_equal 1, edge1.links.size
    link = edge1.links.first
    assert_equal "Human alfentanil metabolism by cytochrome P450 3A3/4. An explanation for the interindividual variability in alfentanil clearance?", link.info
    assert_equal "Anesth Analg 1993;76:1033-1039", link.text
    assert_equal "http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=Retrieve&db=PubMed&list_uids=8484504&dopt=Abstract", link.href

    edge2 = result.at(40)
		assert_equal "methandone", edge2.name
    assert_equal 3, edge2.links.size
    link = edge2.links.last
    assert_equal "Involvement of cytochrome P450 3A4 enzyme in the N-demethylation of methadone in human liver microsomes", link.info
    assert_equal "Chem Res Toxicol 1996 Mar;9(2):365-373", link.text
    assert_equal "http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?db=PubMed&cmd=Retrieve&list_uids=8839037&dopt=Abstract", link.href

    edge3 = result.at(41)
		assert_equal "midazolam", edge3.name
    assert_equal 1, edge3.links.size
    link = edge3.links.first
    assert_equal "Regioselective biotransformation of midazolam by members of the human cytochrome P450 3A (CYP3A) subfamily.", link.info
    assert_equal "Biochem Pharmacol 1994;47(9):1643-1653", link.text
    assert_equal "http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?db=PubMed&cmd=Retrieve&list_uids=8185679&dopt=Abstract", link.href

    edge4 = result.at(42)
    assert_equal "nateglinide", edge4.name
    assert_equal 0, edge4.links.size

    edge4 = result.at(53)
    assert_equal "quetiapine", edge4.name
    assert_equal 1, edge4.links.size
    link = edge4.links.first
    assert_equal "Metabolic mechanism of quetiapine in vivo with clinical therapeutic dose.", link.info
    assert_equal "Methods Find Exp Clin Pharmacol. 2005 Mar;27(2):83-6.", link.text
    assert_equal "http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=Retrieve&db=pubmed&dopt=Abstract&list_uids=15834460&query_hl=2&itool=pubmed_docsum", link.href

    edge5 = result.at(56)
    assert_equal "risperidone", edge5.name
    assert_equal 1, edge5.links.size

    edge6 = result.at(66)
    assert_equal "tamoxifen", edge6.name
    assert_equal 1, edge6.links.size

    edge7 = result.at(67)
    assert_equal "taxol", edge7.name
    assert_equal 0, edge7.links.size

		assert_equal(78, result.size)
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
		assert_equal(25, result['1A2'].substrates.size)
	end
	def test_parse_table
		result = @plugin.parse_table
		assert_equal(10, result.size)
		assert_equal(56, result['1A2'].substrates.size)
	end
end
