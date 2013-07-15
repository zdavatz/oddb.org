#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::FiParse::TestPatinfoHpricot -- oddb.org -- 09.04.2012 -- yasaka@ywesee.com
# ODDB::FiParse::TestPatinfoHpricot -- oddb.org -- 20.06.2011 -- mhatakeyama@ywesee.com
# ODDB::FiParse::TestPatinfoHpricot -- oddb.org -- 17.08.2006 -- hwyss@ywesee.com

require 'hpricot'

$: << File.expand_path('../src', File.dirname(__FILE__))
$: << File.expand_path('../../../src', File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'patinfo_hpricot'

module ODDB
  module FiParse
class TestPatinfoHpricot < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @writer = PatinfoHpricot.new
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
  def test_chapter__with_sections
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
    expected = <<-EOS
Alter    Suspension     Kapseln     Z\303\244pfchen        
in       zu 10 mg/ml    zu 250 mg   125 bzw. 500 mg 
Jahren   pro Tag        pro Tag     pro Tag         
----------------------------------------------------
\302\275        5 ml   3\303\227      -           1 Supp.         
                                    125 mg 2-3\303\227     
----------------------------------------------------
1-3      7,5 ml 3\303\227      -           1 Supp.         
                                    125 mg 3\303\227       
----------------------------------------------------
3-6      10 ml  3\303\227      -           1 Supp.         
                                    125 mg 4\303\227       
----------------------------------------------------
6-9      15 ml  3\303\227      -           1 Supp.         
                                    500 mg 1-2\303\227     
----------------------------------------------------
9-12     20 ml  3\303\227      1 Kps 2-3\303\227  1 Supp.         
                                    500 mg 2\303\227       
----------------------------------------------------
12-14    25 ml  3\303\227      1 Kps 3\303\227    1 Supp.         
                                    500 mg 3\303\227       

    EOS
    assert_equal(expected.chomp, paragraph.text)
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
  def test_identify_chapter__7520
    chapter = flexmock('chapter', 
                       :sections  => 'sections',
                       :sections= => nil
                      )
    @writer.identify_chapter('7520', chapter)
    assert_equal(chapter, @writer.identify_chapter('7520', chapter))
  end
  def test_identify_chapter__nil
    chapter = flexmock('chapter', :to_s => '12345')
    assert_equal(chapter, @writer.identify_chapter(nil, chapter))
  end
  def test_to_textinfo
    assert_kind_of(ODDB::PatinfoDocument, @writer.to_textinfo)
  end
end
class TestPatinfoHpricotCimifeminDe < Test::Unit::TestCase
  def setup
    @path = File.expand_path('data/html/de/cimifemin.html', 
      File.dirname(__FILE__))
    @writer = PatinfoHpricot.new
    open(@path) { |fh| 
      @patinfo = @writer.extract(Hpricot(fh))
    }
  end
  def test_patinfo
    assert_instance_of(PatinfoDocument2001, @patinfo)
  end
  def test_name1
    assert_equal('Cimifemin®', @writer.name.to_s)
  end
  def test_company1
    chapter = @writer.company
    assert_instance_of(ODDB::Text::Chapter, chapter )
    assert_equal('ZELLER MEDICAL', chapter.heading)
  end
  def test_galenic_form1
    chapter = @writer.galenic_form
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Pflanzliches Arzneimittel', chapter.heading)
    assert_equal(0, chapter.sections.size)
  end
  def test_amzv1
    chapter = @writer.amzv
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('AMZV', chapter.heading)
    assert_equal(0, chapter.sections.size)
  end
  def test_effects1
    chapter = @writer.effects
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal("Was ist Cimifemin und wann wird es angewendet?", 
                 chapter.heading)
    assert_equal(1, chapter.sections.size)
    section = chapter.sections.first
    assert_equal('', section.subheading)
    assert_equal(1, section.paragraphs.size)
    paragraph = section.paragraphs.first
    expected =  "Cimifemin ist ein Arzneimittel mit einem Extrakt aus der "
    expected << "Heilpflanze Cimicifuga (Traubensilberkerze). Cimifemin wird "
    expected << "bei Beschwerden in den Wechseljahren (Hitzewallungen, "
    expected << "Schweissausbrüche, Schlafstörungen, Nervosität und "
    expected << "Verstimmungszustände) angewendet. Diese können durch Cimifemin "
    expected << "gelindert werden."
    assert_equal(expected, paragraph.text)
  end
  def test_amendments1
    chapter = @writer.amendments
    assert_instance_of(ODDB::Text::Chapter, chapter )
    assert_equal('Was sollte dazu beachtet werden?', chapter.heading)
    assert_equal(1, chapter.sections.size)
    section = chapter.sections.first
    assert_equal("", section.subheading)
    assert_equal(2, section.paragraphs.size)
    paragraph = section.paragraphs.at(0)
    expected =  "Bei Spannungs- und Schwellungsgefühl in den Brüsten sowie bei "
    expected << "unvorhergesehenen Zwischenblutungen, Schmierblutungen oder bei "
    expected << "wiederkehrender Regelblutung sollten Sie Rücksprache mit Ihrem "
    expected << "Arzt bzw. Ihrer Ärztin nehmen."
    assert_equal(expected, paragraph.text)
    paragraph = section.paragraphs.at(1)
    expected =  "Für Diabetikerinnen geeignet."
    assert_equal(expected, paragraph.text)
  end
  def test_contra_indications1
    chapter = @writer.contra_indications
    assert_instance_of(ODDB::Text::Chapter, chapter )
    assert_equal('Wann darf Cimifemin nicht oder nur mit Vorsicht angewendet werden?', 
                 chapter.heading)
    assert_equal(1, chapter.sections.size)
    section = chapter.sections.first
    assert_equal("", section.subheading)
    assert_equal(4, section.paragraphs.size)
    paragraph = section.paragraphs.at(0)
    expected =  "Cimifemin darf nicht angewendet werden bei bekannter "
    expected << "Überempfindlichkeit auf einen der Inhaltsstoffe oder auf "
    expected << "Ranunculaceen (Hahnenfussgewächse)."
    assert_equal(expected, paragraph.text)
    paragraph = section.paragraphs.at(1)
    expected =  "Bei vorbestehender Leberschädigung wird von der Einnahme von "
    expected << "Cimifemin abgeraten."
    assert_equal(expected, paragraph.text)
    paragraph = section.paragraphs.at(2)
    expected =  "Dieses Präparat beeinflusst die körperlichen und psychischen "
    expected << "Beschwerden in der Abänderung (Klimakterium). Da bisher keine "
    expected << "klinischen Daten vorliegen, die eine günstige Wirkung auf die "
    expected << "Knochen feststellen lassen, kann deshalb dieses Präparat nicht "
    expected << "zur Vorbeugung der Osteoporose verwendet werden."
    assert_equal(expected, paragraph.text)
    paragraph = section.paragraphs.at(3)
    expected =  "Informieren Sie Ihren Arzt, Apotheker oder Drogisten bzw. Ihre "
    expected << "Ärztin, Apothekerin oder Drogistin, wenn Sie an anderen "
    expected << "Krankheiten leiden, Allergien haben oder andere Arzneimittel "
    expected << "(auch selbstgekaufte) einnehmen!"
    assert_equal(expected, paragraph.text)
  end
  def test_usage1
    chapter = @writer.usage
    assert_instance_of(ODDB::Text::Chapter, chapter )
    assert_equal('Wie verwenden Sie Cimifemin?', chapter.heading)
    assert_equal(1, chapter.sections.size)
    section = chapter.sections.first
    assert_equal("", section.subheading)
    assert_equal(3, section.paragraphs.size)
    paragraph = section.paragraphs.at(0)
    expected =  "Soweit nicht anders verschrieben, 2 mal täglich (morgens und "
    expected << "abends) 1 Tablette unzerkaut mit etwas Flüssigkeit einnehmen."
    assert_equal(expected, paragraph.text)
    paragraph = section.paragraphs.at(1)
    expected =  "Cimifemin kann längere Zeit angewendet werden, mindestens über "
    expected << "einen Zeitraum von 6 Wochen. Eine Anwendung über 6 Monate "
    expected << "hinaus soll nur nach Rücksprache mit Ihrem Arzt bzw. Ihrer "
    expected << "Ärztin erfolgen."
    assert_equal(expected, paragraph.text)
    paragraph = section.paragraphs.at(2)
    expected =  "Halten Sie sich an die in der Packungsbeilage angegebene oder "
    expected << "vom Arzt bzw. von der Ärztin verschriebene Dosierung. Wenn Sie "
    expected << "glauben, das Arzneimittel wirke zu schwach oder zu stark, so "
    expected << "sprechen Sie mit Ihrem Arzt, Apotheker oder Drogisten, bzw. "
    expected << "Ihrer Ärztin, Apothekerin oder Drogistin."
    assert_equal(expected, paragraph.text)
  end
  def test_unwanted_effects1
    chapter = @writer.unwanted_effects
    assert_instance_of(ODDB::Text::Chapter, chapter )
    assert_equal('Welche Nebenwirkungen kann Cimifemin haben?', chapter.heading)
    assert_equal(1, chapter.sections.size)
    section = chapter.sections.first
    assert_equal("", section.subheading)
    assert_equal(3, section.paragraphs.size)
    paragraph = section.paragraphs.at(0)
    expected =  "Folgende Nebenwirkungen können bei der Einnahme von Cimifemin "
    expected << "auftreten: in seltenen Fällen leichte Magenbeschwerden, "
    expected << "Übelkeit, sehr selten bei Überempfindlichkeit Hautausschlag, "
    expected << "Juckreiz."
    assert_equal(expected, paragraph.text)
    paragraph = section.paragraphs.at(1)
    expected =  "In sehr seltenen Fällen gibt es Hinweise auf "
    expected << "Leberschädigungen. Bei ungewöhnlichem Leistungsabfall, bei "
    expected << "Gelbfärbung der Bindehaut der Augen oder der Haut, bei dunklem "
    expected << "Urin oder entfärbtem Stuhl sollte Cimifemin abgesetzt und ein "
    expected << "Arzt bzw. eine Ärztin aufgesucht werden."
    assert_equal(expected, paragraph.text)
    paragraph = section.paragraphs.at(2)
    expected =  "Wenn Sie Nebenwirkungen bemerken, die hier nicht beschrieben "
    expected << "sind, sollten Sie Ihren Arzt, Apotheker oder Drogisten bzw. "
    expected << "Ihre Ärztin, Apothekerin oder Drogistin informieren."
    assert_equal(expected, paragraph.text)
  end
  def test_general_advice1
    chapter = @writer.general_advice
    assert_instance_of(ODDB::Text::Chapter, chapter )
    assert_equal('Was ist ferner zu beachten?', chapter.heading)
    assert_equal(1, chapter.sections.size)
    section = chapter.sections.first
    assert_equal("", section.subheading)
    assert_equal(3, section.paragraphs.size)
    paragraph = section.paragraphs.at(0)
    expected =  "Arzneimittel sollen für Kinder unerreichbar aufbewahrt werden. "
    expected << "Bei Raumtemperatur (15–25 °C) aufbewahren."
    assert_equal(expected, paragraph.text)
    paragraph = section.paragraphs.at(1)
    expected =  "Das Arzneimittel darf nur bis zu dem auf dem Behälter mit "
    expected << "«Exp» bezeichneten Datum verwendet werden."
    assert_equal(expected, paragraph.text)
    paragraph = section.paragraphs.at(2)
    expected =  "Weitere Auskünfte erteilt Ihnen Ihr Arzt, Apotheker oder "
    expected << "Drogist bzw. Ihre Ärztin, Apothekerin oder Drogistin."
    assert_equal(expected, paragraph.text)
  end
  def test_composition1
    chapter = @writer.composition
    assert_instance_of(ODDB::Text::Chapter, chapter )
    assert_equal('Was ist in Cimifemin enthalten?', chapter.heading)
    assert_equal(1, chapter.sections.size)
    section = chapter.sections.first
    assert_equal("", section.subheading)
    assert_equal(2, section.paragraphs.size)
    paragraph = section.paragraphs.at(0)
    expected =  "1 Tablette enthält: 0,018–0,026 ml Flüssigextrakt aus "
    expected << "Cimicifugawurzelstock (Traubensilberkerze), "
    expected << "(DEV: 0,78–1,14:1), Auszugsmittel Isopropanol 40% (V/V)."
    assert_equal(expected, paragraph.text)
    paragraph = section.paragraphs.at(1)
    expected =  "Dieses Präparat enthält zusätzlich Hilfsstoffe."
    assert_equal(expected, paragraph.text)
  end
  def test_iksnrs1
    chapter = @writer.iksnrs
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal("Zulassungsnummer", chapter.heading)
    assert_equal(1, chapter.sections.size)
    section = chapter.sections.first
    assert_equal(1, section.paragraphs.size)
    paragraph = section.paragraphs.first
    assert_equal('48734 (Swissmedic).', paragraph.to_s)
  end
  def test_packages1
    chapter = @writer.packages
    assert_instance_of(ODDB::Text::Chapter, chapter )
    assert_equal("Wo erhalten Sie Cimifemin? Welche Packungen sind erhältlich?",
                 chapter.heading)
    assert_equal(1, chapter.sections.size)
    section = chapter.sections.first
    assert_equal("", section.subheading)
    assert_equal(2, section.paragraphs.size)
    paragraph = section.paragraphs.at(0)
    expected =  "In Apotheken und Drogerien, ohne ärztliche Verschreibung."
    assert_equal(expected, paragraph.text)
    paragraph = section.paragraphs.at(1)
    expected =  "Packungen zu 30, 60 und 180 Tabletten."
    assert_equal(expected, paragraph.text)
    assert_equal(3, paragraph.formats.size)
  end
  def test_distribution1
    chapter = @writer.distribution
    assert_instance_of(ODDB::Text::Chapter, chapter )
    assert_equal('Zulassungsinhaberin', chapter.heading)
    assert_equal(1, chapter.sections.size)
    section = chapter.sections.first
    assert_equal("", section.subheading)
    assert_equal(1, section.paragraphs.size)
    paragraph = section.paragraphs.at(0)
    expected =  "Zeller Medical AG, 8590 Romanshorn."
    assert_equal(expected, paragraph.text)
  end
  def test_date1
    chapter = @writer.date
    assert_instance_of(ODDB::Text::Chapter, chapter )
    assert_equal('', chapter.heading)
    assert_equal(1, chapter.sections.size)
    section = chapter.sections.first
    assert_equal("", section.subheading)
    assert_equal(1, section.paragraphs.size)
    expected  = "Diese Packungsbeilage wurde im Februar 2005 letztmals durch "
    expected << "die Arzneimittelbehörde (Swissmedic) geprüft."
    assert_equal(expected, section.paragraphs.first.text)
  end
end
class TestPatinfoHpricotCimifeminFr < Test::Unit::TestCase
  def setup
    @path = File.expand_path('data/html/fr/cimifemin.html', 
      File.dirname(__FILE__))
    @writer = PatinfoHpricot.new
    open(@path) { |fh| 
      @writer.extract(Hpricot(fh))
    }
  end
  def test_name2
    assert_equal('Cimifemine®', @writer.name.to_s)
  end
  def test_company2
    chapter = @writer.company
    assert_instance_of(ODDB::Text::Chapter, chapter )
    assert_equal('ZELLER MEDICAL', chapter.heading)
  end
  def test_amzv2
    chapter = @writer.amzv
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('OEMéd', chapter.heading)
    assert_equal(0, chapter.sections.size)
  end
  def test_composition2
    chapter = @writer.composition
    assert_instance_of(ODDB::Text::Chapter, chapter )
    assert_equal('Que contient Cimifemine?', chapter.heading)
    assert_equal(1, chapter.sections.size)
    section = chapter.sections.first
    assert_equal("", section.subheading)
    assert_equal(2, section.paragraphs.size)
    paragraph = section.paragraphs.at(0)
    expected =  "1 comprimé contient: 0,018–0,026 ml extrait liquide de rhizome "
    expected << "de Cimicifuga (actée à grappes), (RDE: 0,78–1,14:1), agent "
    expected << "d’extraction: isopropanol 40% (v/v)."
    assert_equal(expected, paragraph.text)
    paragraph = section.paragraphs.at(1)
    expected =  "Cette préparation contient en outre des excipients."
    assert_equal(expected, paragraph.text)
  end
end
class TestPatinfoHpricotInderalDe < Test::Unit::TestCase
  def setup
    @path = File.expand_path('data/html/de/inderal.html', 
      File.dirname(__FILE__))
    @writer = PatinfoHpricot.new
    open(@path) { |fh| 
      @writer.extract(Hpricot(fh))
    }
  end
  def test_galenic_form3
    assert_nil(@writer.galenic_form)
  end
  def test_contra_indications3
    chapter = @writer.contra_indications
    assert_instance_of(ODDB::Text::Chapter, chapter )
    assert_equal('Wann darf Inderal nicht angewendet werden?', 
                 chapter.heading)
    assert_equal(1, chapter.sections.size)
    section = chapter.sections.first
    assert_equal("", section.subheading)
    assert_equal(3, section.paragraphs.size)
  end
  def test_precautions3
    chapter = @writer.precautions
    assert_instance_of(ODDB::Text::Chapter, chapter )
    assert_equal('Wann ist bei der Einnahme von Inderal Vorsicht geboten?', 
                 chapter.heading)
    assert_equal(1, chapter.sections.size)
    section = chapter.sections.first
    assert_equal("", section.subheading)
    assert_equal(12, section.paragraphs.size)
  end
  def test_pregnancy3
    chapter = @writer.pregnancy
    assert_instance_of(ODDB::Text::Chapter, chapter )
    assert_equal('Darf Inderal während einer Schwangerschaft oder in der Stillzeit eingenommen werden?', 
                 chapter.heading)
    assert_equal(1, chapter.sections.size)
    section = chapter.sections.first
    assert_equal("", section.subheading)
    assert_equal(1, section.paragraphs.size)
  end
end
class TestPatinfoHpricotPonstanDe < Test::Unit::TestCase
  def setup
    @path = File.expand_path('data/html/de/ponstan.html', 
      File.dirname(__FILE__))
    @writer = PatinfoHpricot.new
    open(@path) { |fh| 
      @patinfo = @writer.extract(Hpricot(fh))
    }
  end
  def test_composition4
    chapter = @writer.composition
    assert_instance_of(ODDB::Text::Chapter, chapter )
    assert_equal('Was ist in Ponstan enthalten?', chapter.heading)
    assert_equal(5, chapter.sections.size)
    section = chapter.sections.at(0)
    assert_equal("", section.subheading)
    assert_equal(1, section.paragraphs.size)
    paragraph = section.paragraphs.at(0)
    expected =  "Wirkstoff: Mefenaminsäure."
    assert_equal(expected, paragraph.text)
    section = chapter.sections.at(1)
    assert_equal("Filmtabletten\n", section.subheading)
    assert_equal(1, section.paragraphs.size)
    paragraph = section.paragraphs.at(0)
    expected =  "500 mg Mefenaminsäure sowie Vanillin (Aromaticum) und andere "
    expected << "Hilfsstoffe."
    assert_equal(expected, paragraph.text)
    section = chapter.sections.last
    assert_equal("Suspension\n", section.subheading)
    assert_equal(2, section.paragraphs.size)
    paragraph = section.paragraphs.at(0)
    expected =  "5 ml enthalten 50 mg Mefenaminsäure, Konservierungsmittel: "
    expected << "Natriumbenzoat (E 211), Saccharin, Vanillin, Aromatica und "
    expected << "andere Hilfsstoffe."
    assert_equal(expected, paragraph.text)
    paragraph = section.paragraphs.at(1)
    expected =  "5 ml enthalten 1 g Zucker (0,1 Brotwert)."
    assert_equal(expected, paragraph.text)
  end
end
class TestPatinfoHpricotNasivinDe < Test::Unit::TestCase
  def setup
    @path = File.expand_path('data/html/de/nasivin.html', 
      File.dirname(__FILE__))
    @writer = PatinfoHpricot.new
    open(@path) { |fh| 
      @patinfo = @writer.extract(Hpricot(fh))
    }
  end
  def test_composition5
    chapter = @writer.effects
    assert_instance_of(ODDB::Text::Chapter, chapter )
    assert_equal('Was ist Nasivin und wann wird es angewendet?', chapter.heading)
    section = chapter.sections.first
    assert_instance_of(ODDB::Text::Section, section )
    assert_equal('', section.subheading)
    chapter = @writer.composition
    assert_instance_of(ODDB::Text::Chapter, chapter )
    assert_equal('Was ist in Nasivin enthalten?', chapter.heading)
    chapter = @writer.packages
    assert_instance_of(ODDB::Text::Chapter, chapter )
    assert_equal('Wo erhalten Sie Nasivin? Welche Packungen sind erhältlich?', chapter.heading)
    section = chapter.sections.first
    paragraph = section.paragraphs.first
    assert_instance_of(ODDB::Text::Paragraph, paragraph )
    assert_equal("In Apotheken und Drogerien ohne ärztliche Verschreibung.", 
                 paragraph.text)
    chapter = @writer.date
    assert_instance_of(ODDB::Text::Chapter, chapter )
    assert_equal('', chapter.heading)
    section = chapter.sections.first
    assert_instance_of(ODDB::Text::Section, section )
    assert_equal("", section.subheading)
    assert_equal(1, section.paragraphs.size)
    assert_equal("Diese Packungsbeilage wurde im März 2007 letztmals durch die Arzneimittelbehörde (Swissmedic) geprüft.", section.to_s)
     

  end
  
  def test_import_chapter
    testCases = [
      
      # Test cases for specific name with ',' or special signs
      ['7620','Wann wird Notakehl Salbe angewendet?'],
      ['7620','Wann wird Traumeel, Salbe angewendet?'],
      ['7680','Wann darf Notakeh D3, Salbe nicht oder nur mit Vorsicht angewendet werden?'],
      ['7680','Wann darf Notakehl® D3, Salbe nicht oder nur mit Vorsicht angewendet werden?'],
      ['0', 'Information für Patientinnen und Patienten'],
      ['0', 'Information destinée aux patients'],
      
      ['9010', 'Name des Präparates'],
      ['9010', 'Name des Präparates, Homöopathisches Arzneimittel (Homöopathisch-spagyrisches'],
      ['9010', 'Arzneimittel)'],
      ['9010', 'Name des Präparates, Anthroposophisches Arzneimittel'],
      ['9010', 'Name des Präparates, Arzneimittel auf Grundlage anthroposophischer Erkenntnis'],
      ['9010', 'Name des Präparates, Pflanzliches Arzneimittel'],
      ['9010', 'Kurzcharakteristikum'],
      ['9010', 'Homöopathisches Arzneimittel (Homöopathisch-spagyrisches Arzneimittel)'],
      ['9010', 'Anthroposophisches Arzneimittel'],
      ['9010', 'Arzneimittel auf Grundlage anthroposophischer Erkenntnis'],
      ['9010', 'Pflanzliches Arzneimittel'],
      ['9010', 'Nom de la préparation'],
      ['9010', 'Nom de la préparation, Médicament homéopathique (médicamenthoméopathique-spagyrique)'],
      ['9010', 'Nom de la préparation, Médicament anthroposophique'],
      ['9010', 'Nom de la préparation, Médicament basé sur les connaissances anthroposophiques'],
      ['9010', 'Nom de la préparation, Médicament phytothérapeutique'],
      ['9010', 'Caractéristique à court'],
      ['9010', 'Médicament homéopathique (médicament homéopathique-spagyrique)'],
      ['9010', 'Médicament anthroposophique'],
      ['9010', 'Médicament basé sur les connaissances anthroposophiques'],
      ['9010', 'Médicament phytothérapeutique'],
      
      ['7620', 'Was ist PLATZHALTER_MEDI und wann wird es angewendet?'],
      ['7620', 'Was sind PLATZHALTER_MEDI und wann werden sie angewendet?'],
      ['7620', 'Qu’est-ce que le PLATZHALTER_MEDI et quand doit-il être utilisé?'],
      ['7620', "Qu’est-ce que l' PLATZHALTER_MEDI et quand doit-il être utilisé?"],
      ['7620', 'Qu’est-ce que la PLATZHALTER_MEDI et quand doit-elle être utilisée?'],
      ['7620', "Qu’est-ce que l' PLATZHALTER_MEDI et quand doit-elle être utilisée?"],
      ['7620', 'Qu’est-ce que PLATZHALTER_MEDI et quand doit-il être utilisé?'],
      ['7620', 'Qu’est-ce que PLATZHALTER_MEDI et quand doit-elle être utilisée?'],
      ['7620', 'Qu’est-ce que les PLATZHALTER_MEDI et quand doivent-ils être utilisés?'],
      ['7620', 'Qu’est-ce que les PLATZHALTER_MEDI et quand doivent-elles être utilisées?'],
      ['7620', 'Qu’est-ce que PLATZHALTER_MEDI et quand doivent-ils être utilisés?'],
      ['7620', 'Qu’est-ce que PLATZHALTER_MEDI et quand doivent-elles être utilisées?'],
      
      ['7620', 'Wann wird PLATZHALTER_MEDI angewendet?'],
      ['7620', 'Wann werden PLATZHALTER_MEDI angewendet?'],
      ['7620', 'Quand PLATZHALTER_MEDI est-il utilisé?'],
      ['7620', 'Quand PLATZHALTER_MEDI est-elle utilisée?'],
      ['7620', 'Quand PLATZHALTER_MEDI sont-ils utilisés?'],
      ['7620', 'Quand PLATZHALTER_MEDI sont-elles utilisées?'],
      ['7620', 'Qu’est-ce que le PLATZHALTER_MEDI et quand est-il utilisé?'],
      ['7620', "Qu’est-ce que l' PLATZHALTER_MEDI et quand est-il utilisé?"],
      ['7620', 'Qu’est-ce que PLATZHALTER_MEDI et quand est-il utilisé?'],
      ['7620', 'Qu’est-ce que la PLATZHALTER_MEDI et quand est-elle utilisée?'],
      ['7620', "Qu’est-ce que l' PLATZHALTER_MEDI et quand est-elle utilisée?"],
      ['7620', 'Qu’est-ce que PLATZHALTER_MEDI et quand est-elle utilisée?'],
      ['7620', 'Qu’est-ce que les PLATZHALTER_MEDI et quand sont-ils utilisés?'],
      ['7620', 'Qu’est-ce que les PLATZHALTER_MEDI et quand sont-elles utilisées?'],
      ['7620', 'Qu’est-ce que PLATZHALTER_MEDI et quand sont-ils utilisés?'],
      ['7620', 'Qu’est-ce que PLATZHALTER_MEDI et quand sont-elles utilisées?'],
      
      ['7640', 'Was sollte dazu beachtet werden?'],
      ['7640', 'De quoi faut-il tenir compte en dehors du traitement?'],
      
      ['7680', 'Wann darf PLATZHALTER_MEDI nicht eingenommen/angewendet werden?'],
      ['7680', 'Wann darf PLATZHALTER_MEDI nicht eingenommen werden?'],
      ['7680', 'Wann darf PLATZHALTER_MEDI nicht angewendet werden?'],
      ['7680', 'Quand PLATZHALTER_MEDI ne doit-il pas être pris/utilisé?'],
      ['7680', 'Quand PLATZHALTER_MEDI ne doit-elle pas être prise/utilisée?'],
      ['7680', 'Quand PLATZHALTER_MEDI ne doit-il pas être pris?'],
      ['7680', 'Quand PLATZHALTER_MEDI ne doit-il pas être utilisé?'],
      ['7680', 'Quand PLATZHALTER_MEDI ne doit-elle pas être prise?'],
      ['7680', 'Quand PLATZHALTER_MEDI ne doit-elle pas être utilisée?'],      
      ['7680', 'Wann dürfen PLATZHALTER_MEDI nicht eingenommen/angewendet werden?'],
      ['7680', 'Wann dürfen PLATZHALTER_MEDI nicht eingenommen werden?'],
      ['7680', 'Wann dürfen PLATZHALTER_MEDI nicht angewendet werden?'],
      ['7680', 'Wann darf PLATZHALTER_MEDI nicht oder nur mit Vorsicht eingenommen/angewendet werden?'],
      ['7680', 'Wann darf PLATZHALTER_MEDI nicht oder nur mit Vorsicht eingenommen werden?'],
      ['7680', 'Wann darf PLATZHALTER_MEDI nicht oder nur mit Vorsicht angewendet werden?'],
      ['7680', 'Wann dürfen PLATZHALTER_MEDI nicht oder nur mit Vorsicht eingenommen/angewendet werden?'],
      ['7680', 'Wann dürfen PLATZHALTER_MEDI nicht oder nur mit Vorsicht eingenommen werden?'],
      ['7680', 'Wann dürfen PLATZHALTER_MEDI nicht oder nur mit Vorsicht angewendet werden?'],
      ['7680', 'Quand PLATZHALTER_MEDI ne doivent-ils pas être pris/utilisés?'],
      ['7680', 'Quand PLATZHALTER_MEDI ne doivent-elles pas être prises/utilisées?'],
      ['7680', 'Quand PLATZHALTER_MEDI ne doivent-ils pas être pris?'],
      ['7680', 'Quand PLATZHALTER_MEDI ne doivent-elles pas être prises?'],
      ['7680', 'Quand PLATZHALTER_MEDI ne doivent-ils pas être utilisés?'],
      ['7680', 'Quand PLATZHALTER_MEDI ne doivent-elles pas être utilisées?'],
      ['7680', 'Quand PLATZHALTER_MEDI ne doit-il pas être pris/utilisé ou seulement avprécaution?'],
      ['7680', 'Quand PLATZHALTER_MEDI ne doit-elle pas être prise/utilisée ou seulement avec précaution?'],
      ['7680', 'Quand PLATZHALTER_MEDI ne doit-il pas être pris ou seulement avec précautio?'],
      ['7680', 'Quand PLATZHALTER_MEDI ne doit-elle pas être prise ou seulement avec précaution?'],
      ['7680', 'Quand PLATZHALTER_MEDI ne doit-elle pas être utilisée ou seulement avec précaution?'],
      ['7680', 'Quand PLATZHALTER_MEDI ne doivent-ils pas être pris/utilisés ou seulement aveprécaution?'],
      ['7680', 'Quand PLATZHALTER_MEDI ne doivent-elles pas être prises/utilisées ou seulemenavec précaution?'],
      ['7680', 'Quand PLATZHALTER_MEDI ne doivent-ils pas être pris ou seulement avec précaution?'],
      ['7680', 'Quand PLATZHALTER_MEDI ne doivent-elles pas être prises ou seulement avec précaution?'],
      ['7680', 'Quand PLATZHALTER_MEDI ne doivent-ils pas être utilisés ou seulement avec précaution?'],
      ['7680', 'Quand PLATZHALTER_MEDI ne doivent-elles pas être utilisées ou seulement avec précaution?'],
      
      ['7700', 'Wann ist bei der Einnahme/Anwendung von PLATZHALTER_MEDI Vorsicht geboten?'],
      ['7700', 'Wann ist bei der Einnahme von PLATZHALTER_MEDI Vorsicht geboten?'],
      ['7700', 'Wann ist bei der Anwendung von PLATZHALTER_MEDI Vorsicht geboten?'],
      ['7700', 'Quelles sont les précautions à observer lors de la prise/de l’utilisation de PLATZHALTER_MEDI?'],
      ['7700', 'Quelles sont les précautions à observer lors de la prise de PLATZHALTER_MEDI?'],
      ['7700', 'Quelles sont les précautions à observer lors de l’utilisation de PLATZHALTER_MEDI?'],
      
      ['7720', 'Darf PLATZHALTER_MEDI während einer Schwangerschaft oder in der Stillzeit eingenommen/angewendet werden?'],
      ['7720', 'Darf PLATZHALTER_MEDI während einer Schwangerschaft oder in der Stillzeit eingenommen werden?'],
      ['7720', 'Darf PLATZHALTER_MEDI während einer Schwangerschaft oder in der Stillzeit angewendet werden?'],
      ['7720', 'Dürfen PLATZHALTER_MEDI während einer Schwangerschaft oder in der Stillzeit eingenommen/angewendet werden?'],
      ['7720', 'Dürfen PLATZHALTER_MEDI während einer Schwangerschaft oder in der Stillzeit eingenommen werden?'],
      ['7720', 'Dürfen PLATZHALTER_MEDI während einer Schwangerschaft oder in der Stillzeit angewendet werden?'],
      ['7720', 'PLATZHALTER_MEDI peut-il être pris/utilisé pendant la grossesse ou l’allaitement?'],
      ['7720', 'PLATZHALTER_MEDI peut-elle être prise/utilisée pendant la grossesse ou l’allaitement?'],
      ['7720', 'PLATZHALTER_MEDI peut-il être pris pendant la grossesse ou l’allaitement?'],
      ['7720', 'PLATZHALTER_MEDI peut-elle être prise pendant la grossesse ou l’allaitement?'],
      ['7720', 'PLATZHALTER_MEDI peut-il être utilisé pendant la grossesse ou l’allaitement?'],
      ['7720', 'PLATZHALTER_MEDI peut-elle être utilisée pendant la grossesse ou l’allaitement?'],
      ['7720', 'PLATZHALTER_MEDI peuvent-ils être pris/utilisés pendant la grossesse ou l’allaitement?'],
      ['7720', 'PLATZHALTER_MEDI peuvent-elles être prises/utilisées pendant la grossesse ou l’allaitement?'],
      ['7720', 'PLATZHALTER_MEDI peuvent-ils être pris pendant la grossesse ou l’allaitement?'],
      ['7720', 'PLATZHALTER_MEDI peuvent-elles être prises pendant la grossesse ou l’allaitement?'],
      ['7720', 'PLATZHALTER_MEDI peuvent-ils être utilisés pendant la grossesse ou l’allaitement?'],
      ['7720', ' PLATZHALTER_MEDI peuvent-elles être utilisées pendant la grossesse ou l’allaitement?'],
      
      ['7740', 'Wie verwenden Sie PLATZHALTER_MEDI?'],
      ['7740', 'Comment utiliser PLATZHALTER_MEDI?'],
      
      ['7760', 'Welche Nebenwirkungen kann PLATZHALTER_MEDI haben?'],
      ['7760', 'Welche Nebenwirkungen können PLATZHALTER_MEDI haben?'],
      ['7760', 'Quels effets secondaires PLATZHALTER_MEDI peut-il provoquer?'],
      ['7760', 'Quels effets secondaires PLATZHALTER_MEDI peut-elle provoquer?'],
      ['7760', 'Quels effets secondaires PLATZHALTER_MEDI peuvent-ils provoquer?'],
      ['7760', 'Quels effets secondaires PLATZHALTER_MEDI peuvent-elles provoquer?'],
      
      ['7780', 'Was ist ferner zu beachten?'],
      ['7780', 'A quoi faut-il encore faire attention?'],
      ['7780', 'À quoi faut-il encore faire attention?'],
      
      ['7840', 'Was ist in PLATZHALTER_MEDI enthalten?'],
      ['7840', 'Que contient PLATZHALTER_MEDI?'],
      
      ['7860', 'Zulassungsnummer'],
      ['7860', 'Numéro d’autorisation'],
      
      ['7880', 'Wo erhalten Sie PLATZHALTER_MEDI? Welche Packungen sind erhältlich?'],
      ['7880', 'Que contiennent PLATZHALTER_MEDI?'],
      ['7880', 'Où obtenez-vous PLATZHALTER_MEDI? Quels sont les emballages à disposition sur le marché?'],

      ['9000', 'Zulassungsinhaberin'],
      ['9000', 'Titulaire de l’autorisation'],

      ['7920', 'Herstellerin'], 
      ['7920', 'Fabricant'],

      ['7940', 'Diese Packungsbeilage wurde im PLATZHALTER_MEDI (Monat/Jahr) letztmals durch die Arzneimittelbehörde (Swissmedic) geprüft.'],
      ['7940', 'Cette notice d’emballage a été vérifiée pour la dernière foisen PLATZHALTER_MEDI (mois/année) par l’autorité de contrôle des médicaments (Swissmedic).'],
      ]
    
    
    nrFailures = 0
    testCases.each{ 
      |tc|
        unless tc == res = ODDB::FiParse::PatinfoHpricot::text_to_chapter(tc[1])
          $stdout.puts "Parsing chapter #{tc[1]} failed, returned #{res[0]} != #{tc[0]}"
          nrFailures += 1
        end
    }
    assert_equal nrFailures, 0
  end
  
end
  end
end
