#!/usr/bin/env ruby
# ChapterParse::TestParser -- oddb -- 09.08.2005 -- ffricker@ywesee.com

$: << File.expand_path('../src', File.dirname(__FILE__))
$: << File.expand_path('../../../src', File.dirname(__FILE__))


gem 'minitest'
require 'minitest/autorun'
require 'chaptparser'

module ODDB
	module ChapterParse
		class Parser 
			attr_reader :nofill
		end
		class TestParserGecko <Minitest::Test
			class Formatter < NullFormatter
				attr_accessor :font_stack
				def initialize(*args)
					@font_stack = []
				end
				def push_font(*args)
					@font_stack.push(args)
				end
				def pop_font
					@font_stack.pop
				end
			end
			def setup
				@formatter = Formatter.new
				@parser = Parser.new(@formatter)
			end
			def test_parse__b
				src = <<-EOS
<span style="font-weight: bold;">Acidum
				EOS
				@parser.feed(src)
				assert_equal([[nil, nil, 1, nil]], 
					@formatter.font_stack)
				@parser.feed('</span>')
				assert_equal([], @formatter.font_stack) end
			def test_parse__bb
				src = <<-EOS
<span bgcolor="#FFFFFF" style="font-weight: bold;font-weight: bold">Acidum
				EOS
				@parser.feed(src)
				assert_equal([[nil, nil, 1, nil]], 
					@formatter.font_stack)
				@parser.feed('</span>')
				assert_equal([], @formatter.font_stack)
			end
			def test_parse__i
				src = <<-EOS
<span style="font-style: italic;">mefenamicum
				EOS
				@parser.feed(src)
				assert_equal([[nil, 1, nil, nil]], 
					@formatter.font_stack)
				@parser.feed('</span>')
				assert_equal([], @formatter.font_stack)
			end
			def test_parse__bi
				src = <<-EOS
<span style="font-weight: bold; font-style: italic;">Eigenschaften/Wirkungen
				EOS
				@parser.feed(src)
				assert_equal([[nil, nil, 1, nil], [nil, 1, nil, nil]],
					@formatter.font_stack)				
				@parser.feed('</span>')
				assert_equal([], @formatter.font_stack)
			end
			def test_parse__font
				src = <<-EOS
<span style="font-family: courier new,courier,mono;">Wirkstoff
				EOS
				@parser.feed(src)
				assert_equal(1, @parser.nofill)
				@parser.feed('</span>')
				assert_equal(0, @parser.nofill)
			end
			def test_parse__combined
				src = <<-EOS
<span style="font-weight: bold;">
  Fett
				EOS
				@parser.feed(src)
				assert_equal([[nil, nil, 1, nil]], 
					@formatter.font_stack)
				src = <<-EOS
  <span style="font-family: courier new,courier,mono;">
	  Fixed-Width Font
				EOS
				@parser.feed(src)
				assert_equal([[nil, nil, 1, nil], [nil, nil, nil, 1]],
					@formatter.font_stack)
				assert_equal(1, @parser.nofill)
				@parser.feed('</span>')
				assert_equal([[nil, nil, 1, nil]], 
					@formatter.font_stack)
				assert_equal(0, @parser.nofill)
				@parser.feed('</span>')
				assert_equal([], @formatter.font_stack)
				assert_equal(0, @parser.nofill)
			end
			def test_parse__courier
				src=<<-EOS
<span style="font-family: courier new,courier,mono;">Test
				EOS
				@parser.feed(src)
				assert_equal([[nil,nil,nil,1]], @formatter.font_stack)
				@parser.feed("</span>")
				assert_equal([], @formatter.font_stack)
			end
			def test_parse__div_preformatted
				src=<<-EOS
<div class="preformatted">Test
				EOS
				@parser.feed(src)
				assert_equal([[nil, nil, nil, 1]], @formatter.font_stack)
				@parser.feed("</div>")
				assert_equal([], @formatter.font_stack)
			end
		end
		class TestParserIE <Minitest::Test
			class Formatter < NullFormatter
				attr_accessor :font_stack
				def initialize(*args)
					@font_stack = []
				end
				def push_font(*args)
					@font_stack.push(args)
				end
				def pop_font
					@font_stack.pop
				end
			end
			def setup
				@formatter = Formatter.new
				@parser = Parser.new(@formatter)
			end
			def test_parse__b
				src=<<-EOS
<STRONG>Text
				EOS
					@parser.feed(src)
				assert_equal([[nil, nil, 1, nil]],
					@formatter.font_stack)
				@parser.feed('</STRONG>')
				assert_equal([], @formatter.font_stack)
			end
			def test_parse__i
				src=<<-EOS
<EM>Text
				EOS
				@parser.feed(src)
				assert_equal([[nil, 1, nil, nil]],
					@formatter.font_stack)
				@parser.feed('</EM>')
				assert_equal([], @formatter.font_stack)
			end
			def test_parse__bi
				src = <<-EOS
<STRONG><EM>Text
				EOS
				@parser.feed(src)
				assert_equal([[nil, nil, 1, nil], [nil, 1, nil, nil]],
					@formatter.font_stack)				
				@parser.feed('</STRONG></EM>')
				assert_equal([], @formatter.font_stack)
			end
			def test_parse__font
				src = <<-EOS
<FONT face="Courier New, Courier, mono">Wirkstoff
				EOS
				@parser.feed(src)
				assert_equal(1, @parser.nofill)
				@parser.feed('</FONT>')
				assert_equal(0, @parser.nofill)
			end
			def test_parse__combined
				src = <<-EOS
<STRONG>
  Fett
				EOS
				@parser.feed(src)
				assert_equal([[nil, nil, 1, nil]], 
					@formatter.font_stack)
				src = <<-EOS
  <FONT face="Courier New, Courier, mono">Wirkstoff
	  Fixed-Width Font
				EOS
				@parser.feed(src)
				assert_equal([[nil, nil, 1, nil], [nil, nil, nil, 1]],
					@formatter.font_stack)
				assert_equal(1, @parser.nofill)
				@parser.feed('</FONT>')
				assert_equal([[nil, nil, 1, nil]], 
					@formatter.font_stack)
				assert_equal(0, @parser.nofill)
				@parser.feed('</STRONG>')
				assert_equal([], @formatter.font_stack)
				assert_equal(0, @parser.nofill)
			end
			def test_parse__courier
				src = <<-EOS
					Courier-Font of Internet-Explorer
				EOS
			end
		end
		class TestParserCopyPasteOpenOffice <Minitest::Test
			class Formatter < NullFormatter
				attr_accessor :font_stack
				def initialize(*args)
					@font_stack = []
				end
				def push_font(*args)
					@font_stack.push(args)
				end
				def pop_font
					@font_stack.pop
				end
			end
			def setup
				@formatter = Formatter.new
				@parser = Parser.new(@formatter)
			end
			def test_parse__h2
				src=<<-EOS
<h2>Text
				EOS
				@parser.feed(src)
				assert_equal([[nil, 1, nil, nil]],
					@formatter.font_stack)
				@parser.feed('</h2>')
				assert_equal([], @formatter.font_stack)
			end
		end
	end
end
