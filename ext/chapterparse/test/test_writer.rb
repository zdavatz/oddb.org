#!/usr/bin/env ruby
# ChapterParse::TestWriter -- oddb -- 12.08.2005 -- ffricker@ywesee.com


$: << File.expand_path('../../../src', File.dirname(__FILE__))
$: << File.expand_path('../src', File.dirname(__FILE__))

require 'test/unit'
require 'writer'

module ODDB
	module ChapterParse
		class TestWriter < Test::Unit::TestCase
			def setup
				@writer = Writer.new
			end
			def test_section
				@writer.new_font([nil, 1, nil, nil])
				@writer.send_flowing_data("Subheading")
				chapter = @writer.chapter
				assert_equal(1, chapter.sections.size)
				section = chapter.sections.first
				assert_equal('Subheading', section.subheading)
				assert_equal(0, section.paragraphs.size)
			end
			def test_section_and_paragraph
				@writer.new_font([nil, 1, nil, nil])
				@writer.send_flowing_data('Subheading')
				@writer.new_font(nil)
				@writer.send_flowing_data("\302\240First Paragraph")
				chapter = @writer.chapter
				assert_equal(1, chapter.sections.size)
				section = chapter.sections.first
				assert_equal('Subheading', section.subheading)
				assert_equal(1, section.paragraphs.size)
				paragraph = section.paragraphs.first
				assert_equal('First Paragraph', paragraph.text)
			end
			def test_section_and_paragraph__on_new_line
				@writer.new_font([nil, 1, nil, nil])
				@writer.send_flowing_data("Subheading")
				@writer.send_line_break
				@writer.new_font(nil)
				@writer.send_flowing_data('First Paragraph')
				chapter = @writer.chapter
				assert_equal(1, chapter.sections.size)
				section = chapter.sections.first
				assert_equal("Subheading\n", section.subheading)
				assert_equal(1, section.paragraphs.size)
				paragraph = section.paragraphs.first
				assert_equal('First Paragraph', paragraph.text)
			end
			def test_section_and_paragraph__on_new_line__2
				@writer.new_font([nil, 1, nil, nil])
				@writer.send_flowing_data("Subheading")
				@writer.new_font(nil)
				@writer.send_line_break
				@writer.send_flowing_data('First Paragraph')
				chapter = @writer.chapter
				assert_equal(1, chapter.sections.size)
				section = chapter.sections.first
				assert_equal("Subheading\n", section.subheading)
				assert_equal(1, section.paragraphs.size)
				paragraph = section.paragraphs.first
				assert_equal('First Paragraph', paragraph.text)
			end
			def test_section_and_2_paragraphs
				@writer.new_font([nil, 1, nil, nil])
				@writer.send_flowing_data('Subheading')
				@writer.new_font(nil)
				@writer.send_flowing_data('First Paragraph')
				@writer.send_line_break
				@writer.send_flowing_data('Second Paragraph')
				@writer.send_line_break
				chapter = @writer.chapter
				assert_equal(1, chapter.sections.size)
				section = chapter.sections.first
				assert_equal('Subheading', section.subheading)
				assert_equal(2, section.paragraphs.size)
				paragraph = section.paragraphs.first
				assert_equal('First Paragraph', paragraph.text)
				paragraph = section.paragraphs.last
				assert_equal('Second Paragraph', paragraph.text)
			end
			def test_2_sections_and_paragraphs
				@writer.new_font([nil, 1, nil, nil])
				@writer.send_flowing_data('Subheading 1')
				@writer.new_font(nil)
				@writer.send_flowing_data('First Paragraph')
				@writer.send_line_break
				@writer.new_font([nil, 1, nil, nil])
				@writer.send_flowing_data('Subheading 2')
				@writer.new_font(nil)
				@writer.send_flowing_data('Second Paragraph')
				@writer.send_line_break
				chapter = @writer.chapter
				assert_equal(2, chapter.sections.size)
				section = chapter.sections.first
				assert_equal('Subheading 1', section.subheading)
				assert_equal(1, section.paragraphs.size)
				paragraph = section.paragraphs.first
				assert_equal('First Paragraph', paragraph.text)

				section = chapter.sections.last
				assert_equal('Subheading 2', section.subheading)
				assert_equal(1, section.paragraphs.size)
				paragraph = section.paragraphs.first
				assert_equal('Second Paragraph', paragraph.text)
			end
			def test_section_without_subheading
				@writer.send_flowing_data('First Paragraph')
				@writer.send_line_break
				chapter = @writer.chapter
				assert_equal(1, chapter.sections.size)
				section = chapter.sections.first
				assert_equal('', section.subheading)
				assert_equal(1, section.paragraphs.size)
				paragraph = section.paragraphs.first
				assert_equal('First Paragraph', paragraph.text)
			end
			def test_paragraph_with_italic
				@writer.send_flowing_data('First Paragraph')
				@writer.new_font([nil, 1, nil, nil])
				@writer.send_flowing_data(' with italic text')
				@writer.new_font(nil)
				@writer.send_flowing_data(' and some more normal.')
				@writer.send_line_break
				chapter = @writer.chapter
				assert_equal(1, chapter.sections.size)
				section = chapter.sections.first
				assert_equal('', section.subheading)
				assert_equal(1, section.paragraphs.size)
				paragraph = section.paragraphs.first
				expected = 'First Paragraph with italic text and some more normal.'
				assert_equal(expected, paragraph.text)
				assert_equal(3, paragraph.formats.size)
				format = paragraph.formats.at(1)
				assert_equal(true, format.italic?)
				assert_equal(15..31, format.range)
			end
			def test_preformatted
				@writer.new_font([nil, nil, nil, 1])
				@writer.send_literal_data('First Paragraph')
				chapter = @writer.chapter
				assert_equal(1, chapter.sections.size)
				section = chapter.sections.first
				assert_equal('', section.subheading)
				assert_equal(1, section.paragraphs.size)
				paragraph = section.paragraphs.first
				assert_equal(true, paragraph.preformatted?)
				assert_equal('First Paragraph', paragraph.text)
			end
			def test_preformatted_2_lines
				@writer.new_font([nil, nil, nil, 1])
				@writer.send_literal_data('First Line')
				@writer.send_line_break
				@writer.new_font(nil)
				@writer.send_paragraph({})
				@writer.new_font([nil, nil, nil, 1])
				@writer.send_literal_data('Second Line')
				chapter = @writer.chapter
				assert_equal(1, chapter.sections.size)
				section = chapter.sections.first
				assert_equal('', section.subheading)
				assert_equal(1, section.paragraphs.size)
				paragraph = section.paragraphs.first
				assert_equal(true, paragraph.preformatted?)
				expected = "First Line\nSecond Line"
				assert_equal(expected, paragraph.text)
			end
			def test_preformatted_2_lines__too_many_newlines
				@writer.new_font([nil, nil, nil, 1])
				@writer.send_literal_data('First Line')
				@writer.send_line_break
				@writer.new_font(nil)
				@writer.send_paragraph({})
				@writer.send_line_break
				@writer.send_line_break
				@writer.send_line_break
				@writer.new_font([nil, nil, nil, 1])
				@writer.send_literal_data('Second Line')
				chapter = @writer.chapter
				assert_equal(1, chapter.sections.size)
				section = chapter.sections.first
				assert_equal('', section.subheading)
				assert_equal(1, section.paragraphs.size)
				paragraph = section.paragraphs.first
				assert_equal(true, paragraph.preformatted?)
				expected = "First Line\nSecond Line"
				assert_equal(expected, paragraph.text)
			end
			def test_preformatted_to_normal
				@writer.new_font([nil, nil, nil, 1])
				@writer.send_literal_data('First Line')
				@writer.send_line_break
				@writer.new_font(nil)
				@writer.send_paragraph({})
				@writer.send_flowing_data('Second Line')
				chapter = @writer.chapter
				assert_equal(1, chapter.sections.size)
				section = chapter.sections.first
				assert_equal('', section.subheading)
				assert_equal(2, section.paragraphs.size)
				paragraph = section.paragraphs.first
				assert_equal(true, paragraph.preformatted?)
				expected = "First Line\n"
				assert_equal(expected, paragraph.text)
				paragraph = section.paragraphs.last
				assert_equal(false, paragraph.preformatted?)
				expected = "Second Line"
				assert_equal(expected, paragraph.text)
			end
		end
	end
end
