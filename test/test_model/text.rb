#!/usr/bin/env ruby
# TestText -- oddb -- 10.09.2003 -- rwaltert@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'model/text'

module ODDB
	module Text
		class Paragraph
			attr_reader :formats
		end
	end
end

class TestImageLink < Test::Unit::TestCase
	def setup
		@link = ODDB::Text::ImageLink.new
	end
	def test_empty
		assert_equal(true, @link.empty?)
		@link.src = '/foo/bar.gif'	
		assert_equal(false, @link.empty?)
	end
	def test_attributes
		@link.src = '/foo/bar.gif'	
		expected = {
			'src' => '/foo/bar.gif'	
		}
		assert_equal(expected, @link.attributes)
	end
end
class TestFormat < Test::Unit::TestCase
	def setup
		@format = ODDB::Text::Format.new
	end
	def test_initialize
		assert_nothing_raised {
			@format.range
		}
		assert_equal(0..-1, @format.range)
	end
	def test_start_writer
		@format.start = 3
		assert_nothing_raised {
			@format.range
		}
		assert_equal(3..-1, @format.range)
	end
	def test_end_writer
		@format.end = 7
		assert_nothing_raised {
			@format.range
		}
		assert_equal(0..7, @format.range)
	end
=begin
	def test_add
		fmt1 = ODDB::Text::Format.new(:bold)
		assert_equal(true, fmt1.bold?)
		assert_equal(false, fmt1.italic?)
		assert_equal(false, fmt1.symbol?)
		fmt2 = fmt1 + :italic
		assert_equal(true, fmt2.bold?)
		assert_equal(true, fmt2.italic?)
		assert_equal(false, fmt2.symbol?)
		fmt3 = fmt2 + [:symbol]
		assert_equal(true, fmt3.bold?)
		assert_equal(true, fmt3.italic?)
		assert_equal(true, fmt3.symbol?)
	end
	def test_subtract
		fmt1 = ODDB::Text::Format.new(:bold, :italic, :symbol)
		assert_equal(true, fmt1.bold?)
		assert_equal(true, fmt1.italic?)
		assert_equal(true, fmt1.symbol?)
		fmt2 = fmt1 - :italic
		assert_equal(true, fmt2.bold?)
		assert_equal(false, fmt2.italic?)
		assert_equal(true, fmt2.symbol?)
		fmt3 = fmt2 - [:symbol]
		assert_equal(true, fmt3.bold?)
		assert_equal(false, fmt3.italic?)
		assert_equal(false, fmt3.symbol?)
	end
