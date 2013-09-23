#!/usr/bin/env ruby
# encoding: utf-8
# TestText -- oddb -- 10.09.2003 -- rwaltert@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'stub/odba'
gem 'minitest'
require 'minitest/autorun'
require 'model/text'
require 'flexmock'

module ODDB
  module Text
    class Paragraph
      attr_reader :formats
    end
  end
  class TestImageLink <Minitest::Test
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
        'src' => '/foo/bar.gif',
        'style' => nil
      }
      assert_equal(expected, @link.attributes)
    end
    def test_gsub
      @link.src = 'some url'
      @link.gsub!(/[aeiou]/) do |match| match.upcase end
      assert_equal 'sOmE Url', @link.src
    end
    def test_preformatted
      assert_equal true, @link.preformatted?
    end
    def test_to_s
      assert_equal '(image)', @link.to_s
    end
  end
  class TestFormat <Minitest::Test
    def setup
      @format = ODDB::Text::Format.new
    end
    def test_initialize
      @format.range
      assert_equal(0..-1, @format.range)
    end
    def test_start_writer
      @format.start = 3
      @format.range
      assert_equal(3..-1, @format.range)
    end
    def test_end_writer
      @format.end = 7
      @format.range
      assert_equal(0..7, @format.range)
    end
  end
  class TestParagraph <Minitest::Test
    def setup
      @paragraph = ODDB::Text::Paragraph.new
    end
    def test_access
      @paragraph << ' foo bar baz'
      assert_equal 'foo bar', @paragraph[1,7]
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
    def test_append2
      @paragraph.preformatted!
      @paragraph << "\tfoo\t"
      @paragraph << "bar"
      assert_equal('        foo     bar', @paragraph.text)
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
      @paragraph << " ≥ "
      @paragraph.set_format
      @paragraph << "Hallo Zürich!"
      assert_equal("Hallo Welt! ≥ Hallo Zürich!", @paragraph.to_s)
    end
    def test_to_s3
      @paragraph.preformatted!
      @paragraph << "     | Header1 | Header2\n"
      @paragraph << "------------------------\n"
      @paragraph << "Row1 |  Cell1  |  Cell2 \n"
      expected = <<-EOS
     | Header1 | Header2
------------------------
Row1 |  Cell1  |  Cell2 
      EOS
      assert_equal(expected, @paragraph.to_s)
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
    def test_append__hyphenated
      assert_equal('', @paragraph.text)
      @paragraph << " foo-\n"
      assert_equal('foo-', @paragraph.text)
      @paragraph << "bar"
      assert_equal('foobar', @paragraph.text)
    end
    def test_append__hyphenated__preformatted
      @paragraph.preformatted!
      assert_equal('', @paragraph.text)
      @paragraph << " foo-\n"
      assert_equal(" foo-\n", @paragraph.text)
      @paragraph << "bar"
      assert_equal(" foo-\nbar", @paragraph.text)
    end
    def test_gsub
      @paragraph << 'Some Text with largely lowercase letters'
      @paragraph.gsub! /[aeiou]/ do |match| match.upcase end
      assert_equal 'SOmE TExt wIth lArgEly lOwErcAsE lEttErs', @paragraph.to_s
      @paragraph << ' and some more'
      assert_equal 'SOmE TExt wIth lArgEly lOwErcAsE lEttErs and some more', @paragraph.to_s
    end
    def test_length
      assert_equal 0, @paragraph.length
      @paragraph << 'foo '
      assert_equal 3, @paragraph.length
      @paragraph << 'bar'
      assert_equal 7, @paragraph.length
    end
    def test_match
      @paragraph << 'Some Text with largely lowercase letters'
      assert_nil @paragraph.match 'X'
      match = @paragraph.match /text/i
      assert_instance_of MatchData, match
    end
    def test_strip
      @paragraph << ' foo bar '
      assert_equal 'foo bar', @paragraph.strip
    end
  end
  class	TestSection <Minitest::Test
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
    def test_gsub
      @section.subheading << 'subheading'
      @section.next_paragraph << 'a paragraph'
      @section.next_paragraph << 'another paragraph'
      @section.gsub! /[aeiou]/ do |match| match.upcase end
      assert_equal <<-EOS.strip, @section.to_s
sUbhEAdIng
A pArAgrAph
AnOthEr pArAgrAph
      EOS
    end
    def test_next_image
      img = @section.next_image
      assert_instance_of Text::ImageLink, img
      assert_equal [img], @section.paragraphs
    end
    def test_next_paragraph
      par1 = @section.next_paragraph
      par2 = @section.next_paragraph
      assert_equal par1.object_id, par2.object_id
      par1 << 'foo'
      par3 = @section.next_paragraph
      assert par1.object_id != par3.object_id
    end
  end
  class TestChapter <Minitest::Test
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
    def test_empty
      @chapter.heading << 'heading'
      assert_equal false, @chapter.empty?
      @chapter.heading.replace ''
      assert_equal true, @chapter.empty?
      @chapter.next_section.next_paragraph << 'paragraph'
      assert_equal false, @chapter.empty?
    end
    def test_gsub
      @chapter.heading << 'heading'
      section = @chapter.next_section
      section.subheading << 'subheading'
      section.next_paragraph << 'paragraph'
      @chapter.gsub! /[aeiou]/ do |match| match.upcase end
      assert_equal <<-EOS.strip, @chapter.to_s
