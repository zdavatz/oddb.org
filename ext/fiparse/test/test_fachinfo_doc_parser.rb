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
		assert_equal("Tramadol Helvepharm® Kapseln/Tropfen/Suppositorien\n", writer.name)
		writer = @text_handler.writers.last
		assert_equal("Tramadol Helvepharm® Capsules/Gouttes/Suppositoires\n", writer.name)
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
		assert_equal("Analgésique d\'action centrale\n", section.subheading)
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
		assert_equal('Indikationen/Anwendungsmöglichkeiten', chapter.heading)
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
		expected = <<-EOS
-----------------------------------------------------------------------------------
Applikations-    Einzeldosis              Tagesdosis
form
-----------------------------------------------------------------------------------
Kapseln          1 Kapsel (50 mg)         bis zu 8 Kapseln
Tropfen          20 Tropfen (50 mg)       bis zu
                                          8\327 20 Tropfen
Suppositorien    1 Suppositorium          bis zu
                 (100 mg)                 4 Suppositorien 
-----------------------------------------------------------------------------------
		EOS
		assert_equal(true, paragraph.preformatted?)
		assert_equal(expected.strip, paragraph.text)
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
		expected.strip!
		expected.length.times { |idx|
			if (expected[idx] != txt[idx])
				puts ">#{expected[0..idx.next]}<"
				puts ">#{txt[0..idx.next]}<"
				break
			end
		}
		assert_equal(expected.strip, txt)
	end
end
class TestFachinfoDocParser3 < Test::Unit::TestCase
	def setup
		@filename = File.expand_path('data/doc/fi_df_a2.doc', 
			File.dirname(__FILE__))
		@text_handler = ODDB::FiParse::FachinfoTextHandler.new
		@parser = Rwv2.create_parser(@filename)
		@parser.set_text_handler(@text_handler)
		@parser.parse
	end
	def test_usage3
		writer = @text_handler.writers.first
		chapter = writer.usage
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Dosierung/Anwendung', chapter.heading)
		assert_equal(11, chapter.sections.size)
		section = chapter.sections.at(9)
		assert_instance_of(ODDB::Text::Section, section)
		assert_equal("Allgemein\n", section.subheading)
		assert_equal(3, section.paragraphs.size)
		paragraph = section.paragraphs.at(2)
		assert_instance_of(ODDB::Text::Paragraph, paragraph)
		expected = <<-EOS
