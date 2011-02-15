#!/usr/bin/env ruby
# TestFachinfoWrapper -- oddb -- 15.03.2004 -- mwalder@ywesee.com

$: << File.expand_path('../src', File.dirname(__FILE__))

require 'test/unit'
require 'chapter_wrapper'

module ODDB
  module FiPDF
    class ChapterWrapper < SimpleDelegator
      attr_writer :wrapper_class
    end
    class TestChapterWrapper < Test::Unit::TestCase
      class StubSectionWrapper < SimpleDelegator
      end
      class StubChapter
        attr_accessor :heading, :sections
        def initialize
          @sections = []
        end
        def each_section(&block)
          @sections.each { |chapter|
            block.call(chapter)
          }
        end
        def first_section
          @sections.first
        end
      end
      class StubFormat
        attr_writer :height
        def get_height(*args)
          @height
        end
      end
      class StubSection
        attr_writer :need_new_page
        def need_new_page?(*args)
          @need_new_page
        end
      end
      def setup
        @chapter = StubChapter.new
        @wrapper = ChapterWrapper.new(@chapter)
      end
      def test_need_new_page_with_heading
        @chapter.heading = "Teletubbie"
        fmt_heading = StubFormat.new
        fmt_heading.height = 8
        formats = {
          :chapter => fmt_heading
        }
        height = 7 
        width = "ignored in this test"
        result = @wrapper.need_new_page?(height, width, formats)
        assert_equal(true, result)
      end
      def test_need_new_page_section
        @chapter.heading = "Lala"
        fmt_heading = StubFormat.new
        fmt_heading.height = 8
        section = StubSection.new
        section.need_new_page = true
        @wrapper.wrapper_class = StubSectionWrapper
        @chapter.sections = [section]
        fmt_section = StubFormat.new
        formats = {
          :chapter => fmt_heading
        }
        height = 10
        width = "ignored in this test"
        result = @wrapper.need_new_page?(height, width, formats)
        assert_equal(true, result)
      end
      def test_need_new_page_no
        @chapter.heading = "Laa Laa"
        fmt_heading = StubFormat.new
        fmt_heading.height = 8
        section = StubSection.new
        section.need_new_page = false
        @wrapper.wrapper_class = StubSectionWrapper
        @chapter.sections = [section]
        formats = {
          :chapter => fmt_heading
        }
        height = 10
        width = "ignored in this test"
        result = @wrapper.need_new_page?(height, width, formats)
        assert_equal(false, result)
      end
    end
  end
end
