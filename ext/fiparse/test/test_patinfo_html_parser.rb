#!/usr/bin/env ruby
# TestPatinfoHtmlParser -- oddb -- 24.10.2003 -- rwaltert@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path("../src", File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'patinfo_html'

module ODDB
	module FiParse
		class PatinfoHtmlWriter
			attr_reader :company, :galenic_form, :effects
			attr_reader :amendments, :contra_indications, :precautions
			attr_reader :pregnancy, :usage, :unwanted_effects
			attr_reader :general_advice, :composition, :packages
			attr_reader :distribution, :date, :amzv, :date_dummy
		end
	end
end

class TestPatinfoHtmlParser00907 < Test::Unit::TestCase
	def setup
		path = File.expand_path('data/html/de/00907.html', 
			File.dirname(__FILE__))
		@html = File.read(path)
		@writer = ODDB::FiParse::PatinfoHtmlWriter.new
		@formatter = ODDB::HtmlFormatter.new(@writer)
		@parser = ODDB::HtmlParser.new(@formatter)
		@parser.feed(@html)	end
	def test_name1
		assert_equal('Arteoptic® 0,5%, 1%, 2%', @writer.name)
	end
	def test_company1
		chapter = @writer.company
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('CHAUVIN NOVOPHARMA', chapter.heading)
	end
	def test_galenic_form1
		chapter = @writer.galenic_form
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Augentropfen', chapter.heading)
		assert_equal(0, chapter.sections.size)
	end
	def test_effects1
		chapter = @writer.effects
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Eigenschaften/Verwendungszweck', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("Was ist Arteoptic und wann wird es angewendet?\n", section.subheading)
		assert_equal(1, section.paragraphs.size)
		paragraph = section.paragraphs.first
		expected = "Arteoptic enthält einen sogenannten Betablocker, der den Augeninnendruck senkt. Arteoptic wird bei erhöhtem Augeninnendruck angewendet, um Ihre Augen vor einer nicht rückgängig zu machenden Verschlechterung des Sehvermögens durch den grünen Star zu schützen. Arteoptic Augentropfen dürfen nur auf Verschreibung des Arztes angewendet werden."
		assert_equal(expected, paragraph.text)
	end
	def test_amendments1
		chapter = @writer.amendments
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Ergänzungen', chapter.heading)
		assert_equal(2, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("Was sollte dazu beachtet werden?\n", section.subheading)
		assert_equal(1, section.paragraphs.size)
		section = chapter.sections.last
		assert_equal("Hinweis für Kontaktlinsenträger:", section.subheading)
	end
	def test_contra_indications1
		chapter = @writer.contra_indications
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Kontraindikationen', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("Wann darf Arteoptic nicht angewendet werden?\n", section.subheading)
		assert_equal(1, section.paragraphs.size)
	end
	def test_precautions1
		chapter = @writer.precautions
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Vorsichtsmassnahmen', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("Wann ist bei der Anwendung von Arteoptic Vorsicht geboten?\n", section.subheading)
		assert_equal(3, section.paragraphs.size)
	end
	def test_pregnancy1
		chapter = @writer.pregnancy
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Schwangerschaft/Stillzeit', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("Darf Arteoptic während einer Schwangerschaft oder in der Stillzeit angewendet werden?\n", section.subheading)
		assert_equal(1, section.paragraphs.size)
	end
	def test_usage1
		chapter = @writer.usage
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Dosierung/Anwendung', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("Wie verwenden Sie Arteoptic?\n", section.subheading)
		assert_equal(5, section.paragraphs.size)
	end
	def test_unwanted_effects1
		chapter = @writer.unwanted_effects
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Unerwünschte Wirkungen', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("Welche Nebenwirkungen kann Arteoptic haben?\n", section.subheading)
		assert_equal(4, section.paragraphs.size)
	end
	def test_general_advice1
		chapter = @writer.general_advice
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Allgemeine Hinweise', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("Was ist ferner zu beachten?\n", section.subheading)
		assert_equal(4, section.paragraphs.size)
	end
	def test_composition1
		chapter = @writer.composition
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Zusammensetzung', chapter.heading)
		assert_equal(2, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("Wirkstoff:", section.subheading)
		assert_equal(1, section.paragraphs.size)
	end
	def test_packages1
		chapter = @writer.packages
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal("Verkaufsart/Packungen", chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("", section.subheading)
		assert_equal(2, section.paragraphs.size)
	end
	def test_distribution1
		chapter = @writer.distribution
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Vertriebsfirma', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("", section.subheading)
		assert_equal(1, section.paragraphs.size)
	end
	def test_date1
		chapter = @writer.date
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Stand der Information', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("", section.subheading)
		assert_equal(1, section.paragraphs.size)
		assert_equal("Mai 2001.", section.paragraphs.first.text)
	end
end
class TestPatinfoHtmlParser00495 < Test::Unit::TestCase
	def setup
		path = File.expand_path('data/html/de/00495.html', 
			File.dirname(__FILE__))
		@html = File.read(path)
		@writer = ODDB::FiParse::PatinfoHtmlWriter.new
		@formatter = ODDB::HtmlFormatter.new(@writer)
		@parser = ODDB::HtmlParser.new(@formatter)
		@parser.feed(@html)	end
	def test_name2
		assert_equal('Mycostatin® Suspension', @writer.name)
	end
	def test_company2
		chapter = @writer.company
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('SANOFI-SYNTHÉLABO', chapter.heading)
	end
	def test_effects2
		chapter = @writer.effects
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Eigenschaften/Verwendungszweck', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("Was ist Mycostatin und wann wird es angewendet?\n", section.subheading)
		assert_equal(2, section.paragraphs.size)
		paragraph = section.paragraphs.first
		expected = "Mycostatin enthält Nystatin, ein gegen Pilzinfektionen (Candidosen) wirksames Antibiotikum. Beim Menschen können Haut und Schleimhäute (Mund, Geschlechtsorgane, Verdauungsorgane) davon betroffen sein."	
		assert_equal(expected, paragraph.text)
	end
end
class TestPatinfoHtmlParser00338 < Test::Unit::TestCase
	def setup
		path = File.expand_path('data/html/de/00338.html', 
			File.dirname(__FILE__))
		@html = File.read(path)
		@writer = ODDB::FiParse::PatinfoHtmlWriter.new
		@formatter = ODDB::HtmlFormatter.new(@writer)
		@parser = ODDB::HtmlParser.new(@formatter)
		@parser.feed(@html)	end
	def test_name3
		assert_equal('Cafergot®', @writer.name)
	end
	def test_company3
		chapter = @writer.company
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('NOVARTIS PHARMA', chapter.heading)
	end
	def test_effects3
		chapter = @writer.effects
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Eigenschaften/Verwendungszweck', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("Was ist Cafergot und wann wird es angewendet?\n", section.subheading)
		assert_equal(1, section.paragraphs.size)
		paragraph = section.paragraphs.first
		expected = "Cafergot ist ein Kombinationspräparat, das auf den Migräneanfall selbst wirkt. Es wirkt gefässverengend auf die erweiterten Arterien. Sein Wirkungseintritt wird durch den Zusatz von Coffein beschleunigt. Cafergot wird auf Verschreibung des Arztes zur Behandlung akuter Migräneanfälle (mit oder ohne Aura) verwendet."	
		assert_equal(expected, paragraph.text)
	end
	def test_contra_indications3
		chapter = @writer.contra_indications
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Kontraindikationen', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("Wann darf Cafergot nicht eingenommen werden?\n", section.subheading)
		assert_equal(9, section.paragraphs.size)
	end
end
class TestPatinfoHtmlParser00943 < Test::Unit::TestCase
	def setup	
		path = File.expand_path('data/html/de/00943.html', 
			File.dirname(__FILE__))
		@html = File.read(path)
		@writer = ODDB::FiParse::PatinfoHtmlWriter.new
		@formatter = ODDB::HtmlFormatter.new(@writer)
		@parser = ODDB::HtmlParser.new(@formatter)
		@parser.feed(@html)	end
	def test_name4
		assert_equal('Rapura®', @writer.name)
	end
	def test_company4
		chapter = @writer.company
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('GLOBOPHARM', chapter.heading)
	end
	def test_galenic_form4
		chapter = @writer.galenic_form
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('', chapter.heading)
		assert_equal(1, chapter.sections.size)
		assert_equal("Heilsalbe auf pflanzlicher Basis", chapter.sections.first.subheading) 
	end
end
class TestPatinfoHtmlParser05050 < Test::Unit::TestCase
	def setup
		path = File.expand_path('data/html/de/05050.html', 
			File.dirname(__FILE__))
		@html = File.read(path)
		@writer = ODDB::FiParse::PatinfoHtmlWriter.new
		@formatter = ODDB::HtmlFormatter.new(@writer)
		@parser = ODDB::HtmlParser.new(@formatter)
		@parser.feed(@html)	end
	def test_amzv5
		chapter = @writer.amzv
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('AMZV 9.11.2001', chapter.heading)
		assert_equal(0, chapter.sections.size)
	end
	def test_effects5
		chapter = @writer.effects
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Was ist Osa Zahngel und wann wird es angewendet?', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal(2, section.paragraphs.size)
		paragraph = section.paragraphs.first
		expected = "Osa Zahngel ist ein schmerzstillendes Gel. Es wird angewendet während der Zahnungsperiode von Kleinkindern. Es ist zuckerfrei und zahnschonend. Es brennt nicht, stillt akute Schmerzen im Zahnfleischbereich, vor allem dann, wenn Zähne die Pilgern durchstossen."
		assert_equal(expected, paragraph.text)
	end
	def test_composition5
		chapter = @writer.composition
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Was ist in Osa Zahngel enthalten?', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal(1, section.paragraphs.size)
		assert_equal("1 g enthält: Salicylamid 80 mg, Lidocainhydrochlorid 1 mg, Dexpanthenol 13 mg, Saccharin, Konservierungsmittel: Benzoesäure (E 210), sowie weitere Hilfsstoffe.", section.paragraphs.first.text)
	end
	def test_iksnrs5
		chapter = @writer.iksnrs
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('42989 (Swissmedic).', chapter.heading)
		assert_equal(0, chapter.sections.size)
	end
	def test_packages5
		chapter = @writer.packages
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal("Wo erhalten Sie Osa Zahngel? Welche Packungen sind erhältlich?", chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("", section.subheading)
		assert_equal(2, section.paragraphs.size)
		paragraph = section.paragraphs.last
		assert_equal('In Tuben zu 10g und 25g.', paragraph.text)
		assert_equal(2, paragraph.formats.size)
	end
end
class TestPatinfoHtmlParser05993 < Test::Unit::TestCase
	def setup
		path = File.expand_path('data/html/de/05993.html', 
			File.dirname(__FILE__))
		@html = File.read(path)
		@writer = ODDB::FiParse::PatinfoHtmlWriter.new
		@formatter = ODDB::HtmlFormatter.new(@writer)
		@parser = ODDB::HtmlParser.new(@formatter)
		@parser.feed(@html)	end
	def test_amzv6
		chapter = @writer.amzv
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('AMZV 9.11.2001', chapter.heading)
		assert_equal(0, chapter.sections.size)
	end
	def test_effects6
		chapter = @writer.effects
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Was ist Co-Epril und wann wird es angewendet?', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal(2, section.paragraphs.size)
		paragraph = section.paragraphs.first
		expected = "Co-Epril ist ein Arzneimittel mit zwei Wirksubstanzen zur Behandlung des hohen Blutdruckes. Die Wirkung des einen Bestandteiles (Enalapril, ein Wirkstoff aus der Gruppe der sog. ACE-Hemmer [Angiotensin-Converting-Enzym-Hemmer]) beruht auf der Hemmung von körpereigenen Stoffen, die für den erhöhten Blutdruck verantwortlich sind. Der andere Bestandteil (Hydrochlorothiazid) erhöht die Salz- und Wasserausscheidung durch die Nieren. Die Wirkmechanismen der beiden Substanzen unterstützen sich gegenseitig. Dadurch kann der Blutdruck wirkungsvoll gesenkt werden."
		assert_equal(expected, paragraph.text)
	end
	def test_contra_indications6
		chapter = @writer.contra_indications
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Wann darf Co-Epril nicht angewendet werden?', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal(6, section.paragraphs.size)
		assert_equal("Nehmen Sie Co-Epril nicht ein, wenn Sie", section.paragraphs.first.text)
	end
	def test_precautions6
		chapter = @writer.precautions
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Wann ist bei der Einnahme/Anwendung von Co-Epril Vorsicht geboten?', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal(10, section.paragraphs.size)
		assert_equal("Dieses Arzneimittel kann die Reaktionsfähigkeit, die Fahrtüchtigkeit und Fähigkeit, Werkzeuge oder Maschinen zu bedienen, beeinträchtigen!", section.paragraphs.first.text)
	end
	def test_pregnancy6
		chapter = @writer.pregnancy
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Darf Co-Epril während einer Schwangerschaft oder in der Stillzeit eingenommen/angewendet werden?', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal(1, section.paragraphs.size)
		assert_equal("Informieren Sie Ihren Arzt oder Ihre Ärztin, falls Sie schwanger sind, eine Schwangerschaft planen oder stillen. Co-Epril darf während der Schwangerschaft und Stillzeit nur auf ausdrückliche Verordnung des Arztes oder Ihrer Ärztin eingenommen werden.", section.paragraphs.first.text)
	end
	def test_usage6
		chapter = @writer.usage
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Wie verwenden Sie Co-Epril?', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal(9, section.paragraphs.size)
		assert_equal("Co-Epril kann vor, während oder nach den Mahlzeiten eingenommen werden. Die Dosierung wird vom Arzt oder der Ärztin festgelegt.", section.paragraphs.first.text)
	end
	def test_unwanted_effects6
		chapter = @writer.unwanted_effects
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Welche Nebenwirkungen kann Co-Epril haben?', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal(11, section.paragraphs.size)
		assert_equal("Folgende Nebenwirkungen können bei der Einnahme von Co-Epril auftreten:", section.paragraphs.first.text)
	end
	def test_general_advice6
		chapter = @writer.general_advice
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Was ist ferner zu beachten?', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal(3, section.paragraphs.size)
		assert_equal("Das Arzneimittel darf nur bis zu dem auf dem Behälter mit «EXP» bezeichneten Datum verwendet werden.", section.paragraphs.first.text)
	end
	def test_composition6
		chapter = @writer.composition
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Was ist in Co-Epril enthalten?', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal(1, section.paragraphs.size)
		assert_equal("Co-Epril enthält als Wirkstoffe 20 mg Enalapril Maleat und 12,5 mg Hydrochlorothiazid sowie Hilfsstoffe und ist erhältlich als teilbare Tablette.", section.paragraphs.first.text)
	end
	def test_iksnrs6
		chapter = @writer.iksnrs
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('55942 (Swissmedic).', chapter.heading)
		assert_equal(0, chapter.sections.size)
	end
	def test_packages6
		chapter = @writer.packages
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal("Wo erhalten Sie Co-Epril? Welche Packungen sind erhältlich?", chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("", section.subheading)
		assert_equal(2, section.paragraphs.size)
		paragraph = section.paragraphs.last
		assert_equal('Packungen zu 30 und 100 Tabletten.', paragraph.text)
		assert_equal(2, paragraph.formats.size)
	end
	def test_distribution6
		chapter = @writer.distribution
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Zulassungsinhaberin', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal(1, section.paragraphs.size)
		assert_equal("Ecosol AG, Zürich.", section.paragraphs.first.text)
	end
	def test_date_dummy6
		chapter = @writer.date_dummy
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Diese Packungsbeilage wurde im März 2002 letztmals durch die Arzneimittelbehörde (Swissmedic) geprüft.', chapter.heading)
		assert_equal(0, chapter.sections.size)
	end
	def test_date6
		chapter = @writer.date
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Stand der Information', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal(2, section.paragraphs.size)
		assert_equal("Diese Packungsbeilage wurde im März 2002 letztmals durch die Arzneimittelbehörde (Swissmedic) geprüft.", section.paragraphs.first.text)
	end
end
class TestPatinfoHtmlParser00914 < Test::Unit::TestCase
	def setup
		path = File.expand_path('data/html/de/00914.html', 
			File.dirname(__FILE__))
		@html = File.read(path)
		@writer = ODDB::FiParse::PatinfoHtmlWriter.new
		@formatter = ODDB::HtmlFormatter.new(@writer)
		@parser = ODDB::HtmlParser.new(@formatter)
		@parser.feed(@html)
	end
	def test_distribution7
		chapter = @writer.distribution
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Zulassungsinhaberin', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal(1, section.paragraphs.size)
		assert_equal("Padma AG, Wiesenstrasse 5, 8603 Schwerzenbach.", section.paragraphs.first.text)
	end
	def test_date7
		chapter = @writer.date
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Stand der Information', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal(2, section.paragraphs.size)
		assert_equal("Diese Packungsbeilage wurde im November 2002 letztmals durch die Arzneimittelbehörde (Swissmedic) geprüft.", section.paragraphs.first.text)
	end
end
class TestPatinfoHtmlParser06028 < Test::Unit::TestCase
	def setup
		path = File.expand_path('data/html/de/06028.html', 
			File.dirname(__FILE__))
		@html = File.read(path)
		@writer = ODDB::FiParse::PatinfoHtmlWriter.new
		@formatter = ODDB::HtmlFormatter.new(@writer)
		@parser = ODDB::HtmlParser.new(@formatter)
		@parser.feed(@html)	end
	def test_name8
		assert_equal('Aspirin®/Aspirin® 500', @writer.name)
	end
	def test_company8
		chapter = @writer.company
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('BAYER', chapter.heading)
	end
	def test_galenic_form8
		chapter = @writer.galenic_form
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal("Tabletten und Kautabletten zu 500 mg\nInstant-Tabletten zu 500 mg", chapter.heading)
		assert_equal(0, chapter.sections.size)
	end
	def test_effects8
		chapter = @writer.effects
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Eigenschaften/Verwendungszweck', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("Was ist Aspirin und wann wird es angewendet?\n", section.subheading)
		assert_equal(2, section.paragraphs.size)
		paragraph = section.paragraphs.first
		expected = "Aspirin enthält den Wirkstoff Acetylsalicylsäure. Dieser wirkt schmerzlindernd und fiebersenkend."
		assert_equal(expected, paragraph.text)
	end
end
class TestPatinfoHtmlParser00907_fr < Test::Unit::TestCase
	def setup
		path = File.expand_path('data/html/fr/00907.html', 
			File.dirname(__FILE__))
		@html = File.read(path)
		@writer = ODDB::FiParse::PatinfoHtmlWriter.new
		@formatter = ODDB::HtmlFormatter.new(@writer)
		@parser = ODDB::HtmlParser.new(@formatter)
		@parser.feed(@html)	end
	def test_name9
		assert_equal('Arteoptic® 0,5%, 1%, 2%', @writer.name)
	end
	def test_company9
		chapter = @writer.company
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('CHAUVIN NOVOPHARMA', chapter.heading)
	end
	def test_galenic_form9
		chapter = @writer.galenic_form
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Collyre', chapter.heading)
		assert_equal(0, chapter.sections.size)
	end
	def test_effects9
		chapter = @writer.effects
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Propriétés/Emploi thérapeutique', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("Qu'est-ce que Arteoptic et quand est-il utilisé?\n", section.subheading)
		assert_equal(1, section.paragraphs.size)
		paragraph = section.paragraphs.first
		expected = "Arteoptic contient un bêta-bloquant qui fait baisser la pression intra-oculaire. Arteoptic est utilisé en cas d'augmentation de la pression intra-oculaire, pour protéger vos yeux d'une aggravation irréversible de la vision sous l'effet d'un glaucome. Arteoptic collyre ne peut être utilisé que sur ordonnance médicale."
		assert_equal(expected, paragraph.text)
	end
	def test_amendments9
		chapter = @writer.amendments
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Complément d\'information', chapter.heading)
		assert_equal(2, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("De quoi faut-il tenir compte en dehors du traitement?\n", section.subheading)
		assert_equal(1, section.paragraphs.size)
		section = chapter.sections.last
		assert_equal("Conseils pour porteurs de lentilles de contact:", section.subheading)
	end
	def test_contra_indications9
		chapter = @writer.contra_indications
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Contre-indications',chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("Quand Arteoptic ne doit-il pas être utilisé?\n", section.subheading)
		assert_equal(1, section.paragraphs.size)
	end
	def test_precautions9
		chapter = @writer.precautions
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Précautions', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("Quelles sont les mesures de précaution à observer lors de l'utilisation de Arteoptic?\n", section.subheading)
		assert_equal(2, section.paragraphs.size)
	end
	def test_pregnancy9
		chapter = @writer.pregnancy
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Grossesse/Allaitement', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("Arteoptic peut-il être utilisé pendant la grossesse ou l'allaitement?\n", section.subheading)
		assert_equal(1, section.paragraphs.size)
	end
	def test_usage9
		chapter = @writer.usage
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Posologie/Mode d\'emploi', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("Comment utiliser Arteoptic?\n", section.subheading)
		assert_equal(5, section.paragraphs.size)
	end
	def test_unwanted_effects9
		chapter = @writer.unwanted_effects
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Effets indésirables', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("Quels effets indésirables Arteoptic peut-il avoir?\n", section.subheading)
		assert_equal(3, section.paragraphs.size)
	end
	def test_general_advice9
		chapter = @writer.general_advice
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Remarques particulières', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("De quoi faut-il en outre tenir compte?\n", section.subheading)
		assert_equal(4, section.paragraphs.size)
	end
	def test_composition9
		chapter = @writer.composition
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Composition', chapter.heading)
		assert_equal(2, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("Principe actif", section.subheading)
		assert_equal(1, section.paragraphs.size)
	end
	def test_packages9
		chapter = @writer.packages
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal("Mode de vente/Présentation", chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("", section.subheading)
		assert_equal(2, section.paragraphs.size)
	end
	def test_distribution9
		chapter = @writer.distribution
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Distributeur', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("", section.subheading)
		assert_equal(1, section.paragraphs.size)
	end
	def test_date9
		chapter = @writer.date
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Mise à jour de l\'information', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("", section.subheading)
		assert_equal(1, section.paragraphs.size)
		assert_equal("Mai 2001.", section.paragraphs.first.text)
	end
end
class TestPatinfoHtmlParser05993_fr < Test::Unit::TestCase
	def setup
		path = File.expand_path('data/html/fr/05993.html', 
			File.dirname(__FILE__))
		@html = File.read(path)
		@writer = ODDB::FiParse::PatinfoHtmlWriter.new
		@formatter = ODDB::HtmlFormatter.new(@writer)
		@parser = ODDB::HtmlParser.new(@formatter)
		@parser.feed(@html)	end
	def test_amzv10
		chapter = @writer.amzv
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('OEMéd 9.11.2001', chapter.heading)
		assert_equal(0, chapter.sections.size)
	end
	def test_effects10
		chapter = @writer.effects
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Qu\'est-ce que Co-Epril et quand est-il utilisé?', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal(2, section.paragraphs.size)
		paragraph = section.paragraphs.first
		expected = "Co-Epril est un médicament contenant deux principes actifs destiné au traitement de l'hypertension artérielle. L'effet de l'un des composants (l'énalapril, un principe actif de la classe dite des inhibiteurs de l'ECA [inhibiteurs de l'enzyme de conversion de l'angiotensine]) repose sur l'inhibition de substances endogènes responsables de la pression artérielle trop élevée. L'autre composant (hydrochlorothiazide) augmente l'élimination rénale de sel et d'eau. Les principes d'action des deux substances se renforcent mutuellement. La pression artérielle peut ainsi être diminuée efficacement."
		assert_equal(expected, paragraph.text)
	end
	def test_contra_indications10
		chapter = @writer.contra_indications
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Quand Co-Epril ne doit-il pas être utilisé?', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal(6, section.paragraphs.size)
		assert_equal("Ne prenez pas Co-Epril si", section.paragraphs.first.text)
	end
	def test_precautions10
		chapter = @writer.precautions
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Quelles sont les précautions à observer lors de la prise/utilisation de Co-Epril?', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal(10, section.paragraphs.size)
		assert_equal("Ce médicament peut affecter les réactions, l'aptitude à la conduite et l'aptitude à utiliser des outils ou des machines!", section.paragraphs.first.text)
	end
	def test_pregnancy10
		chapter = @writer.pregnancy
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Co-Epril peut-il être pris/utilisé pendant la grossesse ou l\'allaitement?', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal(1, section.paragraphs.size)
		assert_equal("Veuillez informer votre médecin si vous êtes enceinte, si vous envisagez une grossesse ou si vous allaitez. Pendant la grossesse ou en période d'allaitement, Co-Epril ne peut être pris que sur prescription expresse de votre médecin.", section.paragraphs.first.text)
	end
	def test_usage10
		chapter = @writer.usage
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Comment utiliser Co-Epril?', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal(9, section.paragraphs.size)
		assert_equal("Co-Epril peut être pris avant, pendant ou après les repas. La posologie est fixée par le médecin.", section.paragraphs.first.text)
	end
	def test_unwanted_effects10
		chapter = @writer.unwanted_effects
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Quels effets secondaires Co-Epril peut-il provoquer?', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal(9, section.paragraphs.size)
		assert_equal("La prise ou l'utilisation de Co-Epril peut provoquer les effets secondaires suivants:", section.paragraphs.first.text)
	end
	def test_general_advice10
		chapter = @writer.general_advice
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('A quoi faut-il encore faire attention?', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal(3, section.paragraphs.size)
		assert_equal("Le médicament ne doit pas être utilisé au-delà de la date figurant après la mention «EXP» sur le récipient.", section.paragraphs.first.text)
	end
	def test_composition10
		chapter = @writer.composition
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Que contient Co-Epril?', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal(1, section.paragraphs.size)
		assert_equal("Co-Epril contient comme principes actifs 20 mg de maléate d'énalapril et 12,5 mg d'hydrochlorothiazide ainsi que des excipients et est disponible sous forme de comprimés sécables.", section.paragraphs.first.text)
	end
	def test_date_dummy10
		chapter = @writer.date_dummy
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal("Cette notice d'emballage a été contrôlée par l'autorité de contrôle des médicaments (Swissmedic) en mars 2002.", chapter.heading)
		assert_equal(0, chapter.sections.size)
	end
	def test_date10
		chapter = @writer.date
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal("Mise à jour de l'information", chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal(2, section.paragraphs.size)
		assert_equal("Cette notice d'emballage a été contrôlée par l'autorité de contrôle des médicaments (Swissmedic) en mars 2002.", section.paragraphs.first.text)
	end
end
class TestPatinfoHtmlParser06209 < Test::Unit::TestCase
	def setup
		path = File.expand_path('data/html/de/06209.html', 
			File.dirname(__FILE__))
		@html = File.read(path)
		@writer = ODDB::FiParse::PatinfoHtmlWriter.new
		@formatter = ODDB::HtmlFormatter.new(@writer)
		@parser = ODDB::HtmlParser.new(@formatter)
		@parser.feed(@html)	end
	def test_amzv11
		chapter = @writer.amzv
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('AMZV 9.11.2001', chapter.heading)
		assert_equal(0, chapter.sections.size)
	end
	def test_effects11
		chapter = @writer.effects
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Was ist Omed und wann wird es angewendet?', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal(8, section.paragraphs.size)
		paragraph = section.paragraphs.first
		expected = "Omed enthaelt den Wirkstoff Omeprazol. Dieser führt zu einer Verminderung der Magensaeureproduktion. Omed dient zur Behandlung von:"
		assert_equal(expected, paragraph.text)
	end
	def test_amendments11
		chapter = @writer.amendments
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('Was sollte dazu beachtet werden?', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal(1, section.paragraphs.size)
		paragraph = section.paragraphs.first
		expected = "Eine durch Magensaeure hervorgerufene Entzündung oder ein Geschwür kann nur richtig behandelt werden, wenn Sie sich genau an die mit Ihrem Arzt oder Ihrer Ärztin besprochenen Anweisungen halten."
		assert_equal(expected, paragraph.text)
	end
	def test_contra_indications11
		chapter = @writer.contra_indications
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Wann darf Omed nicht angewendet werden?', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal(2, section.paragraphs.size)
		expected = "Omed darf nicht eingenommen werden bei bekannter Überempfindlichkeit auf den Wirkstoff oder einen der Hilfsstoffe."
		assert_equal(expected, section.paragraphs.first.text)
	end
end
class TestPatinfoHtmlParser01300 < Test::Unit::TestCase
	def setup
		path = File.expand_path('data/html/de/01300.html', 
			File.dirname(__FILE__))
		@html = File.read(path)
		@writer = ODDB::FiParse::PatinfoHtmlWriter.new
		@formatter = ODDB::HtmlFormatter.new(@writer)
		@parser = ODDB::HtmlParser.new(@formatter)
		@parser.feed(@html)	end
	def test_name10
		assert_equal('Liberol® Baby N', @writer.name)
	end
	def test_company10
		chapter = @writer.company
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('SEMOMED', chapter.heading)
	end
	def test_effects10
		chapter = @writer.effects
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Eigenschaften/Verwendungszweck', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("Was ist Liberol Baby N Salbe und wann wird sie angewendet?\n", section.subheading)
		assert_equal(1, section.paragraphs.size)
		paragraph = section.paragraphs.first
		expected = "Liberol Baby N ist eine Kombination ätherischer Öle. Diese durchdringen die Haut, loesen zähen Schleim, steigern die Durchblutung der Haut. Liberol Baby N eignet sich speziell fuer Säuglinge und Kleinkinder bei Erkältung mit Husten, Schnupfen und Brustkatarrh."
		assert_equal(expected, paragraph.text)
	end
	def test_contra_indications10
		chapter = @writer.contra_indications
		assert_instance_of(ODDB::Text::Chapter, chapter) 
		assert_equal('Kontraindikationen',chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("Wann darf Liberol Baby N Salbe nicht angewendet werden?\n", section.subheading)
		assert_equal(2, section.paragraphs.size)
	end
	def test_precautions10
		chapter = @writer.precautions
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Vorsichtsmassnahmen', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("Wann ist bei der Anwendung von Liberol Baby N Salbe Vorsicht geboten?\n", section.subheading)
		assert_equal(2, section.paragraphs.size)
	end
	def test_usage10
		chapter = @writer.usage
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Dosierung/Anwendung', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("Wie verwenden Sie Liberol Baby N Salbe?\n", section.subheading)
		assert_equal(3, section.paragraphs.size)
	end
	def test_unwanted_effects10
		chapter = @writer.unwanted_effects
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Unerwuenschte Wirkungen', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("Welche Nebenwirkungen kann Liberol Baby N Salbe haben?\n", section.subheading)
		assert_equal(1, section.paragraphs.size)
	end
end
class TestPatinfoHtmlParser00415 < Test::Unit::TestCase
	def setup
		path = File.expand_path('data/html/de/00415.html', 
			File.dirname(__FILE__))
		@html = File.read(path)
		@writer = ODDB::FiParse::PatinfoHtmlWriter.new
		@formatter = ODDB::HtmlFormatter.new(@writer)
		@parser = ODDB::HtmlParser.new(@formatter)
		@parser.feed(@html)	end
	def test_name11
		assert_equal('Geriavit Pharmaton®', @writer.name)
	end
	def test_company11
		chapter = @writer.company
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('PHARMATON', chapter.heading)
	end
	def test_effects11
		chapter = @writer.effects
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Eigenschaften/Verwendungszweck', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("Was ist Geriavit Pharmaton und wann wird es angewendet?\n", section.subheading)
		assert_equal(4, section.paragraphs.size)
		paragraph = section.paragraphs.first
		expected = "Geriavit Pharmaton ist ein Kombinationspraeparat aus Ginseng-Extrakt G115, Vitaminen, Mineralstoffen und Spurenelementen."
		assert_equal(expected, paragraph.text)
	end
	def test_amendments11
		chapter = @writer.amendments
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Ergaenzungen', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("Was sollte dazu beachtet werden?\n", section.subheading)
		assert_equal(1, section.paragraphs.size)
	end
	def test_pregnancy11
		chapter = @writer.pregnancy
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Schwangerschaft/Stillzeit', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("Darf Geriavit Pharmaton waehrend einer Schwangerschaft oder in der Stillzeit eingenommen werden?\n", section.subheading)
		assert_equal(5, section.paragraphs.size)
	end
	def test_usage11
		chapter = @writer.usage
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Dosierung/Anwendung', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("Wie verwenden Sie Geriavit Pharmaton?\n", section.subheading)
		assert_equal(4, section.paragraphs.size)
	end
	def test_unwanted_effects11
		chapter = @writer.unwanted_effects
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Unerwuenschte Wirkungen', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("Welche Nebenwirkungen kann Geriavit Pharmaton haben?\n", section.subheading)
		assert_equal(1, section.paragraphs.size)
	end
	def test_general_advice11
		chapter = @writer.general_advice
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Allgemeine Hinweise', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("Was ist ferner zu beachten?\n", section.subheading)
		assert_equal(3, section.paragraphs.size)
	end
	def test_date11
		chapter = @writer.date
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Stand der Information', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("", section.subheading)
		assert_equal(1, section.paragraphs.size)
		assert_equal("Januar 1997.", section.paragraphs.first.text)
	end
class TestPatinfoHtmlParser00555 < Test::Unit::TestCase
	def setup
		path = File.expand_path('data/html/de/00555.html', 
			File.dirname(__FILE__))
		@html = File.read(path)
		@writer = ODDB::FiParse::PatinfoHtmlWriter.new
		@formatter = ODDB::HtmlFormatter.new(@writer)
		@parser = ODDB::HtmlParser.new(@formatter)
		@parser.feed(@html)	end
	def test_amzv12
		chapter = @writer.amzv
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('AMZV 9.11.2001', chapter.heading)
		assert_equal(0, chapter.sections.size)
	end
	def test_effects12
		chapter = @writer.effects
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Was ist Prostatonin und wann wird es angewendet?', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal(3, section.paragraphs.size)
		paragraph = section.paragraphs.first
		expected = "Prostatonin ist ein Kombinationspraeparat, das bei Beschwerden infolge Prostatavergroesserung (Prostatahyperplasie), und damit verbundenen Stoerungen beim Wasserlassen verwendet wird."
		assert_equal(expected, paragraph.text)
	end
	def test_contra_indications12
		chapter = @writer.contra_indications
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Wann darf Prostatonin nicht oder nur mit Vorsicht angewendet werden?', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal(2, section.paragraphs.size)
		assert_equal("Bis heute sind keine Anwendungseinschraenkungen bekannt. Bei bestimmungsgemaessem Gebrauch sind keine besonderen Vorsichtsmassnahmen notwendig.", section.paragraphs.first.text)
	end
	def test_usage12
		chapter = @writer.usage
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Wie verwenden Sie Prostatonin?', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal(3, section.paragraphs.size)
		assert_equal("Sofern nicht anders verschrieben, 2mal taeglich 1 Kapsel unzerkaut mit etwas Fluessigkeit nach den Mahlzeiten einnehmen.", section.paragraphs.first.text)
	end
end
end
class TestPatinfoHtmlParser00013 < Test::Unit::TestCase
	def setup
		path = File.expand_path('data/html/fr/00013.html', 
			File.dirname(__FILE__))
		@html = File.read(path)
		@writer = ODDB::FiParse::PatinfoHtmlWriter.new
		@formatter = ODDB::HtmlFormatter.new(@writer)
		@parser = ODDB::HtmlParser.new(@formatter)
		@parser.feed(@html)	end
	def test_general_advice12
		chapter = @writer.general_advice
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Remarques particulières', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("De quoi faut-il en outre tenir compte?\n", section.subheading)
		assert_equal(3, section.paragraphs.size)
	end
	def test_composition12
		chapter = @writer.composition
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Composition', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("", section.subheading)
		assert_equal(1, section.paragraphs.size)
		assert_equal("L'Akineton/Akineton retard contient 2 mg contient resp. 4 mg de chlorhydrate de bipéridène (principe actif) ainsi que des excipients pour la fabrication de comprimés.", section.paragraphs.first.text)
	end
	def test_sale13
		chapter = @writer.packages
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Mode d\'emploi/Présentation', chapter.heading)
		assert_equal(3, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("", section.subheading)
		assert_equal(1, section.paragraphs.size)
		assert_equal("En pharmacie, sur ordonnance médicale.", section.paragraphs.first.text)
	end
	def test_date12
		chapter = @writer.date
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Mise à jour de l\'information', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("", section.subheading)
		assert_equal(1, section.paragraphs.size)
		assert_equal("Mai 1999.", section.paragraphs.first.text)
	end
end
class TestPatinfoHtmlParser00116 < Test::Unit::TestCase
	def setup
		path = File.expand_path('data/html/fr/00116.html', 
			File.dirname(__FILE__))
		@html = File.read(path)
		@writer = ODDB::FiParse::PatinfoHtmlWriter.new
		@formatter = ODDB::HtmlFormatter.new(@writer)
		@parser = ODDB::HtmlParser.new(@formatter)
		@parser.feed(@html)	end
	def test_name18
		assert_equal('Klyx Magnum®', @writer.name)
	end
	def test_usage18
		chapter = @writer.usage
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Posologie/Mode d\'emploi', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("Comment utiliser Klyx Magnum?\n", section.subheading)
		assert_equal(2, section.paragraphs.size)
	end
	def test_composition18
		chapter = @writer.composition
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Composition', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal(3, section.paragraphs.size)
	end
	def test_distribution18
		chapter = @writer.distribution
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Distributeur', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("", section.subheading)
		assert_equal(1, section.paragraphs.size)
		assert_equal("Ferring S.A., 8304 Wallisellen.", section.paragraphs.first.text)
	end
	def test_date18
		chapter = @writer.date
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Mise à jour de l\'information', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal("", section.subheading)
		assert_equal(1, section.paragraphs.size)
		assert_equal("Avril 1990.", section.paragraphs.first.text)
	end
end
class TestPatinfoHtmlParser00117 < Test::Unit::TestCase
	def setup
		path = File.expand_path('data/html/de/00744.html', 
			File.dirname(__FILE__))
		@html = File.read(path)
		@writer = ODDB::FiParse::PatinfoHtmlWriter.new
		@formatter = ODDB::HtmlFormatter.new(@writer)
		@parser = ODDB::HtmlParser.new(@formatter)
		@parser.feed(@html)	end	
	def test_composition19
		chapter = @writer.composition
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Zusammensetzung', chapter.heading)
		assert_equal(2, chapter.sections.size)
		section = chapter.sections.first
		assert_equal(3, section.paragraphs.size)
	end
	def test_distribution19
		chapter = @writer.distribution
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Vertriebsfirma', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section= chapter.sections.first
		assert_equal("", section.subheading)
		assert_equal(1, section.paragraphs.size)
	end
end
class TestPatinfoHtmlParser00018 < Test::Unit::TestCase
	def setup
		path = File.expand_path('data/html/de/00455.html', 
			File.dirname(__FILE__))
		@html = File.read(path)
		@writer = ODDB::FiParse::PatinfoHtmlWriter.new
		@formatter = ODDB::HtmlFormatter.new(@writer)
		@parser = ODDB::HtmlParser.new(@formatter)
		@parser.feed(@html)	end
	def test_packages18
		chapter = @writer.packages
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Packungen', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal(1, section.paragraphs.size)
	end
end
class TestPatinfoHtmlParser03831 < Test::Unit::TestCase
	def setup
		path = File.expand_path('data/html/de/03831.html', 
			File.dirname(__FILE__))
		@html = File.read(path)
		@writer = ODDB::FiParse::PatinfoHtmlWriter.new
		@formatter = ODDB::HtmlFormatter.new(@writer)
		@parser = ODDB::HtmlParser.new(@formatter)
		@parser.feed(@html)	
	end
	def test_amzv20
		chapter = @writer.amzv
		assert_instance_of(ODDB::Text::Chapter, chapter)
		assert_equal('AMZV 9.11.2001', chapter.heading)
		assert_equal(0, chapter.sections.size)
	end
	def test_effects20
		chapter = @writer.effects
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal("Was ist Co-Diovan/- Forte 160/12,5/- Forte 160/25\nund wann wird es angewendet?", chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal(4, section.paragraphs.size)
		paragraph = section.paragraphs.first
		expected = "Co-Diovan/- Forte 160/12,5/- Forte 160/25 enthält zwei sich ergänzende Wirksubstanzen, die das blutdruckregulierende System des Körpers beeinflussen: Valsartan, das in erster Linie zu einer Erweiterung der Blutgefässe führt und damit den Blutdruck senkt, und Hydrochlorothiazid, welches den Natriumchlorid- und Wassergehalt im Körper vermindert, indem es die Urinausscheidung erhöht."
		assert_equal(expected, paragraph.text)
	end
	def test_amendment20
		chapter = @writer.amendments
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Was sollte dazu beachtet werden?', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal(1, section.paragraphs.size)
		assert_equal("Wenn ein hoher Blutdruck nicht behandelt wird, können lebenswichtige Organe wie das Herz, die Nieren und das Hirn geschädigt werden. Sie können sich wohl fühlen und keine Symptome haben, aber die unbehandelte Hypertonie kann zu Spätfolgen wie z.B. Hirnschlag, Herzinfarkt, Herzschwäche, Nierenfunktionsstörungen oder Erblinden führen.", section.paragraphs.first.text)
		end
	def test_contra_indications20
		chapter = @writer.contra_indications
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal('Wann darf Co-Diovan/- Forte 160/12,5/- Forte 160/25 nicht angewendet werden?', chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal(1, section.paragraphs.size)
		assert_equal("Sie sollten Co-Diovan/- Forte 160/12,5/- Forte 160/25 nicht einnehmen, wenn Sie jemals überempfindlich oder allergisch auf Valsartan, Hydrochlorothiazid oder einen anderen Bestandteil dieses Arzneimittels reagiert haben. Bei Schwangerschaft, während der Stillzeit oder wenn Sie an einer schweren Leber- oder Nierenerkrankung, Gicht, Nierensteinen (Uratsteinen) oder starken Störungen des Elektrolythaushaltes leiden, sollte Co-Diovan/- Forte 160/12,5/- Forte 160/25 nicht angewendet werden. Falls früher anlässlich der Einnahme eines blutdrucksenkenden Medikamentes Schwellungen im Gesicht, auf Lippen, Zunge oder im Rachen (Schluck- oder Atembeschwerden) auftraten, dürfen Sie Co-Diovan/- Forte 160/12,5/- Forte 160/25 nicht einnehmen.", section.paragraphs.first.text)
		end
	def test_precautions20
		chapter = @writer.precautions
		assert_instance_of(ODDB::Text::Chapter, chapter )
		assert_equal("Wann ist bei der Einnahme/Anwendung von Co-Diovan/\n- Forte 160/12,5/- Forte160/25 Vorsicht geboten?", chapter.heading)
		assert_equal(1, chapter.sections.size)
		section = chapter.sections.first
		assert_equal(10, section.paragraphs.size)
		assert_equal("Wie jedes andere blutdrucksenkende Mittel kann auch Co-Diovan/- Forte 160/12,5/- Forte 160/25 Ihre Aufmerksamkeit und Konzentration herabsetzen. Daher ist Vorsicht im Strassenverkehr und beim Bedienen von Maschinen geboten.", section.paragraphs.first.text)
	end
end