-----------------------------------------------------------------
Kreatinin-Clearance       Erhaltungsdosis
(ml/Min.)
-----------------------------------------------------------------
0                         100 mg jeden 3. Tag
10                        100 mg jeden 2. Tag
20                        100 mg täglich
40                        150 mg täglich
60                        200 mg täglich
80                        250 mg täglich
-----------------------------------------------------------------
	EOS
		assert_equal(expected.strip, paragraph.text)
	end
	def test_kinetic3
		writer = @text_handler.writers.first
		chapter = writer.kinetic
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Pharmakokinetik', chapter.heading)
		assert_equal(4, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("Absorption\n", section.subheading)
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
		assert_equal("Felodil® 5/10\n", writer.name)
		writer = @text_handler.writers.last
		assert_equal("Felodil® 5/10\n", writer.name)
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
		assert_equal('Indikationen / Anwendungsmöglichkeiten', chapter.heading)
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
		expected = <<-EOS
In der HOT-Studie (Hypertension Optimal Treatment) wurde Felodipin entweder als Monotherapie oder bei Bedarf in Kombination mit b-Blockern und/oder ACE-Hemmern und/oder Diuretika verabreicht. Die Wirkung auf die häufigsten kardiovaskulären Ereignisse (z.B. akuter Myokardinfarkt, Herzschlag und Herztod) wurde in Beziehung zu den angestrebten diastolischen Blutdruck-Werten untersucht. Insgesamt wurden 18 790 Patienten mit anfänglichen diastolischen Blutdruck-Werten von 100-115 mmHg im Alter zwischen 50-80 Jahren während durchschnittlich 3,8 (Bereich 3,3-4,9) Jahren in die Studie miteinbezogen. 
		EOS
		assert_equal(expected.strip, paragraph.text)
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
		expected = "56'170"
		result = paragraph.text
		assert_equal(expected, result)
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
		assert_equal('Salmon Pharma', chapter.heading)
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
		assert_equal('Indikationen/Anwendungsmöglichkeiten', chapter.heading)
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
		assert_equal("55'950 (Swissmedic)", paragraph.text)
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
		expected = <<-EOS
Tierexperimentelle Studien haben eine Fetotoxizität gezeigt (s. "Präklinische Daten").
		EOS
		expected.strip!
		assert_equal(expected, paragraph.text)
		paragraph = section.paragraphs.at(2)
		expected = <<-EOS
Es gibt keine Hinweise dafür, dass Vitamin D - selbst in sehr hohen Dosen - beim Menschen teratogen wirkt. Calcitriol Salmon Pharma sollte während der Schwangerschaft nur dann angewandt werden, wenn dies klar notwendig ist.
		EOS
		expected.strip!
		assert_equal(expected, paragraph.text)
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
		@text_handler = ODDB::FiParse::FachinfoTextHandler.new
		@parser = Rwv2.create_parser(@filename)
		@parser.set_text_handler(@text_handler)
    @table_handler = @text_handler.table_handler
    @parser.set_table_handler(@table_handler)
    @parser.set_inline_replacement_handler(ReplHandler.new)
		@parser.parse
	end
	def test_name6
		assert_equal(1, @text_handler.writers.size)
		writer = @text_handler.writers.first
		assert_equal("CIMZIA\256, Pulver\n", writer.name)
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
		assert_equal('Indikationen/Anwendungsmöglichkeiten', chapter.heading)
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
    expected = "In tierexperimentellen Untersuchungen mit Ratten von bis zu 100 mg/kg eines pegylierten Fab Fragmentes eines Nager-anti-murinen Antik\366rpers (cTN3 PF) \344hnlich Certolizumab pegol wurden keine Anzeichen von maternaler Toxizit\344t oder Teratogenit\344t beobachtet. Im Zuge einer embryof\366talen Entwicklungsstudie traten bei 20 mg/kg spontane Missbildungen der Niere auf, die in den historischen Kontrollen nicht aufscheinen aber nicht dosisabh\344ngig waren. Es liegen keine kontrollierten Studien mit Schwangeren vor. Auf Grund seiner inhibitorischen Wirkung auf TNF-? k\366nnte sich Certolizumab pegol bei einer Anwendung w\344hrend der Schwangerschaft auf die normalen Immunreaktionen beim Neugeborenen auswirken. Cimzia sollte daher w\344hrend der Schwangerschaft nicht angewendet werden, es sei denn, dies ist klar notwendig. Frauen im geb\344rf\344higen Alter wird dringend empfohlen, durch geeignete empf\344ngnisverh\374tende Massnahmen einer Schwangerschaft vorzubeugen und diese nach Ende der Behandlung mit Cimzia noch mindestens 4 Monate lang anzuwenden."
		assert_equal(expected, paragraph.text)
		section = chapter.sections.last
		assert_equal("Stillzeit\n", section.subheading)
		paragraph = section.paragraphs.at(0)
    expected = "In Tierstudien wurde ein Transfer von cTN3 PF in die Muttermilch von Ratten mit einer Milch-Plasma Ratio von ca. 10 % gemessen. Es ist nicht bekannt, ob Certolizumab pegol \374ber die menschliche Muttermilch ausgeschieden wird. Es wird daher empfohlen, Cimzia w\344hrend der Schwangerschaft nicht anzuwenden."
		assert_equal(expected, paragraph.text)
	end
	def test_driving_ability6
		writer = @text_handler.writers.first
		chapter = writer.driving_ability
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Wirkung auf die Fahrtüchtigkeit und auf das Bedienen von Maschinen',
                 chapter.heading)
		assert_equal(1, chapter.sections.size)
    puts chapter
	end
=begin
	def test_unwanted_effects6
    flunk "fix this table"
		writer = @text_handler.writers.first
		chapter = writer.unwanted_effects
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Unerwünschte Wirkungen', chapter.heading)
		assert_equal(1, chapter.sections.size)
    section = chapter.sections.first
    puts section
    puts @table_handler.inspect
    assert_not_nil section.paragraphs.at(7)
	end

	def test_company6
		writer = @text_handler.writers.first
		chapter = writer.company
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Salmon Pharma', chapter.heading)
	end
	def test_iksnrs6
		writer = @text_handler.writers.first
    puts writer.chapters
		chapter = writer.iksnrs
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Zulassungsvermerk', chapter.heading)
		assert_equal(1, chapter.sections.size)
		assert_equal(1, chapter.sections.first.paragraphs.size)
		paragraph = chapter.sections.first.paragraphs.first
		assert_equal("55'950 (Swissmedic)", paragraph.text)
	end
	def test_registration_owner6
		writer = @text_handler.writers.first
		chapter = writer.registration_owner
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Zulassungshinhaberin:', chapter.heading)
	end
