#!/usr/bin/env ruby
# TestLimitationPlugin -- oddb -- 05.11.2003 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'plugin/limitation'
require 'model/slentry'

module ODDB
	class LimitationResult
		attr_accessor :par_count
	end
	class GeneralLimitationResult
		ACCEPTABLE_LINKS = [ '33.html', 'twogenerallimok.htm' ]
	end
	class LimitationPlugin < Plugin
		attr_accessor :index_path_called, :parse_index_data_called
		attr_accessor	:parse_sequence_data_called, :indices
		attr_accessor	:update_packages_called, :lim_texts
		attr_accessor :updated_packages, :parsing_errors
		RANGE = ('A'..'B').to_a
	end
	class LimitationIndexWriter < NullWriter
		attr_accessor :linkhandlers, :current_linkhandler
	end
	class LimitationSequenceWriter < NullWriter
		attr_reader :get_limitations_called, :handle_data_called
		attr_reader :values, :key, :key_arr, :values_arr
	end
	class HtmlLimitationHandler
		attr_reader :rows
	end
	module Persistence
		class Pointer
			attr_reader :directions
		end
	end
end

class TestGeneralLimitationResult < Test::Unit::TestCase
	def test_acceptable
		result1 = ODDB::GeneralLimitationResult.new('12', 'de', 1)
		result1.link = '55.html'
		result2 = ODDB::GeneralLimitationResult.new('12', 'de', 2)
		result2.link = '33.html'
		result3 = ODDB::GeneralLimitationResult.new('12', 'de', 2)
		result3.link = '55.html'
		res1 = result1.acceptable?
		res2 = result2.acceptable?
		res3 = result3.acceptable?
		assert_equal(true, res1)
		assert_equal(true, res2)
		assert_equal(false, res3)
	end
end
class TestLimitationIndexWriter < Test::Unit::TestCase
	class StubHtmlLinkHandler
		attr_reader :send_adata_called
		def initialize
			@send_adata_called = false
		end
		def send_adata(*args)
			@send_adata_called = true
		end
	end
	def setup
		path = File.expand_path('../data/html/limitation/links.html', File.dirname(__FILE__))
		html = File.read(path)
		@writer = ODDB::LimitationIndexWriter.new
		formatter = ODDB::HtmlFormatter.new(@writer)
		parser = ODDB::HtmlParser.new(formatter)
		parser.feed(html)
	end
	def test_extract_data
		expected = [
			'link1.html',
			'http://www.link2.htm',
		]
		result = []
		data = @writer.extract_data	
		assert_equal(expected, @writer.collected_values)
	end
	def test_new_linkhandler
		@writer.linkhandlers = ['foo', 'bar'] 
		expected = ['foo', 'bar', 'foobar']
		result = @writer.new_linkhandler('foobar') 
		assert_equal(expected, result) 
		expected = @writer.linkhandlers.last
		result = @writer.current_linkhandler
		assert_equal(expected, result) 
	end
	def test_send_flowing_data
		handler = StubHtmlLinkHandler.new
		@writer.send_flowing_data(nil)
		assert_equal(false, handler.send_adata_called)
		@writer.current_linkhandler = handler 
		@writer.send_flowing_data(nil)
		assert_equal(true, handler.send_adata_called)
	end
