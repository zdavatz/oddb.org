#!/usr/bin/env ruby
# TestFachinfoDocParser -- oddb -- 24.09.2003 -- rwaltert@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path("../src", File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'fachinfo_doc'

module ODDB
	module FiParse
		class FachinfoDocWriter
      attr_reader :name, :company, :galenic_form, :composition, :effects,
        :kinetic, :indications, :usage, :restrictions, :unwanted_effects,
        :interactions, :registration_owner, :overdose, :other_advice, :iksnrs,
        :date, :pregnancy, :contra_indications, :driving_ability, :packages,
        :preclinic
			public :named_chapter, :named_chapters
			attr_reader :chapters
		end
		class FachinfoTextHandler
			public :expand_tabs
			attr_accessor :tabs
		end
	end
end
class TestFachinfoDocParser < Test::Unit::TestCase
  class StubTabDescriptor
    attr_accessor :position, :align
  end
  def setup
    @filename = File.expand_path('data/doc/fi_df_t2.doc', 
      File.dirname(__FILE__))
    @text_handler = ODDB::FiParse::FachinfoTextHandler.new
    @parser = Rwv2.create_parser(@filename)
    @parser.set_text_handler(@text_handler)
    @parser.parse
  end
  def test_name1
    assert_equal(2, @text_handler.writers.size)
    writer = @text_handler.writers.first
    assert_match(/Tramadol Helvepharm.* Kapseln\/Tropfen\/Suppositorien/, writer.name)
    writer = @text_handler.writers.last
    assert_match(/Tramadol Helvepharm.* Capsules\/Gouttes\/Suppositoires/, writer.name)
  end
  def test_company1
    writer = @text_handler.writers.first
    chapter = writer.company
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('HELVEPHARM', chapter.heading)
    assert_equal(0, chapter.sections.size)
    writer = @text_handler.writers.last
    chapter = writer.company
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('HELVEPHARM', chapter.heading)
    assert_equal(0, chapter.sections.size)
  end
  def test_galenic_form_de1
    writer = @text_handler.writers.first
    chapter = writer.galenic_form
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('', chapter.heading)
    assert_equal(1, chapter.sections.size)
    section = chapter.sections.first
    assert_instance_of(ODDB::Text::Section, section)
    assert_equal("Zentralwirksames Analgetikum\n", section.subheading)
    assert_equal(0, section.paragraphs.size)
  end
  def test_galenic_form_fr1
    writer = @text_handler.writers.last
    chapter = writer.galenic_form
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('', chapter.heading)
    assert_equal(1, chapter.sections.size)
    section = chapter.sections.first
    assert_instance_of(ODDB::Text::Section, section)
    assert_match(/Analg.+sique d\'action centrale/, section.subheading)
    assert_equal(0, section.paragraphs.size)
  end
  def test_composition1
    writer = @text_handler.writers.first
    chapter = writer.composition
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Zusammensetzung', chapter.heading)
    assert_equal(10, chapter.sections.size)
    section = chapter.sections.first
    assert_instance_of(ODDB::Text::Section, section)
    assert_equal('Wirkstoff:', section.subheading)
    assert_equal(1, section.paragraphs.size)
    paragraph = section.paragraphs.first
    assert_instance_of(ODDB::Text::Paragraph, paragraph)
    assert_equal('Tramadolhydrochlorid.',paragraph.text)
  end
  def test_effects1
    writer = @text_handler.writers.first
    chapter = writer.effects
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Eigenschaften/Wirkungen', chapter.heading)
    assert_equal(1, chapter.sections.size)
    section = chapter.sections.first
    assert_instance_of(ODDB::Text::Section, section)
    assert_equal('', section.subheading)
    assert_equal(2, section.paragraphs.size)
    paragraph = section.paragraphs.first
    assert_instance_of(ODDB::Text::Paragraph, paragraph)
    assert_equal('Tramadol ist ein Cyclohexanol-Derivat mit opiatagonistischen Eigenschaften. Die Wirkung von Tramadol beruht teilweise auf adrenerge Effekte der Muttersubstanz. Sein aktiver Hauptmetabolit O-Desmethyl-Tramadol ist ein nicht selektiver, reiner Agonist der Opiatrezeptoren, ohne Bevorzugung bestimmter Populationen.',paragraph.text)
  end
  def test_kinetic1
    writer = @text_handler.writers.first
    chapter = writer.kinetic
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Pharmakokinetik', chapter.heading)
    assert_equal(6, chapter.sections.size)
  end
  def test_indications1
    writer = @text_handler.writers.first
    chapter = writer.indications
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_match(/Indikationen\/Anwendungsm.*glichkeiten/, chapter.heading)
    assert_equal(1, chapter.sections.size)
  end
  def test_usage1
    writer = @text_handler.writers.first
    chapter = writer.usage
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Dosierung/Anwendung', chapter.heading)
    assert_equal(10, chapter.sections.size)
    section = chapter.sections.first
    assert_equal(5, section.paragraphs.size)
    paragraph = section.paragraphs.at(1)
    expected = /\-+\nApplikations\-    Einzeldosis              Tagesdosis\nform\n\-+\nKapseln          1 Kapsel \(50 mg\)         bis zu 8 Kapseln\nTropfen          20 Tropfen \(50 mg\)       bis zu\n.* 20 Tropfen\nSuppositorien    1 Suppositorium          bis zu\n +\(100 mg\)                 4 Suppositorien \n\-+\n/
    assert_equal(true, paragraph.preformatted?)
    assert_match(expected, paragraph.text)
  end
  def test_expand_tabs1a
    str = '12345 67890'
    assert_equal(str, @text_handler.expand_tabs(str))
    @text_handler.tabs = [
      0,
      959,
      4795,
      5754,
      6713,
      7672,
      8631,
      1701,
      2268,
      4253,
    ].collect { |pos|
      td =	StubTabDescriptor.new
      td.position = pos
      td
    }
    str = "Applikations-\tEinzeldosis"
    expected = "Applikations-    Einzeldosis"
    assert_equal(expected, @text_handler.expand_tabs(str))
    str = "Applikations-\tEinzeldosis\tTagesdosis"
    expected = "Applikations-    Einzeldosis              Tagesdosis"
    assert_equal(expected, @text_handler.expand_tabs(str))
  end
  def test_expand_tabs1b
    @text_handler.tabs = [
      0,
      959,
      4795,
      5754,
      6713,
      7672,
      8631,
      1701,
      2268,
      4253,
    ].collect { |pos|
      td =	StubTabDescriptor.new
      td.position = pos
      td
    }
    str = "Kapseln\t\t1 Kapsel (50 mg)\tbis zu 8 Kapseln"
    expected = "Kapseln          1 Kapsel (50 mg)         bis zu 8 Kapseln"
    assert_equal(expected, @text_handler.expand_tabs(str))
  end
end
class TestFachinfoDocParser2 < Test::Unit::TestCase
  class StubTabDescriptor
    attr_accessor :position
  end
  def setup
    @filename = File.expand_path('data/doc/fi_df_am.doc', 
      File.dirname(__FILE__))
    @text_handler = ODDB::FiParse::FachinfoTextHandler.new
    @parser = Rwv2.create_parser(@filename)
    @parser.set_text_handler(@text_handler)
    @parser.parse
  end
  def test_effects2
    writer = @text_handler.writers.first
    chapter = writer.effects
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Eigenschaften/Wirkungen', chapter.heading)
    assert_equal(3, chapter.sections.size)
    section = chapter.sections.first
    assert_instance_of(ODDB::Text::Section, section)
    assert_equal('', section.subheading)
    assert_equal(6, section.paragraphs.size)
    paragraph = section.paragraphs.at(2)
    assert_instance_of(ODDB::Text::Paragraph, paragraph)
    expected = <<-EOS
------------------------------------------------------------------------
                   Disktest (10 µg)
                   Durchmesser (mm)
               sensibel      intermediär   resistent
-------------------------------------------------------------------------
Staphylokokken       > 29        -            < 28
Enterokokken         > 17        -            < 16
Streptokokken        > 30      22-29          < 21
Listeria mono-
Cytogenes            > 20        -            < 19
Gram-negative
Darmbakterien        > 17      14-16          < 13
Haemophilus          > 22      19-21          < 18
------------------------------------------------------------------------
                            Verdünnungstest
                            MHK (mg/l)
                            sensibel      resistent
-------------------------------------------------------------------------
Staphylokokken                 < 0,25       Penicil-
                                             linase
Enterokokken                     -            > 16
Streptokokken                  < 0,12          > 4
Listeria monocytogenes          < 2            > 4
Gram-negative Darm-
Bakterien                       < 8           > 32
Haemophilus                     < 1            > 4
------------------------------------------------------------------------
    EOS
    txt = paragraph.text
    expected = /\-+\n +Disktest \(10 .*g\)\n +Durchmesser \(mm\)\n +sensibel +.* +resistent\n\-+\nStaphylokokken +\> 29 +\- +\< 28\nEnterokokken +\> 17 +\- +\< 16\nStreptokokken +\> 30 +22\-29 +\< 21\nListeria mono\-\nCytogenes +\> 20 +\- +\< 19\nGram-negative\nDarmbakterien +\> 17 +14\-16 +\< 13\nHaemophilus +\> 22 +19\-21 +\< 18\n\-+\n +Ver.*nungstest\n +MHK \(mg\/l\)\n +sensibel      resistent\n\-+\nStaphylokokken +\< 0,25 +Penicil\-\n +linase\nEnterokokken +\- +\> 16\nStreptokokken +\< 0,12 +\> 4\nListeria monocytogenes +\< 2 +\> 4\nGram\-negative Darm\-\nBakterien +\< 8 +\> 32\nHaemophilus +\< 1 +\> 4\n\-+/
    assert_match(expected, txt)
  end
end
class TestFachinfoDocParser4 < Test::Unit::TestCase
  def setup
    @filename = File.expand_path('data/doc/felodil_12_01.doc', 
      File.dirname(__FILE__))
    @text_handler = ODDB::FiParse::FachinfoTextHandler.new
    @parser = Rwv2.create_parser(@filename)
    @parser.set_text_handler(@text_handler)
    @parser.parse
  end
  def test_name4
    assert_equal(2, @text_handler.writers.size)
    writer = @text_handler.writers.first
    assert_match(/Felodil.* 5\/10\n/, writer.name)
    writer = @text_handler.writers.last
    assert_match(/Felodil.* 5\/10\n/, writer.name)
  end
  def test_composition4
    writer = @text_handler.writers.first
    chapter = writer.composition
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Zusammensetzung', chapter.heading)
    assert_equal(2, chapter.sections.size)
    section = chapter.sections.first
    assert_instance_of(ODDB::Text::Section, section)
    assert_equal('a) Wirkstoff:', section.subheading)
    assert_equal(1, section.paragraphs.size)
    paragraph = section.paragraphs.first
    assert_instance_of(ODDB::Text::Paragraph, paragraph)
    assert_equal('Felodipin',paragraph.text)
    section = chapter.sections.at(1)
    assert_instance_of(ODDB::Text::Section, section)
    assert_equal('b) Hilfsstoffe:', section.subheading)
    assert_equal(1, section.paragraphs.size)
    paragraph = section.paragraphs.first
    assert_instance_of(ODDB::Text::Paragraph, paragraph)
    assert_equal('Excipiens pro compresso obducto.',paragraph.text)
  end
  def test_galenic_form_de4
    writer = @text_handler.writers.first
    chapter = writer.galenic_form
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Galenische Form und Wirkstoffmenge pro Einheit', chapter.heading)
    assert_equal(1, chapter.sections.size)
    section = chapter.sections.first
    assert_instance_of(ODDB::Text::Section, section)
    assert_equal("", section.subheading)
    assert_equal(2, section.paragraphs.size)
  end
  def test_indications4
    writer = @text_handler.writers.first
    chapter = writer.indications
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_match(/Indikationen \/ Anwendungsm.*glichkeiten/, chapter.heading)
    assert_equal(1, chapter.sections.size)
  end
  def test_usage4
    writer = @text_handler.writers.first
    chapter = writer.usage
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Dosierung / Anwendung', chapter.heading)
    assert_equal(5, chapter.sections.size)
  end
  def test_effects4
    writer = @text_handler.writers.first
    chapter = writer.effects
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Eigenschaften / Wirkungen', chapter.heading)
    assert_equal(1, chapter.sections.size)
    section = chapter.sections.first
    assert_instance_of(ODDB::Text::Section, section)
    assert_equal('', section.subheading)
    assert_equal(19, section.paragraphs.size)
    paragraph = section.paragraphs.at(17)
    assert_instance_of(ODDB::Text::Paragraph, paragraph)
    expected = /In der HOT\-Studie \(Hypertension Optimal Treatment\) wurde Felodipin entweder als Monotherapie oder bei Bedarf in Kombination mit b\-Blockern und\/oder ACE\-Hemmern und\/oder Diuretika verabreicht. Die Wirkung auf die .*ufigsten kardiovasku.*ren Ereignisse \(z\.B\. akuter Myokardinfarkt, Herzschlag und Herztod\) wurde in Beziehung zu den angestrebten diastolischen Blutdruck\-Werten untersucht\. Insgesamt wurden 18 790 Patienten mit an.*nglichen diastolischen Blutdruck\-Werten von 100\-115 mmHg im Alter zwischen 50\-80 Jahren .*hrend durchschnittlich 3,8 \(Bereich 3,3\-4,9\) Jahren in die Studie miteinbezogen\./ 
    assert_match(expected, paragraph.text)
  end
  def test_iksnrs4
    writer = @text_handler.writers.first
    chapter = writer.iksnrs
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Zulassungsvermerk', chapter.heading)
    assert_equal(1, chapter.sections.size)
    section = chapter.sections.first
    assert_equal(1, section.paragraphs.size)
    paragraph = section.paragraphs.first
    result = paragraph.text
    assert_match(/56.*170/, result)
  end
  def test_registration_owner4
    writer = @text_handler.writers.first
    chapter = writer.registration_owner
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Zulassungsinhaberin', chapter.heading)
  end
end
class TestFachinfoDocParser5 < Test::Unit::TestCase
  def setup
    @filename = File.expand_path('data/doc/Calcitriol_d_10.03.doc', 
      File.dirname(__FILE__))
    @text_handler = ODDB::FiParse::FachinfoTextHandler.new
    @parser = Rwv2.create_parser(@filename)
    @parser.set_text_handler(@text_handler)
    @parser.parse
  end
  def test_name5
    assert_equal(1, @text_handler.writers.size)
    writer = @text_handler.writers.first
    assert_equal("Calcitriol Salmon Pharma\n", writer.name)
  end
  def test_company5
    writer = @text_handler.writers.first
    chapter = writer.company
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal("Salmon Pharma", chapter.heading)
  end
  def test_composition5
    writer = @text_handler.writers.first
    chapter = writer.composition
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Zusammensetzung', chapter.heading)
    assert_equal(2, chapter.sections.size)
    section = chapter.sections.first
    assert_instance_of(ODDB::Text::Section, section)
    assert_equal('Wirkstoff:', section.subheading)
    assert_equal(1, section.paragraphs.size)
    paragraph = section.paragraphs.first
    assert_instance_of(ODDB::Text::Paragraph, paragraph)
  end
  def test_galenic_form5
    writer = @text_handler.writers.first
    chapter = writer.galenic_form
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Galenische Form und Wirkstoffmenge pro Einheit', chapter.heading)
    assert_equal(1, chapter.sections.size)
    section = chapter.sections.first
    assert_instance_of(ODDB::Text::Section, section)
    assert_equal("Kapseln\n", section.subheading)
    assert_equal(1, section.paragraphs.size)
  end
  def test_indications5
    writer = @text_handler.writers.first
    chapter = writer.indications
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_match(/Indikationen\/Anwendungsm.*glichkeiten/, chapter.heading)
    assert_equal(1, chapter.sections.size)
  end
  def test_usage5
    writer = @text_handler.writers.first
    chapter = writer.usage
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Dosierung/Anwendung', chapter.heading)
    assert_equal(7, chapter.sections.size)
  end
  def test_iksnrs5
    writer = @text_handler.writers.first
    chapter = writer.iksnrs
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Zulassungsvermerk', chapter.heading)
    assert_equal(1, chapter.sections.size)
    assert_equal(1, chapter.sections.first.paragraphs.size)
    paragraph = chapter.sections.first.paragraphs.first
    assert_equal("55950 (Swissmedic)", paragraph.text)
  end
  def test_registration_owner5
    writer = @text_handler.writers.first
    chapter = writer.registration_owner
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Zulassungshinhaberin:', chapter.heading)
  end
  def test_pregnancy5
    writer = @text_handler.writers.first
    chapter = writer.pregnancy
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Schwangerschaft/Stillzeit', chapter.heading)
    assert_equal(1, chapter.sections.size)
    section = chapter.sections.first
    assert_equal('', section.subheading)
    paragraph = section.paragraphs.at(1)
    expected = /Tierexperimentelle Studien haben eine Fetotoxizit.*t gezeigt \(s\..*Pr.*klinische Daten.*\)\./
    assert_match(expected, paragraph.text)
    paragraph = section.paragraphs.at(2)
    expected = /Es gibt keine Hinweise daf.*r\, dass Vitamin D .* selbst in sehr hohen Dosen .* beim Menschen teratogen wirkt\. Calcitriol Salmon Pharma sollte w.*hrend der Schwangerschaft nur dann angewandt werden\, wenn dies klar notwendig ist\./
    assert_match(expected, paragraph.text)
  end
  def test_packages5
    writer = @text_handler.writers.first
    chapter = writer.packages
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Packungen', chapter.heading)
    assert_equal(1, chapter.sections.size)
  end
end
class TestFachinfoDocParser6 < Test::Unit::TestCase
  class ReplHandler
    def method_missing(*args)
      puts "inline_replacement_handler received: #{args.inspect}"
    end
  end
  def setup
    @filename = File.expand_path('data/doc/Cimzia_d_07.doc', 
      File.dirname(__FILE__))
    @parser = Rwv2.create_parser(@filename)
    @text_handler = ODDB::FiParse::FachinfoTextHandler.new
    @parser.set_text_handler(@text_handler)
    @table_handler = @text_handler.table_handler
    @parser.set_table_handler(@table_handler)
    @parser.set_inline_replacement_handler(ReplHandler.new)
    @parser.parse
  end
  def test_name6
    assert_equal(1, @text_handler.writers.size)
    writer = @text_handler.writers.first
    #assert_equal("CIMZIA\256, Pulver\n", writer.name)
    assert_match(/CIMZIA.* Pulver\n/, writer.name)
  end
  def test_composition6
    writer = @text_handler.writers.first
    chapter = writer.composition
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Zusammensetzung', chapter.heading)
    assert_equal(2, chapter.sections.size)
    section = chapter.sections.first
    assert_instance_of(ODDB::Text::Section, section)
    assert_equal('Wirkstoff:', section.subheading)
    assert_equal(1, section.paragraphs.size)
    paragraph = section.paragraphs.first
    assert_instance_of(ODDB::Text::Paragraph, paragraph)
  end
  def test_galenic_form6
    writer = @text_handler.writers.first
    chapter = writer.galenic_form
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Galenische Form und Wirkstoffmenge pro Einheit', chapter.heading)
    assert_equal(1, chapter.sections.size)
    section = chapter.sections.first
    assert_instance_of(ODDB::Text::Section, section)
    assert_equal("", section.subheading)
    assert_equal(2, section.paragraphs.size)
  end
  def test_indications6
    writer = @text_handler.writers.first
    chapter = writer.indications
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_match(/Indikationen\/Anwendungsm.*glichkeiten/, chapter.heading)
    assert_equal(1, chapter.sections.size)
  end
  def test_usage6
    writer = @text_handler.writers.first
    chapter = writer.usage
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Dosierung/Anwendung', chapter.heading)
    assert_equal(1, chapter.sections.size)
  end
  def test_contra_indiations6
    writer = @text_handler.writers.first
    chapter = writer.contra_indications
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Kontraindikationen', chapter.heading)
    assert_equal(1, chapter.sections.size)
  end
  def test_restrictions6
    writer = @text_handler.writers.first
    chapter = writer.restrictions
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Warnhinweise und Vorsichtsmassnahmen', chapter.heading)
    assert_equal(1, chapter.sections.size)
  end
  def test_interactions6
    writer = @text_handler.writers.first
    chapter = writer.interactions
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Interaktionen', chapter.heading)
    assert_equal(1, chapter.sections.size)
  end
  def test_pregnancy6
    writer = @text_handler.writers.first
    chapter = writer.pregnancy
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Schwangerschaft, Stillzeit', chapter.heading)
    assert_equal(2, chapter.sections.size)
    section = chapter.sections.first
    assert_equal("Schwangerschaft\n", section.subheading)
    paragraph = section.paragraphs.at(0)
    expected = /In tierexperimentellen Untersuchungen mit Ratten von bis zu 100 mg\/kg eines pegylierten Fab Fragmentes eines Nager-anti-murinen Antik.*rpers \(cTN3 PF\) .*hnlich Certolizumab pegol wurden keine Anzeichen von maternaler Toxizit.*t oder Teratogenit.*t beobachtet. Im Zuge einer embryof.*talen Entwicklungsstudie traten bei 20 mg\/kg spontane Missbildungen der Niere auf, die in den historischen Kontrollen nicht aufscheinen aber nicht dosisabh.*ngig waren. Es liegen keine kontrollierten Studien mit Schwangeren vor\. Auf Grund seiner inhibitorischen Wirkung auf TNF.* k.*nnte sich Certolizumab pegol bei einer Anwendung w.*hrend der Schwangerschaft auf die normalen Immunreaktionen beim Neugeborenen auswirken. Cimzia sollte daher w.*hrend der Schwangerschaft nicht angewendet werden, es sei denn, dies ist klar notwendig\. Frauen im geb.*rf.*higen Alter wird dringend empfohlen, durch geeignete empf.*ngnisverh.*tende Massnahmen einer Schwangerschaft vorzubeugen und diese nach Ende der Behandlung mit Cimzia noch mindestens 4 Monate lang anzuwenden\./
    assert_match(expected, paragraph.text)
    section = chapter.sections.last
    assert_equal("Stillzeit\n", section.subheading)
    paragraph = section.paragraphs.at(0)
    expected = /In Tierstudien wurde ein Transfer von cTN3 PF in die Muttermilch von Ratten mit einer Milch.*Plasma Ratio von ca\. 10 \% gemessen\. Es ist nicht bekannt, ob Certolizumab pegol .*ber die menschliche Muttermilch ausgeschieden wird\. Es wird daher empfohlen, Cimzia w.*hrend der Schwangerschaft nicht anzuwenden\./
    assert_match(expected, paragraph.text)
  end
  def test_driving_ability6
    writer = @text_handler.writers.first
    chapter = writer.driving_ability
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_match(/Wirkung auf die Fahrt.*chtigkeit und auf das Bedienen von Maschinen/,
                 chapter.heading)
    assert_equal(1, chapter.sections.size)
    paragraph = chapter.sections.first.paragraphs.first
    assert_match(/Es wurden keine entsprechenden Studien durchgef.*hrt\./, 
                 paragraph.text)
  end
  def test_unwanted_effects6
    writer = @text_handler.writers.first
    chapter = writer.unwanted_effects
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_match(/Unerw.*nschte Wirkungen/, chapter.heading)
    assert_equal(1, chapter.sections.size)
    section = chapter.sections.first
    assert_instance_of(ODDB::Text::Section, section)
    assert_match(/Tabelle 1\:.*Unerw.*nschte Wirkungen in klinischen Studien/,
                 section.paragraphs.at(7).text)
    table = section.paragraphs.at(8)
    assert_instance_of ODDB::Text::Table, table
    assert_equal(47, table.rows.size)
    assert_equal('Systemorganklasse', table.cell(0,0).text)
    assert_match(/H.*ufigkeit/, table.cell(0,1).text)
    assert_match(/Unerw.*nschte Ereignisse/, table.cell(0,2).text)
    assert_equal('Infektionen', table.cell(1,0).text)
    assert_match(/H.*ufig/, table.cell(1,1).text)
    assert_equal('Infektionen der Harnwege, Herpes simplex, Infektionen der oberen Atemwege', 
                 table.cell(1,2).text)
    assert_equal('', table.cell(2,0).text)
    assert_equal('Gelegentlich', table.cell(2,1).text)
    assert_match(/Influenza, perianale Abszesse, Bronchitis, Sinusitis, Abszesse, Cellulitis, Herpes zoster, abdominale Abszesse, Pilzinfektionen, Candidiasis, Otitis externa, Pharyngitis, perirektale Abszesse, Infektionen der Atemwege, Tonsillitis, Vaginalmykosen, Furunkel, Gastroenteritis, Pneumonie \(mit teilweise t.*dlichem Verlauf\), Varizellen/, 
                 table.cell(2,2).text)
    assert_equal('Atmungsorgane', table.cell(24,0).text)
    assert_equal('Gelegentlich', table.cell(24,1).text)
    assert_equal('Dyspnoe, Rhinitis, Pleuraerguss', table.cell(24,2).text)
    assert_match(/Gastrointestinale St.*rungen/, table.cell(26,0).text)
    assert_equal('Untersuchungen', table.cell(46,0).text)
    assert_equal('Selten', table.cell(46,1).text)
    assert_match(/Verl.*ngerte Gerinnungszeit/, table.cell(46,2).text)
    next_par = section.paragraphs.at(9)
    assert_match(/In klinischen Studien sind in seltenen F.*llen Blasenbildung, Verletzungen, Erstickung und Erm.*dungsbr.*che aufgetreten\./,
                 next_par.text)
  end
  def test_overdose6
    writer = @text_handler.writers.first
    chapter = writer.overdose
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_match(/.*berdosierung/, chapter.heading)
  end
  def test_effects6
    writer = @text_handler.writers.first
    chapter = writer.effects
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Eigenschaften/Wirkungen', chapter.heading)
    assert_equal(4, chapter.sections.size)
    section = chapter.sections.at(0)
    assert_equal('ATC-Code:', section.subheading)
    assert_equal(2, section.paragraphs.size)
    section = chapter.sections.at(3)
    assert_equal "Klinische Wirksamkeit:\n", section.subheading
    assert_match(/Tabelle 2\:.*PRECiSE 1 .* Klinisches Ansprechen; gesamte Studienpopulation/,
                 section.paragraphs.at(4).text) 
    table = section.paragraphs.at(5)
    assert_instance_of ODDB::Text::Table, table
    assert_equal 19, table.rows.size
    assert_equal "Anzahl (%) der Responder\n95%CI", table.cell(0,1).text
    fmts = table.cell(0,1).formats 
    assert_equal(2, fmts.size)
    assert_equal([:bold], fmts.first.values)
    assert_equal(0..23, fmts.first.range)
    assert_equal([], fmts.last.values)
    assert_equal(24..-1, fmts.last.range)
    assert_match(/.* p\-Wert nicht berechnet\n\* p\-value \< 0,05 logistischer Regressionstest/, 
                 table.cell(18,0).text)
    assert_equal(3, table.cell(18,0).col_span)
    next_par = section.paragraphs.at(6)
    assert_match(/Die Anwendung von Immunsuppressiva oder Kortikosteroiden zum Baseline.*Zeitpunkt hatte keine Auswirkungen auf das klinische Ansprechen auf Cimzia\. Cimzia war wirksam in Bezug auf die Induktion und Aufrechterhaltung des Ansprechens in der Subpopulation der mit Infliximab vorbehandelten Patienten \(Woche 6: 24,5\% vs 20,0\%\; Wochen 6 und 26\: 15,5\% vs 10,6\% f.*r Cimzia bzw\. Placebo\)\./,
                 next_par.text)
    assert_match(/Tabelle 3\:.*PRECiSE 2 .* Klinisches Ansprechen \(Response\) und klinische Remission in der Gesamt.*Studienpopulation/,
                 section.paragraphs.at(17).text) 
    table = section.paragraphs.at(18)
    assert_instance_of ODDB::Text::Table, table
    assert_equal 5, table.cell(7,0).col_span
  end
  def test_kinetic6
    writer = @text_handler.writers.first
    chapter = writer.kinetic
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Pharmakokinetik', chapter.heading)
    assert_equal(5, chapter.sections.size)
    assert_equal("", chapter.sections.at(0).subheading)
    assert_equal("Absorption\n", chapter.sections.at(1).subheading)
  end
  def test_iksnrs6
    writer = @text_handler.writers.first
    chapter = writer.iksnrs
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Zulassungsnummer', chapter.heading)
    assert_equal(1, chapter.sections.size)
    assert_equal(1, chapter.sections.first.paragraphs.size)
    paragraph = chapter.sections.first.paragraphs.first
    assert_match(/57.*856 \(Swissmedic\)/, paragraph.text)
  end
  def test_registration_owner6
    writer = @text_handler.writers.first
    chapter = writer.registration_owner
    assert_instance_of(ODDB::Text::Chapter, chapter)
    assert_equal('Zulassungsinhaberin', chapter.heading)
  end
end
=begin  ## this file consists of some kind of layout table - ignore for the moment
class TestFachinfoDocParser7 < Test::Unit::TestCase
	def setup
		@filename = File.expand_path('data/doc/Flectoparin_d_08.doc', 
			File.dirname(__FILE__))
		@text_handler = ODDB::FiParse::FachinfoTextHandler.new
		@parser = Rwv2.create_parser(@filename)
		@parser.set_text_handler(@text_handler)
    @table_handler = @text_handler.table_handler
    @parser.set_table_handler(@table_handler)
		@parser.parse
    @text_handler.cutoff_fontsize = 28
		@parser.parse
	end
	def test_name7
		assert_equal(1, @text_handler.writers.size)
		writer = @text_handler.writers.first
    #puts writer.inspect
		assert_equal("Flectoparin Tissugel\n", writer.name)
	end
	def test_composition7
		writer = @text_handler.writers.first
		chapter = writer.composition
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Zusammensetzung', chapter.heading)
		assert_equal(2, chapter.sections.size)
		section = chapter.sections.first
		assert_instance_of(ODDB::Text::Section, section)
		assert_equal('Wirkstoffe:', section.subheading)
		assert_equal(1, section.paragraphs.size)
		paragraph = section.paragraphs.first
		assert_instance_of(ODDB::Text::Paragraph, paragraph)
	end
	def test_galenic_form7
		writer = @text_handler.writers.first
		chapter = writer.galenic_form
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Galenische Form und Wirkstoffmenge pro Einheit', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_instance_of(ODDB::Text::Section, section)
		assert_equal("", section.subheading)
		assert_equal(2, section.paragraphs.size)
	end
	def test_indications7
		writer = @text_handler.writers.first
		chapter = writer.indications
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Indikationen/Anwendungsmöglichkeiten', chapter.heading)
		assert_equal(1, chapter.sections.size)
	end
	def test_usage7
		writer = @text_handler.writers.first
		chapter = writer.usage
		assert_instance_of(ODDB::Text::Chapter, chapter)
  	assert_equal('Dosierung/Anwendung', chapter.heading)
		assert_equal(2, chapter.sections.size)
	end
	def test_contra_indiations7
		writer = @text_handler.writers.first
		chapter = writer.contra_indications
		assert_instance_of(ODDB::Text::Chapter, chapter)
  	assert_equal('Kontraindikationen', chapter.heading)
		assert_equal(1, chapter.sections.size)
	end
	def test_restrictions7
		writer = @text_handler.writers.first
		chapter = writer.restrictions
		assert_instance_of(ODDB::Text::Chapter, chapter)
  	assert_equal('Warnhinweise und Vorsichtsmassnahmen', chapter.heading)
		assert_equal(1, chapter.sections.size)
	end
	def test_interactions7
		writer = @text_handler.writers.first
		chapter = writer.interactions
		assert_instance_of(ODDB::Text::Chapter, chapter)
  	assert_equal('Interaktionen', chapter.heading)
		assert_equal(1, chapter.sections.size)
	end
	def test_pregnancy7
    puts @table_handler.inspect
    flunk
		writer = @text_handler.writers.first
		chapter = writer.pregnancy
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Schwangerschaft/Stillzeit', chapter.heading)
		assert_equal(5, chapter.sections.size)
		section = chapter.sections.first
	end
	def test_driving_ability7
		writer = @text_handler.writers.first
		chapter = writer.driving_ability
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Wirkung auf die Fahrtüchtigkeit und auf das Bedienen von Maschinen',
                 chapter.heading)
		assert_equal(1, chapter.sections.size)
	end
	def test_unwanted_effects7
		writer = @text_handler.writers.first
		chapter = writer.unwanted_effects
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Unerwünschte Wirkungen', chapter.heading)
		assert_equal(3, chapter.sections.size)
    section = chapter.sections.first
	end
	def test_overdose7
		writer = @text_handler.writers.first
		chapter = writer.overdose
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Überdosierung', chapter.heading)
		assert_equal(1, chapter.sections.size)
    section = chapter.sections.first
	end
	def test_effects7
		writer = @text_handler.writers.first
		chapter = writer.effects
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Eigenschaften/Wirkungen', chapter.heading)
		assert_equal(6, chapter.sections.size)
    section = chapter.sections.first
	end
	def test_kinetic7
		writer = @text_handler.writers.first
		chapter = writer.kinetic
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Pharmakokinetik', chapter.heading)
		assert_equal(2, chapter.sections.size)
    section = chapter.sections.first
	end
	def test_preclinic7
		writer = @text_handler.writers.first
		chapter = writer.preclinic
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Präklinische Daten', chapter.heading)
		assert_equal(1, chapter.sections.size)
    section = chapter.sections.first
	end
	def test_other_advice7
		writer = @text_handler.writers.first
		chapter = writer.other_advice
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Sonstige Hinweise', chapter.heading)
		assert_equal(4, chapter.sections.size)
    section = chapter.sections.first
	end
	def test_iksnrs7
		writer = @text_handler.writers.first
		chapter = writer.iksnrs
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Zulassungsvermerk', chapter.heading)
		assert_equal(1, chapter.sections.size)
		assert_equal(1, chapter.sections.first.paragraphs.size)
		paragraph = chapter.sections.first.paragraphs.first
		assert_equal("57'347 (Swissmedic)", paragraph.text)
	end
	def test_packages7
		writer = @text_handler.writers.first
		chapter = writer.packages
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Packungen', chapter.heading)
		assert_equal(1, chapter.sections.size)
    section = chapter.sections.first
	end
	def test_registration_owner7
		writer = @text_handler.writers.first
		chapter = writer.registration_owner
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Zulassungsinhaberin', chapter.heading)
		assert_equal(1, chapter.sections.size)
	end
