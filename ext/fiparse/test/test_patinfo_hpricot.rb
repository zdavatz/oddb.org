#!/usr/bin/env ruby
# FiParse::TestPatinfoHpricot -- oddb -- 17.08.2006 -- hwyss@ywesee.com

require 'hpricot'

$: << File.expand_path('../src', File.dirname(__FILE__))
$: << File.expand_path('../../../src', File.dirname(__FILE__))

require 'test/unit'
require 'patinfo_hpricot'

module ODDB
  module FiParse
class TestPatinfoHpricot < Test::Unit::TestCase
  def setup
    @writer = PatinfoHpricot.new
  end
  def test_chapter
    html = <<-HTML
  <div class="Abschnitt">
    <div class="AbschnittTitel">
      <a name="7840">Was ist in Cimifemin enthalten?</a>
    </div>
    <span style="font-style: italic;">1 Tablette</span>
enthält: 0,018-0,026 ml Flüssigextrakt aus Cimicifugawurzelstock
(Traubensilberkerze), (DEV: 0,78-1,14:1), Auszugsmittel Isopropanol 40%
(V/V).<br>Dieses Präparat enthält zusätzlich Hilfsstoffe.<br></div>
    HTML
    code, chapter = @writer.chapter(Hpricot(html).at("div.Abschnitt"))
    assert_equal('7840', code)
    assert_instance_of(ODDB::Text::Chapter, chapter )
    assert_equal('Was ist in Cimifemin enthalten?', chapter.heading)
    assert_equal(1, chapter.sections.size)
    section = chapter.sections.first
    assert_equal("", section.subheading)
    assert_equal(2, section.paragraphs.size)
    paragraph = section.paragraphs.at(0)
    expected =  "1 Tablette enth�lt: 0,018-0,026 ml Fl�ssigextrakt aus "
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
    expected =  "Dieses Pr�parat enth�lt zus�tzlich Hilfsstoffe."
    assert_equal(expected, paragraph.text)
  end
  def test_chapter__with_sections
    html = <<-HTML
  <div class="Abschnitt">
    <div class="AbschnittTitel">
      <a name="7740">Wie verwenden Sie Ponstan?</a>
  </div>Halten Sie sich generell an die von Ihrem Arzt bzw. Ihrer Ärztin verordneten Richtlinien. Die übliche Dosierung beträgt:<br><div class="Untertitel">Für Erwachsene und Jugendliche über 14 Jahre</div>Täglich 3 mal 1 Filmtablette bzw. 3 mal 2 Kapseln Ponstan während der Mahlzeiten. Je nach Bedarf kann diese Dosis vermindert oder erhöht werden, jedoch sollten Sie am selben Tag nicht mehr als 4 Filmtabletten oder 8 Kapseln einnehmen. Die übliche Dosierung für Zäpfchen beträgt 3mal täglich 1 Zäpfchen Ponstan zu 500 mg.<br>Ponstan Zäpfchen sollten Sie nicht mehr als 7 Tage hintereinander anwenden, da es bei längerer Anwendung zu lokalen Reizerscheinungen kommen kann. <br>Für Kinder im Alter von 6 Monaten bis 14 Jahren wird Ihr Arzt bzw. Ihre Ärztin die Dosis dem Alter entsprechend anpassen. Bei Einnahme von Suspension oder Kapseln gibt man im allgemeinen als Einzeldosis 6,5 mg pro kg Körpergewicht. Bei Verwendung von Zäpfchen werden 12 mg pro kg Körpergewicht verabreicht. Kinder sollten Ponstan nur kurzfristig erhalten, es sei denn zur Behandlung der Still'schen Krankheit.<br>Ändern Sie nicht von sich aus die verschriebene Dosierung. Wenn Sie glauben, das Arzneimittel wirke zu schwach oder zu stark, so sprechen Sie mit Ihrem Arzt oder Apotheker bzw. mit Ihrer Ärztin oder Apothekerin.<br><div class="Untertitel">Dosierungsschema für Kinder</div><table cellSpacing="0" cellPadding="0" border="0"><tr><td class="Tabelle">
----------------------------------------------------</td></tr><tr><td class="Tabelle">
Alter    Suspension     Kapseln     Zäpfchen        </td></tr><tr><td class="Tabelle">
in       zu 10 mg/ml    zu 250 mg   125 bzw. 500 mg </td></tr><tr><td class="Tabelle">
Jahren   pro Tag        pro Tag     pro Tag         </td></tr><tr><td class="Tabelle">
----------------------------------------------------</td></tr><tr><td class="Tabelle">
½        5 ml   3×      -           1 Supp.         </td></tr><tr><td class="Tabelle">
                                    125 mg 2-3×     </td></tr><tr><td class="Tabelle">
