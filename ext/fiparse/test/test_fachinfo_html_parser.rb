#!/usr/bin/env ruby
# TestFachinfo -- oddb -- 08.09.2003 -- rwaltert@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path("../src", File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'fachinfo_html'

module ODDB
	module FiParse
		class FachinfoHtmlWriter
			DOCUMENT_ROOT = 'ext/fiparse/test/data'
			IMAGE_PATH = '/images/fachinfo'
			attr_reader :name, :company, :galenic_form, :composition
			attr_reader :effects, :kinetic, :indications, :usage
			attr_reader :restrictions, :unwanted_effects
			attr_reader :interactions, :registration_owner
			attr_reader :overdose, :other_advice, :iksnrs, :date
			public :named_chapter, :named_chapters
		end
	end
end

class TestFachinfoHtmlWriter < Test::Unit::TestCase
	def setup
		@writer = ODDB::FiParse::FachinfoHtmlWriter.new
	end
	def test_writer_interface
		assert_respond_to(@writer, :flush)
		assert_respond_to(@writer, :new_alignment)
		assert_respond_to(@writer, :new_font)
		assert_respond_to(@writer, :new_margin)
		assert_respond_to(@writer, :new_spacing)
		assert_respond_to(@writer, :new_styles)
		assert_respond_to(@writer, :send_line_break)
		assert_respond_to(@writer, :send_paragraph)
		assert_respond_to(@writer, :send_hor_rule)
		assert_respond_to(@writer, :send_flowing_data)
		assert_respond_to(@writer, :send_literal_data)
		assert_respond_to(@writer, :send_label_data)
	end
	def test_named_chapter
		assert_nil(@writer.iksnrs)
		@writer.named_chapter(:iksnrs)
		assert_instance_of(ODDB::Text::Chapter, @writer.iksnrs)
	end
	def test_named_chapters
		assert_nil(@writer.iksnrs)
		assert_nil(@writer.date)
		chapters = @writer.named_chapters([:iksnrs, :date])
		assert_instance_of(ODDB::Text::Chapter, @writer.iksnrs)
		assert_instance_of(ODDB::Text::Chapter, @writer.date)
		expected = [
			@writer.iksnrs, @writer.date
		]
		assert_equal(expected, chapters)
	end