end
=end
class TestFachinfoDocParser8 < Test::Unit::TestCase
  class ReplHandler
    def method_missing(*args)
      puts "inline_replacement_handler received: #{args.inspect}"
    end
  end
	def setup
		@filename = File.expand_path('data/doc/Togal_ASS_f.doc', 
			File.dirname(__FILE__))
		@text_handler = ODDB::FiParse::FachinfoTextHandler.new
		@parser = Rwv2.create_parser(@filename)
		@parser.set_text_handler(@text_handler)
    @table_handler = @text_handler.table_handler
    @parser.set_table_handler(@table_handler)
    @parser.set_inline_replacement_handler(ReplHandler.new)
		@parser.parse
    @text_handler.cutoff_fontsize = @text_handler.max_fontsize
		@parser.parse
	end
	def test_name8
		assert_equal(1, @text_handler.writers.size)
		writer = @text_handler.writers.first
		assert_match(/Togal.+ ASS 300\/500\n/, writer.name)
	end
	def test_composition8
		writer = @text_handler.writers.first
		chapter = writer.composition
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Composition', chapter.heading)
		assert_equal(2, chapter.sections.size)
		section = chapter.sections.first
		assert_instance_of(ODDB::Text::Section, section)
		assert_match(/Principe actif.*\:/, section.subheading)
		assert_equal(1, section.paragraphs.size)
		paragraph = section.paragraphs.first
		assert_instance_of(ODDB::Text::Paragraph, paragraph)
	end
	def test_galenic_form8
		writer = @text_handler.writers.first
		chapter = writer.galenic_form
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_match(/Forme gal.*nique et quantit.* de principe actif par unit.+/, chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_instance_of(ODDB::Text::Section, section)
		assert_equal("", section.subheading)
		assert_equal(2, section.paragraphs.size)
	end
	def test_indications8
		writer = @text_handler.writers.first
		chapter = writer.indications
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_match(/Indications\/Possibilit.*s d.*emploi/, chapter.heading)
		assert_equal(1, chapter.sections.size)
	end
	def test_usage8
		writer = @text_handler.writers.first
		chapter = writer.usage
		assert_instance_of(ODDB::Text::Chapter, chapter)
  	assert_match(/Posologie\/Mode d.*emploi/, chapter.heading)
		assert_equal(2, chapter.sections.size)
	end
	def test_contra_indiations8
		writer = @text_handler.writers.first
		chapter = writer.contra_indications
		assert_instance_of(ODDB::Text::Chapter, chapter)
  	assert_equal('Contre-indications', chapter.heading)
		assert_equal(1, chapter.sections.size)
	end
	def test_restrictions8
		writer = @text_handler.writers.first
		chapter = writer.restrictions
		assert_instance_of(ODDB::Text::Chapter, chapter)
  	assert_match(/Mises en garde et pr.*cautions/, chapter.heading)
		assert_equal(1, chapter.sections.size)
    section = chapter.sections.first
    paragraph = section.paragraphs.at(6)
    assert_match(/carence en glucose-6-phosphate-d.*shydrog.*nase d.*origine g.*n.*tique;/,
                 paragraph.text)
    paragraph = section.paragraphs.at(7)
    assert_match(/traitement concomitant par des anticoagulants.*;/,
                 paragraph.text)
	end
	def test_interactions8
		writer = @text_handler.writers.first
		chapter = writer.interactions
		assert_instance_of(ODDB::Text::Chapter, chapter)
  	assert_equal('Interactions', chapter.heading)
		assert_equal(1, chapter.sections.size)
	end
	def test_pregnancy8
		writer = @text_handler.writers.first
		chapter = writer.pregnancy
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Grossesse/Allaitement', chapter.heading)
		assert_equal(2, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("Grossesse\n", section.subheading)
		paragraph = section.paragraphs.at(0)
    expected = /La prudence s.*impose lors de l.*utilisation de salicylates durant le premier et le deuxi.*me trimestres de la grossesse\. En exp.*rimentation animale, les salicylates ont montr.* des effets ind.*sirables sur le f.*tus \(tels qu.*une augmentation de la mortalit.*, des troubles de la croissance, des intoxications aux salicylates\), mais il n.*existe pas d.*tudes contr.*l.*es chez la femme enceinte\. En fonction des exp.*riences actuelles, il semble cependant que ce risque soit minime aux doses th.*rapeutiques normales\. Au cours du dernier trimestre de la grossesse, la prise de salicylates peut entra.*ner une inhibition des contractions et des h.*morragies, une prolongation de la dur.*e de la gestation et une fermeture pr.*matur.*e du canal art.*riel \(ductus arteriosus\)\. Voici pourquoi ils sont contre\-indiqu.*s\./
		assert_match(expected, paragraph.text)
		section = chapter.sections.last
		assert_equal("Allaitement\n", section.subheading)
		paragraph = section.paragraphs.at(0)
    expected = /Les salicylates passent dans le lait maternel\. La concentration dans le lait maternel est la m.*me ou m.*me plus haute que dans le plasma maternel. Aux doses habituelles utilis.*es .* court terme \(pour l.*analg.*sie et l.*action antipyr.*tique\), aucune cons.*quence nuisible pour le nourrisson n.*est .* pr.*voir. Une interruption de l.*allaitement n.*est pas n.*cessaire si le m.*dicament est utilis.* occasionnellement aux doses recommand.*es. L.*allaitement devrait .*tre interrompu si le m.*dicament est utilis.* de mani.*re prolong.*e, resp\. .* des doses plus .*lev.*es\./
		assert_match(expected, paragraph.text)
	end
	def test_driving_ability8
		writer = @text_handler.writers.first
		chapter = writer.driving_ability
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_match(/Effet sur l.*aptitude .* la conduite et .* l.*utilisation de machines/,
                 chapter.heading)
		assert_equal(1, chapter.sections.size)
	end
	def test_unwanted_effects8
		writer = @text_handler.writers.first
		chapter = writer.unwanted_effects
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_match(/Effets ind.*sirables/, chapter.heading)
		assert_equal(21, chapter.sections.size)
    section = chapter.sections.first
	end
	def test_company8
		writer = @text_handler.writers.first
		chapter = writer.company
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('ARS VITAE', chapter.heading)
	end
	def test_iksnrs8
		writer = @text_handler.writers.first
		chapter = writer.iksnrs
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Estampille', chapter.heading)
		assert_equal(1, chapter.sections.size)
		assert_equal(1, chapter.sections.first.paragraphs.size)
		paragraph = chapter.sections.first.paragraphs.first
		assert_equal("50863 (Swissmedic).", paragraph.text)
	end
	def test_registration_owner8
		writer = @text_handler.writers.first
		chapter = writer.registration_owner
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_match(/Titulaire de l.*autorisation/, chapter.heading)
	end
end
class TestFachinfoDocParser9 < Test::Unit::TestCase
  class ReplHandler
    def method_missing(*args)
      puts "inline_replacement_handler received: #{args.inspect}"
    end
  end
	def setup
		@filename = File.expand_path('data/doc/Calcitriol_f.doc', 
			File.dirname(__FILE__))
		@text_handler = ODDB::FiParse::FachinfoTextHandler.new
		@parser = Rwv2.create_parser(@filename)
		@parser.set_text_handler(@text_handler)
    @table_handler = @text_handler.table_handler
    @parser.set_table_handler(@table_handler)
    @parser.set_inline_replacement_handler(ReplHandler.new)
		@parser.parse
    @text_handler.cutoff_fontsize = @text_handler.max_fontsize
		@parser.parse
	end
  def test_test
    assert(true)
  end
	def test_name9
    ## the difficulty here is that we have no uniquely largest fontsize.
		assert_equal(1, @text_handler.writers.size)
		writer = @text_handler.writers.first
		assert_equal("Calcitriol Salmon Pharma\n", writer.name)
    assert_equal(20, writer.chapters.length)
	end
	def test_registration_owner9
		writer = @text_handler.writers.first
		chapter = writer.registration_owner
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_match(/Titulaire de l.*autorisation/, chapter.heading)
	end
end
class TestFachinfoDocParser10 < Test::Unit::TestCase
  class ReplHandler
    def method_missing(*args)
      puts "inline_replacement_handler received: #{args.inspect}"
    end
  end
	def setup
		#@filename = File.expand_path('data/doc/test.doc', 
		@filename = File.expand_path('data/doc/Tendro.doc', 
			File.dirname(__FILE__))
		@text_handler = ODDB::FiParse::FachinfoTextHandler.new
		@parser = Rwv2.create_parser(@filename)
		@parser.set_text_handler(@text_handler)
    @table_handler = @text_handler.table_handler
    @parser.set_table_handler(@table_handler)
    @parser.set_inline_replacement_handler(ReplHandler.new)
		@parser.parse
    #@text_handler.cutoff_fontsize = @text_handler.max_fontsize
		#@parser.parse
	end
	def test_name10
		assert_equal(1, @text_handler.writers.size)
		writer = @text_handler.writers.first
		assert_equal("Tendro, Augentropfen\n", writer.name)
	end
	def test_composition10
		writer = @text_handler.writers.first
		chapter = writer.composition
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Zusammensetzung', chapter.heading)
		assert_equal(2, chapter.sections.size)
		section = chapter.sections.first
		assert_instance_of(ODDB::Text::Section, section)
		assert_equal(1, section.paragraphs.size)
		paragraph = section.paragraphs.first
		assert_instance_of(ODDB::Text::Paragraph, paragraph)
	end
	def test_galenic_form10
		writer = @text_handler.writers.first
		chapter = writer.galenic_form
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal("Galenische Form und Wirkstoffmengen pro Einheit", 
                 chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_instance_of(ODDB::Text::Section, section)
		assert_match(/Tropfen\. 1 ml enth.*lt\:\n/, section.subheading)
		assert_equal(1, section.paragraphs.size)
	end
	def test_indications10
		writer = @text_handler.writers.first
		chapter = writer.indications
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_match(/Indikationen\/Anwendungsm.*glichkeiten/, chapter.heading)
		assert_equal(1, chapter.sections.size)
	end
	def test_iksnrs10
		writer = @text_handler.writers.first
		chapter = writer.iksnrs
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Zulassungsnummer', chapter.heading)
		assert_equal(1, chapter.sections.size)
		assert_equal(1, chapter.sections.first.paragraphs.size)
		paragraph = chapter.sections.first.paragraphs.first
		assert_equal("47831  (Swissmedic)", paragraph.text)
	end
	def test_registration_owner10
		writer = @text_handler.writers.first
		chapter = writer.registration_owner
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Zulassungsinhaberin', chapter.heading)
	end
end
class TestFachinfoDocParser11 < Test::Unit::TestCase
  class ReplHandler
    def method_missing(*args)
      puts "inline_replacement_handler received: #{args.inspect}"
    end
  end
	def setup
		@filename = File.expand_path('data/doc/Yakona_d.doc', 
			File.dirname(__FILE__))
		@text_handler = ODDB::FiParse::FachinfoTextHandler.new
		@parser = Rwv2.create_parser(@filename)
		@parser.set_text_handler(@text_handler)
    @table_handler = @text_handler.table_handler
    @parser.set_table_handler(@table_handler)
    @parser.set_inline_replacement_handler(ReplHandler.new)
		@parser.parse
    #@text_handler.cutoff_fontsize = @text_handler.max_fontsize
		#@parser.parse
	end
	def test_name11
		assert_equal(1, @text_handler.writers.size)
		writer = @text_handler.writers.first
		assert_equal("Yakona-Hypericum\n", writer.name)
	end
	def test_composition11
		writer = @text_handler.writers.first
		chapter = writer.composition
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Zusammensetzung', chapter.heading)
		assert_equal(2, chapter.sections.size)
		section = chapter.sections.first
		assert_instance_of(ODDB::Text::Section, section)
		assert_equal(1, section.paragraphs.size)
		paragraph = section.paragraphs.first
		assert_instance_of(ODDB::Text::Paragraph, paragraph)
	end
	def test_galenic_form11
		writer = @text_handler.writers.first
		chapter = writer.galenic_form
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal("Galenische Form und Wirkstoffmenge pro Einheit", 
                 chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_instance_of(ODDB::Text::Section, section)
		assert_equal("1 Kapsel\n", section.subheading)
		assert_equal(1, section.paragraphs.size)
	end
	def test_indications11
		writer = @text_handler.writers.first
		chapter = writer.indications
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_match(/Indikationen\/Anwendungsm.*glichkeiten/, chapter.heading)
		assert_equal(1, chapter.sections.size)
	end
	def test_iksnrs11
		writer = @text_handler.writers.first
		chapter = writer.iksnrs
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Zulassungsvermerk', chapter.heading)
		assert_equal(1, chapter.sections.size)
		assert_equal(1, chapter.sections.first.paragraphs.size)
		paragraph = chapter.sections.first.paragraphs.first
		assert_equal("56972  (Swissmedic)", paragraph.text)
	end
	def test_registration_owner11
		writer = @text_handler.writers.first
		chapter = writer.registration_owner
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Zulassungsinhaberin', chapter.heading)
	end
end
class TestFachinfoDocParser12 < Test::Unit::TestCase
  class ReplHandler
    def method_missing(*args)
      puts "inline_replacement_handler received: #{args.inspect}"
    end
  end
	def setup
		@filename = File.expand_path('data/doc/Yakona_f.doc', 
			File.dirname(__FILE__))
		@text_handler = ODDB::FiParse::FachinfoTextHandler.new
		@parser = Rwv2.create_parser(@filename)
		@parser.set_text_handler(@text_handler)
    @table_handler = @text_handler.table_handler
    @parser.set_table_handler(@table_handler)
    @parser.set_inline_replacement_handler(ReplHandler.new)
		@parser.parse
    #@text_handler.cutoff_fontsize = @text_handler.max_fontsize
		#@parser.parse
	end
	def test_name12
		assert_equal(1, @text_handler.writers.size)
		writer = @text_handler.writers.first
		assert_equal("Yakona-Hypericum\n", writer.name)
	end
	def test_composition12
		writer = @text_handler.writers.first
		chapter = writer.composition
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Composition', chapter.heading)
		assert_equal(2, chapter.sections.size)
		section = chapter.sections.first
		assert_instance_of(ODDB::Text::Section, section)
		assert_equal(1, section.paragraphs.size)
		paragraph = section.paragraphs.first
		assert_instance_of(ODDB::Text::Paragraph, paragraph)
	end
	def test_galenic_form12
		writer = @text_handler.writers.first
		chapter = writer.galenic_form
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_match(/Forme gal.*nique et quantit.* de principe actif par unit.*/, 
                 chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_instance_of(ODDB::Text::Section, section)
		assert_equal("1 capsule contient :\n", section.subheading)
		assert_equal(1, section.paragraphs.size)
	end
	def test_indications12
		writer = @text_handler.writers.first
		chapter = writer.indications
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_match(/Indications\/domaines d.*application/, chapter.heading)
		assert_equal(1, chapter.sections.size)
	end
	def test_iksnrs12
		writer = @text_handler.writers.first
		chapter = writer.iksnrs
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Autorisation', chapter.heading)
		assert_equal(1, chapter.sections.size)
		assert_equal(1, chapter.sections.first.paragraphs.size)
		paragraph = chapter.sections.first.paragraphs.first
		assert_equal("56972  (Swissmedic)", paragraph.text)
	end
	def test_registration_owner12
		writer = @text_handler.writers.first
		chapter = writer.registration_owner
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_match(/Titulaire de l.*autorisation/, chapter.heading)
	end
end
class TestFachinfoDocParser13 < Test::Unit::TestCase
  class ReplHandler
    def method_missing(*args)
      puts "inline_replacement_handler received: #{args.inspect}"
    end
  end
	def setup
		@filename = File.expand_path('data/doc/Lapidar_f.doc', 
			File.dirname(__FILE__))
		@text_handler = ODDB::FiParse::FachinfoTextHandler.new
		@parser = Rwv2.create_parser(@filename)
		@parser.set_text_handler(@text_handler)
    @table_handler = @text_handler.table_handler
    @parser.set_table_handler(@table_handler)
    @parser.set_inline_replacement_handler(ReplHandler.new)
		@parser.parse
    @text_handler.cutoff_fontsize = @text_handler.max_fontsize
		@parser.parse
	end
	def test_name13
		assert_equal(1, @text_handler.writers.size)
		writer = @text_handler.writers.first
		assert_match(/LAPIDAR .* 10\n/, writer.name)
	end
	def test_composition13
		writer = @text_handler.writers.first
		chapter = writer.composition
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Composition', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_instance_of(ODDB::Text::Section, section)
		assert_equal(2, section.paragraphs.size)
		paragraph = section.paragraphs.first
		assert_instance_of(ODDB::Text::Paragraph, paragraph)
	end
	def test_indications13
		writer = @text_handler.writers.first
		chapter = writer.indications
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_match(/Indications\/possibilit.*s d.*emploi/, chapter.heading)
		assert_equal(2, chapter.sections.size)
	end
	def test_preclinic13
		writer = @text_handler.writers.first
		chapter = writer.preclinic
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_match(/Donn.*s pr.*cliniques/, chapter.heading)
		assert_equal(2, chapter.sections.size)
	end
	def test_iksnrs13
		writer = @text_handler.writers.first
		chapter = writer.iksnrs
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Estampille', chapter.heading)
		assert_equal(1, chapter.sections.size)
		assert_equal(1, chapter.sections.first.paragraphs.size)
		paragraph = chapter.sections.first.paragraphs.first
		assert_equal("10392 (Swissmedic)", paragraph.text)
	end
	def test_registration_owner13
		writer = @text_handler.writers.first
		chapter = writer.registration_owner
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_match(/Titulaire de l.*autorisation/, chapter.heading)
	end
	def test_date13
		writer = @text_handler.writers.first
		chapter = writer.date
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_match(/Mise .* jour de l.*information/, chapter.heading)
		paragraph = chapter.sections.first.paragraphs.first
		assert_equal("Mai 2006", paragraph.text)
	end
end
