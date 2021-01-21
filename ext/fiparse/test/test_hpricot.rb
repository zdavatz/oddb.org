#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::FiParse::TestPatinfoHpricot -- oddb.org -- 09.04.2012 -- yasaka@ywesee.com
# ODDB::FiParse::TestPatinfoHpricot -- oddb.org -- 20.06.2011 -- mhatakeyama@ywesee.com
# ODDB::FiParse::TestPatinfoHpricot -- oddb.org -- 17.08.2006 -- hwyss@ywesee.com

require 'hpricot'

$: << File.expand_path('../src', File.dirname(__FILE__))
$: << File.expand_path('../../../src', File.dirname(__FILE__))
$: << File.expand_path('../../..', File.dirname(__FILE__))
$: << File.expand_path('../../../test', File.dirname(__FILE__))

begin require 'pry'; rescue LoadError; end
require 'stub/odba'
require 'minitest/autorun'
require 'flexmock/minitest'
require 'patinfo_hpricot'
require 'plugin/text_info'
$: << File.expand_path('../../../test', File.dirname(__FILE__))
require 'stub/cgi'
require 'fachinfo_hpricot'
require 'patinfo_hpricot'

module ODDB
  module FiParse
class TestPatinfoHpricot <Minitest::Test
  def setup
    @writer = FachinfoHpricot.new
  end
  def test_galenic_form_with_multiple_entries
    html = <<-HTML
    <p class="s3" id="section1"><span class="s2"><span>CoAprovel® 150/12,5; 300/12,5; 300/25</span></span></p>
    <p class="s7" id="section3"><span class="s6"><span>Galenische Form und Wirkstoffmenge pro Einheit</span></span></p>
<p class="s7"><span class="s8"><span>CoAprovel 150/12.5:</span></span><span class="s9"><span> Filmtabletten zu 150 mg Irbesartan und 12.5 mg Hydrochlorothiazid.</span></span></p>
<p class="s7"><span class="s8"><span>CoAprovel 300/12.5:</span></span><span class="s9"><span> Filmtabletten zu 300 mg Irbesartan und 12.5 mg Hydrochlorothiazid.</span></span></p>
<p class="s7"><span class="s8"><span>CoAprovel 300/25:</span></span><span class="s9"><span> Filmtabletten zu 300 mg Irbesartan und 25 mg Hydrochlorothiazid.</span></span></p>
HTML
    writer = FachinfoHpricot.new
    writer.format =  :swissmedicinfo
    fachinfo = writer.extract(Hpricot(html), :pi, 'CoAprovel®')
    assert_equal('Galenische Form und Wirkstoffmenge pro Einheit', fachinfo.galenic_form.heading)
    assert_equal('CoAprovel 150/12.5: Filmtabletten zu 150 mg Irbesartan und 12.5 mg Hydrochlorothiazid.',
                 fachinfo.galenic_form.paragraphs.first.text)
    assert_equal('CoAprovel 300/25: Filmtabletten zu 300 mg Irbesartan und 25 mg Hydrochlorothiazid.',
                 fachinfo.galenic_form.paragraphs.last.text)
  end

  def test_nasivin_spaces
  html = <<-HTML
    <div class="paragraph">
      <h2><a name="7840">Was ist in Cimifemin enthalten?</a></h2>
  <p class="s3"><span class="s4"><span>ab 6 Ja</span></span><span class="s4"><span>hren angewendet werden. Nasivin </span></span><span class="s4"><span>Nasentropfen 0.025% dürfen nur bei</span></span></p>
    </div>
