#!/usr/bin/env ruby
# TestFachinfoWrapper -- oddb -- 15.03.2004 -- mwalder@ywesee.com

$: << File.expand_path('../src', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'section_wrapper'
require 'model/text'

module ODDB
	module FiPDF
		class SectionWrapper < SimpleDelegator 
			attr_writer :wrapper_class
		end
		class TestSectionWrapper <Minitest::Test
			class StubParagraphWrapper < SimpleDelegator
			end
			class StubSection
				attr_accessor :subheading, :paragraphs, :prepend
				def initialize 
					@subheading = ""
          @paragraphs = []
				end
				def each_paragraph(&block)
					@paragraphs.each{ |section|
						block.call(section)
					}
				end
				def first_paragraph
					@paragraphs.first
				end
			end
			class StubFormat
				attr_writer :height
				def get_height(*args)
					@height
				end
			end
			class StubParagraph
				attr_writer :need_new_page
				def need_new_page?(*args)
					@need_new_page
				end
				def prepend(*args)
				end
			end
			def setup
				@section = StubSection.new
				@wrapper = SectionWrapper.new(@section)
			end
			def test_need_new_page_with_subheading
				@wrapper.wrapper_class = StubParagraphWrapper
				@section.subheading = "Tinky Winky" 
				fmt_subheading = StubFormat.new
				fmt_subheading.height = 6
				formats = {
					:section => fmt_subheading
				}
				height = 5
				width = "ignored in this test "
				result = @wrapper.need_new_page?(height, width, formats)
				assert_equal(true, result)
			end
			def test_need_new_page_with_paragraph
				@wrapper.wrapper_class = StubParagraphWrapper
				@section.subheading = "Tinky Winky" 
				fmt_subheading = StubFormat.new
				fmt_subheading.height = 6
				formats = {
					:section => fmt_subheading
				}
				height = 7
				width = "ignored in this test "
				paragraph = StubParagraph.new
				paragraph.need_new_page = true
				@section.paragraphs = [paragraph]
				result = @wrapper.need_new_page?(height, width, formats)
				assert_equal(true, result)
			end
			def test_need_new_page_no
				@wrapper.wrapper_class = StubParagraphWrapper
				@section.subheading = "Tinky Winky" 
				fmt_subheading = StubFormat.new
				fmt_subheading.height = 6
				formats = {
					:section => fmt_subheading
				}
				height = 7
				width = "ignored in this test "
				paragraph = StubParagraph.new
				paragraph.need_new_page = false
				@section.paragraphs = [paragraph]
				result = @wrapper.need_new_page?(height, width, formats)
				assert_equal(false, result)
			end
			def test_prepend_paragraph
				section = ODDB::Text::Section.new
				section.subheading = 'no newline'
				paragraph = section.next_paragraph
				paragraph << "the Paragraph"

				wrapper = SectionWrapper.new(section)
				para_wrapper = wrapper.first_paragraph
				assert_equal('<i>no newline </i>the Paragraph', para_wrapper.text)
				assert_equal('', wrapper.subheading)
				assert_equal('no newline', section.subheading)
				assert_equal('the Paragraph', paragraph.text)
			end
			def test_each_paragraph
				@section.subheading = "foo\n"
				count = 0
				@wrapper.paragraphs = []
				@wrapper.each_paragraph {
					count += 1
				}
				assert_equal(0, count)
				@wrapper.paragraphs = ["foo"]
				count = 0
				@wrapper.each_paragraph {
					count += 1
				}
				assert_equal(1, count)
				@wrapper.paragraphs = ["foo","baar"]
				count = 0
				@wrapper.each_paragraph {
					count += 1
				}
				assert_equal(2, count)
			end
		end
	end
end