end
class TestLimitationSequenceWriter < Test::Unit::TestCase
	def setup
		path = File.expand_path('../data/html/limitation/5754.htm', File.dirname(__FILE__))
		html = File.read(path)
		@writer = ODDB::LimitationSequenceWriter.new
		formatter = ODDB::HtmlFormatter.new(@writer)
		parser = ODDB::HtmlParser.new(formatter)
		parser.feed(html)
	end
	def test_get_limitations
		limitations = @writer.get_limitations
		assert_equal(11, limitations.size)
		expected = [
			"[55725 004] (259 13 01)",
			"[55725 008] (259 13 18)",
			"[55725 012] (259 13 24)",
			"[55725 016] (259 13 30)",
			"[55725 020] (259 13 47)",
			"[55725 024] (259 13 53)",
			"[55725 028] (259 13 76)",
			"[55725 032] (259 13 82)",
			"[55725 036] (259 13 99)",
			"[55725 040] (259 14 07)",
			"[55725 042] (267 33 70)",
		]
		@values = []
		limitations = @writer.get_limitations
		limitations.each { |lh|
			lh.rows.each { |rw|
				@values << rw.cdata(5)
			}
		}
		assert_equal(expected, @values.compact)
	end
	def test_get_limitations2
		path = File.expand_path('../data/html/limitation/5569.htm', File.dirname(__FILE__))
		html = File.read(path)
		writer = ODDB::LimitationSequenceWriter.new
		formatter = ODDB::HtmlFormatter.new(writer)
		parser = ODDB::HtmlParser.new(formatter)
		parser.feed(html)
		limitations = writer.get_limitations
		assert_equal(3, limitations.size)
		expected = [
			"[55378 001] (229 39 28)",
			"[55378 005] (229 39 34)",
			"[55378 007] (229 39 40)",
			"[55378 011] (229 39 57)",
			"[55378 013] (229 39 63)",
			"[55378 017] (229 39 86)",
		]
		key_values = []
		limitations = writer.get_limitations
		limitations.each { |lh|
			lh.rows.each { |rw|
				key_values << rw.cdata(5)
			}
		}
		assert_equal(expected, key_values.compact)
	end
	def test_get_limitations3
		path = File.expand_path('../data/html/limitation/limandere.htm', File.dirname(__FILE__))
		html = File.read(path)
		writer = ODDB::LimitationSequenceWriter.new
		formatter = ODDB::HtmlFormatter.new(writer)
		parser = ODDB::HtmlParser.new(formatter)
		parser.feed(html)
		limitations = writer.get_limitations
		puts limitations.inspect
		assert_equal(1, limitations.size)
		expected = [
			"[55453 004] (250 19 01)",
		]
		key_values = []
		limitations = writer.get_limitations
		limitations.each { |lh|
			lh.rows.each { |rw|
				key_values << rw.cdata(5)
			}
		}
		assert_equal(expected, key_values.compact)
	end
	def test_extract_data
		begin
			@writer.instance_eval <<-EOS
				alias :original_get_limitations :get_limitations
				alias :original_handle_data :handle_data
				def get_limitations
					@get_limitations_called = true
					[]
				end
				def handle_data(*args)
					@handle_data_called = true
				end
			EOS
			@writer.extract_data
			assert_equal(true, @writer.get_limitations_called)
			assert_equal(nil, @writer.handle_data_called)
		ensure
			@writer.instance_eval <<-EOS
				alias :handle_data :original_handle_data
				alias :get_limitations :original_get_limitations
			EOS
		end
	end
	def test_extract_data2
		begin
			@writer.instance_eval <<-EOS
				alias :original_handle_data :handle_data
				def handle_data(*args)
					@handle_data_called = true
					['a', 'b']
				end
			EOS
			@writer.extract_data
			assert_equal(true, @writer.handle_data_called)
		ensure
			@writer.instance_eval <<-EOS
				alias :handle_data :original_handle_data
			EOS
		end
	end
	def test_extract_data3
		begin
			@writer.instance_eval <<-EOS
				alias :original_handle_data :handle_data
				def handle_data(key, values)
					@key = key
					@values = values
				end
			EOS
			@writer.extract_data
			expected = [
				"Anémie rénale lors d'une insuffisance rénale.",
				"Traitement de l'anémie symptomatique (Hb < 10,5 g/dl) chez les patients adultes atteints de tumeurs solides, pressentis pour une chimiothérapie pendant une durée minimum de deux mois.",
			]
			result = []
			@writer.values.each { |arr|
				result << arr[1]
			}
			assert_equal(expected, result)
		ensure
			@writer.instance_eval <<-EOS
				alias :handle_data :original_handle_data
			EOS
		end
	end
	def test_extract_data4
		begin
			@writer.instance_eval <<-EOS
				alias :original_handle_data :handle_data
				def handle_data(key, values)
					@key = key
					@values = values
				end
			EOS
			@writer.extract_data
			expected = '[55725 042] (267 33 70)'
			assert_equal(expected, @writer.key)
		ensure
			@writer.instance_eval <<-EOS
				alias :handle_data :original_handle_data
			EOS
		end
	end
	def test_extract_data5
		path = File.expand_path('../data/html/limitation/4940.htm', File.dirname(__FILE__))
		html = File.read(path)
		writer = ODDB::LimitationSequenceWriter.new
		formatter = ODDB::HtmlFormatter.new(writer)
		parser = ODDB::HtmlParser.new(formatter)
		parser.feed(html)
		begin
			writer.instance_eval <<-EOS
				alias :original_handle_data :handle_data
				def handle_data(key, values)
					@key = key
					@values = values
					[key, values]
				end
			EOS
			writer.extract_data
			expected = '[54157 096] (215 14 24)'
			assert_equal(expected, writer.key)
			expected = "Limitatio: Behandlung von akutem Erbrechen bei stark emetogener Chemotherapie, maximal während 3 Tagen."
			assert_equal(expected, writer.values.first[0])
		ensure
			writer.instance_eval <<-EOS
				alias :handle_data :original_handle_data
			EOS
		end
	end
	def test_extract_data6
		path = File.expand_path('../data/html/limitation/twopackonelim.htm', File.dirname(__FILE__))
		html = File.read(path)
		writer = ODDB::LimitationSequenceWriter.new
		formatter = ODDB::HtmlFormatter.new(writer)
		parser = ODDB::HtmlParser.new(formatter)
		parser.feed(html)
		begin
			writer.instance_eval <<-EOS
				alias :original_handle_data :handle_data
				def handle_data(key, values)
					@key_arr ||= []
					@values_arr ||= []
					@key_arr << key
					@values_arr << values
					[key, values]
				end
			EOS
			result = writer.extract_data
			expected = [
				"[55725 004] (259 13 01)", 
				"[55725 008] (259 13 18)",
			]
			assert_equal(expected, writer.key_arr)
			expected = [
				[
					"Limitatio: de_twopackonelim1", 
					"fr_twopackonelim1", 
					"it_twopackonelim1"
				], 
				[
					"Limitatio: de_twopackonelim2",	
					"fr_twopackonelim2", 
					"it_twopackonelim2"
				],
			]
			assert_equal(expected, writer.values_arr[1])
			expected = ODDB::LimitationResult	
			assert_equal(expected, result.first.class)
		ensure
			writer.instance_eval <<-EOS
				alias :handle_data :original_handle_data
			EOS
		end
	end
	def test_extract_data7
		path = File.expand_path('../data/html/limitation/twogenerallim.htm', File.dirname(__FILE__))
		html = File.read(path)
		writer = ODDB::LimitationSequenceWriter.new
		formatter = ODDB::HtmlFormatter.new(writer)
		parser = ODDB::HtmlParser.new(formatter)
		parser.feed(html)
		result = writer.extract_data
		expected = ODDB::GeneralLimitationResult
		assert_equal(expected, result.first.class)
		assert_equal(2, result.first.par_count)
	end
	def test_extract_data8
		path = File.expand_path('../data/html/limitation/onlytwolang.htm', File.dirname(__FILE__))
		html = File.read(path)
		writer = ODDB::LimitationSequenceWriter.new
		formatter = ODDB::HtmlFormatter.new(writer)
		parser = ODDB::HtmlParser.new(formatter)
		parser.feed(html)
		result = writer.extract_data
		expected = ODDB::GeneralLimitationResult
		assert_equal(expected, result.first.class)
		assert_equal(1, result.first.par_count)
		res = result.first.languages["de"].to_s
		assert_equal("lim1_de", res)
		res = result.first.languages["it"].to_s
		assert_equal("", res)
		res = result.first.languages["fr"].to_s
		puts res.inspect
		assert_equal("lim1_fr", res)
	end
	def test_handle_data
		values	= [
			[
				"Limitatio: de_foo",
				"fr_fèà",
				"it_foo",
			],
			[
				"Limitatio: de_bar",
				"fr_bar",
				"it_bar",
			],
		]	
		expected = [
			"it_foo",
			"it_bar",
			"fr_fèà",
			"fr_bar",
			"de_foo",
			"de_bar",
		]
		result = []
		arr = @writer.handle_data('[55725 042] (267 33 70)', values)
		arr[1].values.each { |chap|
			chap.sections.each { |sect|
				sect.paragraphs.each { |par|
					result << par.text
				}
			}
		}
		assert_equal(expected, result)
		assert_equal(['55725','042'], arr[0])
	end
	def test_parse_limitatio
		path = File.expand_path('../data/html/limitation/4940.htm', File.dirname(__FILE__))
		html = File.read(path)
		writer = ODDB::LimitationSequenceWriter.new
		formatter = ODDB::HtmlFormatter.new(writer)
		parser = ODDB::HtmlParser.new(formatter)
		parser.feed(html)
		expected = "Traitement des vomissements aigus du à une chimiothérapie avec effet hautement émétisant, durant trois jours maximum."
		result = writer.parse_limitatio.first[1]
		assert_equal(expected, result)
	end
	def test_parse_limitatio2
		path = File.expand_path('../data/html/limitation/twogenerallim.htm', File.dirname(__FILE__))
		html = File.read(path)
		writer = ODDB::LimitationSequenceWriter.new
		formatter = ODDB::HtmlFormatter.new(writer)
		parser = ODDB::HtmlParser.new(formatter)
		parser.feed(html)
		result = writer.parse_limitatio
		assert_equal('Limitatio: lim2_de', result[1].first)
	end