end
class TestFachinfoHtmlWriter7036 < Test::Unit::TestCase
	def setup
		path = File.expand_path('data/html/de/07036.html', 
			File.dirname(__FILE__))
		@html = File.read(path)
		@writer = ODDB::FiParse::FachinfoHtmlWriter.new
		@formatter = ODDB::HtmlFormatter.new(@writer)
		@parser = ODDB::HtmlParser.new(@formatter)
		@parser.feed(@html)
	end
	def test_name1
		assert_equal("ACC® eco\n", @writer.name)
	end
	def test_company1
		assert_instance_of(ODDB::Text::Chapter, @writer.company)
		assert_equal('ECOSOL', @writer.company.heading)
	end
	def test_galenic_form1
		chapter = @writer.galenic_form
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Granulat/Brausetabletten', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_instance_of(ODDB::Text::Section, section)
		assert_equal("Mukolytikum\n", section.subheading)
		assert_equal(0, section.paragraphs.size)
	end
	def test_composition1
		chapter = @writer.composition
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Zusammensetzung', chapter.heading)
		assert_equal(3, chapter.sections.size)
		section1 = chapter.sections.first
		assert_equal('Granulat in Beuteln zu 600 mg:', section1.subheading)
	  assert_equal(1, section1.paragraphs.size)
		paragraph1 = section1.paragraphs.first
		assert_equal('Acetylcysteinum 600 mg, saccharum, saccharinum, aromatica, excipiens ad granulatum pro charta.', paragraph1.text)
		section2 = chapter.sections.last
		assert_equal('Brausetabletten zu 600 mg:', section2.subheading)
	  assert_equal(1, section2.paragraphs.size)
		paragraph2 = section2.paragraphs.first
		assert_equal('Acetylcysteinum 600 mg, cyclamas, saccharinum, aromatica, excipiens pro compresso eff.', paragraph2.text)

	end
	def test_effects1
		chapter = @writer.effects
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Eigenschaften/Wirkungen', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section1 = chapter.sections.first
		assert_equal('', section1.subheading)
	  assert_equal(4, section1.paragraphs.size)
		paragraph1 = section1.paragraphs.first
		assert_equal('ACC eco enthält als Wirkstoff N-Acetylcystein, ein Cysteinderivat mit einer freien SH-Gruppe, das sowohl mukolytische als auch antioxidative Eigenschaften besitzt.', paragraph1.text)
	end
	def test_kinetic1
		chapter = @writer.kinetic
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Pharmakokinetik', chapter.heading)
		assert_equal(4, chapter.sections.size)
		section1 = chapter.sections.first
		assert_equal("Absorption\n", section1.subheading)
	  assert_equal(1, section1.paragraphs.size)
		paragraph1 = section1.paragraphs.first
		assert_equal('N-Acetylcystein wird nach oraler Aufnahme rasch und nahezu vollständig resorbiert. Aufgrund des hohen First-Pass-Effektes ist die Bioverfügbarkeit von oral verabreichtem N-Acetylcystein sehr gering (ca. 10%). Die maximalen Plasmakonzentrationen werden beim Menschen nach 1-3 Stunden erreicht.', paragraph1.text)
	end
	def test_indications1
		chapter = @writer.indications
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Indikationen/Anwendungsmöglichkeiten', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section1 = chapter.sections.first
		assert_equal("Granulat, Brausetabletten\n", section1.subheading)
	  assert_equal(1, section1.paragraphs.size)
		paragraph1 = section1.paragraphs.first
		assert_equal('Alle Atemwegserkrankungen, die zur Bildung von zähem Sekret führen, welches nicht oder nur ungenügend expektoriert werden kann, wie akute und chronische Bronchitis, Laryngitis, Sinusitis, Tracheitis, und Bronchialasthma sowie als Zusatzbehandlung bei Mukoviszidose.', paragraph1.text)
	end
	def test_usage1
		chapter = @writer.usage
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Dosierung/Anwendung', chapter.heading)
		assert_equal(8, chapter.sections.size)
		section1 = chapter.sections.first
		assert_equal("Granulat, Brausetabletten\n", section1.subheading)
	  assert_equal(0, section1.paragraphs.size)
	end
	def test_restrictions1
		chapter = @writer.restrictions
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Anwendungseinschränkungen', chapter.heading)
		assert_equal(3, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("Kontraindikationen\n", section.subheading)
		pars  = section.paragraphs
	  assert_equal(4, pars.size)
		assert_equal('Bekannte Überempfindlichkeit gegenüber N-Acetylcystein, aktives peptisches Ulkus, Stillzeit.', pars.at(0).text)
		assert_equal('Die Brausetabletten zu 200 mg sind aufgrund des hohen Wirkstoffgehalts für Kinder unter 2 Jahren nicht geeignet. Die Brausetabletten und das Granulat zu 600 mg sind aufgrund des hohen Wirkstoffgehaltes für Kinder unter 14 Jahren (bei Kindern mit zystischer Fibrose: unter 6 Jahren) nicht geeignet.', pars.at(1).text)
		assert_equal('Patienten mit Fruktose-Intoleranz, z.B. mit Fruktose-1,6-diphosphatase-Mangel, sollen das mit Saccharose (Rohrzucker) gesüsste Granulat nicht einnehmen. Diese Patienten können auf die Brausetabletten oder auf ein anderes geeignetes Präparat ausweichen.', pars.at(2).text)
		assert_equal('Die gleichzeitige Verwendung eines Antitussivums ist medizinisch nicht sinnvoll (siehe «Vorsichtsmassnahmen»).', pars.at(3).text)
		section = chapter.sections.at(1)
		assert_equal("Vorsichtsmassnahmen\n", section.subheading)
		pars = section.paragraphs
		assert_equal(5, pars.size)
		assert_equal('Da ACC eco Erbrechen auslösen kann, ist bei Patienten mit einem Risiko für gastrointestinale Blutungen (Ösophagusvarizen, latentes peptisches Ulcus) Vorsicht geboten.', pars.at(0).text)
		section = chapter.sections.at(2)
		assert_equal("Schwangerschaft/Stillzeit\n", section.subheading)
		pars = section.paragraphs
		assert_equal(2, pars.size)
		assert_equal('Schwangerschaftskategorie B.', pars.at(0).text)
	end
	def test_unwanted_effects1
		chapter = @writer.unwanted_effects
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Unerwünschte Wirkungen', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal('', section.subheading)
		assert_equal(2, section.paragraphs.size)
		assert_equal('Gelegentlich kommt es zu leichten gastrointestinalen Störungen (Sodbrennen, Übelkeit, Erbrechen, Durchfall) und in seltenen Fällen zu Urtikaria, Kopfschmerzen, Ohrensausen und Fieber. Bei prädisponierten Patienten kann eine Hypersensibilität in Form von Reaktionen der Haut und bei solchen mit hyperreaktivem Bronchialsystem bei Asthma bronchiale können Bronchospasmen auftreten (siehe «Kontraindikationen» und «Vorsichtsmassnahmen»).', section.paragraphs.first.text)
	end
	def test_interactions1
		chapter = @writer.interactions
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Interaktionen', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal('', section.subheading)
		assert_equal(3, section.paragraphs.size)
		assert_equal('Gleichzeitige Verabreichung eines Antitussivums: siehe «Anwendungseinschränkungen».', section.paragraphs.first.text)
	end
	def test_overdose1
		chapter = @writer.overdose
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Überdosierung', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal('', section.subheading)
		assert_equal(1, section.paragraphs.size)
		assert_equal('Dank der grossen therapeutischen Breite von N-Acetylcystein sind bisher keine Fälle von Intoxikationen bekannt geworden.', section.paragraphs.first.text)
	end
	def test_other_advice1
		chapter = @writer.other_advice
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Sonstige Hinweise', chapter.heading)
		assert_equal(4, chapter.sections.size)
		section = chapter.sections.at(0)
		assert_equal("Inkompatibilitäten\n", section.subheading)
		assert_equal(1, section.paragraphs.size)
		assert_equal('Die Wirksubstanz von ACC eco, N-Acetyl-L-Cystein, ist inkompatibel mit den meisten Metallen, mit Sauerstoff und oxydierenden Substanzen.', section.paragraphs.first.text)
		section = chapter.sections.at(1)
		assert_equal("Hinweise für Diabetiker\n", section.subheading)
		assert_equal(2, section.paragraphs.size)
		section = chapter.sections.at(2)
		assert_equal("Für Hypertoniker:", section.subheading)
	end
	def test_iksnrs1
		chapter = @writer.iksnrs
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('IKS-Nummern', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal('', section.subheading)
		assert_equal(1, section.paragraphs.size)
		assert_equal('53985, 55622.', section.paragraphs.first.text)
	end
	def test_date1
		chapter = @writer.date
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Stand der Information', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal('', section.subheading)
		assert_equal(2, section.paragraphs.size)
		assert_equal('Juni 2000.', section.paragraphs.first.text)
	end
	def test_pseudo1
		assert_equal(false, @writer.pseudo?)
	end
end
class TestFachinfoHtmlWriter8968 < Test::Unit::TestCase
	def setup
		path = File.expand_path('data/html/de/08968.html', 
			File.dirname(__FILE__))
		@html = File.read(path)
		@writer = ODDB::FiParse::FachinfoHtmlWriter.new
		@formatter = ODDB::HtmlFormatter.new(@writer)
		@parser = ODDB::HtmlParser.new(@formatter)
		@parser.feed(@html)
	end
	def test_name2
		assert_equal("Atedurex®/- mite\n", @writer.name)
	end
	def test_company2
		assert_instance_of(ODDB::Text::Chapter, @writer.company)
		assert_equal('ECOSOL', @writer.company.heading)
	end
	def test_galenic_form2
		chapter = @writer.galenic_form
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_instance_of(ODDB::Text::Section, section)
		assert_equal("Kombiniertes blutdrucksenkendes Mittel\n", section.subheading)
		assert_equal(0, section.paragraphs.size)
	end
	def test_composition2
		chapter = @writer.composition
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Zusammensetzung', chapter.heading)
		assert_equal(4, chapter.sections.size)
		section1 = chapter.sections.first
		assert_equal("Atedurex\n", section1.subheading)
	  assert_equal(0, section1.paragraphs.size)
	end
	def test_iksnrs2
		chapter = @writer.iksnrs
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('IKS-Nummern', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal('', section.subheading)
		assert_equal(1, section.paragraphs.size)
		assert_equal('54076.', section.paragraphs.first.text)
	end
end
class TestFachinfoHtmlWriter9277 < Test::Unit::TestCase
	def setup
		path = File.expand_path('data/html/de/09277.html', 
			File.dirname(__FILE__))
		@html = File.read(path)
		@writer = ODDB::FiParse::FachinfoHtmlWriter.new
		@formatter = ODDB::HtmlFormatter.new(@writer)
		@parser = ODDB::HtmlParser.new(@formatter)
		@parser.feed(@html)
	end
	def test_effects3
		chapter = @writer.usage
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Dosierung/Anwendung', chapter.heading)
		assert_equal(7, chapter.sections.size)
		section1 = chapter.sections.at(6)
		assert_equal("Eingeschränkte Nierenfunktion\n", section1.subheading)
	  assert_equal(5, section1.paragraphs.size)
		table = section1.paragraphs.at(1)
		assert_instance_of(ODDB::Text::Paragraph, table)
		assert_equal(true, table.preformatted?)
		expected = <<-PRE
----------------------------------------------------
Kreatinin-Clearance     Dosis    Dosierungsintervall
(ml/min)                (mg)     (h)                
----------------------------------------------------
<10                     200      12                 
----------------------------------------------------
		PRE
		expected.strip!
		expected.length.times { |idx|
			if (expected[idx] != table.text[idx])
				puts ">#{expected[0..idx.next]}<"
				puts ">#{table.text[0..idx.next]}<"
				break
			end
		}
		assert_equal(expected, table.text)
	end
	def test_pseudo3
		assert_equal(false, @writer.pseudo?)
	end
end
class TestFachinfoHtmlWriter7034 < Test::Unit::TestCase
	def setup
		path = File.expand_path('data/html/de/07034.html', 
			File.dirname(__FILE__))
		@html = File.read(path)
		@writer = ODDB::FiParse::FachinfoHtmlWriter.new
		@formatter = ODDB::HtmlFormatter.new(@writer)
		@parser = ODDB::HtmlParser.new(@formatter)
		@parser.feed(@html)
	end
	def test_pseudo4
		assert_equal(true, @writer.pseudo?)
	end
end
class TestFachinfoHtmlWriter9903 < Test::Unit::TestCase
	def setup
		path = File.expand_path('data/html/de/09903.html', 
			File.dirname(__FILE__))
		@html = File.read(path)
		@writer = ODDB::FiParse::FachinfoHtmlWriter.new
		@formatter = ODDB::HtmlFormatter.new(@writer)
		@parser = ODDB::HtmlParser.new(@formatter)
		@parser.feed(@html)
	end
	def test_galenic_form5
		chapter = @writer.galenic_form
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Galenische Form und Wirkstoffmenge pro Einheit', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_instance_of(ODDB::Text::Section, section)
		assert_equal("", section.subheading)
		assert_equal(1, section.paragraphs.size)
		paragraph = section.paragraphs.first
		assert_instance_of(ODDB::Text::Paragraph, paragraph)
		assert_equal('Kapseln zu 250 mg Saccharomyces boulardii lyophilisiert.', paragraph.text)
	end
	def test_iksnrs5
		chapter = @writer.iksnrs
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Zulassungsvermerk', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal('', section.subheading)
		assert_equal(1, section.paragraphs.size)
		assert_equal('55836 (Swissmedic).', section.paragraphs.first.text)
	end
	def test_registration_owner5
		chapter = @writer.registration_owner
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Zulassungsinhaberin', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal('', section.subheading)
		assert_equal(1, section.paragraphs.size)
		assert_equal('Ecosol AG, Cham/Steinhausen.', section.paragraphs.first.text)
	end
end
class TestFachinfoHtmlWriter9971 < Test::Unit::TestCase
	def setup
		path = File.expand_path('data/html/de/09971.html', 
			File.dirname(__FILE__))
		@html = File.read(path)
		@writer = ODDB::FiParse::FachinfoHtmlWriter.new
		@formatter = ODDB::HtmlFormatter.new(@writer)
		@parser = ODDB::HtmlParser.new(@formatter)
		@parser.feed(@html)
	end
	def test_date6
		chapter = @writer.date
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Stand der Information', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal('', section.subheading)
		assert_equal(1, section.paragraphs.size)
		assert_equal('April 2001.', section.paragraphs.first.text)
	end
end
class TestFachinfoHtmlWriter9854 < Test::Unit::TestCase
	def setup
		path = File.expand_path('data/html/de/09854.html', 
			File.dirname(__FILE__))
		@html = File.read(path)
		@writer = ODDB::FiParse::FachinfoHtmlWriter.new
		@formatter = ODDB::HtmlFormatter.new(@writer)
		@parser = ODDB::HtmlParser.new(@formatter)
		@parser.feed(@html)
	end
	def test_date7
		chapter = @writer.date
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Stand der Information', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal('', section.subheading)
		assert_equal(1, section.paragraphs.size)
		assert_equal('Dezember 2001.', section.paragraphs.first.text)
	end
end
class TestFachinfoHtmlWriter9685 < Test::Unit::TestCase
	def setup
		path = File.expand_path('data/html/de/09685.html', 
			File.dirname(__FILE__))
		@html = File.read(path)
		@writer = ODDB::FiParse::FachinfoHtmlWriter.new
		@formatter = ODDB::HtmlFormatter.new(@writer)
		@parser = ODDB::HtmlParser.new(@formatter)
		@parser.feed(@html)
	end
	def test_usage8
		chapter = @writer.usage
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Dosierung/Anwendung', chapter.heading)
		#assert_equal(8, chapter.sections.size)
		section = chapter.sections.at(4)
		assert_equal("Erwachsene und Kinder über 40 kg\n"	, section.subheading)
	  assert_equal(1, section.paragraphs.size)
		expected = <<-EOS
----------------------------------------------------
Kreatinin-     Leichte bis mittel-   Schwere        
Clearance      schwere Infektionen   Infektionen    
----------------------------------------------------
10-30 ml/Min.  375 mg                625 mg         
               alle 12 Stunden       alle 12 Stunden
weniger als    375 mg                625 mg         
10 ml/Min.     alle 24 Stunden       alle 24 Stunden
----------------------------------------------------
		EOS
		assert_equal(expected.strip, section.paragraphs.first.text)
	end
end
class TestFachinfoHtmlWriter4169 < Test::Unit::TestCase
	def setup
		path = File.expand_path('data/html/de/04169.html', 
			File.dirname(__FILE__))
		@html = File.read(path)
		@writer = ODDB::FiParse::FachinfoHtmlWriter.new
		@formatter = ODDB::HtmlFormatter.new(@writer)
		@parser = ODDB::HtmlParser.new(@formatter)
		@parser.feed(@html)
	end
	def test_galenic_form9
		chapter = @writer.galenic_form
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_instance_of(ODDB::Text::Section, section)
		assert_equal("Thrombozytenaggregationshemmer\n", section.subheading)
		assert_equal(0, section.paragraphs.size)
	end
	def test_composition9
		chapter = @writer.composition
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Zusammensetzung', chapter.heading)
		assert_equal(2, chapter.sections.size)
		section1 = chapter.sections.first
		assert_equal('1 Tablette Aspirin Cardio 100', section1.subheading)
	  assert_equal(1, section1.paragraphs.size)
	end
	def test_effects9
		chapter = @writer.effects
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Eigenschaften/Wirkungen', chapter.heading)
		section1 = chapter.sections.first
		assert_equal('', section1.subheading)
	  assert_equal(1, section1.paragraphs.size)
		paragraph1 = section1.paragraphs.first
		expected = 'Acetylsalicylsä ure (ASS) ist der Essig-Ester der Salicyls äure.'
		result = paragraph1.text
		assert_equal(expected, paragraph1.text)
	end
	def test_iksnrs9
		chapter = @writer.iksnrs
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('IKS-Nummern', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal('', section.subheading)
		assert_equal(1, section.paragraphs.size)
		assert_equal('51795.', section.paragraphs.first.text)
	end
end
# the following test does not pass because the image-url has changed...
=begin
class TestFachinfoHtmlWriter9927 < Test::Unit::TestCase
	def setup
		path = File.expand_path('data/html/de/09927.html', 
			File.dirname(__FILE__))
		@html = File.read(path)
		@writer = ODDB::FiParse::FachinfoHtmlWriter.new
		@formatter = ODDB::HtmlFormatter.new(@writer)
		@parser = ODDB::HtmlParser.new(@formatter)
		@parser.feed(@html)
	end
	def test_effects10
		expected = File.expand_path('data/images/fachinfo/de/00001.gif', 
			File.dirname(__FILE__))
		begin
			chapter = @writer.effects
			assert_instance_of(ODDB::Text::Chapter, chapter)
			assert_equal('Eigenschaften/Wirkungen', chapter.heading)
			section1 = chapter.sections.at(6)
			assert_equal("Abbildung 1: ACR20-Ansprechraten über 52 Wochen in Studie 3", section1.subheading)
			assert_equal(4, section1.paragraphs.size, section1)
			paragraph1 = section1.paragraphs.first
			assert_instance_of(ODDB::Text::ImageLink, paragraph1)
			assert_equal('/images/fachinfo/de/00001.gif', paragraph1.src)
			assert_equal(true, File.exist?(expected), "File: #{expected} not found")
		ensure
			if(File.exist?(expected))
				File.delete(expected)
			end
		end
		section2 = chapter.sections.at(3)
		assert_equal("Klinische Wirksamkeit\n", section2.subheading)
		paragraph2 = section2.paragraphs.at(1)
		expected = <<-EOS
In Studie 1 evaluierte man 271 Patienten mit einer mässigen bis schweren aktiven rheumatoiden Arthritis, die ³18 Jahre alt waren, bei denen die Therapie mit mindestens einem, aber mit nicht mehr als vier krankheitsmodifizierenden Antirheumatika versagt und bei denen Methotrexat in einer Dosierung von 12,5 bis 25 mg (10 mg bei Methotrexat-Intoleranz) jede Woche eine ungenügende Wirksamkeit gezeigt hatte, und deren Methotrexat-Dosis während der Studie bei 10 bis 25 mg jede Woche konstant blieb. Die Patienten hatten ³6 geschwollene Gelenke und ³9 druckschmerzhafte Gelenke. Die rheumatoide Arthritis hatte man nach den Kriterien des American College of Rheumatology (ACR) diagnostiziert. Über einen Zeitraum von 24 Wochen verabreichte man jede zweite Woche Dosen in Höhe von 20, 40 bzw. 80 mg Humira oder ein Placebo.
		EOS
		raw = paragraph2.text #instance_eval('@raw_txt')
		assert_equal(expected.strip, raw)
		expected = <<-EOS
In Studie 1 evaluierte man 271 Patienten mit einer mässigen bis schweren aktiven rheumatoiden Arthritis, die >=18 Jahre alt waren, bei denen die Therapie mit mindestens einem, aber mit nicht mehr als vier krankheitsmodifizierenden Antirheumatika versagt und bei denen Methotrexat in einer Dosierung von 12,5 bis 25 mg (10 mg bei Methotrexat-Intoleranz) jede Woche eine ungenügende Wirksamkeit gezeigt hatte, und deren Methotrexat-Dosis während der Studie bei 10 bis 25 mg jede Woche konstant blieb. Die Patienten hatten >=6 geschwollene Gelenke und >=9 druckschmerzhafte Gelenke. Die rheumatoide Arthritis hatte man nach den Kriterien des American College of Rheumatology (ACR) diagnostiziert. Über einen Zeitraum von 24 Wochen verabreichte man jede zweite Woche Dosen in Höhe von 20, 40 bzw. 80 mg Humira oder ein Placebo.
		EOS
		txt = paragraph2.to_s
		assert_equal(expected.strip, txt)
	end
end
=end
class TestFachinfoHtmlWriter9422 < Test::Unit::TestCase
	def setup
		path = File.expand_path('data/html/de/09422.html', 
			File.dirname(__FILE__))
		@html = File.read(path)
		@writer = ODDB::FiParse::FachinfoHtmlWriter.new
		@formatter = ODDB::HtmlFormatter.new(@writer)
		@parser = ODDB::HtmlParser.new(@formatter)
		@parser.feed(@html)
	end
	def test_name11
		assert_equal("ALK7 Graesermischung und Roggen/\nALK7 Frühblühermischung\n", @writer.name)
	end
	def test_galenic_form11
		chapter = @writer.galenic_form
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Depotsuspension zur s.c. Injektion', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_instance_of(ODDB::Text::Section, section)
		expected = <<-EOS
ALK7 Graesermischung und Roggen:
Avena elatior, Dactylis glomerata, Festuca pratensis, Lolium perenne, Phleum pratense, Poa pratensis, Secale cereale
ALK7 Frühblühermischung: Alnus glutinosa, Betula verrucosa, Corylus avellana
		EOS
		assert_equal(expected, section.subheading)
		assert_equal(0, section.paragraphs.size)
	end
end