----------------------------------------------------</td></tr><tr><td class="Tabelle">
1-3      7,5 ml 3×      -           1 Supp.         </td></tr><tr><td class="Tabelle">
                                    125 mg 3×       </td></tr><tr><td class="Tabelle">
----------------------------------------------------</td></tr><tr><td class="Tabelle">
3-6      10 ml  3×      -           1 Supp.         </td></tr><tr><td class="Tabelle">
                                    125 mg 4×       </td></tr><tr><td class="Tabelle">
----------------------------------------------------</td></tr><tr><td class="Tabelle">
6-9      15 ml  3×      -           1 Supp.         </td></tr><tr><td class="Tabelle">
                                    500 mg 1-2×     </td></tr><tr><td class="Tabelle">
----------------------------------------------------</td></tr><tr><td class="Tabelle">
9-12     20 ml  3×      1 Kps 2-3×  1 Supp.         </td></tr><tr><td class="Tabelle">
                                    500 mg 2×       </td></tr><tr><td class="Tabelle">
----------------------------------------------------</td></tr><tr><td class="Tabelle">
12-14    25 ml  3×      1 Kps 3×    1 Supp.         </td></tr><tr><td class="Tabelle">
                                    500 mg 3×       </td></tr><tr><td class="Tabelle">
----------------------------------------------------</td></tr><tr><td class="Tabelle"></td></tr></table></div>
    HTML
    code, chapter = @writer.chapter(Hpricot(html).at("div.Abschnitt"))
    assert_equal('7740', code)
    assert_instance_of(ODDB::Text::Chapter, chapter )
    assert_equal('Wie verwenden Sie Ponstan?', chapter.heading)
    assert_equal(3, chapter.sections.size)
    section = chapter.sections.at(0)
    assert_equal("", section.subheading)
    assert_equal(1, section.paragraphs.size)
    paragraph = section.paragraphs.at(0)
    expected =  "Halten Sie sich generell an die von Ihrem Arzt bzw. Ihrer "
    expected << "�rztin verordneten Richtlinien. Die �bliche Dosierung betr�gt:"
    assert_equal(expected, paragraph.text)
    section = chapter.sections.at(1)
    assert_equal("F�r Erwachsene und Jugendliche �ber 14 Jahre\n", 
                 section.subheading)
    assert_equal(4, section.paragraphs.size)
    paragraph = section.paragraphs.at(0)
    expected =  "T�glich 3 mal 1 Filmtablette bzw. 3 mal 2 Kapseln Ponstan "
    expected << "w�hrend der Mahlzeiten. Je nach Bedarf kann diese Dosis "
    expected << "vermindert oder erh�ht werden, jedoch sollten Sie am selben "
    expected << "Tag nicht mehr als 4 Filmtabletten oder 8 Kapseln einnehmen. "
    expected << "Die �bliche Dosierung f�r Z�pfchen betr�gt 3mal t�glich 1 "
    expected << "Z�pfchen Ponstan zu 500 mg."
    assert_equal(expected, paragraph.text)
    section = chapter.sections.at(2)
    assert_equal(1, section.paragraphs.size)
    paragraph = section.paragraphs.at(0)
    expected = <<-EOS

----------------------------------------------------
Alter    Suspension     Kapseln     Z�pfchen        
in       zu 10 mg/ml    zu 250 mg   125 bzw. 500 mg 
Jahren   pro Tag        pro Tag     pro Tag         
----------------------------------------------------
�        5 ml   3�      -           1 Supp.         
                                    125 mg 2-3�     
----------------------------------------------------
1-3      7,5 ml 3�      -           1 Supp.         
                                    125 mg 3�       
----------------------------------------------------
3-6      10 ml  3�      -           1 Supp.         
                                    125 mg 4�       
----------------------------------------------------
6-9      15 ml  3�      -           1 Supp.         
                                    500 mg 1-2�     
----------------------------------------------------
9-12     20 ml  3�      1 Kps 2-3�  1 Supp.         
                                    500 mg 2�       
----------------------------------------------------
12-14    25 ml  3�      1 Kps 3�    1 Supp.         
                                    500 mg 3�       