end
class TestLimitationPlugin < Test::Unit::TestCase
	class StubApp
		attr_accessor :packages, :registrations
		attr_reader :iksnrs, :ikscds, :update_pointer 
		attr_reader	:update_values, :delete_pointer
		attr_reader :update_limitation
		def initialize
			@iksnrs = []
			@ikscds = []
		end
		def each_package(&block)
			@packages.each(&block)
		end
		def registration(iksnr)
			@iksnrs << iksnr	
			self
		end
		def package(ikscd)
			@ikscds << ikscd
			@packages[0]
		end	
		def update(pointer, values)
			if(values.keys.include?(:limitation))
				@update_limitation = values	
			end
			@update_pointer = pointer
			@update_values = values
		end
		def delete(pointer)
			@delete_pointer = pointer
		end
	end
	class StubPackage
		attr_accessor :sequence, :pointer
		attr_reader :sl_entry, :languages
		def initialize
			@languages = []
		end
		def create_sl_entry
			@sl_entry = StubSlEntry.new
		end
		def ikskey
			'55725042'
		end
		def pointer
			@pointer ||= ODDB::Persistence::Pointer.new
		end
		def set_limitation
			@sl_entry = StubSlEntry.new
			@sl_entry.set_limitation_true
		end
		def set_sequence(name_base)
			seq = sequence()
			seq.name_base = name_base
		end
		def name_base
			@sequence.name_base
		end
		def sequence
			@sequence ||= StubSequence.new
		end
	end
	class StubSequence
		attr_accessor :name_base
	end
	class StubLimText
		attr_accessor :pointer
	end
	class StubSlEntry
		attr_accessor :limitation, :pointer
		attr_reader :limitation_text
		def set_limitation_true
			@limitation = true
		end
		def set_limitation_text
			@limitation_text = StubLimText.new
			@limitation_text.pointer = 'limited'
		end
	end
	def setup
		pack1 = StubPackage.new
		pack1.create_sl_entry
		@pack2 = StubPackage.new
		@pack2.set_limitation
		@pack2.set_sequence('Aranesp')
		@pack3 = StubPackage.new
		@pack3.set_limitation
		@pack3.set_sequence('Ancopir')
		pack4 = StubPackage.new
		@app = StubApp.new
		@app.packages = [pack1, @pack2, @pack3, pack4]
		@plugin = ODDB::LimitationPlugin.new(@app)
		@plugin.indices = [ 
				'Bb',
				'5754.htm',
				'Bar',
		]
		path = File.expand_path('../data/html/limitation/5754.htm', 
			File.dirname(__FILE__))
		file = File.open(path)
		lines = []
		file.each_line { |line| 
			lines << line
		}
		@html_5754 = lines.join(" ")
	end
	def test_collect_parsed_indices
		@plugin.indices = []
		begin
			dir = File.expand_path('../data/html/limitation/',
				File.dirname(__FILE__))
			@plugin.instance_eval <<-EOS
				alias :original_index_data_body :index_data_body
				def index_data_body(letter)
					@letter = letter
					file = "Index_" + letter + ".htm"
					path = File.expand_path(file, '#{dir}')
					html = File.read(path)
				end
			EOS
			data = @plugin.collect_parsed_indices
			expected = [
				'1263.htm', 
				'5754.htm',
				'327.htm',
			]
			result = @plugin.indices
			assert_equal(result, expected)
		ensure
			@plugin.instance_eval <<-EOS
				alias :index_data_body :original_index_data_body
			EOS
		end
	end
	def test_index_data
		begin
			@plugin.instance_eval <<-EOS
				alias :original_parse_index_data :parse_index_data
				def parse_index_data(body)
					@parse_index_data_called = true
				end
			EOS
			@plugin.index_data('A')
			assert_equal(true, @plugin.parse_index_data_called)
		ensure
			@plugin.instance_eval <<-EOS
				alias :parse_index_data :original_parse_index_data
			EOS
		end
	end
	def test_index_data_body
		expressions = []
		expressions.push(/\<html\>\<head\>\<link rel=\"stylesheet\" href=\"sl2style.css\" type=\"text\/css\"\>\<\/head\>\<body bgcolor=\"#FFFFFF\"\>\<font face=\"Arial\"\>/)
		expressions.push(/\<p id=SL2ALPHT\>Alphabetisches Register - Répértoire alphabetique\<\/p\>/)
		expressions.push(/\<p id=SL2ALPHL>A\<\/p>/)
		expressions.push(/\<p id=SL2ALPH\>\<a href=\"1263.htm\"\>A.T. 10\<\/a\>\<\/p\>/)
		expressions.each { |exp|
			assert(exp.match(@plugin.index_data_body('A')), 'Structure of the the online html-page has changed!')
		}
	end
	def test_index_data_path
		begin
			@plugin.instance_eval <<-EOS
				alias :original_index_data_path :index_data_path
				def index_data_path(letter)
					@index_path_called = true
				end
			EOS
			@plugin.index_data_path(nil)
			assert_equal(true, @plugin.index_path_called)
		ensure
			@plugin.instance_eval <<-EOS
				alias :index_data_path :original_index_data_path
			EOS
		end
	end
	def test_index_path
		result = @plugin.index_path({'Index'=>'B'})
		expected = '/sl/batchhtm/Index_B.htm'
		assert_equal(expected, result)
	end
	def test_sequence_data
		begin
			@plugin.instance_eval <<-EOS
				alias :original_parse_sequence_data :parse_sequence_data
				def parse_sequence_data(body, link)
					@parse_sequence_data_called = true
				end
			EOS
			@plugin.sequence_data('5754.htm')
			assert_equal(true, @plugin.parse_sequence_data_called)
		ensure
			@plugin.instance_eval <<-EOS
				alias :parse_sequence_data :original_parse_sequence_data
			EOS
		end
	end
	def test_sequence_data2
		begin
			@plugin.instance_eval <<-EOS
				alias :original_parse_sequence_data :parse_sequence_data
				def parse_sequence_data(body, link)
					@parse_sequence_data_called = true
				end
			EOS
			@plugin.sequence_data('nosite.htm')
			assert_equal(nil, @plugin.parse_sequence_data_called)
		ensure
			@plugin.instance_eval <<-EOS
				alias :parse_sequence_data :original_parse_sequence_data
			EOS
		end
	end
	def test_sequence_data3
		begin
			@plugin.instance_eval <<-EOS
				alias :original_parse_sequence_data :parse_sequence_data
				def parse_sequence_data(body)
					@parse_sequence_data_called = true
				end
			EOS
			@plugin.sequence_data('http://nosite.htm')
			assert_equal(nil, @plugin.parse_sequence_data_called)
		ensure
			@plugin.instance_eval <<-EOS
				alias :parse_sequence_data :original_parse_sequence_data
			EOS
		end
	end
	def test_sequence_data_body
		expressions = []
		expressions.push(/\<html\>\<head\>\<link rel=\"stylesheet\" href=\"sl2style.css\" type=\"text\/css\"\>\<\/head\>\<body bgcolor=\"#FFFFFF\"\>\<font face=\"Arial\"\>/)
		expressions.push(/\<table id=SL2ITTAB width=\"100%\"\>/)
		expressions.push(/\<tr\>\<td width=\"15%\"\>\<\/td\>\<td id=SL2PRNAME width=\"35%\"\>Aranesp\<\/td\>\<td id=SL2PARTN width=\"49%\"\>\<A HREF=\"PRT487.HTM\"\>AMGEN SWITZERLAND AG\<\/A\>\<\/td\>\<td width=\"1%\"\>\<\/td\>\<\/tr\>\<\/table\>/)
		expressions.push(//)
		expressions.each { |exp|
			assert(exp.match(@plugin.sequence_data_body('5754.htm')), 'Structure of the the online html-page has changed!')
		}
	end
	def test_sequence_data_path
		result = @plugin.sequence_data_path('5754.htm')
		expected = '/sl/batchhtm/5754.htm' 
		assert_equal(expected, result)
	end
	def test_parse_index_data
		path = File.expand_path('../data/html/limitation/index.htm', File.dirname(__FILE__))
		html = File.read(path)
		result = @plugin.parse_index_data(html)
		expected = [
			'1263.htm',	
			'2774.htm',
			'5711.htm',
			'3877.htm',
			'3321.htm',
		]
		assert_equal(expected, result)
	end
	def test_parse_sequence_data
		path = File.expand_path('../data/html/limitation/5754_small.htm', File.dirname(__FILE__))
		html = File.read(path)
		result = []
		@plugin.parse_sequence_data(html, '5754_small.htm')
		@plugin.parse_sequence_data(html, '5754_small.htm').values.each { |hash|
			result << hash.keys
		}
		expected = [['it','fr','de'],['it','fr','de']] 
		assert_equal(expected, result)
		expected = {}
		result = @plugin.parsing_errors
		assert_equal(expected, result)
	end
	def test_parse_sequence_data2
		path = File.expand_path('../data/html/limitation/5754_small.htm', File.dirname(__FILE__))
		html = File.read(path)
		result = [] 
		@plugin.parse_sequence_data(html, '5754_small.htm').values.each { |hash|
			hash.values.each { |chap|
				result << chap.sections[0].paragraphs[0].text
			}
		}
		expected = [
			"Anemia renale nel caso di un'insufficienza renale.", 
			"Anémie rénale lors d'une insuffisance rénale.", 
			"Renale Anämie bei Niereninsuffizienz."
		]
		assert_equal(expected, result[0,3])
	end
	def test_parse_sequence_data3
		path = File.expand_path('../data/html/limitation/twogenerallim.htm', File.dirname(__FILE__))
		html = File.read(path)
		result = @plugin.parse_sequence_data(html, 'twogenerallim.htm')
		expected = {}
		assert_equal(expected, result)
		assert_equal(['twogenerallim.htm'], @plugin.parsing_errors.keys)
	end
	def test_parse_sequence_data4
		path = File.expand_path('../data/html/limitation/twogenerallimok.htm', File.dirname(__FILE__))
		html = File.read(path)
		result = @plugin.parse_sequence_data(html, 'twogenerallimok.htm')
		assert_equal([["55763", "004"]], result.keys)
		assert_equal([], @plugin.parsing_errors.keys)
	end
	def test_purge_limitation_texts
		@pack2.sl_entry.pointer = ODDB::Persistence::Pointer.new
		@app.packages = [@pack2, @pack3]
		data_hsh = @plugin.sequence_data('5754.htm')	
		@plugin.update_packages(data_hsh)
		@plugin.purge_limitation_texts
		expected = nil
		result = @app.delete_pointer
		assert_equal(expected, result)
	end
	def test_purge_limitation_texts2
		@pack2.sl_entry.pointer = ODDB::Persistence::Pointer.new
		@pack2.sl_entry.set_limitation_text
		@app.packages = [@pack2, @pack3]
		data_hsh = @plugin.sequence_data('5754.htm')	
		@plugin.update_packages(data_hsh)
		@plugin.updated_packages = []
		@plugin.purge_limitation_texts
		#expected = ODDB::Persistence::Pointer
		assert_equal('limited', @app.delete_pointer)
		#expected = :limitation_text
		#result = @app.delete_pointer.directions.flatten[0]
		#assert_equal(expected, result)
	end
	def test_update
		#@plugin.update
	end
	def test_check_data
		begin
			@plugin.instance_eval <<-EOS
				alias :original_update_packages :update_packages
				def update_packages(pack)
					@update_packages_called = true
				end
			EOS
			@plugin.check_data({})
			assert_equal(nil, @plugin.update_packages_called)
			@plugin.check_data(nil)
			assert_equal(nil, @plugin.update_packages_called)
			@plugin.check_data({'a'=>'b'})
			assert_equal(true, @plugin.update_packages_called)
		ensure
			@plugin.instance_eval <<-EOS
				alias :update_packages :original_update_packages
			EOS
		end
	end	
	def test_update_packages
		@app.packages = [@pack2]
		data_hsh = @plugin.parse_sequence_data(@html_5754, '5754.htm')	
		@plugin.update_packages(data_hsh)
		expected = ODDB::Persistence::Pointer
		assert_equal(expected, @app.update_pointer.class)
		expected = :create
		result = @app.update_pointer.directions.flatten[0]
		assert_equal(expected, result)
	end
	def test_update_packages2
		@app.packages = [@pack2]
		data_hsh = @plugin.parse_sequence_data(@html_5754, '5754.htm')	
		@plugin.update_packages(data_hsh)
		expected = Array.new(11, @pack2)
		result = @plugin.updated_packages 
		assert_equal(expected, result)
	end
	def test_update_packages3
		@app.packages = [@pack3]
		data_hsh = @plugin.parse_sequence_data(@html_5754, '5754.htm')	
		@plugin.update_packages(data_hsh)
		expected = Array.new(11, '55725')
		result = @app.iksnrs
		assert_equal(expected, result)
		expected = [
			"004", "008", "012", "016", "020", "024", 
			"028", "032", "036", "040", "042"
		] 
		result = @app.ikscds.sort
		assert_equal(expected, result)
	end
	def test_update_packages4
		pack = StubPackage.new
		@app.packages = [pack]
		data_hsh = @plugin.parse_sequence_data(@html_5754, '5754.htm')	
		@plugin.update_packages(data_hsh)
		expected = Array.new(11, pack)
		result = @plugin.updated_packages 
		assert_equal(expected, result)
		expected = { :limitation	=>	true }
		result = @app.update_limitation
		assert_equal(expected, result)
	end
	def test_report
		@plugin.updated_packages << ""
		expected = "updated packages: 1\nparsing errors:   0"
		result = @plugin.report
		assert_equal(expected, result)
	end
	def test_report2
		@plugin.updated_packages << "" << ""
		@plugin.parsing_errors.store('1234.html', 'fehler')
		expected = "updated packages: 2\nparsing errors:   1\n1234.html => fehler"
		result = @plugin.report
		assert_equal(expected, result)
	end
end