=end
end
class TestParagraph < Test::Unit::TestCase
	def setup
		@paragraph = ODDB::Text::Paragraph.new
	end
	def test_append
		assert_equal('', @paragraph.text)
		@paragraph << ' foo'
		assert_equal('foo', @paragraph.text)
		@paragraph << ' bar '
		assert_equal('foo bar', @paragraph.text)
		@paragraph << 'baz'
		assert_equal('foo bar baz', @paragraph.text)
	end
	def test_empty
		assert_equal(true, @paragraph.empty?)
		@paragraph << ' '
		assert_equal(true, @paragraph.empty?)
		@paragraph << 'foo'
		assert_equal(false, @paragraph.empty?)
	end
	def test_set_format1
		format1 = @paragraph.set_format(:italic)
		assert_equal(0..-1, format1.range)
		assert_equal(true, format1.italic?)
		assert_equal(false, format1.bold?)
		assert_equal([:italic], format1.values)
		assert_equal([format1], @paragraph.formats)
		@paragraph << "Formatted"
		format2 = @paragraph.set_format(:bold)
		assert_equal([format1, format2], @paragraph.formats)
		assert_equal(0..8, format1.range)
		assert_equal(true, format1.italic?)
		assert_equal(false, format1.bold?)
		assert_equal(9..-1, format2.range)
		assert_equal(false, format2.italic?)
		assert_equal(true, format2.bold?)
		assert_equal([:bold], format2.values)
		@paragraph << " text "
		format3 = @paragraph.set_format
		assert_equal([format1, format2, format3], @paragraph.formats)
		assert_equal(9..13, format2.range)
		assert_equal(14..-1, format3.range)
		assert_equal(false, format3.italic?)
		assert_equal(false, format3.bold?)
		assert_equal([], format3.values)
		@paragraph << "is nice!"
		assert_equal('Formatted text is nice!', @paragraph.text)
	end
	def test_set_format2
		format1 = @paragraph.set_format(:italic)
		assert_equal(0..-1, format1.range)
		assert_equal(true, format1.italic?)
		assert_equal(false, format1.bold?)
		assert_equal([:italic], format1.values)
		assert_equal([format1], @paragraph.formats)
		format2 = @paragraph.set_format(:bold)
		assert_equal([format2], @paragraph.formats)
		assert_equal(0..-1, format2.range)
		assert_equal(false, format2.italic?)
		assert_equal(true, format2.bold?)
		assert_equal([:bold], format2.values)
	end
	def test_augment_format1
		format1 = @paragraph.set_format(:italic)
		assert_equal(0..-1, format1.range)
		assert_equal(true, format1.italic?)
		assert_equal(false, format1.bold?)
		assert_equal([:italic], format1.values)
		assert_equal([format1], @paragraph.formats)
		@paragraph << "Formatted"
		format2 = @paragraph.augment_format(:bold)
		assert_equal([format1, format2], @paragraph.formats)
		assert_equal(0..8, format1.range)
		assert_equal(true, format1.italic?)
		assert_equal(false, format1.bold?)
		assert_equal(9..-1, format2.range)
		assert_equal(true, format2.italic?)
		assert_equal(true, format2.bold?)
		assert_equal([:italic, :bold], format2.values)
	end
	def test_reduce_format1
		format1 = @paragraph.set_format(:italic, :bold)
		assert_equal(0..-1, format1.range)
		assert_equal(true, format1.italic?)
		assert_equal(true, format1.bold?)
		assert_equal([:italic, :bold], format1.values)
		assert_equal([format1], @paragraph.formats)
		@paragraph << "Formatted"
		format2 = @paragraph.reduce_format(:italic)
		assert_equal([format1, format2], @paragraph.formats)
		assert_equal(0..8, format1.range)
		assert_equal(true, format1.italic?)
		assert_equal(true, format1.bold?)
		assert_equal(9..-1, format2.range)
		assert_equal(false, format2.italic?)
		assert_equal(true, format2.bold?)
		assert_equal([:bold], format2.values)
	end
	def test_to_s1
		@paragraph << "Hallo Welt!"
		assert_equal("Hallo Welt!", @paragraph.to_s)
	end
	def test_to_s2
		@paragraph << "Hallo Welt!"
		assert_equal("Hallo Welt!", @paragraph.to_s)
		@paragraph.set_format(:symbol)
		@paragraph << " \263 "
		@paragraph.set_format
		@paragraph << "Hallo Zürich!"
		assert_equal("Hallo Welt! >= Hallo Zürich!", @paragraph.to_s)
	end
	def test_prepend
		format1 = @paragraph.set_format
		@paragraph << "UnFormatted"
		assert_equal(0..-1, format1.range)
		assert_equal(false, format1.italic?)
		assert_equal(false, format1.bold?)
		assert_equal([], format1.values)
		assert_equal([format1], @paragraph.formats)
		format2 = @paragraph.set_format(:bold)
		@paragraph << "Bold"
		assert_equal(0..10, format1.range)
		assert_equal(false, format1.italic?)
		assert_equal(false, format1.bold?)
		assert_equal([], format1.values)
		assert_equal(11..-1, format2.range)
		assert_equal(false, format2.italic?)
		assert_equal(true, format2.bold?)
		assert_equal([:bold], format2.values)
		assert_equal([format1, format2], @paragraph.formats)
		@paragraph.prepend('Formatted', :italic)
		format3 = @paragraph.formats.first
		assert_equal(0..8, format3.range)
		assert_equal(true, format3.italic?)
		assert_equal(false, format3.bold?)
		assert_equal([:italic], format3.values)
		assert_equal(9..19, format1.range)
		assert_equal(false, format1.italic?)
		assert_equal(false, format1.bold?)
		assert_equal([], format1.values)
		assert_equal(20..-1, format2.range)
		assert_equal(false, format2.italic?)
		assert_equal(true, format2.bold?)
		assert_equal([:bold], format2.values)
		assert_equal([format3, format1, format2], @paragraph.formats)
		assert_equal('FormattedUnFormattedBold', @paragraph.text)
		@paragraph << " The End"
		assert_equal('FormattedUnFormattedBold The End', @paragraph.text)
	end