=end
end
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
		assert_equal(2, section.paragraphs.size)
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
=begin
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
=end
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
		assert_equal("Togal\256 ASS 300/500\n", writer.name)
	end
	def test_composition8
		writer = @text_handler.writers.first
		chapter = writer.composition
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Composition', chapter.heading)
		assert_equal(2, chapter.sections.size)
		section = chapter.sections.first
		assert_instance_of(ODDB::Text::Section, section)
		assert_equal("Principe actif\240:", section.subheading)
		assert_equal(1, section.paragraphs.size)
		paragraph = section.paragraphs.first
		assert_instance_of(ODDB::Text::Paragraph, paragraph)
	end
	def test_galenic_form8
		writer = @text_handler.writers.first
		chapter = writer.galenic_form
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal("Forme gal\351nique et quantit\351 de principe actif par unit\351", chapter.heading)
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
		assert_equal("Indications/Possibilit\351s d'emploi", chapter.heading)
		assert_equal(1, chapter.sections.size)
	end
	def test_usage8
		writer = @text_handler.writers.first
		chapter = writer.usage
		assert_instance_of(ODDB::Text::Chapter, chapter)
  	assert_equal("Posologie/Mode d'emploi", chapter.heading)
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
  	assert_equal('Mises en garde et précautions', chapter.heading)
		assert_equal(1, chapter.sections.size)
    section = chapter.sections.first
    paragraph = section.paragraphs.at(6)
    assert_equal("carence en glucose-6-phosphate-déshydrogénase d'origine génétique;",
                 paragraph.text)
    paragraph = section.paragraphs.at(7)
    assert_equal("traitement concomitant par des anticoagulants\240;",
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
    expected = "La prudence s'impose lors de l'utilisation de salicylates durant le premier et le deuxi\350me trimestres de la grossesse. En exp\351rimentation animale, les salicylates ont montr\351 des effets ind\351sirables sur le foetus (tels qu'une augmentation de la mortalit\351, des troubles de la croissance, des intoxications aux salicylates), mais il n'existe pas d'\351tudes contr\364l\351es chez la femme enceinte. En fonction des exp\351riences actuelles, il semble cependant que ce risque soit minime aux doses th\351rapeutiques normales. Au cours du dernier trimestre de la grossesse, la prise de salicylates peut entra\356ner une inhibition des contractions et des h\351morragies, une prolongation de la dur\351e de la gestation et une fermeture pr\351matur\351e du canal art\351riel (ductus arteriosus). Voici pourquoi ils sont contre-indiqu\351s."
		assert_equal(expected, paragraph.text)
		section = chapter.sections.last
		assert_equal("Allaitement\n", section.subheading)
		paragraph = section.paragraphs.at(0)
    expected = "Les salicylates passent dans le lait maternel. La concentration dans le lait maternel est la m\352me ou m\352me plus haute que dans le plasma maternel. Aux doses habituelles utilis\351es \340 court terme (pour l'analg\351sie et l'action antipyr\351tique), aucune cons\351quence nuisible pour le nourrisson n'est \340 pr\351voir. Une interruption de l'allaitement n'est pas n\351cessaire si le m\351dicament est utilis\351 occasionnellement aux doses recommand\351es. L'allaitement devrait \352tre interrompu si le m\351dicament est utilis\351 de mani\350re prolong\351e, resp. \340 des doses plus \351lev\351es."
		assert_equal(expected, paragraph.text)
	end
	def test_driving_ability8
		writer = @text_handler.writers.first
		chapter = writer.driving_ability
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal("Effet sur l'aptitude \340 la conduite et \340 l'utilisation de machines",
                 chapter.heading)
		assert_equal(1, chapter.sections.size)
	end
	def test_unwanted_effects8
		writer = @text_handler.writers.first
		chapter = writer.unwanted_effects
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Effets indésirables', chapter.heading)
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
		assert_equal('Titulaire de l\'autorisation', chapter.heading)
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
		assert_equal('Titulaire de l\'autorisation', chapter.heading)
	end
end
class TestFachinfoDocParser10 < Test::Unit::TestCase
  class ReplHandler
    def method_missing(*args)
      puts "inline_replacement_handler received: #{args.inspect}"
    end
  end
	def setup
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
		assert_equal("Tropfen. 1 ml enthält:\n", section.subheading)
		assert_equal(1, section.paragraphs.size)
	end
	def test_indications10
		writer = @text_handler.writers.first
		chapter = writer.indications
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal("Indikationen/Anwendungsmöglichkeiten", chapter.heading)
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
		assert_equal("47'831  (Swissmedic)", paragraph.text)
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
		assert_equal("Indikationen/Anwendungsmöglichkeiten", chapter.heading)
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
		assert_equal("Forme galénique et quantité de principe actif par unité", 
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
		assert_equal("Indications/domaines d'application", chapter.heading)
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
		assert_equal('Titulaire de l\'autorisation', chapter.heading)
	end
end
