#!/usr/bin/env ruby
# TestFachinfoWrapper -- oddb -- 15.03.2004 -- mwalder@ywesee.com

$: << File.expand_path('../src', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'fachinfo_wrapper'
require 'delegate'
module FiPDF
	class FachinfoWrapper < SimpleDelegator
		attr_writer :wrapper_class
	end
	class TestFachinfoWrapper < Test::Unit::TestCase
		class StubChapterWrapper < SimpleDelegator
		end
		class StubFachinfo
			attr_accessor :chapters, :name, :company_name
			def each_chapter(&block)
				@chapters.each { |chapter|
					block.call(chapter)
				}
			end
			def first_chapter
				@chapters.first
			end
		end
		class StubFormat
			attr_writer :height
			attr_accessor :margin
			def get_height(*args)
				@height
			end
		end
		class StubChapter
			attr_writer :need_new_page
			def need_new_page?(*args)
				@need_new_page
			end
		end
		def setup
			@fachinfo = StubFachinfo.new
			@wrapper = FachinfoWrapper.new(@fachinfo)
		end
		def test_need_new_page__drug_name
			@fachinfo.name = "Ponstan"
			@fachinfo.company_name = "ywesee"
			fmt_dname = StubFormat.new
			fmt_dname.height = 10
			fmt_dname.margin = 0
			fmt_cname = StubFormat.new
			fmt_cname.height = 5
			formats = {
				:drug_name => fmt_dname,
				:company_name => fmt_cname
			}
			@wrapper.wrapper_class = StubChapterWrapper
			height = 7
			width = "ignored in this test"
			result = @wrapper.need_new_page?(height, width, formats)
			assert_equal(true, result)
		end
		def test_need_new_page__company_name
			@fachinfo.name = "Ponstan"
			@fachinfo.company_name = "ywesee"
			fmt_dname = StubFormat.new
			fmt_dname.margin = 0
			fmt_dname.height = 10
			fmt_cname = StubFormat.new
			fmt_cname.height = 5
			formats = {
				:drug_name => fmt_dname,
				:company_name => fmt_cname
			}
			@wrapper.wrapper_class = StubChapterWrapper
			height = 14 
			width = "ignored in this test"
			result = @wrapper.need_new_page?(height, width, formats)
			assert_equal(true, result)
		end
		def test_need_new_page__chapter
			@fachinfo.name = "Ponstan"
			@fachinfo.company_name = "ywesee"
			fmt_dname = StubFormat.new
			fmt_dname.margin = 0
			fmt_dname.height = 10
			fmt_cname = StubFormat.new
			fmt_cname.height = 5
			formats = {
				:drug_name => fmt_dname,
				:company_name => fmt_cname
			}
			@wrapper.wrapper_class = StubChapterWrapper
			height = 16 
			width = "ignored in this test"
			chapter = StubChapter.new
			chapter.need_new_page = true
			@fachinfo.chapters = [chapter]
			@wrapper.wrapper_class = StubChapterWrapper
			result = @wrapper.need_new_page?(height, width, formats)
			assert_equal(true, result)
		end
		def test_need_new_page__no
			@fachinfo.name = "Ponstan"
			@fachinfo.company_name = "ywesee"
			fmt_dname = StubFormat.new
			fmt_dname.margin = 0
			fmt_dname.height = 10
			fmt_cname = StubFormat.new
			fmt_cname.height = 5
			formats = {
				:drug_name => fmt_dname,
				:company_name => fmt_cname
			}
			@wrapper.wrapper_class = StubChapterWrapper
			height = 16 
			width = "ignored in this test"
			chapter = StubChapter.new
			chapter.need_new_page = false
			@fachinfo.chapters = [chapter]
			@wrapper.wrapper_class = StubChapterWrapper
			result = @wrapper.need_new_page?(height, width, formats)
			assert_equal(false, result)
		end
		def test_each_chapter
			@fachinfo.chapters = [
				"foo", "bar", "baz"
			]
			@wrapper.each_chapter { |chapter|
				assert_instance_of(ChapterWrapper, chapter)
			}
		end
	end
end
