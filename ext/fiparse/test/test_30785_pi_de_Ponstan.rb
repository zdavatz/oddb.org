#!/usr/bin/env ruby
$: << File.expand_path("../src", File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))
require "minitest/autorun"
require "fiparse"
require "flexmock/minitest"
require "util/workdir"

module ODDB
  class PatinfoDocument
    def odba_id
      1
    end
  end
  module FiParse
    class TestPatinfoPonstanDe < Minitest::Test
      def setup
        return if defined?(@@path) && defined?(@@patinfo) && @@patinfo
        @@path = File.join(File.dirname(__FILE__), "data", "html", "30785_pi_de_Ponstan.html")
        @parser = ODDB::FiParse
        @@patinfo =  @parser.parse_patinfo_html(File.read(@@path), lang: "de")
      end
      def test_patinfo
        assert_equal(ODDB::PatinfoDocument, @@patinfo.class)
      end
      def test_name
        assert_equal("Ponstan®", @@patinfo.name)
      end
      def test_chapter_7740_usage
        chapter = @@patinfo.usage
        assert_equal("Wie verwenden Sie Ponstan?",  @@patinfo.usage.heading)
        assert_equal("Wie verwenden Sie Ponstan?", chapter.heading)
        assert_equal(3, chapter.sections.size)
        section = chapter.sections.at(0)
        assert_equal("", section.subheading)
        assert_equal(4, section.paragraphs.size)
        paragraph = section.paragraphs.at(0)
        expected = "Halten Sie sich generell an die von Ihrem Arzt bzw. Ihrer Ärztin verordnete Dosierung. Die übliche Dosierung beträgt:"
        assert_equal(expected, paragraph.text)
        section1 = chapter.sections.at(1)
        assert_equal(1, section1.paragraphs.size)
        paragraph = section1.paragraphs.at(0)
        expected = "·Für Erwachsene und Jugendliche über 14 Jahre: Täglich 3 mal 1 Filmtablette bzw. 3 mal 2 Hartkapseln Ponstan während der Mahlzeiten. Je nach Bedarf kann diese Dosis vermindert oder erhöht werden, jedoch sollten Sie am selben Tag nicht mehr als 4 Filmtabletten oder 8 Hartkapseln einnehmen. Die übliche Dosierung für Zäpfchen beträgt 3 mal täglich 1 Zäpfchen Ponstan zu 500 mg. Ponstan Zäpfchen sollten Sie nicht mehr als 7 Tage hintereinander anwenden, da es bei längerer Anwendung zu lokalen Reizerscheinungen kommen kann."
        paragraph = section.paragraphs[1].to_s
        assert_equal(expected, paragraph.to_s)
        assert_equal(4, section.paragraphs.size)
        paragraph = section.paragraphs.at(0)
        expected_neu = 'Körpergewicht (kg) Alter (in Jahren) Hartkapseln zu 250 mg pro Tag Zäpfchen zu 125 bzw. 500 mg pro Tag
6-10 ½ - 1 Zäpfchen 125 mg: 2(-3)×
10-15 1-3 - 1 Zäpfchen 125 mg: 3×
15-22 3-6 - 1 Zäpfchen 125 mg: 4×
22-32 6-9 - 1 Zäpfchen 500 mg: 1(-2)×
32-47 9-12 1 Hartkapsel: 2(-3)× 1 Zäpfchen 500 mg: 2×
47-57 12-14 1 Hartkapsel: 3× 1 Zäpfchen 500 mg: 3×
'
        assert_equal(expected_neu, chapter.sections.at(1).paragraphs.first.to_s)
        expected = %(  Alter    Suspension     Kapseln     Zäpfchen
  in       zu 10 mg/ml    zu 250 mg   125 bzw. 500 mg
  Jahren   pro Tag        pro Tag     pro Tag
-------------------------------------------------------
  ½        5 ml   3×      -           1 Supp.
                                     125 mg 2-3×
-------------------------------------------------------
 1-3      7,5 ml 3×      -           1 Supp.
                                     125 mg 3×
-------------------------------------------------------
 3-6      10 ml  3×      -           1 Supp.
                                     125 mg 4×
-------------------------------------------------------
 6-9      15 ml  3×      -           1 Supp.
                                     500 mg 1-2×
-------------------------------------------------------
 9-12     20 ml  3×      1 Kps 2-3×  1 Supp.
                                     500 mg 2×
-------------------------------------------------------
 12-14    25 ml  3×      1 Kps 3×    1 Supp.
                                     500 mg 3×)
                                      if false
        assert_equal(true, paragraph.preformatted?)
        expected_lines = expected.split("\n")
        paragraph_lines = paragraph.to_s.split("\n")
        expected_lines.each_with_index do |line, idx|
          assert_equal(line.strip, paragraph_lines[idx].strip)
        end
                                      end
        # assert_equal("Für Erwachsene und Jugendliche über 14 Jahre\n", section1.subheading)
        assert_match(/Ponstan/, @@patinfo.usage.to_s)
      end

      def test_chapters
        ODDB::PatinfoDocument2001::CHAPTERS.each do |chapter|
          begin
            res = eval("@@patinfo.#{chapter}")
          rescue => error
            puts "For 30785_pi_de_Ponstan.html chapter #{chapter} is not defined"
          end
        end
      end
    end
  end
end
