#!/usr/bin/env ruby
# encoding: utf-8
# TestHayesPlugin -- oddb -- 25.02.2004 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'plugin/hayes'
require 'util/html_parser'

module ODDB
	module Interaction
		class HayesWriter < NullWriter
			attr_reader :cytochromes, :substances, :category
			attr_accessor :function, :function_one, :function_two
			attr_accessor :current_substance
			attr_reader :hr_row, :hr_function
			attr_reader :hs_substance, :hs_cyts
		end
		class HayesPlugin < Plugin
			TARGET = File.expand_path('../../test/data/html/interaction/hayes', File.dirname(__FILE__))
		end
	end
end

class TestHayesPlugin < Test::Unit::TestCase
	class StubApp
		def initialize
			@cytochromes = {}
		end
	end
	def setup
		app = StubApp.new
		@plugin = ODDB::Interaction::HayesPlugin.new(app)
	end
	def test_fetch_pages
		#@plugin.fetch_pages
	end
	def test_parse_substrate_table
		cytochromes = @plugin.parse_substrate_table
		result = []
		cytochromes['2B6'].substrates.each { |conn|
			result.push(conn.name)
		}
		expected = [
			"Bupropion",
			"Cyclophosphamide",
			"Efavirenz",
			"Ifosfamide",
			"Methadone",
			"Tamoxifen",
		]
		assert_equal(expected, result)
		assert_equal([], cytochromes['1A2'].inhibitors)
	end

	def test_parse_interaction_table2
		cytochromes = @plugin.parse_interaction_table
		result = []
		cytochromes['2C8'].inducers.each { |conn|
			result.push(conn.name)
		}
		expected = [
			"Phenobarbital", 
			"Primidone",
		]
		assert_equal(expected, result)
	end