hEAdIng
sUbhEAdIng
pArAgrAph
      EOS
    end
    def test_include
      assert_equal false, @chapter.include?(Text::Section.new)
      seq = @chapter.next_section
      assert_equal true, @chapter.include?(seq)
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
      assert(section != section2)
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
    def test_to_search
      @chapter.heading << 'heading'
      section = @chapter.next_section
      section.subheading << 'subheading'
      section.next_paragraph << 'paragraph'
      expected = "heading subheading paragraph"
      assert_equal expected, @chapter.to_search
    end
    def test_to_s__no_heading
      section = @chapter.next_section
      section.subheading = "foo"
      assert_equal("foo", @chapter.to_s)
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
  end
  class TestDocument <Minitest::Test
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
  class TestTable <Minitest::Test
    def setup
      @table = Text::Table.new
    end
    def test_cell
      @table.next_row!
      cell1 = @table.next_cell!
      @table << 'cell1'
      cell2 = @table.next_cell!
      @table << 'cell2'
      @table.next_row!
      cell3 = @table.next_cell!
      @table << 'cell3'
      cell4 = @table.next_cell!
      @table << 'cell4'
      assert_equal cell1, @table.cell(0,0)
      assert_equal cell2, @table.cell(0,1)
      assert_equal cell3, @table.cell(1,0)
      assert_equal cell4, @table.cell(1,1)      
    end
    def test_clean
      @table.next_row!
      cell1 = @table.next_cell!
      @table << 'foo'
      cell2 = @table.next_cell!
      @table.next_row!
      cell3 = @table.next_cell!
      cell4 = @table.next_cell!
      @table.clean!
      assert_equal <<-EOS.strip, @table.to_s
---
foo  
---
      EOS
    end
    def test_column_widths
      @table.next_row!
      cell1 = @table.next_cell!
      @table << 'cell1'
      cell2 = @table.next_cell!
      @table << 'cell2 longer'
      @table.next_row!
      cell3 = @table.next_cell!
      @table << 'cell3'
      cell4 = @table.next_cell!
      @table << 'cell4'
      assert_equal [5, 12], @table.column_widths
    end
    def test_current_cell
      @table.current_cell
      assert_nil @table.current_cell
      @table.next_row!
      assert_nil @table.current_cell
      cell1 = @table.next_cell!
      assert_equal cell1, @table.current_cell
      cell2 = @table.next_cell!
      assert_equal cell2, @table.current_cell
    end
    def test_current_row
      @table.current_row
      assert_nil @table.current_row
      row1 = @table.next_row!
      assert_equal row1, @table.current_row
      row2 = @table.next_row!
      assert_equal row2, @table.current_row
    end
    def test_each_normalized
      @table.next_row!
      cell1 = @table.next_cell!
      @table << 'cell1'
      @table.next_row!
      cell3 = @table.next_cell!
      @table << 'cell3'
      cell4 = @table.next_cell!
      @table << 'cell4'
      rows = []
      @table.each_normalized do |row|
        rows.push row
      end
      assert_equal [[cell1, nil], [cell3, cell4]], rows
    end
    def test_empty
      assert_equal true, @table.empty?
      @table.next_row!
      assert_equal true, @table.empty?
      @table.next_cell!
      assert_equal true, @table.empty?
      @table << 'cell1'
      assert_equal false, @table.empty?
    end
    def test_gsub
      @table.next_row!
      @table.next_cell!
      @table << 'cell1'
      @table.next_cell!
      @table << 'cell2'
      @table.next_row!
      @table.next_cell!
      @table << 'cell3'
      @table.next_cell!
      @table << 'cell4'
      @table.gsub! /[aeiou]/ do |match| match.upcase end
      assert_equal <<-EOS.strip, @table.to_s
------------
cEll1  cEll2  
------------
cEll3  cEll4  
------------
      EOS
    end
    def test_next_paragraph
      @table.next_row!
      @table.next_cell!
      @table << 'cell1'
      @table.next_paragraph
      @table << 'still cell1'
      assert_equal <<-EOS.strip, @table.to_s
-----------
cell1        
still cell1  
-----------
      EOS

    end
    def test_preformatted
      assert_equal true, @table.preformatted?
    end
    def test_to_s
      @table.next_row!
      @table.next_cell!
      @table << 'cell1'
      @table.next_cell!
      @table << 'cell2'
      @table.next_row!
      @table.next_cell!
      @table << 'cell3'
      @table.next_cell!
      @table << 'cell4'
      assert_equal <<-EOS.strip, @table.to_s
------------
cell1  cell2  
------------
cell3  cell4  
------------
      EOS
    end
    def test_to_s__wrapped
      @table.next_row!
      @table.next_cell!
      @table << 'This table needs to be wrapped'
      @table.next_cell!
      @table << 'Ideally, this test will use the hyphenator library'
      @table.next_row!
      @table.next_cell!
      @table << 'Hopefully it will work'
      @table.next_cell!
      @table << 'And we will see some hyphens'
      assert_equal <<-EOS.strip, @table.to_s(:width => 20)
--------------------
This     Ideally,      
table    this test     
needs    will use the  
to be    hyphenator    
wrapped  library       
--------------------
Hopef-   And we will   
ully it  see some      
will     hyphens       
work                   
--------------------
      EOS
    end
    def test_width
      @table.next_row!
      cell1 = @table.next_cell!
      @table << 'cell1'
      @table.next_row!
      cell3 = @table.next_cell!
      @table << 'cell3'
      cell4 = @table.next_cell!
      @table << 'cell4'
      assert_equal 2, @table.width
    end
  end
end