end
class	TestSection < Test::Unit::TestCase
	def setup
		@section = ODDB::Text::Section.new
	end
	def test_clean
		@section.subheading = ' '
		paragraph = @section.next_paragraph
		@section.clean!
		assert_equal([], @section.paragraphs)
		assert_equal('', @section.subheading)
		paragraph = @section.next_paragraph
		paragraph << "foo"
		@section.clean!
		assert_equal([paragraph], @section.paragraphs)
	end
	def test_empty
		assert_equal([], @section.paragraphs)
		assert_equal('', @section.subheading)
		assert_equal(true, @section.empty?)
		@section.subheading = 'foo'
		assert_equal(false, @section.empty?)
		@section.subheading = ''
		assert_equal(true, @section.empty?)
		@section.paragraphs.push('goo')
		assert_equal(false, @section.empty?)
		@section.paragraphs.pop
		assert_equal(true, @section.empty?)
	end
	def test_match
		assert_nil(@section.match(/foo/))	
		@section.subheading = 'foo'
		assert_instance_of(MatchData, @section.match(/foo/))
		assert_nil(@section.match(/bar/))	
		@section.paragraphs.push('bar')
		assert_instance_of(MatchData, @section.match(/bar/))
	end
	def test_to_s2
		@section.subheading = "Hallo!"
		par1 = @section.next_paragraph
		par1 << "schöne"
		par2 = @section.next_paragraph
		par2 << "Welt!"
		assert_equal("Hallo!\nschöne\nWelt!", @section.to_s)
	end
	def test_to_s__no_subheading
		paragraph = @section.next_paragraph
		paragraph << "foo"
		assert_equal("foo", @section.to_s)
	end
end
class TestChapter < Test::Unit::TestCase
	def setup
		@chapter = ODDB::Text::Chapter.new
	end
	def test_clean
		@chapter.heading = ' '
		section = @chapter.next_section
		@chapter.clean!
		assert_equal('', @chapter.heading)
		assert_equal([], @chapter.sections)
		section = @chapter.next_section
		paragraph = section.next_paragraph
		@chapter.clean!
		assert_equal([], @chapter.sections)
		section = @chapter.next_section
		paragraph = section.next_paragraph
		paragraph << 'foo'
		@chapter.clean!
		assert_equal([section], @chapter.sections)
	end
	def test_match
		assert_nil(@chapter.match(/foo/))	
		@chapter.heading = 'foo'
		assert_instance_of(MatchData, @chapter.match(/foo/))
		assert_nil(@chapter.match(/bar/))	
		@chapter.sections.push('bar')
		assert_instance_of(MatchData, @chapter.match(/bar/))
	end
	def test_next_section
		assert_equal(0, @chapter.sections.size)
		section = @chapter.next_section
		assert_instance_of(ODDB::Text::Section, section)
		assert_equal(1, @chapter.sections.size)
		section1 = @chapter.next_section
		assert_instance_of(ODDB::Text::Section, section1)
		assert_equal(1, @chapter.sections.size)
		assert_equal(section, section1)
		section.subheading = 'foo'
		section2 = @chapter.next_section
		assert_equal(2, @chapter.sections.size)
		assert_not_equal(section, section2)
	end
	def test_to_s3
		@chapter.heading = "Hallo!"
		sec1 = @chapter.next_section
		sec1.subheading = "Auch Hallo!"
		par1 = sec1.next_paragraph
		par1 << "Schöne foo..."
		par2 = sec1.next_paragraph
		par2 << "Schöne bar..."
		sec2 = @chapter.next_section
		sec2.subheading = "Nochmals Hallo!"
		par3 = sec2.next_paragraph
		par3 << "Schöne baz..."
		par4 = sec2.next_paragraph
		par4 << "Schöne Welt!"
		expected = <<-EOS
Hallo!
Auch Hallo!
Schöne foo...
Schöne bar...
Nochmals Hallo!
Schöne baz...
Schöne Welt!
		EOS
		assert_equal(expected.strip, @chapter.to_s)
	end
	def test_paragraphs
		expected = []
		['txt1', 'txt2', 'txt3'].each { |str|
			par = @chapter.next_section.next_paragraph
			par << str
			expected << par
		}
		assert_equal(expected, @chapter.paragraphs)
	end
	def test_to_s__no_heading
		section = @chapter.next_section
		section.subheading = "foo"
		assert_equal("foo", @chapter.to_s)
	end
end
class TestDocument < Test::Unit::TestCase
	def setup
		@document = ODDB::Text::Document.new
	end
	def test_update_values
		@document.update_values({:de	=>	'foobar'})
		assert_equal('foobar', @document.de)
		assert_equal('foobar', @document.fr)
		@document.update_values({:de	=>	'barbaz', :fr => 'ron'})
		assert_equal('barbaz', @document.de)
		assert_equal('ron', @document.fr)
		assert_equal('barbaz', @document.en)
	end
end
