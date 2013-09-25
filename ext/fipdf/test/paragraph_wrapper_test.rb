#!/usr/bin/env ruby
# TestParagraphWrapper -- oddb -- 15.03.2004 -- rwaltert@ywesee.com

$: << File.expand_path('../src', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'paragraph_wrapper'
require 'model/text'

module ODDB
	module FiPDF
		class ParagraphWrapper < SimpleDelegator 
			attr_accessor :wrapper_class, :writer
		end
		class TestParagraphWrapper <Minitest::Test
			class StubFormat
				attr_accessor :height, :font, :differences, :size, :justification, :spacing_before, :font_height, :line_count
				def get_height(*args)
					@height
				end
				def font_height(height)
					@size
				end
				def line_count(*args)
					@line_count
				end
				def spacing_before(*args)
					@spacing_before
				end
			end
			class StubParagraph
				attr_accessor :need_new_page, :text, :preformatted
				def need_new_page?(*args)
					@need_new_page
				end
				def preformatted?
					@preformatted
				end
				def prepend(*args)
				end
			end
			def setup
				@paragraph = StubParagraph.new
				@wrapper = ParagraphWrapper.new(@paragraph)
			end
			def test_enforce_page_height_with_widow
				fmt = StubFormat.new
				first_height = 45 
				fmt.size = 5
				fmt.line_count = 20
				column_height = 50
				width = 200
				result = @wrapper.enforce_page_break?(first_height, column_height, width, fmt)
				assert_equal(18, result)
			end
			def test_enforce_page_height_no_widow
				fmt = StubFormat.new
				fmt.line_count = 20
				first_height = 43 
				fmt.size = 5
				column_height = 50
				width = 200
				result = @wrapper.enforce_page_break?(first_height, column_height, width, fmt)
				assert_equal(false, result)
			end
			def test_need_new_page_paragraph_total_more_3_old_2
				@wrapper.instance_eval <<-EOS
	def lines_per_height(*args)
		2
	end
				EOS
				@paragraph.text = "foo"
				height = 12
				width = 200
				fmt_name = StubFormat.new
				fmt_name.line_count = 20
				fmt_name.spacing_before = 0
				fmt_name.height = 13
				fmt_name.size = 1
				formats = {
					:preformatted	=> "foo",
					:paragraph		=> fmt_name,
				}
				result = @wrapper.need_new_page?(height, width, formats)
				assert_equal(false, result)
			end
			def test_need_new_page_no
				@wrapper.instance_eval <<-EOS
	def lines_per_height(*args)
		2
	end
				EOS
				height = 15
				width = 200
				fmt_name = StubFormat.new
				fmt_name.line_count = 3
				fmt_name.spacing_before = 0
				fmt_name.height = 8
				fmt_name.size = 2
				formats = {
					:preformatted => "foo",
					:paragraph		=> fmt_name,
				}
				@paragraph.preformatted = false
				@paragraph.text = "foo baar"
				result = @wrapper.need_new_page?(height, width, formats)
				assert_equal(false, result)
			end
			def test_3_line_paragraph_widow
				@wrapper.instance_eval <<-EOS
	def lines_per_height(*args)
		2
	end
				EOS
				height = 10
				width = 200
				fmt_name = StubFormat.new
				fmt_name.line_count = 3
				fmt_name.spacing_before = 0
				fmt_name.height = 11
				formats = {
					:preformatted => "foo",
					:paragraph		=> fmt_name,
				}
				@paragraph.preformatted = false
				@paragraph.text = "foo baar" 
				result = @wrapper.need_new_page?(height, width, formats)
				assert_equal(true, result)
			end
			def test_3_line_paragraph_no_new_page
				@wrapper.instance_eval <<-EOS
	def lines_per_height(*args)
		3
	end
				EOS
				height = 10
				width = 200
				fmt_name = StubFormat.new
				fmt_name.line_count = 3
				fmt_name.spacing_before = 0
				fmt_name.height = 10
				formats = {
					:preformatted => "foo",
					:paragraph		=> fmt_name,
				}
				@paragraph.preformatted = false
				@paragraph.text = "foo baar" 
				result = @wrapper.need_new_page?(height, width, formats)
				assert_equal(false, result)
			end
			def test_lines_per_height
				height = 10
				size = 2
				fmt = StubFormat.new
				fmt.size = 2
				fmt.line_count = 2
				assert_equal(5, @wrapper.lines_per_height(height, fmt))
			end
			def test_format_paragraph_bold
				paragraph = ODDB::Text::Paragraph.new
				paragraph.set_format(:bold)
				paragraph << "Bold Text!"
				wrapper = ParagraphWrapper.new(paragraph)
				formatted = wrapper.format_text
				expected = "<b>Bold Text!</b>"
				assert_equal(expected, formatted)
			end
			def test_format_paragraph_italic
				paragraph = ODDB::Text::Paragraph.new
				paragraph.set_format(:italic)
				paragraph << "Kursiv Text!"
				wrapper = ParagraphWrapper.new(paragraph)
				formatted = wrapper.format_text
				expected = "<i>Kursiv Text!</i>"
				assert_equal(expected, formatted)
			end
			def test_format_paragraph_mixed
				paragraph = ODDB::Text::Paragraph.new
				paragraph.set_format(:italic)
				paragraph << "Kursiv Text!"
				paragraph.set_format(:bold)
				paragraph << " und ein bisschen Bold..."
				paragraph.set_format(:bold, :italic)
				paragraph << " und auch mal beide." 
				wrapper = ParagraphWrapper.new(paragraph)
				formatted = wrapper.format_text
				expected = "<i>Kursiv Text!</i><b> und ein bisschen Bold...</b><b><i> und auch mal beide.</i></b>"
				assert_equal(expected, formatted)
			end
			def test_format_paragraph_symbol
				paragraph = ODDB::Text::Paragraph.new
				paragraph.set_format(:symbol)
				paragraph << "a"
				paragraph.set_format
				paragraph << "-Tocopherol"
				wrapper = ParagraphWrapper.new(paragraph)
				formatted = wrapper.format_text
				expected = "<f:Symbol>a</f>-Tocopherol"
				assert_equal(expected, formatted)
			end
		end
	end
end