----------------------------------------------------
    EOS
    assert_equal(expected.chomp, paragraph.text)
    assert_equal(true, paragraph.preformatted?)
  end
  def test_identify_chapter__raises_unknown_chaptercode
    assert_raises(RuntimeError) { 
      @writer.identify_chapter('7800', nil)
    }
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
    assert_equal('Cimifemin�', @writer.name)
  end
  def test_company1
    chapter = @writer.company
    assert_instance_of(ODDB::Text::Chapter, chapter )
    assert_equal('ZELLER', chapter.heading)
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
    assert_equal('AMZV 9.11.2001', chapter.heading)
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
    expected << "Schweissausbr�che, Schlafst�rungen, Nervosit�t und "
    expected << "Verstimmungszust�nde) angewendet. Diese k�nnen durch Cimifemin "
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
    expected =  "Bei Spannungs- und Schwellungsgef�hl in den Br�sten sowie bei "
    expected << "unvorhergesehenen Zwischenblutungen, Schmierblutungen oder bei "
    expected << "wiederkehrender Regelblutung sollten Sie R�cksprache mit Ihrem "
    expected << "Arzt bzw. Ihrer �rztin nehmen."
    assert_equal(expected, paragraph.text)
    paragraph = section.paragraphs.at(1)
    expected =  "F�r Diabetikerinnen geeignet."
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
    expected << "�berempfindlichkeit auf einen der Inhaltsstoffe oder auf "
    expected << "Ranunculaceen (Hahnenfussgew�chse)."
    assert_equal(expected, paragraph.text)
    paragraph = section.paragraphs.at(1)
    expected =  "Bei vorbestehender Lebersch�digung wird von der Einnahme von "
    expected << "Cimifemin abgeraten."
    assert_equal(expected, paragraph.text)
    paragraph = section.paragraphs.at(2)
    expected =  "Dieses Pr�parat beeinflusst die k�rperlichen und psychischen "
    expected << "Beschwerden in der Ab�nderung (Klimakterium). Da bisher keine "
    expected << "klinischen Daten vorliegen, die eine g�nstige Wirkung auf die "
    expected << "Knochen feststellen lassen, kann deshalb dieses Pr�parat nicht "
    expected << "zur Vorbeugung der Osteoporose verwendet werden."
    assert_equal(expected, paragraph.text)
    paragraph = section.paragraphs.at(3)
    expected =  "Informieren Sie Ihren Arzt, Apotheker oder Drogisten bzw. Ihre "
    expected << "�rztin, Apothekerin oder Drogistin, wenn Sie an anderen "
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
    expected =  "Soweit nicht anders verschrieben, 2 mal t�glich (morgens und "
    expected << "abends) 1 Tablette unzerkaut mit etwas Fl�ssigkeit einnehmen."
    assert_equal(expected, paragraph.text)
    paragraph = section.paragraphs.at(1)
    expected =  "Cimifemin kann l�ngere Zeit angewendet werden, mindestens �ber "
    expected << "einen Zeitraum von 6 Wochen. Eine Anwendung �ber 6 Monate "
    expected << "hinaus soll nur nach R�cksprache mit Ihrem Arzt bzw. Ihrer "
    expected << "�rztin erfolgen."
    assert_equal(expected, paragraph.text)
    paragraph = section.paragraphs.at(2)
    expected =  "Halten Sie sich an die in der Packungsbeilage angegebene oder "
    expected << "vom Arzt bzw. von der �rztin verschriebene Dosierung. Wenn Sie "
    expected << "glauben, das Arzneimittel wirke zu schwach oder zu stark, so "
    expected << "sprechen Sie mit Ihrem Arzt, Apotheker oder Drogisten, bzw. "
    expected << "Ihrer �rztin, Apothekerin oder Drogistin."
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
    expected =  "Folgende Nebenwirkungen k�nnen bei der Einnahme von Cimifemin "
    expected << "auftreten: in seltenen F�llen leichte Magenbeschwerden, "
    expected << "�belkeit, sehr selten bei �berempfindlichkeit Hautausschlag, "
    expected << "Juckreiz."
    assert_equal(expected, paragraph.text)
    paragraph = section.paragraphs.at(1)
    expected =  "In sehr seltenen F�llen gibt es Hinweise auf "
    expected << "Lebersch�digungen. Bei ungew�hnlichem Leistungsabfall, bei "
    expected << "Gelbf�rbung der Bindehaut der Augen oder der Haut, bei dunklem "
    expected << "Urin oder entf�rbtem Stuhl sollte Cimifemin abgesetzt und ein "
    expected << "Arzt bzw. eine �rztin aufgesucht werden."
    assert_equal(expected, paragraph.text)
    paragraph = section.paragraphs.at(2)
    expected =  "Wenn Sie Nebenwirkungen bemerken, die hier nicht beschrieben "
    expected << "sind, sollten Sie Ihren Arzt, Apotheker oder Drogisten bzw. "
    expected << "Ihre �rztin, Apothekerin oder Drogistin informieren."
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
    expected =  "Arzneimittel sollen f�r Kinder unerreichbar aufbewahrt werden. "
    expected << "Bei Raumtemperatur (15-25 �C) aufbewahren."
    assert_equal(expected, paragraph.text)
    paragraph = section.paragraphs.at(1)
    expected =  "Das Arzneimittel darf nur bis zu dem auf dem Beh�lter mit "
    expected << "�Exp� bezeichneten Datum verwendet werden."
    assert_equal(expected, paragraph.text)
    paragraph = section.paragraphs.at(2)
    expected =  "Weitere Ausk�nfte erteilt Ihnen Ihr Arzt, Apotheker oder "
    expected << "Drogist bzw. Ihre �rztin, Apothekerin oder Drogistin."
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
    expected =  "1 Tablette enth�lt: 0,018-0,026 ml Fl�ssigextrakt aus "
    expected << "Cimicifugawurzelstock (Traubensilberkerze), "
    expected << "(DEV: 0,78-1,14:1), Auszugsmittel Isopropanol 40% (V/V)."
    assert_equal(expected, paragraph.text)
    paragraph = section.paragraphs.at(1)
    expected =  "Dieses Pr�parat enth�lt zus�tzlich Hilfsstoffe."
    assert_equal(expected, paragraph.text)
  end
  def test_iksnrs1
    chapter = @writer.iksnrs
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal(1, chapter.sections.size)
    assert_equal('48734 (Swissmedic).', chapter.to_s)
  end
  def test_packages1
    chapter = @writer.packages
    assert_instance_of(ODDB::Text::Chapter, chapter )
    assert_equal("Wo erhalten Sie Cimifemin? Welche Packungen sind erh�ltlich?",
                 chapter.heading)
    assert_equal(1, chapter.sections.size)
    section = chapter.sections.first
    assert_equal("", section.subheading)
    assert_equal(2, section.paragraphs.size)
    paragraph = section.paragraphs.at(0)
    expected =  "In Apotheken und Drogerien, ohne �rztliche Verschreibung."
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
    expected =  "Max Zeller S�hne AG, 8590 Romanshorn."
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
    expected << "die Arzneimittelbeh�rde (Swissmedic) gepr�ft."
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
    assert_equal('Cimifemine�', @writer.name)
  end
  def test_company2
    chapter = @writer.company
    assert_instance_of(ODDB::Text::Chapter, chapter )
    assert_equal('ZELLER', chapter.heading)
  end
  def test_amzv2
    chapter = @writer.amzv
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('OEM�d 9.11.2001', chapter.heading)
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
    expected =  "1 comprim� contient: 0,018-0,026 ml extrait liquide de rhizome "
    expected << "de Cimicifuga (act�e � grappes), (RDE: 0,78-1,14:1), agent "
    expected << "d'extraction: isopropanol 40% (v/v)."
    assert_equal(expected, paragraph.text)
    paragraph = section.paragraphs.at(1)
    expected =  "Cette pr�paration contient en outre des excipients."
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
    assert_equal('Darf Inderal w�hrend einer Schwangerschaft oder in der Stillzeit eingenommen werden?', 
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
    expected =  "Wirkstoff: Mefenamins�ure."
    assert_equal(expected, paragraph.text)
    section = chapter.sections.at(1)
    assert_equal("Filmtabletten\n", section.subheading)
    assert_equal(1, section.paragraphs.size)
    paragraph = section.paragraphs.at(0)
    expected =  "500 mg Mefenamins�ure sowie Vanillin (Aromaticum) und andere "
    expected << "Hilfsstoffe."
    assert_equal(expected, paragraph.text)
    section = chapter.sections.last
    assert_equal("Suspension\n", section.subheading)
    assert_equal(2, section.paragraphs.size)
    paragraph = section.paragraphs.at(0)
    expected =  "5 ml enthalten 50 mg Mefenamins�ure, Konservierungsmittel: "
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
    assert_equal('Wo erhalten Sie Nasivin? Welche Packungen sind erh�ltlich?', chapter.heading)
    section = chapter.sections.first
    assert_instance_of(ODDB::Text::Section, section )
    assert_equal("In Apotheken und Drogerien ohne �rztliche Verschreibung\n", section.subheading)

  end
end
  end
end
