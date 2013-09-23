#!/usr/bin/env ruby
#TestFachinfoWriter -- oddb -- 02.02.2004 -- mwalder@ywesee.com

$: << File.expand_path('../src', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'fachinfo_writer'
require 'model/text'
require 'date'

module ODDB
	module Text
		class Paragraph
			attr_writer :text
		end
	end
	module FiPDF
		class StubRegistration
			attr_accessor :generic_type
			attr_accessor :company_name
			def initialize(generic_type = nil)
				@generic_type = generic_type
			end
		end
		class FachinfoWriter
			remove_const :COLUMNS_FI
			COLUMNS_FI = 3
			remove_const :COLUMN_GAP_INDEX
			COLUMN_GAP_INDEX = 7.5
			remove_const :COLUMNS_INDEX
			COLUMNS_INDEX = 4
			remove_const :COLUMN_GAP_FI
			COLUMN_GAP_FI = 10
			remove_const :FIXED_WIDTH_FONT
			FIXED_WIDTH_FONT = "Courier"
			remove_const :FONT_SIZE_FIXED_WIDTH
			FONT_SIZE_FIXED_WIDTH = 5.3
			remove_const :MARGIN_BOTTOM
			MARGIN_BOTTOM = 20 
			remove_const :MARGIN_IN
			MARGIN_IN = 40
			remove_const :MARGIN_OUT
			MARGIN_OUT = 15
			remove_const :MARGIN_TOP
			MARGIN_TOP = 20
			remove_const :PAGE_NUMBER_SIZE
			PAGE_NUMBER_SIZE = 8
			remove_const :PAGE_NUMBER_YPOS
			PAGE_NUMBER_YPOS = 10
			remove_const :VARIABLE_WIDTH_FONT
			VARIABLE_WIDTH_FONT = "Helvetica"
			attr_accessor :rules, :fi_page_number, :flic_name, :substance_index, :ezPages, :first_line_of_page
			attr_writer :current_generic_type
			attr_reader :state_stack, :formats
			def save_pdf
				path = File.expand_path("data/test.pdf", File.dirname(__FILE__))
				File.open(path, "wb") { |f| f << to_s }
			end
			def drug_name_format
				format = Format.new
				format.spacing_before = -8
				format.size = 10
				format.margin = 3
				format.font = VARIABLE_WIDTH_FONT
				format
			end
			def company_name_format
				format = Format.new
				format.spacing_before = -1
				format.size = 7
				format.font = VARIABLE_WIDTH_FONT
				format.justification = :right
				format
			end
			def chapter_format
				format = Format.new
				format.spacing_before = -4
				format.size = 7
				format.font = VARIABLE_WIDTH_FONT
				format
			end
			def flic_name_format
				format = Format.new
				format.ypos = 825
				format.size = 10
				format.font = VARIABLE_WIDTH_FONT
				format
			end
			def section_format
				format = Format.new
				format.spacing_before = -1.5
				format.size = 7
				format.font = VARIABLE_WIDTH_FONT
				format
			end
			def paragraph_format
				format = Format.new
				format.spacing_before = -0.5
				format.spacing_after = -0.5
				format.size = 7
				format.font = VARIABLE_WIDTH_FONT
				format.justification = :full
				format
			end
			def preformatted_format
				format = Format.new
				format.spacing_before = -2.5
				format.spacing_after = -2.5
				format.size = 5.3
				format.font = FIXED_WIDTH_FONT
				format.justification = :left
				format
			end
			def chapter_index_format
				format = Format.new
				format.spacing_before = -3
				format.size = 7
				format.font = VARIABLE_WIDTH_FONT 
				format
			end
			def kombi_index_format
				format = Format.new
				format.spacing_before = -0.5
				format.size = 6
				format.font = VARIABLE_WIDTH_FONT 
				format
			end
			def text_index_format
				format = Format.new
				format.spacing_before = -0.5
				format.size = 5.5 
				format.justification = :left
				format.font = VARIABLE_WIDTH_FONT 
				format
			end
		end
	end
  class TestFachinfoWriter <Minitest::Test
    class StubFachinfoDocument	
      attr_accessor :chapters, :company_name, :name, :generic_type, :substance_names, :first_chapter
      def initialize
        @substance_names = []
      end
      def each_chapter(&block)
        @chapters.each(&block)
      end
      def company_name
        @company_name
      end
      def first_chapter
        @chapters.first
      end
    end
    class StubRule
      attr_writer :fulfilled
      def initialize(fulfilled = false)
        @fulfilled = fulfilled
      end
      def fulfilled?
        @fulfilled
      end
    end
    class StubRule1 < StubRule
      
    end
    class StubRule2 < StubRule
    end
    def setup
      @today = Date.today.to_s.delete "-"
      @chapter = ODDB::Text::Chapter.new
      @writer = ODDB::FiPDF::FachinfoWriter.new
    end
    def extract_result_lines(output, search, before, after)
      lines = output.split("\n")
      idx = nil
      lines.each_with_index { |line, index|
        if(line.index(search))
          idx = index
        end
      }
      lines[idx-before, before + after + 1].join("\n")
    end
    def test_add_substance_name
      fachinfo = StubFachinfoDocument.new
      fachinfo.name = "Ponstan"
      fachinfo.company_name = "Ywesee"
      fachinfo.generic_type = :generic
      fachinfo.substance_names = ["Zucker", "Salz"]
      @writer.fi_page_number = 1
      expected = { 
        "Zucker" =>	[
          ["Ponstan", "Ywesee", "1", "generic", "2", "anchor0"]
        ],
        "Salz"		=>	[
          ["Ponstan", "Ywesee", "1", "generic", "2", "anchor0"]
        ],
      }
      assert_equal(expected, @writer.add_substance_name(fachinfo))
    end
    def test_fachinfo_rule
      fachinfo = StubFachinfoDocument.new
      fachinfo.name = "Ponstan"
      fachinfo.company_name = "ywesee"
      fachinfo.generic_type = :generic
      ch1 = ODDB::Text::Chapter.new
      ch1.heading = "Zusammensetzung"
      sec1 = ch1.next_section
      sec1.subheading = "Wirkstoff"
      para1 = sec1.next_paragraph
      para1 << "paragraph 1 " * 10
      ch2 = ODDB::Text::Chapter.new
      ch2.heading = "Eigenschaften"
      sec2 = ch2.next_section
      sec2.subheading = "Hilfstoffe\n"
      para2 = sec2.next_paragraph
      para2 << "paragraph 2 " * 4
      fachinfo.chapters = [
        ch1,
      ]
      @writer.fi_new_page
      @writer.y  =  ODDB::FiPDF::FachinfoWriter::MARGIN_BOTTOM\
        + 8 * @writer.font_height(@writer.formats[:paragraph].size) 
      @writer.write_fachinfo(fachinfo)
      #@writer.write_substance_index
      #fachinfo2 = Marshal.load(Marshal.dump(fachinfo))
      #@writer.write_fachinfo(fachinfo2)
      #@writer.save_pdf
      #puts @writer.dump_bigvars
=begin
      expected = <<-EOS
  stream<
  <
  q<
  1.000 1.000 1.000 rg<
  35.000 821.890 183.427 -801.890 re f<
  0.1 w 1 J <
  Q<
  q<
  0.168 0.640 0.461 rg<
  218.427 803.882 183.427 18.008 re f<
  0.1 w 1 J <
  Q<
  q<
  0.635 1.000 0.627 rg<
  218.427 803.882 183.427 -64.524 re f<
  0.1 w 1 J <
  Q<
  <
  0.000 0.000 0.000 rg<
  BT 576.280 10.000 Td /F3 8.0 Tf (1) Tj ET<
  0.1 w 1 J <
  218.427 20.000 m 218.427 821.890 l S<
  q<
  0.1 w 1 J <
  Q<
  1.000 1.000 1.000 rg<
  BT 223.427 808.498 Td 0.000 Tw /F4 12.0 Tf (Ponstan) Tj ET<
  0.000 0.000 0.000 rg<
  BT 373.309 794.570 Td 0.000 Tw /F3 8.0 Tf (ywesee) Tj ET<
  BT 223.427 779.642 Td 0.000 Tw /F4 8.0 Tf (Zusammensetzung) Tj ET<
  BT 223.427 767.214 Td 4.023 Tw /F5 8.0 Tf (Wirkstoff) Tj /F3 8.0 Tf ( paragraph 1 paragraph 1 paragraph 1) Tj ET<
  BT 223.427 758.286 Td 2.213 Tw /F3 8.0 Tf (paragraph 1 paragraph 1 paragraph 1 paragraph 1) Tj ET<
  BT 223.427 749.358 Td 0.000 Tw /F3 8.0 Tf (paragraph 1 paragraph 1 paragraph 1) Tj ET<
  endstream<
      EOS
=end
      
      expected = <<-EOS
BT 223.427 810.330 Td /F1 10.0 Tf 0 Tr (Ponstan) Tj ET<
      EOS
      # NOTE: to avoid confusion about end-of-line whitespace, both
      #       expected and output have added "<"-signs at EOL
      output = @writer.render.gsub("\n", "<\n")
      possible_lines = []
      output.each_line { |line|
        if(line.index('Ponstan'))
          possible_lines << line
        end
      }
      message = "Expected: \n#{expected}\nin:\n#{possible_lines.join()}"
      assert_equal(true, possible_lines.include?(expected), message)
    end
    def test_combination_substances
      substances = 
      [
        ["Aonstan", "Ywesee", "1", "generic", "1"],
        ["Bonstan", "Ywesee", "1", "generic", "3"],
        ["Constan", "Ywesee", "1", "generic", "5"],
        ["Donstan", "Ywesee", "1", "generic", "6"], 
        ["Eonstan", "Ywesee", "1", "generic", "2"],
      ]
      expected = 
      [
        ["Bonstan", "Ywesee", "1", "generic", "3"],
        ["Constan", "Ywesee", "1", "generic", "5"],
        ["Eonstan", "Ywesee", "1", "generic", "2"],
      ]
      assert_equal(expected, @writer.combination_substances(substances))
    end
    def test_single_substances
      substances = [
        ["Aonstan", "Ywesee", "1", "generic", "3"],
        ["Bonstan", "Ywesee", "1", "generic", "1"],
        ["Constan", "Ywesee", "1", "generic", "1"],
        ["Donstan", "Ywesee", "1", "generic", "6"], 
        ["Eonstan", "Ywesee", "1", "generic", "1"],
      ]
      expected = [
        ["Bonstan", "Ywesee", "1", "generic", "1"],
        ["Constan", "Ywesee", "1", "generic", "1"],
        ["Eonstan", "Ywesee", "1", "generic", "1"],
      ]
      assert_equal(expected, @writer.single_substances(substances))
    end
    def test_heading
      @chapter.heading = "Ein Medikament"
      @writer.fi_new_page
      @writer.write_heading(@chapter)
      #@writer.save_pdf
      expected = <<-EOS
q<
BT 575.832 10.000 Td /F4 8.0 Tf 0 Tr (1) Tj ET<
1 w<
Q<
BT 40.000 813.798 Td /F1 7.0 Tf 0 Tr (Ein Medikament) Tj ET<
      EOS
      # NOTE: to avoid confusion about end-of-line whitespace, both
      #       expected and output have added "<"-signs at EOL
      output = @writer.render.gsub("\n", "<\n")
      result = extract_result_lines(output, 'Ein Medikament', 5, 0)
      message = "Expected: \n#{expected}\nin:\n#{result}"
      assert_not_nil(output.index(expected), message)
    end
=begin
    def test_write_fachinfo
      fachinfo = StubFachinfoDocument.new
      fachinfo.name = "Ponstan df df df df kjadlkjf alkjd f"
      fachinfo.company_name = "Ywesee"
      ch1 = ODDB::Text::Chapter.new
      ch1.heading = "Zusammensetzung"
      sec1 = ch1.next_section
      sec1.subheading = "Wirkstoff\n"
      para1 = sec1.next_paragraph
      para1 << "paragraph 1 " * 10
      ch2 = ODDB::Text::Chapter.new
      ch2.heading = "Eigenschaften"
      sec2 = ch2.next_section
      sec2.subheading = "Hilfstoffe\n"
      para2 = sec2.next_paragraph
      para2 << "paragraph 2 " * 4
      para3 = sec2.next_paragraph
      para3 << "paragraph 3 in section 2 " * 7
      ch3 = ODDB::Text::Chapter.new
      ch3.heading = "Schwangerschaft"
      sec3 = ch3.next_section
      sec3.subheading = "Krankheit"
      para4 = sec3.next_paragraph
      para4 << "paragraph 4 " * 321
      para5 = sec3.next_paragraph
      para5 << "preformatted " * 12
      para5.preformatted!
      ch4 = ODDB::Text::Chapter.new
      ch4.heading << "Informationen"
      sec4 = ch4.next_section
      para6 = sec4.next_paragraph
      para6 << "Paragraph6 " *14
      fachinfo.chapters = [
        ch1,
        ch2,
        ch3,
        ch4,
        ch1,
        ch2,
        ch3,
        ch4,
      ]
      fachinfo.generic_type = :original
      @writer.fi_new_page
      @writer.first_line_of_page = true
      #	@writer.y = ODDB::FiPDF::FachinfoWriter::MARGIN_BOTTOM + @writer.calculate_drug_name("<b>"+fachinfo.name+"</b>") + @writer.calculate_company_name(fachinfo.company_name) + @writer.calculate_heading(fachinfo.chapters[0]) + @writer.calculate_section(fachinfo.chapters[0].sections[0])[:min_page_break_y]
      @writer.y = 112
      @writer.write_fachinfo(fachinfo)
      fachinfo.generic_type = :generic
      @writer.write_fachinfo(fachinfo)
      fachinfo.generic_type = :unknown
      @writer.write_fachinfo(fachinfo)
      @writer.write_fachinfo(fachinfo)
      @writer.write_fachinfo(fachinfo)
      #@writer.write_fachinfo(fachinfo, "ywesee", :generic)
      #@writer.write_fachinfo(fachinfo, "Documed", :original)
      #@writer.write_fachinfo(fachinfo, "pro-generika", :unknown)
      @writer.write_substance_index
      #@writer.save_pdf
    end
    def test_write_internal_link
      product = ["Ponstan", "Ywesee", 1, "generic", "1", "anchor1"]
      @writer.fi_new_page
      @writer.set_page_element_type(:page_type_substance_index)
      @writer.write_tuple(product)
      #@writer.save_pdf
      expected = <<-EOS
  16 0 obj<
  << /Type /Annot<
  /Subtype /Link<
  /A 17 0 R<
  /Border [0 0 0]<
  /H /I<
  /Rect [40.0000 821.8900 213.4267 807.9365 ]<
  >><
  endobj<
      EOS
      output = @writer.render.gsub("\n", "<\n")
      message = "Expected: \n#{expected}\nin:\n#{output}"
      assert_not_nil(output.index(expected), message)
    end
    def test_write_drug_name_link
      @writer.fi_new_page
      @writer.write_drug_name("FooBaar®")
      #@writer.save_pdf
      expected = <<-EOS
    /URI (http://www.oddb.org/de/gcc/search/search_query/Foohallo)<
    EOS
    end
    def test_write_flic_name_odd_page
      @writer.fi_page_number = 1
      @writer.flic_name = "Ponstan"
      @writer.write_flic_name
      #@writer.save_pdf
      expected = <<-EOS
  BT 543.590 825.000 Td /F3 10.0 Tf 0 Tr (Ponstan) Tj ET<
      EOS
      output = @writer.render.gsub("\n", "<\n")
      message = "Expected: \n#{expected}\nin:\n#{output}"
      assert_not_nil(output.index(expected), message)
    end
    def test_write_flic_name_even_page
      @writer.fi_page_number = 2
      @writer.flic_name = "Ponstan"
      @writer.write_flic_name
      #@writer.save_pdf
      expected = <<-EOS
  BT 15.000 825.000 Td /F3 10.0 Tf 0 Tr (Ponstan) Tj ET<
      EOS
      output = @writer.render.gsub("\n", "<\n")
      message = "Expected: \n#{expected}\nin:\n#{output}"
      assert_not_nil(output.index(expected), message)
    end
=end
    def test_write_flic_name_one_page
      fachinfo = StubFachinfoDocument.new
      fachinfo.name = "Ponstan"
      fachinfo.company_name = "Ywesee"
      ch1 = ODDB::Text::Chapter.new
      ch1.heading = "Zusammensetzung"
      fachinfo.chapters = [
        ch1,
      ]
      @writer.fi_new_page
      @writer.write_fachinfo(fachinfo)
      #so that the last pdf page has a flic name
      @writer.write_flic_name
      #@writer.save_pdf
      assert_equal("Ponstan", @writer.flic_name)
    end
    def test_write_flic_name_three_pages
      fachinfo = StubFachinfoDocument.new
      fachinfo.name = "Ponstan"
      fachinfo.company_name = "Ywesee"
      ch1 = ODDB::Text::Chapter.new
      ch1.heading = "Zusammensetzung"
      section = ch1.next_section
      section = ch1.next_section
      section.subheading = "Wirkstoff"
      para1 = section.next_paragraph
      para1 << "paragraph 1 " * 5
      fachinfo.chapters = [
        ch1,
        ch1,
        ch1,
        ch1,
        ch1,
      ]
      @writer.fi_new_page
      @writer.y = 200
      #@writer.new_page
      @writer.write_fachinfo(fachinfo)
      assert_equal("Ponstan", @writer.flic_name)
      @writer.new_page
      @writer.new_page
      assert_equal("Ponstan", @writer.flic_name)
      @writer.new_page
      assert_equal("Ponstan", @writer.flic_name)
      @writer.new_page
      @writer.new_page
      fachinfo2 = StubFachinfoDocument.new
      fachinfo2.name = "Aspirin"
      fachinfo2.company_name = "Ywesee"
      ch1 = ODDB::Text::Chapter.new
      ch1.heading = "Zusammensetzung2"
      fachinfo2.chapters = [
        ch1,
      ]
      @writer.new_page
      @writer.write_fachinfo(fachinfo2)
      fachinfo3 = StubFachinfoDocument.new
      fachinfo3.name = "Penicilin"
      fachinfo3.company_name = "Ywesee"
      ch1 = ODDB::Text::Chapter.new
      ch1.heading = "Zusammensetzung2"
      fachinfo3.chapters = [
        ch1,
      ]
      @writer.write_fachinfo(fachinfo3)
      #so that the last pdf page has a flic name
      @writer.write_flic_name
      #@writer.save_pdf
      assert_equal("Penicilin",@writer.flic_name)
    end
    def test_write_flic_names_even_page
      fachinfo = StubFachinfoDocument.new
      fachinfo.name = "Ponstan"
      fachinfo.company_name = "Ywesee"
      ch1 = ODDB::Text::Chapter.new
      ch1.heading = "Zusammensetzung"
      fachinfo.chapters = [
        ch1,
        ch1,
        ch1,
        ch1,
      ]
      @writer.fi_new_page
      @writer.fi_page_number = 2
      @writer.write_fachinfo(fachinfo)
      fachinfo.name = "Autorix"
      @writer.write_fachinfo(fachinfo)
      fachinfo.name = "Porzelanius"
      @writer.write_fachinfo(fachinfo)
      fachinfo.name = "Milzbrand"
      @writer.write_fachinfo(fachinfo)
      fachinfo.name = "Aspirinuale"
      @writer.write_fachinfo(fachinfo)
      fachinfo.name = "Merfen"
      @writer.write_fachinfo(fachinfo)
      fachinfo.name = "Aproz"
      @writer.write_fachinfo(fachinfo)
      #@writer.save_pdf
      @writer.write_flic_name
      assert_equal("Ponstan", @writer.flic_name)
    end
    def test_write_flic_names_odd_page
      fachinfo = StubFachinfoDocument.new
      fachinfo.name = "Ponstan"
      fachinfo.company_name = "Ywesee"
      ch1 = ODDB::Text::Chapter.new
      ch1.heading = "Zusammensetzung"
      fachinfo.chapters = [
        ch1,
        ch1,
        ch1,
        ch1,
      ]
      @writer.fi_new_page
      @writer.write_fachinfo(fachinfo)
      fachinfo.name = "Autorix"
      @writer.write_fachinfo(fachinfo)
      fachinfo.name = "Porzelanius"
      @writer.write_fachinfo(fachinfo)
      fachinfo.name = "Milzbrand"
      @writer.write_fachinfo(fachinfo)
      fachinfo.name = "Aspirinuale"
      @writer.write_fachinfo(fachinfo)
      fachinfo.name = "Merfen"
      @writer.write_fachinfo(fachinfo)
      fachinfo.name = "Aproz"
      @writer.write_fachinfo(fachinfo)
      #@writer.save_pdf
      assert_equal("Aproz", @writer.flic_name)
    end
    def test_write_paragraph
      @writer.fi_new_page
      section = @chapter.next_section
      paragraph = section.next_paragraph
      paragraph << "Kein Preformatted"
      p_wrapper = ODDB::FiPDF::ParagraphWrapper.new(paragraph)
      @writer.write_paragraph(p_wrapper)
      #@writer.save_pdf
      expected = <<-EOS
BT 40.000 813.798 Td /F4 7.0 Tf 0 Tr (Kein Preformatted) Tj ET<
      EOS
      # NOTE: to avoid confusion about end-of-line whitespace, both
      #       expected and output have added "<"-signs at EOL
      output = @writer.render.gsub("\n", "<\n")
      message = "Expected: \n#{expected}\nin:\n#{output}"
      assert_not_nil(output.index(expected), message)
    end
    def test_write_paragraph_strip_1_letter
      @writer.fi_new_page
      section = @chapter.next_section
      paragraph = section.next_paragraph
      paragraph << "-nerfiges - am anfang"
      p_wrapper = ODDB::FiPDF::ParagraphWrapper.new(paragraph)
      @writer.write_paragraph(p_wrapper)
      #@writer.save_pdf
      expected = <<-EOS
BT 40.000 813.798 Td /F4 7.0 Tf 0 Tr (nerfiges - am anfang) Tj ET<
      EOS
      # NOTE: to avoid confusion about end-of-line whitespace, both
      #       expected and output have added "<"-signs at EOL
      output = @writer.render.gsub("\n", "<\n")
      message = "Expected: \n#{expected}\nin:\n#{output}"
      assert_not_nil(output.index(expected), message)
    end
    def test_write_paragraph__preformatted
      @writer.fi_new_page
      section = @chapter.next_section
      paragraph = section.next_paragraph
      paragraph << "Preformatted"
      paragraph.preformatted!
      p_wrapper = ODDB::FiPDF::ParagraphWrapper.new(paragraph)
      @writer.write_paragraph(p_wrapper)
      #@writer.save_pdf
      expected = <<-EOS
BT 40.000 816.298 Td /F2 5.3 Tf 0 Tr (Preformatted) Tj ET<
      EOS
      # NOTE: to avoid confusion about end-of-line whitespace, both
      #       expected and output have added "<"-signs at EOL
      output = @writer.render.gsub("\n", "<\n")
      message = "Expected: \n#{expected}\nin:\n#{output}"
      assert_not_nil(output.index(expected), message)
    end
    def test_write_section__preformatted
      @writer.fi_new_page
      section = @chapter.next_section
      section.subheading = "Subheading ohne NewLine"
      paragraph = section.next_paragraph
      paragraph << "Paragraph 1"
      paragraph2 = section.next_paragraph
      paragraph2 << "Preformatted Paragraph"
      paragraph2.preformatted!
      paragraph3 = section.next_paragraph
      paragraph3 << "Paragraph 3"
      s_wrapper = ODDB::FiPDF::SectionWrapper.new(section)
      @writer.write_section(s_wrapper)
      #@writer.save_pdf
      expected = <<-EOS
BT 40.000 813.798 Td /F5 7.0 Tf 0 Tr (Subheading ohne NewLine ) Tj /F4 7.0 Tf 0 Tr (Paragraph 1) Tj ET<
BT 40.000 805.207 Td /F2 5.3 Tf 0 Tr (Preformatted Paragraph) Tj ET<
BT 40.000 794.115 Td /F4 7.0 Tf 0 Tr (Paragraph 3) Tj ET<
      EOS
      # NOTE: to avoid confusion about end-of-line whitespace, both
      #       expected and output have added "<"-signs at EOL
      output = @writer.render.gsub("\n", "<\n")
      result = extract_result_lines(output, 'Subheading', 1, 2)
      message = "Expected: \n#{expected}\nin:\n#{result}"
      assert_not_nil(output.index(expected), message)
    end
    def test_write_section__newline_subheading
      @writer.fi_new_page
      section = @chapter.next_section
      section.subheading = "Subheading mit Newline\n"
      paragraph = section.next_paragraph
      paragraph << "Fliesstext"
      paragraph2 = section.next_paragraph
      paragraph2 << "Noch ein Paragraph"
      s_wrapper = ODDB::FiPDF::SectionWrapper.new(section)
      @writer.write_section(s_wrapper)
      #@writer.save_pdf
      expected = <<-EOS
BT 40.000 813.798 Td /F5 7.0 Tf 0 Tr (Subheading mit Newline) Tj ET<
BT 40.000 805.206 Td /F4 7.0 Tf 0 Tr (Fliesstext) Tj ET<
BT 40.000 796.114 Td /F4 7.0 Tf 0 Tr (Noch ein Paragraph) Tj ET<
      EOS
      # NOTE: to avoid confusion about end-of-line whitespace, both
      #       expected and output have added "<"-signs at EOL
      output = @writer.render.gsub("\n", "<\n")
      result = extract_result_lines(output, 'Subheading', 1, 2)
      message = "Expected: \n#{expected}\nin:\n#{result}"
      assert_not_nil(output.index(expected), message)
    end
    def test_write_section__inline_subheading
      section = @chapter.next_section
      section.subheading = "Subheading ohne Newline"
      paragraph = section.next_paragraph
      paragraph << "Fliesstext mit hoffentlich Umbruchgemässer Länge" 
      paragraph2 = section.next_paragraph
      paragraph2 << "Ein zweiter Paragraph, so fürs Gemüt"
      s_wrapper = ODDB::FiPDF::SectionWrapper.new(section)
      @writer.fi_new_page
      @writer.write_section(s_wrapper)
      #@writer.save_pdf
      expected = <<-EOS
BT 40.000 813.798 Td 3.016 Tw /F5 7.0 Tf 0 Tr (Subheading ohne Newline ) Tj /F4 7.0 Tf 0 Tr (Fliesstext mit hoffentlich) Tj ET<
BT 40.000 805.706 Td 0.000 Tw /F4 7.0 Tf 0 Tr (Umbruchgemässer Länge) Tj ET<
BT 40.000 796.614 Td 0.000 Tw /F4 7.0 Tf 0 Tr (Ein zweiter Paragraph, so fürs Gemüt) Tj ET<
      EOS
      # NOTE: to avoid confusion about end-of-line whitespace, both
      #       expected and output have added "<"-signs at EOL
      output = @writer.render.gsub("\n", "<\n")
      result = extract_result_lines(output, 'Subheading', 1, 2)
      message = "Expected: \n#{expected}\nin:\n#{result}"
      assert_not_nil(output.index(expected), message)
    end
    def test_change_column_count
      @writer.page_type_standard
      @writer.text("The rest of the File", 10)
      @writer.new_page
      @writer.text('and its second column')
      @writer.new_page(true, @writer.first_page, :before)
     # @writer.col_num = 1
      @writer.page_type_substance_index
      @writer.text('index 1')
      @writer.new_page
      colnum =	@writer.column_number
      @writer.text('index 2')
      #@writer.save_pdf
      assert_equal(1, colnum)
    end
=begin
    def test_write_index
      @writer.page_type_standard
      @writer.text("The rest of the File", 10)
      @writer.new_page
      @writer.new_page
      @writer.new_page
      products = [
        ["Ponstan", "Ywesee", 1, :generic, "2"],
      ]
      @writer.substance_index.store("Penicilin", products[0])
      @writer.prepare_substance_index
      @writer.new_page
      @writer.new_page
      @writer.new_page
      @writer.set_page_element_type(:page_type_substance_index)
      @writer.new_page
      @writer.instance_variable_set("@first_line_of_page", false)
      @writer.y  =  @writer.bottom_margin +
         1 * @writer.font_height(@writer.formats[:chapter_index].size) \
        + 2 * @writer.font_height(@writer.formats[:text_index].size) \
        + 1 * @writer.font_height(@writer.formats[:kombi_index].size) \
     - (@writer.formats[:kombi_index].spacing_before("foo") + @writer.formats[:chapter_index].spacing_before("foo") + @writer.formats[:text_index].spacing_before("foo")) - 0.1
      @writer.write_index
      #@writer.save_pdf
      expected = <<-EOS
BT 151.945 813.798 Td /F1 7.0 Tf 0 Tr (Penicilin) Tj ET<
BT 151.945 806.362 Td /F5 6.0 Tf 0 Tr (Kombinationen) Tj ET<
0.000 0.400 0.000 rg<
BT 151.945 800.004 Td /F3 5.5 Tf 0 Tr (Ponstan \\(1\\)) Tj ET<
BT 151.945 793.646 Td /F5 5.5 Tf 0 Tr (Ywesee) Tj ET<
      EOS
      # NOTE: to avoid confusion about end-of-line whitespace, both
      #       expected and output have added "<"-signs at EOL
      output = @writer.render.gsub("\n", "<\n")
      result = extract_result_lines(output, 'Penicilin', 0, 4)
      message = "Expected: \n#{expected}\nin:\n#{result}"
      assert_not_nil(output.index(expected), message)
    end
    def test_widow_combination
      @writer.page_type_standard
      @writer.text("The rest of the File", 10)
      products = [
        ["Ponstan", "Ywesee", 1, :generic, "2"],
      ]
      @writer.substance_index.store("Penicilin", products[0])
      @writer.prepare_substance_index
      @writer.first_line_of_page = false
      @writer.y  = ODDB::FiPDF::FachinfoWriter::MARGIN_BOTTOM \
        + 2 * @writer.font_height(@writer.formats[:text_index].size) \
        + 1 * @writer.font_height(@writer.formats[:chapter_index].size) \
        + 1 * @writer.font_height(@writer.formats[:kombi_index].size) \
        - (@writer.formats[:kombi_index].spacing_before("foo")\
        + 1 * @writer.formats[:text_index].spacing_before("foo") + @writer.formats[:chapter_index].spacing_before("foo")) - 0.001 
      @writer.write_index
      #@writer.save_pdf
      expected = <<-EOS
  BT 40.000 805.706 Td /F1 14.0 Tf 0 Tr ( WIRKSTOFFREGISTER ) Tj ET<
  0.000 0.000 0.000 rg<
  0.1 w 1 J <
  173.195 20.000 m 173.195 791.890 l S<
  BT 176.945 783.798 Td /F1 7.0 Tf 0 Tr (Penicilin) Tj ET<
  BT 176.945 776.362 Td /F5 6.0 Tf 0 Tr (Kombinationen) Tj ET<
  0.000 0.400 0.000 rg<
  BT 176.945 770.004 Td /F3 5.5 Tf 0 Tr (Ponstan \\(1\\)) Tj ET<
      EOS
      # NOTE: to avoid confusion about end-of-line whitespace, both
      #       expected and output have added "<"-signs at EOL
      output = @writer.render.gsub("\n", "<\n")
      result = extract_result_lines(output, 'WIRKSTOFF', 0, 8)
      message = "Expected: \n#{expected}\nin:\n#{result}"
      assert_not_nil(output.index(expected), message)
    end
    def test_write_combination
      @writer.page_type_standard
      @writer.text("The rest of the File", 10)
      @writer.new_page
      @writer.new_page
      @writer.new_page
      products = [
        ["FOO", "Ywesee", 1, :generic, "1"],
        ["Ponstan", "Ywesee", 1, :generic, "2"],
      ]
      @writer.substance_index.store("Penicilin", products[0])
      @writer.substance_index.store("Penicilin", products[1])
      @writer.prepare_substance_index
      @writer.new_page
      @writer.new_page
      @writer.new_page
      @writer.set_page_element_type(:page_type_substance_index)
      @writer.new_page
      @writer.first_line_of_page = false
      @writer.y  = ODDB::FiPDF::FachinfoWriter::MARGIN_BOTTOM \
        + 4 * @writer.font_height(@writer.formats[:text_index].size) \
        + 1 * @writer.font_height(@writer.formats[:chapter_index].size) \
        + 1 * @writer.font_height(@writer.formats[:kombi_index].size) \
        - (@writer.formats[:kombi_index].spacing_before("foo")\
        + 2 * @writer.formats[:text_index].spacing_before("foo") + @writer.formats[:chapter_index].spacing_before("foo")) - 2
      @writer.write_index
      #		@writer.save_pdf
      expected = <<-EOS
  BT 151.945 814.954 Td /F5 6.0 Tf 0 Tr (Kombinationen) Tj ET<
  0.000 0.400 0.000 rg<
  BT 151.945 808.596 Td /F3 5.5 Tf 0 Tr (Ponstan \\(1\\)) Tj ET<
  BT 151.945 802.238 Td /F5 5.5 Tf 0 Tr (Ywesee) Tj ET<
      EOS
      # NOTE: to avoid confusion about end-of-line whitespace, both
      #       expected and output have added "<"-signs at EOL
      output = @writer.render.gsub("\n", "<\n")
      result = extract_result_lines(output, 'Penicilin', 0, 12)
      message = "Expected: \n#{expected}\nin:\n#{result}"
      assert_not_nil(output.index(expected), message)
    end
    def test_write_tuple
      @writer.set_page_element_type(:page_type_substance_title)
      @writer.fi_new_page
      product = ["Ponstan", "Ywesee", 1, "generic", "1"]
      @writer.prepare_substance_index
      @writer.new_page
      @writer.new_page
      @writer.new_page
      @writer.set_page_element_type(:page_type_substance_index)
      @writer.new_page
      @writer.first_line_of_page = false
      @writer.y  = 2 * @writer.font_height(\
        @writer.formats[:text_index].size) \
        + ODDB::FiPDF::FachinfoWriter::MARGIN_BOTTOM \
        - 1 * @writer.formats[:text_index].spacing_before(\
        "fooBaar") - 0.01
      @writer.write_tuple(product)
      #		@writer.save_pdf
      expected = <<-EOS
  BT 151.945 815.532 Td /F3 5.5 Tf 0 Tr (Ponstan \\(1\\)) Tj ET<
  BT 151.945 809.174 Td /F5 5.5 Tf 0 Tr (Ywesee) Tj ET<
      EOS
      # NOTE: to avoid confusion about end-of-line whitespace, both
      #       expected and output have added "<"-signs at EOL
      output = @writer.render.gsub("\n", "<\n")
      result = extract_result_lines(output, 'Ponstan', 1, 1)
      message = "Expected: \n#{expected}\nin:\n#{result}"
      assert_not_nil(output.index(expected), message)
    end
    def test_write_tuple__company_on_2_lines
      @writer.set_page_element_type(:page_type_substance_index)
      @writer.fi_new_page
      product = ["PonstanPonstanPonstanPonstanPonstanPonstan und wieder Ponstan", "Ywesee", 1, "generic", "1"]
      @writer.prepare_substance_index
      @writer.new_page
      @writer.new_page
      @writer.new_page
      @writer.set_page_element_type(:page_type_substance_index)
      @writer.new_page
      @writer.first_line_of_page = false
      @writer.y  = 3 * @writer.font_height(\
        @writer.formats[:text_index].size) \
        + ODDB::FiPDF::FachinfoWriter::MARGIN_BOTTOM \
        - 1 * @writer.formats[:text_index].spacing_before(\
        "fooBaar") - 0.001
      @writer.write_tuple(product)
      #		@writer.save_pdf
      expected = <<-EOS
  BT 151.945 815.532 Td /F3 5.5 Tf 0 Tr (PonstanPonstanPonstanPonstanPonstanPonstan) Tj ET<
  BT 151.945 809.174 Td /F3 5.5 Tf 0 Tr (und wieder Ponstan \\(1\\)) Tj ET<
  BT 151.945 802.816 Td /F5 5.5 Tf 0 Tr (Ywesee) Tj ET<
      EOS
      # NOTE: to avoid confusion about end-of-line whitespace, both
      #       expected and output have added "<"-signs at EOL
      output = @writer.render.gsub("\n", "<\n")
      result = extract_result_lines(output, 'Ponstan', 1, 2)
      message = "Expected: \n#{expected}\nin:\n#{result}"
      assert_not_nil(output.index(expected), message)
    end
=end
    def test_add_destination
      @writer.fi_new_page
      @writer.write_drug_name("<b>Foobaar</b>")
      #@writer.save_pdf
      expected = <<-EOF
[6 0 R /XYZ 40 821.89 0]<
      EOF
      # NOTE: to avoid confusion about end-of-line whitespace, both
      #       expected and output have added "<"-signs at EOL
      output = @writer.render.gsub("\n", "<\n")
      message = "Expected: \n#{expected}\nin:\n#{output}"
      assert_not_nil(output.index(expected), message)
    end
    def test_tuple_to_paragraph
      tuple = ["Ponstan", "Ywesee", 1, :generic, "2"]
      wrapper = @writer.wrap_tuple(tuple)
      assert_instance_of(ODDB::FiPDF::ParagraphWrapper, wrapper)
      assert_equal("Ponstan (1)<i>\nYwesee</i>", wrapper.text)
    end
=begin
    def test_write_substance_index_3_pages
      @writer.page_type_standard
      @writer.text("The rest of the File", 10)
      @writer.new_page
      @writer.text('and its second column')
      products = [
        ["Ponstan", "Ywesee", 1, :generic, "2"],
        ["Mefenamings", "Mefa", 1, :original, "3"],
        ["Acid", "Mefa", 1, :original, "1"],
        ["Panadol", "Mefa", 1, :original, "4"],
        ["Viagra", "Mefa", 1, :unknown,"1"]
      ]
      20.times { |var|
        products.each { |product|
          @writer.substance_index.store("Penicilin", product)
          @writer.substance_index.store("Anabolika", product)
          @writer.substance_index.store("Viagra", product)
          @writer.substance_index.store("Penicilin" + var.to_s, product)
          @writer.substance_index.store("Penicilin", product)
          @writer.substance_index.store("Merfen", product)
        }
      }
      @writer.write_substance_index
      expected = <<-EOF
/Kids [14 0 R<
494 0 R<
956 0 R<
6 0 R<
]<
      EOF
      # NOTE: to avoid confusion about end-of-line whitespace, both
      #       expected and output have added "<"-signs at EOL
      output = @writer.render.gsub("\n", "<\n")
      result = extract_result_lines(output, 'Ponstan', 1, 1)
      message = "Expected: \n#{expected}\nin:\n#{result}"
      assert_not_nil(output.index(expected), message)
    end
=end
    def test_write_page_numbers
      @writer.fi_new_page
      @writer.write_page_number(2)
      @writer.new_page
      @writer.write_page_number(3333333)
      #@writer.save_pdf
      expected = [
        "BT 575.832 10.000 Td /F4 8.0 Tf 0 Tr (1) Tj ET<",
        "BT 15.000 10.000 Td /F4 8.0 Tf 0 Tr (2) Tj ET<",
        "BT 549.144 10.000 Td /F4 8.0 Tf 0 Tr (3333333) Tj ET<",
      ]
      # NOTE: to avoid confusion about end-of-line whitespace, both
      #       expected and output have added "<"-signs at EOL
      output = @writer.render.gsub("\n", "<\n")
      expected.each { |line| 
        message = "Expected: \n#{line}\nin:\n#{output}"
        assert_not_nil(output.index(line), message)
      }
    end
=begin
    def test_new_page
      # TODO: what does this test test?
      @chapter.heading = "The Tale of the Fox"
      s1 = @chapter.next_section
      s1.subheading = "The Fox and the lazy Dogs\n"
      p1 = s1.next_paragraph
      p1 << "The quick brown Fox jumped over the lazy Dogs! " * 50
      @writer.write_chapter(@chapter)
      @writer.write_chapter(@chapter)
      @writer.write_chapter(@chapter)
      @writer.write_chapter(@chapter)
      @writer.write_chapter(@chapter)
      #@writer.save_pdf
      expected = <<-EOS
  %PDF-1.3
  %âãÏÓ

  1 0 obj
  << /Type /Catalog
  /Outlines 2 0 R
  /Pages 3 0 R>>
  endobj
  2 0 obj
  << /Type /Outlines /Count 0 >>
  endobj
  3 0 obj
  << /Type /Pages
  /Kids [6 0 R
  14 0 R
  ]
  /Count 2
  /Resources <<
  /ProcSet 4 0 R
  /Font << 
  /F1 9 0 R
  /F2 11 0 R
  /F3 13 0 R >>
  >>
  /MediaBox [0 0 595.28 841.89]
   >>
  endobj
  4 0 obj
  [/PDF /Text ]
  endobj
  5 0 obj
  <<
  /CreationDate (D:#{@today})
  /Producer (Ruby PDF::Writer, http://www.halostatue.ca/)
  >>
  endobj
  6 0 obj
  << /Type /Page
  /Parent 3 0 R
  /Contents 7 0 R
  >>
  endobj
  7 0 obj
  <<
  /Length 24865 >>
  stream

  q
  0.999 0.999 0.999 rg
  25.000 821.890 570.280 801.890 re f

  Q
  q
  0.999 0.999 0.999 rg
  213.427 821.890 570.280 801.890 re f
  1 w 1 J  [ 0 10 ] 0 d
  Q
  q
  0.999 0.999 0.999 rg
  401.853 821.890 570.280 801.890 re f
  1 w 1 J  [ 0 10 ] 0 d
  Q

  0.000 0.000 0.000 rg
  BT 579.720 15.000 Td /F1 10.0 Tf 0 Tr (1) Tj ET
  BT 30.000 812.642 Td /F2 8.0 Tf 0 Tr (The Tale of the Fox) Tj ET
  BT 30.000 799.894 Td /F3 8.0 Tf 0 Tr (The Fox and the lazy Dogs) Tj /F1 8.0 Tf 0 Tr () Tj ET
  BT 30.000 788.146 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 778.898 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 769.650 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 760.402 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 751.154 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 741.906 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 732.658 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 723.410 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 714.162 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 704.914 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 695.666 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 686.418 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 677.170 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 667.922 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 658.674 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 649.426 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 640.178 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 630.930 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 621.682 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 612.434 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 603.186 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 593.938 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 584.690 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 575.442 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 566.194 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 556.946 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 547.698 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 538.450 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 529.202 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 519.954 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 510.706 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 501.458 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 492.210 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 482.962 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 473.714 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 464.466 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 455.218 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 445.970 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 436.722 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 427.474 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 418.226 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 408.978 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 399.730 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 390.482 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 381.234 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 371.986 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 362.738 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 353.490 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 344.242 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 334.994 Td 0.000 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 319.746 Td 0.000 Tw /F2 8.0 Tf 0 Tr (The Tale of the Fox) Tj ET
  BT 30.000 306.998 Td 0.000 Tw /F3 8.0 Tf 0 Tr (The Fox and the lazy Dogs) Tj /F1 8.0 Tf 0 Tr () Tj ET
  BT 30.000 295.250 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 286.002 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 276.754 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 267.506 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 258.258 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 249.010 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 239.762 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 230.514 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 221.266 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 212.018 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 202.770 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 193.522 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 184.274 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 175.026 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 165.778 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 156.530 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 147.282 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 138.034 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 128.786 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 119.538 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 110.290 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 101.042 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 91.794 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 82.546 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 73.298 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 64.050 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 54.802 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 45.554 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 36.306 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 30.000 27.058 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  1 w 1 J  [ 0 10 ] 0 d
  213.427 20.000 m 213.427 821.890 l S
  BT 218.427 821.890 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 812.642 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 803.394 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 794.146 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 784.898 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 775.650 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 766.402 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 757.154 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 747.906 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 738.658 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 729.410 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 720.162 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 710.914 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 701.666 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 692.418 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 683.170 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 673.922 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 664.674 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 655.426 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 646.178 Td 0.000 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 630.930 Td 0.000 Tw /F2 8.0 Tf 0 Tr (The Tale of the Fox) Tj ET
  BT 218.427 618.182 Td 0.000 Tw /F3 8.0 Tf 0 Tr (The Fox and the lazy Dogs) Tj /F1 8.0 Tf 0 Tr () Tj ET
  BT 218.427 606.434 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 597.186 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 587.938 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 578.690 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 569.442 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 560.194 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 550.946 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 541.698 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 532.450 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 523.202 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 513.954 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 504.706 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 495.458 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 486.210 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 476.962 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 467.714 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 458.466 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 449.218 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 439.970 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 430.722 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 421.474 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 412.226 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 402.978 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 393.730 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 384.482 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 375.234 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 365.986 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 356.738 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 347.490 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 338.242 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 328.994 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 319.746 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 310.498 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 301.250 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 292.002 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 282.754 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 273.506 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 264.258 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 255.010 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 245.762 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 236.514 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 227.266 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 218.018 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 208.770 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 199.522 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 190.274 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 181.026 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 171.778 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 162.530 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 153.282 Td 0.000 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 138.034 Td 0.000 Tw /F2 8.0 Tf 0 Tr (The Tale of the Fox) Tj ET
  BT 218.427 125.286 Td 0.000 Tw /F3 8.0 Tf 0 Tr (The Fox and the lazy Dogs) Tj /F1 8.0 Tf 0 Tr () Tj ET
  BT 218.427 113.538 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 104.290 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 95.042 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 85.794 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 76.546 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 67.298 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 58.050 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 48.802 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 39.554 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 30.306 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 218.427 21.058 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  1 w 1 J  [ 0 10 ] 0 d
  401.853 20.000 m 401.853 821.890 l S
  BT 406.853 821.890 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 812.642 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 803.394 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 794.146 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 784.898 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 775.650 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 766.402 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 757.154 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 747.906 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 738.658 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 729.410 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 720.162 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 710.914 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 701.666 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 692.418 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 683.170 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 673.922 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 664.674 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 655.426 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 646.178 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 636.930 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 627.682 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 618.434 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 609.186 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 599.938 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 590.690 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 581.442 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 572.194 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 562.946 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 553.698 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 544.450 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 535.202 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 525.954 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 516.706 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 507.458 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 498.210 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 488.962 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 479.714 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 470.466 Td 0.000 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 455.218 Td 0.000 Tw /F2 8.0 Tf 0 Tr (The Tale of the Fox) Tj ET
  BT 406.853 442.470 Td 0.000 Tw /F3 8.0 Tf 0 Tr (The Fox and the lazy Dogs) Tj /F1 8.0 Tf 0 Tr () Tj ET
  BT 406.853 430.722 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 421.474 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 412.226 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 402.978 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 393.730 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 384.482 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 375.234 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 365.986 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 356.738 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 347.490 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 338.242 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 328.994 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 319.746 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 310.498 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 301.250 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 292.002 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 282.754 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 273.506 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 264.258 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 255.010 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 245.762 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 236.514 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 227.266 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 218.018 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 208.770 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 199.522 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 190.274 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 181.026 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 171.778 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 162.530 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 153.282 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 144.034 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 134.786 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 125.538 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 116.290 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 107.042 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 97.794 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 88.546 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 79.298 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 70.050 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 60.802 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 51.554 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 42.306 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 33.058 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 406.853 23.810 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  endstream
  endobj

  8 0 obj
  << /Type /Encoding
  /BaseEncoding /WinAnsiEncoding
  /Differences 
  [
  ]
  >>
  endobj
  9 0 obj
  << /Type /Font
  /Subtype /Type1
  /Name /F1
  /BaseFont /Helvetica
  /Encoding 8 0 R
  >>
  endobj
  10 0 obj
  << /Type /Encoding
  /BaseEncoding /WinAnsiEncoding
  /Differences 
  [
  ]
  >>
  endobj
  11 0 obj
  << /Type /Font
  /Subtype /Type1
  /Name /F2
  /BaseFont /Helvetica-Bold
  /Encoding 10 0 R
  >>
  endobj
  12 0 obj
  << /Type /Encoding
  /BaseEncoding /WinAnsiEncoding
  /Differences 
  [
  ]
  >>
  endobj
  13 0 obj
  << /Type /Font
  /Subtype /Type1
  /Name /F3
  /BaseFont /Helvetica-Oblique
  /Encoding 12 0 R
  >>
  endobj
  14 0 obj
  << /Type /Page
  /Parent 3 0 R
  /Contents 15 0 R
  >>
  endobj
  15 0 obj
  <<
  /Length 574 >>
  stream

  0.000 0.000 0.000 rg
  1 w 1 J  [ 0 10 ] 0 d
  BT 10.000 15.000 Td 0.000 Tw /F1 10.0 Tf 0 Tr (2) Tj ET
  BT 10.000 821.890 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 10.000 812.642 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 10.000 803.394 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 10.000 794.146 Td 0.628 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  BT 10.000 784.898 Td 0.000 Tw /F1 8.0 Tf 0 Tr (The quick brown Fox jumped over the lazy Dogs!) Tj ET
  endstream
  endobj

  xref
  0 16
  0000000000 65535 f 
  0000000015 00000 n 
  0000000079 00000 n 
  0000000125 00000 n 
  0000000298 00000 n 
  0000000327 00000 n 
  0000000431 00000 n 
  0000000494 00000 n 
  0000025413 00000 n 
  0000025499 00000 n 
  0000025595 00000 n 
  0000025682 00000 n 
  0000025785 00000 n 
  0000025872 00000 n 
  0000025978 00000 n 
  0000026043 00000 n 

  trailer
    << /Size 16
       /Root 1 0 R
       /Info 5 0 R
    >>
  startxref
  26670
  %%EOF
      EOS
      assert_equal(expected, @writer.render)
    end
=end
    def test_set_ptype_margins
      # tests that set_ptype_margins sets the margins correctly for even 
      # and odd pages
      @chapter.heading = "The Tale of the Fox"
      s1 = @chapter.next_section
      s1.subheading = "The Fox and the lazy Dogs\n"
      p1 = s1.next_paragraph
      p1 << "The quick brown Fox jumped over the lazy Dogs! " * 4
      @writer.set_ptype_margins(:odd)
      assert_equal(ODDB::FiPDF::FachinfoWriter::MARGIN_IN, @writer.left_margin)
      assert_equal(ODDB::FiPDF::FachinfoWriter::MARGIN_OUT, @writer.right_margin)
      @writer.set_ptype_margins(:even)
      assert_equal(ODDB::FiPDF::FachinfoWriter::MARGIN_OUT, @writer.left_margin)
      assert_equal(ODDB::FiPDF::FachinfoWriter::MARGIN_IN, @writer.right_margin)
    end
    def test_write_drug_name_link
      @writer.fi_new_page
      @writer.write_drug_name("<b>Foohallo®</b>")
      #@writer.save_pdf
      expected = <<-EOS
/URI (http://www.oddb.org/de/gcc/search/search_query/Foohallo)<
  EOS
      output = @writer.render.gsub("\n", "<\n")
      message = "Expected: \n#{expected}\nin:\n#{output}"
      assert_not_nil(output.index(expected), message)
    end
    def test_write_drug_name
      @writer.fi_new_page
      @writer.current_generic_type = :original
      @writer.write_drug_name("Ponstan")
      @writer.current_generic_type = :generic
      @writer.write_drug_name("Mefenacid")
      @writer.current_generic_type = :unknown
      @writer.write_drug_name("Dunnosan")
      #@writer.save_pdf
      expected = <<-EOS
1.000 1.000 1.000 rg<
BT 40.000 810.330 Td /F4 10.0 Tf 0 Tr (Ponstan) Tj ET<
0.000 0.000 0.000 rg<
q<
0.168 0.640 0.461 rg<
35.000 782.770 183.427 16.560 re f<
1 w<
Q<
1.000 1.000 1.000 rg<
BT 40.000 787.770 Td /F4 10.0 Tf 0 Tr (Mefenacid) Tj ET<
0.000 0.000 0.000 rg<
q<
0.667 0.667 0.667 rg<
35.000 760.210 183.427 16.560 re f<
1 w<
Q<
BT 40.000 765.210 Td /F4 10.0 Tf 0 Tr (Dunnosan) Tj ET<
      EOS
      # NOTE: to avoid confusion about end-of-line whitespace, both
      #       expected and output have added "<"-signs at EOL
      output = @writer.render.gsub("\n", "<\n")
      result = extract_result_lines(output, 'Ponstan', 3, 15)
      message = "Expected: \n#{expected}\nin:\n#{result}"
      assert_not_nil(output.index(expected), message)
    end
    def test_draw_background
      fachinfo = StubFachinfoDocument.new
      fachinfo.name = "Ponstan"
      fachinfo.generic_type = :generic
      fachinfo.company_name = "Ywesee"
      ch1 = ODDB::Text::Chapter.new
      ch1.heading = "Zusammensetzung"
      sec1 = ch1.next_section
      sec1.subheading = "Wirkstoff"
      para1 = sec1.next_paragraph
      para1 << "The quick brown fox jumped over the lazy dogs" * 10
      fachinfo.chapters = [ch1]
      @writer.write_fachinfo(fachinfo)
      #@writer.save_pdf
      expected = <<-EOS
BT 188.528 798.238 Td /F4 7.0 Tf 0 Tr (Ywesee) Tj ET<
BT 40.000 786.146 Td /F1 7.0 Tf 0 Tr (Zusammensetzung) Tj ET<
BT 40.000 777.554 Td 1.887 Tw /F5 7.0 Tf 0 Tr (Wirkstoff ) Tj /F4 7.0 Tf 0 Tr (The quick brown fox jumped over the lazy) Tj ET<
BT 40.000 769.462 Td 4.155 Tw /F4 7.0 Tf 0 Tr (dogsThe quick brown fox jumped over the lazy) Tj ET<
BT 40.000 761.370 Td 4.155 Tw /F4 7.0 Tf 0 Tr (dogsThe quick brown fox jumped over the lazy) Tj ET<
BT 40.000 753.278 Td 4.155 Tw /F4 7.0 Tf 0 Tr (dogsThe quick brown fox jumped over the lazy) Tj ET<
BT 40.000 745.186 Td 4.155 Tw /F4 7.0 Tf 0 Tr (dogsThe quick brown fox jumped over the lazy) Tj ET<
BT 40.000 737.094 Td 4.155 Tw /F4 7.0 Tf 0 Tr (dogsThe quick brown fox jumped over the lazy) Tj ET<
BT 40.000 729.002 Td 4.155 Tw /F4 7.0 Tf 0 Tr (dogsThe quick brown fox jumped over the lazy) Tj ET<
BT 40.000 720.910 Td 4.155 Tw /F4 7.0 Tf 0 Tr (dogsThe quick brown fox jumped over the lazy) Tj ET<
BT 40.000 712.818 Td 4.155 Tw /F4 7.0 Tf 0 Tr (dogsThe quick brown fox jumped over the lazy) Tj ET<
BT 40.000 704.726 Td 0.000 Tw /F4 7.0 Tf 0 Tr (dogsThe quick brown fox jumped over the lazy dogs) Tj ET<
      EOS
      # NOTE: to avoid confusion about end-of-line whitespace, both
      #       expected and output have added "<"-signs at EOL
      output = @writer.render.gsub("\n", "<\n")
      result = extract_result_lines(output, 'Ywesee', 4, 12)
      message = "Expected: \n#{expected}\nin:\n#{result}"
      assert_not_nil(output.index(expected), message)
    end
    def test_generic_color
      map = ODDB::FiPDF::FachinfoWriter::COLOR_BG
      generic = Color::RGB.from_fraction(*map[:generic])
      unknown = Color::RGB.from_fraction(*map[:unknown])
      assert_equal(generic, @writer.generic_color(:generic))
      assert_equal(unknown, @writer.generic_color(nil))
      assert_equal(unknown, @writer.generic_color(nil))
      assert_equal(unknown, @writer.generic_color(:unknown, {}))
      
      map = {:unknown => [1,1,1], :other => [0,0,0]}
      bar = Color::RGB.from_fraction(0,0,0)
      foo = Color::RGB.from_fraction(1,1,1)
      assert_equal(bar, @writer.generic_color(:other, map))
      assert_equal(foo, @writer.generic_color(:bla, map))
    end
    def test_orphan_paragraph
      text = "Foo, Baar und Test  sind keine zugelassenen Heilmittel " *4
      @writer.fi_new_page
      @writer.first_line_of_page = false
      @writer.y  =  ODDB::FiPDF::FachinfoWriter::MARGIN_BOTTOM  + 1 * @writer.font_height(@writer.formats[:paragraph].size) - @writer.formats[:paragraph].spacing_before("foo")
      paragraph = ODDB::Text::Paragraph.new
      paragraph << text
      p_wrapper = ODDB::FiPDF::ParagraphWrapper.new(paragraph)
      @writer.write_paragraph(p_wrapper)
      #@writer.save_pdf
      # NOTE: to avoid confusion about end-of-line whitespace, both
      #       expected and output have added "<"-signs at EOL
      output = @writer.render.gsub("\n", "<\n")
      #the end of the file
      expected = <<-EOF
BT 223.427 813.798 Td 0.280 Tw /F4 7.0 Tf 0 Tr (Foo, Baar und Test  sind keine zugelassenen Heilmittel) Tj ET<
BT 223.427 805.706 Td 0.280 Tw /F4 7.0 Tf 0 Tr (Foo, Baar und Test  sind keine zugelassenen Heilmittel) Tj ET<
BT 223.427 797.614 Td 0.280 Tw /F4 7.0 Tf 0 Tr (Foo, Baar und Test  sind keine zugelassenen Heilmittel) Tj ET<
BT 223.427 789.522 Td 0.000 Tw /F4 7.0 Tf 0 Tr (Foo, Baar und Test  sind keine zugelassenen Heilmittel) Tj ET<
      EOF
      message = "Expected: \n#{expected}\nin:\n#{output}"
      assert_not_nil(output.index(expected), message)
    end
    def test_orphan_paragraph_text_subheading
      text = "Foo, Baar und Test  sind keine zugelassenen Heilmittel " *4
      @writer.fi_new_page
      @writer.first_line_of_page = false
      @writer.y  =  ODDB::FiPDF::FachinfoWriter::MARGIN_BOTTOM  + 4 * @writer.font_height(@writer.formats[:paragraph].size) - @writer.formats[:paragraph].spacing_before("foo")
      section  = ODDB::Text::Section.new
      section.subheading = "subheading"
      paragraph = section.next_paragraph
      paragraph << text
      s_wrapper = ODDB::FiPDF::SectionWrapper.new(section)
      @writer.write_section(s_wrapper)
      #@writer.save_pdf
      expected = <<-EOF
BT 40.000 44.276 Td 5.709 Tw /F5 7.0 Tf 0 Tr (subheading ) Tj /F4 7.0 Tf 0 Tr (Foo, Baar und Test  sind keine) Tj ET<
BT 40.000 36.184 Td 0.280 Tw /F4 7.0 Tf 0 Tr (zugelassenen Heilmittel Foo, Baar und Test  sind keine) Tj ET<
BT 40.000 28.092 Td 0.280 Tw /F4 7.0 Tf 0 Tr (zugelassenen Heilmittel Foo, Baar und Test  sind keine) Tj ET<
q<
1.000 1.000 1.000 rg<
218.427 20.000 183.427 801.890 re f<
1 w<
Q<
BT 223.427 813.798 Td 0.280 Tw /F4 7.0 Tf 0 Tr (zugelassenen Heilmittel Foo, Baar und Test  sind keine) Tj ET<
      EOF
      # NOTE: to avoid confusion about end-of-line whitespace, both
      #       expected and output have added "<"-signs at EOL
      output = @writer.render.gsub("\n", "<\n")
      result = extract_result_lines(output, 'subheading', 0, 10)
      message = "Expected: \n#{expected}\nin:\n#{result}"
      assert_not_nil(output.index(expected), message)
    end
    def test_orphan_paragraph_text_subheading_newline
      text = "Foo, Baar und Test  sind keine zugelassenen Heilmittel " *4
      @writer.fi_new_page
      @writer.first_line_of_page = false
      @writer.y  =  ODDB::FiPDF::FachinfoWriter::MARGIN_BOTTOM  + 0 * @writer.font_height(@writer.formats[:paragraph].size) - @writer.formats[:paragraph].spacing_before("foo") - @writer.formats[:section].spacing_before("foo") + @writer.font_height(@writer.formats[:section].size) - 0.1
      section  = ODDB::Text::Section.new
      section.subheading = "subheading\n"
      paragraph = section.next_paragraph
      paragraph << text
      s_wrapper = ODDB::FiPDF::SectionWrapper.new(section)
      @writer.write_section(s_wrapper)
      #@writer.save_pdf
      # NOTE: to avoid confusion about end-of-line whitespace, both
      #       expected and output have added "<"-signs at EOL
      output = @writer.render.gsub("\n", "<\n")
      #the end of the file
      expected = <<-EOF
BT 223.427 813.798 Td /F5 7.0 Tf 0 Tr (subheading) Tj ET<
BT 223.427 805.206 Td 0.280 Tw /F4 7.0 Tf 0 Tr (Foo, Baar und Test  sind keine zugelassenen Heilmittel) Tj ET<
BT 223.427 797.114 Td 0.280 Tw /F4 7.0 Tf 0 Tr (Foo, Baar und Test  sind keine zugelassenen Heilmittel) Tj ET<
BT 223.427 789.022 Td 0.280 Tw /F4 7.0 Tf 0 Tr (Foo, Baar und Test  sind keine zugelassenen Heilmittel) Tj ET<
BT 223.427 780.930 Td 0.000 Tw /F4 7.0 Tf 0 Tr (Foo, Baar und Test  sind keine zugelassenen Heilmittel) Tj ET<
      EOF
      message = "Expected: \n#{expected}\nin:\n#{output}"
      assert_not_nil(output.index(expected), message)
    end
    def test_write_chapter
      chapter = ODDB::Text::Chapter.new
      chapter.heading << "Verbot"
      section = chapter.next_section
      paragraph1 = section.next_paragraph
      text = "Foo, Baar und Test  sind keine zugelassenen Heilmittel" *1
      paragraph1 << text
      @writer.fi_new_page
      @writer.first_line_of_page = false
      c_wrapper = ODDB::FiPDF::ChapterWrapper.new(chapter)
      @writer.write_chapter(c_wrapper)
      #@writer.save_pdf
      expected = <<-EOF
BT 40.000 809.798 Td /F1 7.0 Tf 0 Tr (Verbot) Tj ET<
BT 40.000 801.206 Td /F4 7.0 Tf 0 Tr (Foo, Baar und Test  sind keine zugelassenen Heilmittel) Tj ET<
      EOF
      # NOTE: to avoid confusion about end-of-line whitespace, both
      #       expected and output have added "<"-signs at EOL
      output = @writer.render.gsub("\n", "<\n")
      result = extract_result_lines(output, 'Verbot', 0, 2)
      message = "Expected: \n#{expected}\nin:\n#{result}"
      assert_not_nil(output.index(expected), message)
    end
    def test_orphan_chapter_text
      chapter = ODDB::Text::Chapter.new
      chapter.heading << "Verbot"
      section = chapter.next_section
      section.subheading << "Drogen"
      paragraph1 = section.next_paragraph
      text = "Foo, Baar und Test  sind keine zugelassenen Heilmittel" *4
      paragraph1 << text
      @writer.fi_new_page
      @writer.first_line_of_page = false
      @writer.y  =  ODDB::FiPDF::FachinfoWriter::MARGIN_BOTTOM \
        + @writer.font_height(@writer.formats[:chapter].size) \
        - @writer.formats[:chapter].spacing_before("foo") \
        + 2 * @writer.font_height(@writer.formats[:paragraph].size) \
        - @writer.formats[:paragraph].spacing_before("foo") \
        - 0.001
      c_wrapper = ODDB::FiPDF::ChapterWrapper.new(chapter)
      @writer.write_chapter(c_wrapper)
      #@writer.save_pdf
      expected = <<-EOF
BT 223.427 805.206 Td 1.008 Tw /F5 7.0 Tf 0 Tr (Drogen ) Tj /F4 7.0 Tf 0 Tr (Foo, Baar und Test  sind keine zugelassenen) Tj ET<
BT 223.427 797.114 Td 0.598 Tw /F4 7.0 Tf 0 Tr (HeilmittelFoo, Baar und Test  sind keine zugelassenen) Tj ET<
BT 223.427 789.022 Td 0.598 Tw /F4 7.0 Tf 0 Tr (HeilmittelFoo, Baar und Test  sind keine zugelassenen) Tj ET<
BT 223.427 780.930 Td 0.598 Tw /F4 7.0 Tf 0 Tr (HeilmittelFoo, Baar und Test  sind keine zugelassenen) Tj ET<
BT 223.427 772.838 Td 0.000 Tw /F4 7.0 Tf 0 Tr (Heilmittel) Tj ET<
      EOF
      # NOTE: to avoid confusion about end-of-line whitespace, both
      #       expected and output have added "<"-signs at EOL
      output = @writer.render.gsub("\n", "<\n")
      result = extract_result_lines(output, 'Drogen', 1, 4)
      message = "Expected: \n#{expected}\nin:\n#{result}"
      assert_not_nil(output.index(expected), message)
    end
    def test_orphan_chapter_text_subheading_newline
      chapter = ODDB::Text::Chapter.new
      chapter.heading << "Verbot"
      section = chapter.next_section
      section.subheading << "Drogen\n"
      paragraph1 = section.next_paragraph
      text = "Foo, Baar und Test  sind keine zugelassenen Heilmittel" *4
      paragraph1 << text
      @writer.fi_new_page
      @writer.first_line_of_page = false
      c_wrapper = ODDB::FiPDF::ChapterWrapper.new(chapter)
      @writer.y  =  ODDB::FiPDF::FachinfoWriter::MARGIN_BOTTOM \
        + @writer.font_height(@writer.formats[:chapter].size)- @writer.formats[:chapter].spacing_before("foo")
      @writer.write_chapter(c_wrapper)
      #@writer.save_pdf
      # NOTE: to avoid confusion about end-of-line whitespace, both
      #  expected and output have added "<"-signs at EOL
      output = @writer.render.gsub("\n", "<\n")
      #the end of the file
      expected = <<-EOF
BT 223.427 813.798 Td /F1 7.0 Tf 0 Tr (Verbot) Tj ET<
BT 223.427 804.206 Td /F5 7.0 Tf 0 Tr (Drogen) Tj ET<
BT 223.427 795.614 Td 4.709 Tw /F4 7.0 Tf 0 Tr (Foo, Baar und Test  sind keine zugelassenen) Tj ET<
BT 223.427 787.522 Td 0.598 Tw /F4 7.0 Tf 0 Tr (HeilmittelFoo, Baar und Test  sind keine zugelassenen) Tj ET<
BT 223.427 779.430 Td 0.598 Tw /F4 7.0 Tf 0 Tr (HeilmittelFoo, Baar und Test  sind keine zugelassenen) Tj ET<
BT 223.427 771.338 Td 0.598 Tw /F4 7.0 Tf 0 Tr (HeilmittelFoo, Baar und Test  sind keine zugelassenen) Tj ET<
BT 223.427 763.246 Td 0.000 Tw /F4 7.0 Tf 0 Tr (Heilmittel) Tj ET<
      EOF
      message = "Expected: \n#{expected}\nin:\n#{output}"
      assert_not_nil(output.index(expected), message)
    end
    #Preformatted test kann verbessert werden
   def test_preformatted_text
     text = <<-EOS
----------------------------------------------------
        pro Tag      250 mg                         
----------------------------------------------------
 1/2    3Ṫ 5 ml      -         2(-3)Ṫtgl. 1 à 125 mg
 1-3    3Ṫ 7,5 ml    -             3Ṫtgl. 1 à 125 mg
 3-6    3Ṫ10 ml      -             4Ṫtgl. 1 à 125 mg
 6-9    3Ṫ15 ml      -         1(-2)Ṫtgl. 1 à 500 mg
 9-12   3Ṫ20 ml      2(-3)Ṫ                         
                     tgl. 1        2Ṫtgl. 1 à 500 mg
12-14   3Ṫ25 ml      3Ṫtgl. 1      3Ṫtgl. 1 à 500 mg
----------------------------------------------------
      EOS
      paragraph = ODDB::Text::Paragraph.new
      paragraph << text
      paragraph.preformatted!
      @writer.fi_new_page
      @writer.first_line_of_page = false
      p_wrapper = ODDB::FiPDF::ParagraphWrapper.new(paragraph)
      @writer.y  =  ODDB::FiPDF::FachinfoWriter::MARGIN_BOTTOM \
        + 3 * @writer.font_height(@writer.formats[:preformatted].size) - @writer.formats[:preformatted].spacing_before(text)
      @writer.write_paragraph(p_wrapper)
      #@writer.save_pdf
      expected = <<-EOF
BT 40.000 32.789 Td /F2 5.3 Tf 0 Tr (----------------------------------------------------) Tj ET<
BT 40.000 27.197 Td /F2 5.3 Tf 0 Tr (        pro Tag      250 mg) Tj ET<
BT 40.000 21.606 Td /F2 5.3 Tf 0 Tr (----------------------------------------------------) Tj ET<
q<
1.000 1.000 1.000 rg<
218.427 20.000 183.427 801.890 re f<
1 w<
Q<
BT 223.427 816.298 Td /F2 5.3 Tf 0 Tr ( 1/2    3Ṫ 5 ml      -         2\\(-3\\)Ṫtgl. 1 à 125 mg) Tj ET<
BT 223.427 810.707 Td /F2 5.3 Tf 0 Tr ( 1-3    3Ṫ 7,5 ml    -             3Ṫtgl. 1 à 125 mg) Tj ET<
BT 223.427 805.115 Td /F2 5.3 Tf 0 Tr ( 3-6    3Ṫ10 ml      -             4Ṫtgl. 1 à 125 mg) Tj ET<
BT 223.427 799.524 Td /F2 5.3 Tf 0 Tr ( 6-9    3Ṫ15 ml      -         1\\(-2\\)Ṫtgl. 1 à 500 mg) Tj ET<
      EOF
      # NOTE: to avoid confusion about end-of-line whitespace, both
      #  expected and output have added "<"-signs at EOL
      output = @writer.render.gsub("\n", "<\n")
      result = extract_result_lines(output, 'pro Tag', 2, 8)
      message = "Expected: \n#{expected}\nin:\n#{result}"
      assert_not_nil(output.index(expected), message)
    end
    def test_widow_paragraph
      chapter = ODDB::Text::Chapter.new
      section = chapter.next_section
      section.subheading = "Foo\n"
      paragraph = section.next_paragraph
      text = "Baaar und Test sind keine zugelassenen Heilmittel " *3
      paragraph << text
      p_wrapper = ODDB::FiPDF::ParagraphWrapper.new(paragraph)
      @writer.fi_new_page
      @writer.first_line_of_page = false
      @writer.y  =  ODDB::FiPDF::FachinfoWriter::MARGIN_BOTTOM\
        + 2 * @writer.font_height(@writer.formats[:paragraph].size)\
        - @writer.formats[:paragraph].spacing_before(text)
      @writer.write_paragraph(p_wrapper)	
      #@writer.save_pdf
      # NOTE: to avoid confusion about end-of-line whitespace, both
      #  expected and output have added "<"-signs at EOL
      output = @writer.render.gsub("\n", "<\n")
      #the end of the file
      expected = <<-EOF
BT 223.427 813.798 Td 2.708 Tw /F4 7.0 Tf 0 Tr (Baaar und Test sind keine zugelassenen Heilmittel) Tj ET<
BT 223.427 805.706 Td 2.708 Tw /F4 7.0 Tf 0 Tr (Baaar und Test sind keine zugelassenen Heilmittel) Tj ET<
BT 223.427 797.614 Td 0.000 Tw /F4 7.0 Tf 0 Tr (Baaar und Test sind keine zugelassenen Heilmittel) Tj ET<
      EOF
      message = "Expected: \n#{expected}\nin:\n#{output}"
      assert_not_nil(output.index(expected), message)
    end
    def test_widow_text_by_site_change
      chapter = ODDB::Text::Chapter.new
      section = chapter.next_section
      section.subheading = "Foo\n"
      paragraph = section.next_paragraph
      text = "Foo, Baaar und Test sind keine zugelassenen Heilmittel " *3
      paragraph << text
      c_wrapper = ODDB::FiPDF::ChapterWrapper.new(chapter)
      @writer.fi_new_page
      @writer.new_page
      @writer.new_page
      @writer.y  =  ODDB::FiPDF::FachinfoWriter::MARGIN_BOTTOM\
        + 2 * @writer.font_height(@writer.formats[:paragraph].size)\
        - @writer.formats[:paragraph].spacing_before(text)
      @writer.write_chapter(c_wrapper)	
      #@writer.save_pdf
      # NOTE: to avoid confusion about end-of-line whitespace, both
      #  expected and output have added "<"-signs at EOL
      output = @writer.render.gsub("\n", "<\n")
      #the end of the file
      expected = <<-EOF
BT 223.427 813.798 Td /F5 7.0 Tf 0 Tr (Foo) Tj ET<
BT 223.427 805.206 Td 0.042 Tw /F4 7.0 Tf 0 Tr (Foo, Baaar und Test sind keine zugelassenen Heilmittel) Tj ET<
BT 223.427 797.114 Td 0.042 Tw /F4 7.0 Tf 0 Tr (Foo, Baaar und Test sind keine zugelassenen Heilmittel) Tj ET<
BT 223.427 789.022 Td 0.000 Tw /F4 7.0 Tf 0 Tr (Foo, Baaar und Test sind keine zugelassenen Heilmittel) Tj ET<
      EOF
      message = "Expected: \n#{expected}\nin:\n#{output}"
      assert_not_nil(output.index(expected), message)
    end
    def test_write_alphabet__A
      @writer.flic_name = "appelbergen"
      @writer.write_alphabet
      #@writer.save_pdf
      expected = [
        "585.280 792.190 10.000 27.700 re f",
        "BT 584.944 799.592 Td /F1 16.0 Tf 0 Tr (A) Tj ET"
      ]
      # NOTE: to avoid confusion about end-of-line whitespace, both
      #       expected and output have added "<"-signs at EOL
      output = @writer.render.gsub("\n", "<\n")
      expected.each { |line|
        message = "Expected: \n#{line}\nin:\n#{output}"
        assert_not_nil(output.index(line), message)
      }
    end
    def test_write_alphabet__AB
      @writer.flic_name = "appelbergen"
      @writer.write_alphabet
      @writer.flic_name = "bremerhaven"
      @writer.write_alphabet
      #@writer.save_pdf
      expected = [
        "585.280 792.190 10.000 27.700 re f<",
        "585.280 762.491 10.000 27.700 re f<",
        "585.280 762.491 10.000 27.700 re f<",
        "585.280 762.491 10.000 27.700 re f<"
      ]
      # NOTE: to avoid confusion about end-of-line whitespace, both
      #       expected and output have added "<"-signs at EOL
      output = @writer.render.gsub("\n", "<\n")
      expected.each { |line|
        message = "Expected: \n#{line}\nin:\n#{output}"
        assert_not_nil(output.index(line), message)
      }
    end
    def test_write_alphabet__Z_other
      @writer.flic_name = "Zoroaster"
      @writer.write_alphabet
      @writer.flic_name = "3-Tetrahydrodingol"
      @writer.write_alphabet
      #@writer.save_pdf
      expected = [
        "585.280 49.700 10.000 27.700 re f",
        "585.280 20.000 10.000 27.700 re f",
        "BT 585.392 57.101 Td /F1 16.0 Tf 0 Tr (Z) Tj ET<",
        "BT 587.168 27.402 Td /F1 16.0 Tf 0 Tr (*) Tj ET<",
      ]
      # NOTE: to avoid confusion about end-of-line whitespace, both
      #       expected and output have added "<"-signs at EOL
      output = @writer.render.gsub("\n", "<\n")
      expected.each { |line|
        message = "Expected: \n#{line}\nin:\n#{output}"
        assert_not_nil(output.index(line), message)
      }
    end
    def test_anchor_name
      assert_equal('anchor3', @writer.anchor_name(3))
      assert_equal('anchor5', @writer.anchor_name(5))
    end
  end
end
