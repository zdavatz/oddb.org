# TestWrapper -- oddb -- 15.03.2004 -- mwalder@ywesee.com

$: << File.expand_path('../src', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'model/text'
require 'format'
module ODDB
	module FiPDF
		class Format 
			attr_accessor :writer
		end
		class TestFormat < Test::Unit::TestCase
			class StubWriter
				attr_accessor :num_lines, :height, :add_text_wrap_results
				def initialize
					@add_text_wrap_results = []
					@calls = 0
				end
				def select_font(*args)
				end
				def add_text_wrap(*args)
					@calls += 1
					if (@calls == 2)
					""
					else
						"foo"
					end
				end
				def get_font_height(*args)
					@height
				end
			end
			def setup
				@format = Format.new
				@writer = StubWriter.new
			end
			def test_line_count
				@format.writer = StubWriter.new
				text = "foobaar foobaar"
				assert_equal(2, @format.line_count(text, 200))
			end
			def test_line_count_break
				@format.writer = StubWriter.new
				text = "foobaar\nfoobaar"
				assert_equal(2, @format.line_count(text, 20000))
			end
			def test_get_height
				@format.writer = StubWriter.new
				@format.writer.height = 8
				text = "foobaar foobaar"
				assert_equal(16, @format.get_height(text, 200))
			end
			def test_spacing_before
				@format.writer = StubWriter.new
				text = ""
				assert_equal(0, @format.spacing_before(text))
			end
			def test_spacing_after
				@format.writer = StubWriter.new
				text = ""
				assert_equal(0, @format.spacing_after(text))
			end
		end
	end
end