end
class TestHayesWriter < Test::Unit::TestCase
	def setup
		@writer = ODDB::Interaction::HayesWriter.new
		formatter = ODDB::HtmlFormatter.new(@writer)
		parser = ODDB::HtmlParser.new(formatter)
		target = ODDB::Interaction::HayesPlugin::TARGET
		table = "CYP450-1.html"
		@html = File.read([target, table].join("/"))
		parser.feed(@html)
	end
	def test_second_hayes_file
		writer = ODDB::Interaction::HayesWriter.new
		formatter = ODDB::HtmlFormatter.new(writer)
		parser = ODDB::HtmlParser.new(formatter)
		target = ODDB::Interaction::HayesPlugin::TARGET
		table = "CYP450-2.html"
		html = File.read([target, table].join("/"))
		parser.feed(html)
		cytochromes = writer.extract_data
		#assert_equal(13, cytochromes.size)
		assert_equal(11, cytochromes.size)
		result = cytochromes["2C19"].inhibitors.size
		assert_equal(19, result)
		result = cytochromes["2C19"].inducers.size
		assert_equal(5, result)
	end
	def test_check_cytochrome
		result = @writer.check_cytochrome("3A4")
		assert_equal(["3A4"], result)	
		result = @writer.check_cytochrome("2C19")
		assert_equal(["2C19"], result)	
		result = @writer.check_cytochrome("3A5-8")
		#expected = [ "3A5", "3A6", "3A7", "3A8" ]
		expected = ["3A5-8"]
		assert_equal(expected, result)	
	end
	def test_check_string
		result = @writer.check_string("foobar")
		assert_equal(true, result)
		result = @writer.check_string([])
		assert_equal(false, result)
	end
	def test_create_connection
		obj = @writer.create_connection("suBstanCe", "inhibits")
		expected = ODDB::Interaction::InhibitorConnection 
		assert_equal(expected, obj.class)
		assert_equal("suBstanCe", obj.name)
	end
	def test_handle_cytochrome
		obj = ODDB::Interaction::InhibitorConnection.new("suBstanCe", 'en')
		obj_two = ODDB::Interaction::InhibitorConnection.new("SubStanCeTwo", "en")
		@writer.handle_cytochrome(["3A5", "3A6"], obj)
		assert_equal(2, @writer.cytochromes.size)
		result = @writer.cytochromes["3A5"].inhibitors.first
		assert_equal(obj, result)
		@writer.handle_cytochrome(["3A5"], obj_two)
		assert_equal(2, @writer.cytochromes.size)
		result = @writer.cytochromes["3A5"].inhibitors.size
		assert_equal(2, result)
		result = @writer.cytochromes["3A5"].inhibitors
		assert_equal([obj, obj_two], result)
	end
	def test_handle_functions
		begin
			@writer.instance_eval <<-EOS
				alias :original_handle_substance :handle_substance
				alias :original_handle_row :handle_row
				def handle_row(row, function)
					@hr_row = row
					@hr_function = function
					"3A5"
				end
				def handle_substance(substance, cyts)
					@hs_substance = substance
					@hs_cyts = cyts
				end
			EOS
			@writer.current_substance = "SUBstanCe"
			@writer.function = "substrate"
			@writer.handle_functions("foo", nil)
			assert_equal("foo", @writer.hr_row)
			assert_equal("substrate", @writer.hr_function)
			assert_equal("SUBstanCe", @writer.hs_substance)
			assert_equal(["3A5"], @writer.hs_cyts)
		ensure
			@writer.instance_eval <<-EOS
				alias :handle_substance :original_handle_substance
				alias :handle_row :original_handle_row
			EOS
		end
	end
	def test_handle_functions2
		begin
			@writer.instance_eval <<-EOS
				alias :original_handle_substance :handle_substance
				alias :original_handle_row :handle_row
				def handle_row(row, function)
					if(@hr_row)
						@hr_row << row
					else
						@hr_row = row
					end	
					if(@hr_function)
						@hr_function << function
					else
						@hr_function = function
					end	
					"3A5"
				end
				def handle_substance(substance, cyts)
					@hs_substance = substance
					@hs_cyts = cyts
				end
			EOS
			@writer.current_substance = "subSTANCE"
			@writer.function_one = "inhibits"
			@writer.function_two = "induces"
			@writer.handle_functions("foo", "bar")
			assert_equal("foobar", @writer.hr_row)
			assert_equal("inhibitsinduces", @writer.hr_function)
			assert_equal("subSTANCE", @writer.hs_substance)
			assert_equal(["3A5", "3A5"], @writer.hs_cyts)
		ensure
			@writer.instance_eval <<-EOS
				alias :handle_substance :original_handle_substance
				alias :handle_row :original_handle_row
			EOS
		end
	end
	def test_handle_functions3
		begin
			@writer.instance_eval <<-EOS
				alias :original_handle_substance :handle_substance
				alias :original_handle_row :handle_row
				def handle_row(row, function)
					if(@hr_row)
						@hr_row << row
					else
						@hr_row = row
					end	
					if(@hr_function)
						@hr_function << function
					else
						@hr_function = function
					end	
					"3A5"
				end
				def handle_substance(substance, cyts)
					@hs_substance = substance
					@hs_cyts = cyts
				end
			EOS
			@writer.current_substance = "subSTANCE"
			@writer.function_one = "inhibits"
			@writer.function_two = "induces"
			@writer.handle_functions("foo", nil)
			assert_equal("foo", @writer.hr_row)
			assert_equal("inhibits", @writer.hr_function)
			assert_equal("subSTANCE", @writer.hs_substance)
			assert_equal(["3A5"], @writer.hs_cyts)
		ensure
			@writer.instance_eval <<-EOS
				alias :handle_substance :original_handle_substance
				alias :handle_row :original_handle_row
			EOS
		end
	end
	def test_handle_row
		result = @writer.handle_row("ROU", "funk-zion")
		expected = {
			"ROU"	=>	"funk-zion",
		}
		assert_equal(expected, result)
		result = @writer.handle_row(["ROU", "rou"], "funk-zion")
		expected = {
			"ROU"	=>	"funk-zion",
			"rou"	=>	"funk-zion",
		}
		assert_equal(expected, result)
	end
	def test_new_fonthandler
		handler = ODDB::HtmlFontHandler.new(Hash["color","#000080"])
		@writer.new_fonthandler(handler)
		assert_equal("start", @writer.category)
		handler = ODDB::HtmlFontHandler.new(Hash["color","Red"])
		@writer.new_fonthandler(handler)
		assert_equal(nil, @writer.category)
		handler = ODDB::HtmlFontHandler.new(Hash["color","Blue"])
		@writer.new_fonthandler(handler)
		assert_equal("start", @writer.category)
	end
	def test_send_flowing_data
		#@writer.send_flowing_data(@html)
		#puts @writer.tablehandlers[0].inspect
	end
	def test_parse_substance
		writer = ODDB::Interaction::HayesWriter.new
		formatter = ODDB::HtmlFormatter.new(writer)
		parser = ODDB::HtmlParser.new(formatter)
		target = ODDB::Interaction::HayesPlugin::TARGET
		table = "custom_table-1.html"
		html = File.read([target, table].join("/"))
		parser.feed(html)
		writer.parse_substances
		assert_equal(4, writer.cytochromes.size)
		result = writer.cytochromes["1A1"].substrates.first
		expected = ODDB::Interaction::SubstrateConnection
		assert_equal(expected, result.class)
		assert_equal("SubStanzOne", result.name)
		result = writer.cytochromes["1A2"].substrates
		assert_equal(2, result.size)
		subs = []
		result.each do |sub|; subs.push sub.name; end
		expected = ["SubStanzOne", "SubStanzTwo"]
		assert_equal(expected, subs)
	end
	def test_parse_substance2
		writer = ODDB::Interaction::HayesWriter.new
		formatter = ODDB::HtmlFormatter.new(writer)
		parser = ODDB::HtmlParser.new(formatter)
		target = ODDB::Interaction::HayesPlugin::TARGET
		table = "custom_table-2.html"
		html = File.read([target, table].join("/"))
		parser.feed(html)
		writer.parse_substances
		assert_equal(5, writer.cytochromes.size)
		result = writer.cytochromes["1A6"].inducers.first
		expected = ODDB::Interaction::InducerConnection
		assert_equal(expected, result.class)
		assert_equal("SubStanzTwo", result.name)
		result = writer.cytochromes["1A2"].inhibitors
		assert_equal(2, result.size)
		subs = []
		result.each do |sub|; subs.push sub.name; end
		expected = ["SubStanzOne", "SubStanzThree"]
		assert_equal(expected, subs)
	end
end
