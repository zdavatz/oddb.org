#!/usr/bin/env ruby
# TestFachifoPlugin -- ODDB -- 12.11.2003 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'plugin/fachinfo'
require 'model/text'

class StubFachinfoParser
	class << self
		def parse_fachinfo_html(src)
			src
		end
	end
end
module ODDB
	class FachinfoPlugin < Plugin
		HTML_PATH = File.expand_path('../data/html', File.dirname(__FILE__))
		PARSER = StubFachinfoParser
		LOG_PATH = File.expand_path('../data/fachinfo.log', File.dirname(__FILE__))
		
		public :target
	end
end

class TestFachinfoPlugin < Test::Unit::TestCase
	class StubApp
		attr_accessor :update_values, :update_pointers, :update_result
		attr_reader :replace_iksnrs, :replace_pointers
		attr_writer :registration
		def initialize
			@update_values = []
			@update_pointers = []
			@replace_iksnrs = []
			@replace_pointers = []
		end
		def registration(iksnr)
			@registration
		end
		def update(pointer, value)
			@update_pointers << pointer
			@update_values << value
			@update_result
		end
		def replace_fachinfo(iksnr, pointer)
			@replace_iksnrs << iksnr
			@replace_pointers << pointer
		end
	end
	class StubDocument
		attr_accessor :iksnrs, :name
	end
	class StubFachinfo
		attr_accessor :pointer
	end
	class StubRegistration
	end
	def setup
		@logpath = ODDB::FachinfoPlugin::LOG_PATH
		@app = StubApp.new
		@plugin = ODDB::FachinfoPlugin.new(@app)
	end
	def tear_down
		if(File.exists?(@logpath))
			File.delete(@logpath)
		end
	end
	def test_package_languages
		begin
			defile = @plugin.target('de', 1)	
			frfile = @plugin.target('fr', 1)
			File.open(defile, 'w') { |fh| fh << "de_fi" }
			expected = {
				'de'	=>	'de_fi',
			}
			assert_equal(expected, @plugin.package_languages(1))

			File.open(frfile, 'w') { |fh| fh << "fr_fi" }
			expected = {
				'de'	=>	'de_fi',
				'fr'	=>	'fr_fi',
			}
			assert_equal(expected, @plugin.package_languages(1))
		ensure
			File.delete(defile) if File.exist?(defile)
			File.delete(frfile) if File.exist?(frfile)
		end
	end
	def test_extract_iksnrs1
		doc1 = StubDocument.new
		doc1.iksnrs = "12345, 67890 (Swissmedic)"
		doc2 = StubDocument.new
		doc2.iksnrs = "65432, 67890 (Swissmedic)"
		languages = {
			'de'	=>	doc1,
			'fr'	=>	doc2,
		}
		expected = [
			"12345", "67890", "65432"
		].sort
		assert_equal(expected, @plugin.extract_iksnrs(languages).sort)
	end
	def test_extract_iksnrs2
		doc1 = StubDocument.new
		chapter = ODDB::Text::Chapter.new
		section = chapter.next_section
		paragraph = section.next_paragraph
		paragraph << "12'345, 67890 (Swissmedic)"
		doc1.iksnrs = chapter
		languages = {
			'de'	=>	doc1,
		}
		expected = [
			"12345", "67890", 
		].sort
		assert_equal(expected, @plugin.extract_iksnrs(languages).sort)
	end
	def test_update_registrations
		doc1 = StubDocument.new
		doc1.iksnrs = "12345, 67890 (Swissmedic)"
		languages = {
			'de'	=>	doc1,
			'fr'	=>	doc1,
		}
		fi = StubFachinfo.new
		fi.pointer = "fi_pointer"
		@app.registration = StubRegistration.new
		@app.update_result = fi
		@plugin.update_registrations(languages)
		fipointer = ODDB::Persistence::Pointer.new(:fachinfo)
		assert_equal(fipointer.creator, @app.update_pointers.first)
		assert_equal(languages, @app.update_values.first)
		assert_equal(['12345', '67890'], @app.replace_iksnrs)
		assert_equal(Array.new(2, "fi_pointer"), @app.replace_pointers)
	end
	def test_log_news1
		file = ODDB::FachinfoPlugin::LOG_PATH
		if(File.exists?(@logpath))
			File.delete(@logpath)
		end
		assert_nothing_raised { 
			@plugin.log_news(['foo'])
		}
		assert(File.exists?(@logpath), "unable to write logfile!")
		assert_equal("foo\n", File.read(@logpath))
	end
	def test_old_news
		file = ODDB::FachinfoPlugin::LOG_PATH
		File.open(file, 'w') { |fh|
			fh.puts([123, 456, 789, 101112])
		}
		expected = [
			123, 456, 789, 101112,
		]
		assert_equal(expected, @plugin.old_news)
	end
	def test_store_orphaned
		key = 'theKey'
		languages = {
			'language' => 'fachinfo',
		}
		@plugin.store_orphaned(key, languages)
		assert_equal(1, @app.update_pointers.size)
		pointer = ODDB::Persistence::Pointer.new([:orphaned_fachinfo])
		expected = {
			:key	=>	key,
			:languages => languages,
		}
		assert_equal([pointer.creator], @app.update_pointers)
		assert_equal([expected], @app.update_values)
	end
	def test_log_news2
		file = ODDB::FachinfoPlugin::LOG_PATH
		File.open(file, 'w') { |fh|
			fh.puts([123, 456, 789, 101112])
		}
		@plugin.log_news([654, 789, 1314])
		expected = [
			654, 789, 1314, 123, 456, 101112,
		]
		assert_equal(expected, @plugin.old_news)
	end
	def test_true_news1
		news = [1234, 5678, 9807, 4567, 3456]
		old_news = [9807, 4567]
		expected = [1234, 5678]
		assert_equal(expected, @plugin.true_news(news, old_news))
	end
	def test_true_news2
		news = [1234, 5678, 9807, 4567, 3456]
		old_news = []
		assert_equal(news, @plugin.true_news(news, old_news))
	end
end
