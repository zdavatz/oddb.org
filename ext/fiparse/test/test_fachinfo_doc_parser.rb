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
			attr_reader :name, :company, :galenic_form, :composition
			attr_reader :effects, :kinetic, :indications, :usage
			attr_reader :restrictions, :unwanted_effects
			attr_reader :interactions, :registration_owner
			attr_reader :overdose, :other_advice, :iksnrs, :date, :pregnancy
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
		@subdocument_handler = ODDB::FiParse::FachinfoSubDocumentHandler.new(@text_handler)
		@parser = Rwv2.create_parser(@filename)
		@parser.set_text_handler(@text_handler)
		@parser.set_subdocument_handler(@subdocument_handler)
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
		@subdocument_handler = ODDB::FiParse::FachinfoSubDocumentHandler.new(@text_handler)
		@parser = Rwv2.create_parser(@filename)
		@parser.set_text_handler(@text_handler)
		@parser.set_subdocument_handler(@subdocument_handler)
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
		@subdocument_handler = ODDB::FiParse::FachinfoSubDocumentHandler.new(@text_handler)
		@parser = Rwv2.create_parser(@filename)
		@parser.set_text_handler(@text_handler)
		@parser.set_subdocument_handler(@subdocument_handler)
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
		@subdocument_handler = ODDB::FiParse::FachinfoSubDocumentHandler.new(@text_handler)
		@parser = Rwv2.create_parser(@filename)
		@parser.set_text_handler(@text_handler)
		@parser.set_subdocument_handler(@subdocument_handler)
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
		@subdocument_handler = ODDB::FiParse::FachinfoSubDocumentHandler.new(@text_handler)
		@parser = Rwv2.create_parser(@filename)
		@parser.set_text_handler(@text_handler)
		@parser.set_subdocument_handler(@subdocument_handler)
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
		assert_equal("Kapseln", section.subheading)
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
end
