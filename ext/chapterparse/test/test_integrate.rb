#!/usr/bin/env ruby
#  -- oddb -- 16.08.2005 -- ffricker@ywesee.com


$: << File.expand_path('../src', File.dirname(__FILE__))
$: << File.expand_path('../../../src', File.dirname(__FILE__))

require 'test/unit'
require 'parser'
require 'ext/chapterparse/src/writer'

module ODDB
	module ChapterParse 
		class Parser
			attr_reader :nofill
		end
		class TestParserExcipiens < Test::Unit::TestCase
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
				@writer = ChapterParse::Writer.new
				@formatter = HtmlFormatter.new(@writer)
				@parser = ChapterParse::Parser.new(@formatter)
			end	
			def	test_italic_excipiens
				html = <<-EOS
<div class="section">
	<span style="font-style: italic;"> </span>
	<span class="paragraph">
		Dieser Text&nbsp;ist normal 
		<span style="font-style: italic;">
			und dieser in Italic
		</span>
	</span>
</div>
				EOS
				@parser.feed(html)
				#puts @writer.chapter.inspect
			end	
			def test_subheading_newline
				html = <<-EOS
			<span style="font-style: italic;">Kinder ab ½ Jahr: </span><br> <div style="font-style: italic;"><span style="font-style: italic;">½-1 Jahr:</span>&nbsp;<span class="paragraph">2×&nbsp;täglich 1 Suppositorium 125&nbsp;mg.</span></div> <div style="font-style: italic;"><span style="font-style: italic;">1-3 Jahre:</span>&nbsp;<span class="paragraph">3×&nbsp;täglich 1 Suppositorium 125&nbsp;mg.</span></div><div style="font-style: italic;"><span class="paragraph"></span><span class="paragraph"><br> </span><span class="paragraph"></span></div>
				EOS
				@parser.feed(html)
				#puts @writer.chapter.inspect
			end
			def test_courier_output
				src = <<-EOS
				<span style="font-family: courier new,mono;">Dies ist Courier.</span>
				EOS
				@parser.feed(src)
				puts @writer.chapter.inspect
			end
		end
	end 
end