HTML
    code, chapter = @writer.chapter(Hpricot(html).at("div.paragraph"))
    assert_equal('7840', code)
    assert_instance_of(ODDB::Text::Chapter, chapter )
    assert_equal('Was ist in Cimifemin enthalten?', chapter.heading)
    assert_equal(1, chapter.sections.size)
    section = chapter.sections.first
    assert_equal("", section.subheading)
    assert_equal(1, section.paragraphs.size)
    paragraph = section.paragraphs.at(0)
    expected =  "ab 6 Jahren angewendet werden. Nasivin Nasentropfen 0.025% dürfen nur bei"
    assert_equal(1, paragraph.formats.size)
    assert_equal(expected, paragraph.text)
  end

  def test_chapter_bare
    html = <<-HTML
    <div class="paragraph">
      <p First Paragraph</p>
       <p class="noSpacing" Second Paragraph</p>
    </div>
    HTML
    code, chapter = @writer.chapter(Hpricot(html).at("div.paragraph"))
  end
  def test_chapter
    html = <<-HTML
    <div class="paragraph">
      <h2><a name="7840">Was ist in Cimifemin enthalten?</a></h2>
      <p class="spacing"><span style="font-style: italic;">1 Tablette</span>
        enthält: 0,018-0,026 ml Flüssigextrakt aus Cimicifugawurzelstock
        (Traubensilberkerze), (DEV: 0,78-1,14:1), Auszugsmittel Isopropanol 40%
        (V/V).</p>
      <p class="noSpacing">Dieses Präparat enthält zusätzlich Hilfsstoffe.</p>
    </div>
    HTML
    code, chapter = @writer.chapter(Hpricot(html).at("div.paragraph"))
    assert_equal('7840', code)
    assert_instance_of(ODDB::Text::Chapter, chapter )
    assert_equal('Was ist in Cimifemin enthalten?', chapter.heading)
    assert_equal(1, chapter.sections.size)
    section = chapter.sections.first
    assert_equal("", section.subheading)
    assert_equal(2, section.paragraphs.size)
    paragraph = section.paragraphs.at(0)
    expected =  "1 Tablette enthält: 0,018-0,026 ml Flüssigextrakt aus "
    expected << "Cimicifugawurzelstock (Traubensilberkerze), "
    expected << "(DEV: 0,78-1,14:1), Auszugsmittel Isopropanol 40% (V/V)."
    assert_equal(2, paragraph.formats.size)
    fmt = paragraph.formats.first
    assert_equal([:italic], fmt.values)
    assert_equal(0..9, fmt.range)
    fmt = paragraph.formats.last
    assert_equal([], fmt.values)
    assert_equal(10..-1, fmt.range)
    assert_equal(expected, paragraph.text)
    paragraph = section.paragraphs.at(1)
    expected =  "Dieses Präparat enthält zusätzlich Hilfsstoffe."
    assert_equal(expected, paragraph.text)
  end
  def test_chapter_with_sections
    html = <<-HTML
    <div class="paragraph">
      <h2><a name="7740">Wie verwenden Sie Ponstan?</a></h2>
      <p class="noSpacing">Halten Sie sich generell an die von Ihrem Arzt bzw. Ihrer Ärztin verordneten Richtlinien. Die übliche Dosierung beträgt:</p>
      <h3>Für Erwachsene und Jugendliche über 15 Jahre</h3>
      <p class="spacing1">Täglich 3 mal 1 Filmtablette bzw. 3 mal 2 Kapseln Ponstan während der Mahlzeiten. Je nach Bedarf kann diese Dosis vermindert oder erhöht werden, jedoch sollten Sie am selben Tag nicht mehr als 4 Filmtabletten oder 8 Kapseln einnehmen. Die übliche Dosierung für Zäpfchen beträgt 3mal täglich 1 Zäpfchen Ponstan zu 500 mg.</p>
    </div>
    HTML
    code, chapter = @writer.chapter(Hpricot(html).at("div.paragraph"))
    assert_equal('7740', code)
    assert_instance_of(ODDB::Text::Chapter, chapter )
    assert_equal('Wie verwenden Sie Ponstan?', chapter.heading)
    assert_equal(2, chapter.sections.size)
    section = chapter.sections.at(0)
    assert_equal("", section.subheading)
    assert_equal(1, section.paragraphs.size)
    paragraph = section.paragraphs.at(0)
    expected =  "Halten Sie sich generell an die von Ihrem Arzt bzw. Ihrer "
    expected << "Ärztin verordneten Richtlinien. Die übliche Dosierung beträgt:"
    assert_equal(expected, paragraph.text)
    second_section = chapter.sections.at(1)
    paragraph_2 = second_section.paragraphs.at(0)
    assert_equal("Für Erwachsene und Jugendliche über 15 Jahre\n",
                 second_section.subheading)
    expected =  "Täglich 3 mal 1 Filmtablette bzw. 3 mal 2 Kapseln Ponstan "
    expected << "während der Mahlzeiten. Je nach Bedarf kann diese Dosis "
    expected << "vermindert oder erhöht werden, jedoch sollten Sie am selben "
    expected << "Tag nicht mehr als 4 Filmtabletten oder 8 Kapseln einnehmen. "
    expected << "Die übliche Dosierung für Zäpfchen beträgt 3mal täglich 1 "
    expected << "Zäpfchen Ponstan zu 500 mg."
    assert_equal(expected, paragraph_2.text)
    assert_equal(1, second_section.paragraphs.size)
  end
  def test_chapter_ponstan_with_sections
    html = <<-HTML
    <div class="paragraph">
      <h2><a name="7740">Wie verwenden Sie Ponstan?</a></h2>
      <p class="noSpacing">Halten Sie sich generell an die von Ihrem Arzt bzw. Ihrer Ärztin verordneten Richtlinien. Die übliche Dosierung beträgt:</p>
      <h3><span style="font-style:italic">Für Erwachsene und Jugendliche über 14 Jahre</span></h3>
      <p class="spacing1">Täglich 3 mal 1 Filmtablette bzw. 3 mal 2 Kapseln Ponstan während der Mahlzeiten. Je nach Bedarf kann diese Dosis vermindert oder erhöht werden, jedoch sollten Sie am selben Tag nicht mehr als 4 Filmtabletten oder 8 Kapseln einnehmen. Die übliche Dosierung für Zäpfchen beträgt 3mal täglich 1 Zäpfchen Ponstan zu 500 mg.</p>
      <p class="spacing1">Ponstan Zäpfchen sollten Sie nicht mehr als 7 Tage hintereinander anwenden, da es bei längerer Anwendung zu lokalen Reizerscheinungen kommen kann.</p>
      <p class="spacing1">Für Kinder im Alter von 6 Monaten bis 14 Jahren wird Ihr Arzt bzw. Ihre Ärztin die Dosis dem Alter entsprechend anpassen. Bei Einnahme von Suspension oder Kapseln gibt man im allgemeinen als Einzeldosis 6,5 mg pro kg Körpergewicht. Bei Verwendung von Zäpfchen werden 12 mg pro kg Körpergewicht verabreicht. Kinder sollten Ponstan nur kurzfristig erhalten, es sei denn zur Behandlung der Still'schen Krankheit.</p>
      <p class="spacing1">Ändern Sie nicht von sich aus die verschriebene Dosierung. Wenn Sie glauben, das Arzneimittel wirke zu schwach oder zu stark, so sprechen Sie mit Ihrem Arzt oder Apotheker bzw. mit Ihrer Ärztin oder Apothekerin.</p>
      <h3><span style="font-style:italic; ">Dosierungsschema für Kinder</span></h3>
        <table cellSpacing="0" cellPadding="0" border="0">
          <thead>
            <tr>
              <th>Alter\302\240\302\240\302\240\302\240Suspension\302\240\302\240\302\240\302\240\302\240Kapseln\302\240\302\240\302\240\302\240\302\240Zäpfchen\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240</th>
            </tr>
            <tr>
              <th>in\302\240\302\240\302\240\302\240\302\240\302\240\302\240zu\302\24010\302\240mg/ml\302\240\302\240\302\240\302\240zu\302\240250\302\240mg\302\240\302\240\302\240125\302\240bzw.\302\240500\302\240mg\302\240</th>
            </tr>
            <tr>
              <th class="rowSepBelow">Jahren\302\240\302\240\302\240pro\302\240Tag\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240pro\302\240Tag\302\240\302\240\302\240\302\240\302\240pro\302\240Tag\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>½\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\2405\302\240ml\302\240\302\240\302\2403×\302\240\302\240\302\240\302\240\302\240\302\240-\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\2401\302\240Supp.\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240</td>
            </tr>
            <tr>
              <td class="rowSepBelow">\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240125\302\240mg\302\2402-3×\302\240\302\240\302\240\302\240\302\240</td>
            </tr>
            <tr>
              <td>1-3\302\240\302\240\302\240\302\240\302\240\302\2407,5\302\240ml\302\2403×\302\240\302\240\302\240\302\240\302\240\302\240-\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\2401\302\240Supp.\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240</td>
            </tr>
            <tr>
              <td class="rowSepBelow">\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240125\302\240mg\302\2403×\302\240\302\240\302\240\302\240\302\240\302\240\302\240</td>
            </tr>
            <tr>
              <td>3-6\302\240\302\240\302\240\302\240\302\240\302\24010\302\240ml\302\240\302\2403×\302\240\302\240\302\240\302\240\302\240\302\240-\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\2401\302\240Supp.\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240</td>
            </tr>
            <tr>
              <td class="rowSepBelow">\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240125\302\240mg\302\2404×\302\240\302\240\302\240\302\240\302\240\302\240\302\240</td>
            </tr>
            <tr>
              <td>6-9\302\240\302\240\302\240\302\240\302\240\302\24015\302\240ml\302\240\302\2403×\302\240\302\240\302\240\302\240\302\240\302\240-\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\2401\302\240Supp.\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240</td>
            </tr>
            <tr>
              <td class="rowSepBelow">\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240500\302\240mg\302\2401-2×\302\240\302\240\302\240\302\240\302\240</td>
            </tr>
            <tr>
              <td>9-12\302\240\302\240\302\240\302\240\302\24020\302\240ml\302\240\302\2403×\302\240\302\240\302\240\302\240\302\240\302\2401\302\240Kps\302\2402-3×\302\240\302\2401\302\240Supp.\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240</td>
            </tr>
            <tr>
              <td class="rowSepBelow">\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240500\302\240mg\302\2402×\302\240\302\240\302\240\302\240\302\240\302\240\302\240</td>
            </tr>
            <tr>
              <td>12-14\302\240\302\240\302\240\302\24025\302\240ml\302\240\302\2403×\302\240\302\240\302\240\302\240\302\240\302\2401\302\240Kps\302\2403×\302\240\302\240\302\240\302\2401\302\240Supp.\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240</td>
            </tr>
            <tr>
              <td>\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240\302\240500\302\240mg\302\2403×\302\240\302\240\302\240\302\240\302\240\302\240\302\240</td>
            </tr>
          </tbody>
        </table>
      </div>
    HTML
    code, chapter = @writer.chapter(Hpricot(html).at("div.paragraph"))
    assert_equal('7740', code)
    assert_instance_of(ODDB::Text::Chapter, chapter )
    assert_equal('Wie verwenden Sie Ponstan?', chapter.heading)
    assert_equal(4, chapter.sections.size)
    section = chapter.sections.at(0)
    assert_equal("", section.subheading)
    assert_equal(1, section.paragraphs.size)
    paragraph = section.paragraphs.at(0)
    expected =  "Halten Sie sich generell an die von Ihrem Arzt bzw. Ihrer "
    expected << "Ärztin verordneten Richtlinien. Die übliche Dosierung beträgt:"
    assert_equal(expected, paragraph.text)
    section = chapter.sections.at(1)
    assert_equal("Für Erwachsene und Jugendliche über 14 Jahre\n",
                 section.subheading)
    assert_equal(4, section.paragraphs.size)
    paragraph = section.paragraphs.at(0)
    expected =  "Täglich 3 mal 1 Filmtablette bzw. 3 mal 2 Kapseln Ponstan "
    expected << "während der Mahlzeiten. Je nach Bedarf kann diese Dosis "
    expected << "vermindert oder erhöht werden, jedoch sollten Sie am selben "
    expected << "Tag nicht mehr als 4 Filmtabletten oder 8 Kapseln einnehmen. "
    expected << "Die übliche Dosierung für Zäpfchen beträgt 3mal täglich 1 "
    expected << "Zäpfchen Ponstan zu 500 mg."
    assert_equal(expected, paragraph.text)
    section = chapter.sections.at(3)
    assert_equal(1, section.paragraphs.size)
    paragraph = section.paragraphs.at(0)
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
                                     500 mg 3x)
    puts "exp <#{expected}>"
    puts "ist <#{paragraph.text.gsub(/\w+$/,'')}>"
    assert_equal(expected, paragraph.text)
    assert_equal(true, paragraph.preformatted?)
  end
  def test_identify_chapter__raises_unknown_chaptercode
    assert_raises(RuntimeError) {
      @writer.identify_chapter('7800', nil)
    }
  end
  def test_identify_chapter__7930
    assert_nil(@writer.identify_chapter('7930', nil))
  end
  def test_identify_chapter__nil
    chapter = flexmock('chapter', :to_s => '12345')
    assert_equal(chapter, @writer.identify_chapter(nil, chapter))
  end
  def test_to_textinfo
    assert_kind_of(ODDB::PatinfoDocument, @writer.to_textinfo)
  end
end
class TestPatinfoHpricot <Minitest::Test
  def setup
    @writer = PatinfoHpricot.new
  end
  def test_identify_chapter__7520
    chapter = flexmock('chapter',
                       :sections  => 'sections',
                       :sections= => nil
                      )
    @writer.identify_chapter('7520', chapter)
    assert_equal(chapter, @writer.identify_chapter('7520', chapter))
  end
end
  end
end
