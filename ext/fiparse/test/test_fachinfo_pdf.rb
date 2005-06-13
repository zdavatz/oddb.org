#!/usr/bin/env ruby
# Fachinfo -- oddb -- 26.10.2003 -- mwalder@ywesee.com rwaltert@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path("../src", File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require	'fachinfo_pdf'
require "yaml"
require 'rpdf2txt/parser'

module ODDB
	class FachinfoDocument
		def odba_id
			1
		end
	end
	module FiParse
		class TestFachinfoPDFWriter < Test::Unit::TestCase
			def setup
				@writer = FachinfoPDFWriter.new
 #				@parser = Rpdf2txt::Parser.new(File.read(File.expand_path("../fiparse/test/data/pdf/test_file1.pdf")))
 #		@parser.extract_text(@fachinfo_pdf)
				path = File.expand_path('../test/data/method_calls.rb',File.dirname(__FILE__))
				eval(File.read(path))
				@fachinfo = @writer.to_fachinfo
			end
			def test_name
				name = @fachinfo.name
				assert_equal("Rhinopront\256 N", name)
			end
			def test_composition
				chapter = @fachinfo.composition
				assert_equal('Zusammensetzung', chapter.heading)

				section1 = chapter.sections.first
				assert_equal('Wirkstoffe:', section1.subheading)
				assert_equal(1, section1.paragraphs.size)
				paragraph1 = section1.paragraphs.first
				expected = 'Chlorphenamini maleas, Phenylephrini hydrochloridum.'
				assert_equal(expected, paragraph1.text)
				section2 = chapter.sections.last
				assert_equal('Hilfsstoffe:', section2.subheading)
				assert_equal(1, section2.paragraphs.size)
				paragraph2 = section2.paragraphs.first
				expected = 'Saccharum 253,4 mg; Color.: E 127, E 132; Excip. pro caps. gelat.'
				assert_equal(expected, paragraph2.text)
			end
			def test_galenic_form
				chapter = @fachinfo.galenic_form
				assert_equal('Galenische Form und Wirkstoffmenge pro Einheit', chapter.heading)
				section1 = chapter.sections.first
				assert_equal('', section1.subheading)
			end
			def test_indications
				chapter = @fachinfo.indications
				assert_equal('Indikationen/Anwendungsmöglichkeiten', chapter.heading)
				section1 = chapter.sections.first
				assert_equal('', section1.subheading)
				paragraph1 = section1.paragraphs.first
				expected = 'Entzündliche und allergische Erkrankungen der oberen Atemwege wie Schnupfen, Heuschnupfen, chronisches Nasenrinnen, vasomotorische bzw. allergische Rhinitis, Rhinopharyngitis, allergische Sinusitis. Als Adjuvans bei Grippe und Erkältungen.'
				assert_equal(expected, paragraph1.text)
			end
			def test_usage
				chapter = @fachinfo.usage
				assert_equal('Dosierung/Anwendung',chapter.heading)
				section1 = chapter.sections.first
				assert_equal('Erwachsene und Kinder ab 12 Jahren:', section1.subheading)
				paragraph1 = section1.paragraphs.first
				expected = 'Beim Auftreten der Symptome 1 Kapsel alle 12 Stunden, d.h. 1 Kapsel morgens und 1 Kapsel abends.'
				assert_equal(expected, paragraph1.text)
			end
			def test_contra_indications
				chapter = @fachinfo.contra_indications
				assert_equal('Kontraindikationen',chapter.heading)
				section1 = chapter.sections.first
				assert_equal('', section1.subheading)
				paragraph1 = section1.paragraphs.first
				expected = 'Einnahme von MAO-Hemmern.'
				assert_equal(expected, paragraph1.text)
			end
			def test_restrictions
				chapter = @fachinfo.restrictions
				assert_equal('Warnhinweise und Vorsichtsmassnahmen', chapter.heading)
				section1 = chapter.sections.first
				assert_equal("Relative Kontraindikationen\n", section1.subheading)
				assert_equal(2, section1.paragraphs.size)
				paragraph1 = section1.paragraphs.first
				expected = 'Bei schwerer Krankheit der Koronargefässe oder stark erhöhtem Blutdruck darf Rhinopront N nur nach Rücksprache mit einem Arzt eingenommen werden.'
				assert_equal(expected, paragraph1.text)
				paragraph2 = section1.paragraphs.at(1)
				expected = "Siehe \253Schwangerschaft/Stillzeit\273."
				assert_equal(expected, paragraph2.text)
				section2 = chapter.sections.at(1)
				assert_equal("Warnhinweise und Vorsichtsmassnahmen\n", section2.subheading)
				assert_equal(1, section2.paragraphs.size)
				paragraph1 = section2.paragraphs.first
				expected = 'Vorsicht ist geboten bei: Engwinkelglaukom, Zuckerkrankheit, Prostata-Hypertrophie, Hyperthyreose, Asthma bronchiale.'
				assert_equal(expected, paragraph1.text)
			end
			def test_interaction
				chapter = @fachinfo.interactions
				assert_equal('Interaktionen',chapter.heading)
				section1 = chapter.sections.first
				assert_equal('', section1.subheading)
				paragraph1 = section1.paragraphs.first
				expected = "MAO-Hemmer und trizyklische Antidepressiva verst\344rken den Vasokonstriktoreffekt des Phenylephrins. Antihistaminika verst\344rken die Wirkung von Alkohol und von zentralwirkenden Beruhigungsmitteln (z.B. Barbiturate, Sedativa, Analgetika, Hypnotika)."
				assert_equal(expected, paragraph1.text)
			end
			def test_pregnancy
				chapter = @fachinfo.pregnancy
				assert_equal('Schwangerschaft/Stillzeit',chapter.heading)
				section1 = chapter.sections.first
				assert_equal('', section1.subheading)
				paragraph1 = section1.paragraphs.first
				expected =	"Die Sicherheit von Chlorphenamin und Phenylephrin oder ihrer Kombination w\344hrend der ersten beiden Schwangerschaftstrimester wurde nicht erwiesen. Im letzten Schwangerschaftstrimester und w\344hrend der Stillzeit bergen diese Pr\344parate das Risiko schwerer unerw\374nschter Wirkungen, wie z.B. durch Chlorphenamin bewirkte Kr\344mpfe beim F\366tus und beim Neugeborenen. Folglich sind sie in diesem Stadium der Schwangerschaft kontraindiziert."
				assert_equal(expected, paragraph1.text)
				paragraph2 = section1.paragraphs.last
				expected = 'Die Anwendung während der Stillzeit ist zu vermeiden.'
				assert_equal(expected, paragraph2.text)
			end
			def test_driving_ability
				chapter = @fachinfo.driving_ability
				assert_equal('Wirkung auf die Fahrtüchtigkeit und auf das Bedienen von Maschinen', chapter.heading)
				section1 = chapter.sections.first
				assert_equal('', section1.subheading)
				paragraph1 = section1.paragraphs.first
				assert_equal('Wenn auch die sedierende Wirkung des Antihistaminikums nur gering ist, dies um so mehr als es in Retard-Form angewandt wird, kann Rhinopront N die Reaktionsfähigkeit vermindern: beim Autofahren und Bedienen von Maschinen ist Vorsicht geboten.', paragraph1.text)
			end
			def test_unwanted_effects
				chapter = @fachinfo.unwanted_effects
				assert_equal('Unerwünschte Wirkungen', chapter.heading)

				section1 = chapter.sections.first
				assert_equal('', section1.subheading)
				assert_equal(1, section1.paragraphs.size)
				paragraph1 = section1.paragraphs.first
				expected = 'Je nach individueller Empfindlichkeit kann Rhinopront N folgende Nebenwirkungen verursachen:'
				assert_equal(expected, paragraph1.text)

				section2 = chapter.sections.at(1)
				assert_equal("Störungen des Blut- und Lymphsystems\n", section2.subheading)
				assert_equal(0, section2.paragraphs.size)
				section3 = chapter.sections.at(2)
				assert_equal('Sehr selten:', section3.subheading)
				paragraph1 = section3.paragraphs.first
				expected = 'Veränderungen des Blutbildes.'
				assert_equal(expected, paragraph1.text)
				section4 = chapter.sections.at(3)
				assert_equal("Augenleiden\n", section4.subheading)
				section5 = chapter.sections.at(4)
				assert_equal('Gelegentlich:',section5.subheading)
				paragraph1 = section5.paragraphs.first
				expected = 'Verschwommenes Sehen.'
				assert_equal(expected, paragraph1.text)
				section6 = chapter.sections.at(5)
				assert_equal("St\366rungen des Nervensystem\n",section6.subheading)
				section7 = chapter.sections.at(6)
				assert_equal('Häufig:',section7.subheading)
				paragraph1 = section7.paragraphs.first
				expected = "Vor\374bergehende Schl\344frigkeit (10-25%) oder eine Verminderung der Aufmerksamkeit."
				assert_equal(expected, paragraph1.text)
				section8 = chapter.sections.at(7)
				assert_equal("Gastrointestinale St\366rungen\n",section8.subheading)
				section9 = chapter.sections.at(8)
				assert_equal('Gelegentlich:',section9.subheading)
				paragraph1 = section9.paragraphs.first
				expected = "Mundtrockenheit."
				assert_equal(expected, paragraph1.text)

				section10 = chapter.sections.at(9)
				assert_equal("Haut\n",section10.subheading)
				section11 = chapter.sections.at(10)
				assert_equal("Ausnahmsweise:",section11.subheading)
				paragraph1 = section11.paragraphs.first
				expected = "Rash."
				assert_equal(expected, paragraph1.text)
				section12 = chapter.sections.at(11)
				assert_equal("St\366rungen des muskuloskelettalen Systems\n", section12.subheading)
				assert_equal(expected, paragraph1.text)
				sectionlast = chapter.sections.last
				assert_equal('Vereinzelt:', sectionlast.subheading)
				paragraph1 = sectionlast.paragraphs.first
				expected = 'Knochenmarkdepression.'
				assert_equal(expected, paragraph1.text)
				#paragraph2 = section2.paragraphs.first
				#expected = ''
				#assert_equal(expected, paragraph2.text)
			end
			def test_overdose
				chapter = @fachinfo.overdose
				assert_equal('Überdosierung',chapter.heading)
				section1 = chapter.sections.first
				assert_equal("Symptome in Zusammenhang mit Chlorphenamin\n", section1.subheading)
				paragraph1 = section1.paragraphs.first
				expected = 'Stimulierung (Kinder) oder Dämpfung (Erwachsene) des ZNS.'
				assert_equal(expected, paragraph1.text)
				section2 = chapter.sections.at(1)
				assert_equal("Symptome in Zusammenhang mit Phenylephrin\n", section2.subheading)
				paragraph1 = section2.paragraphs.first
				expected = 'Hohe Hypertonie und Bradykardie.'
				assert_equal(expected, paragraph1.text)
				section3 = chapter.sections.at(2)
				assert_equal("Behandlung:", section3.subheading)
				paragraph1 = section3.paragraphs.first
				expected = 'Symptomatisch.'
				assert_equal(expected, paragraph1.text)
			end
			def test_effects
				chapter = @fachinfo.effects
				assert_equal('Eigenschaften/Wirkungen',chapter.heading)
				section1 = chapter.sections.first
				assert_equal('', section1.subheading)
				paragraph1 = section1.paragraphs.first
				expected = 'ATC-Code: R01BA53'
				assert_equal(expected, paragraph1.text)
				section2 = chapter.sections.at(1)
				assert_equal("Wirkungsmechanismus\n", section2.subheading)
				paragraph1 = section2.paragraphs.first
				expected = 'Rhinopront N vereinigt die Wirkung von:'
				assert_equal(expected, paragraph1.text)
				paragraph2 = section2.paragraphs.at(1)
				expected = 'einem Antihistaminikum, Chlorphenaminmaleat. Es ist gut verträglich und bringt rasche Linderung der lästigen Erscheinungen des Schnupfens wie Nasenrinnen, Niesen, Kribbeln und Tränenfluss;'
				assert_equal(expected, paragraph2.text)
				paragraph3 = section2.paragraphs.at(2)
				expected = "einem Vasokonstriktor, Phenylephrinhydrochlorid, der abschwellend auf entz\374ndete Nasenschleimhaut wirkt, die verstopften Naseng\344nge befreit und dadurch die Atmung erleichtert."
				assert_equal(expected, paragraph3.text)
				paragraph4 = section2.paragraphs.at(3)
				expected = "Die 10-12 Stunden anhaltende Langzeitwirkung von Rhinopront N beruht auf der Dialyse der Wirkstoffe (Diffucap\256), welche in den Hunderten von Mikrogranula jeder Kapsel enthalten sind. Somit verschafft eine Kapsel, morgens beim Aufstehen eingenommen, eine w\344hrend des ganzen Tages gleichm\344ssig anhaltende Erleichterung; eine zweite, vor dem Schlafengehen, gew\344hrleistet eine ungest\366rte Nachtruhe und am n\344chsten Morgen ein Aufwachen ohne Verstopfung der Nase."
				assert_equal(expected, paragraph4.text)
			end
			def test_kinetic
				chapter = @fachinfo.kinetic
				assert_equal('Pharmakokinetik',chapter.heading)
				section1 = chapter.sections.first
				assert_equal("Absorption, Distribution, Metabolismus, Elimination\n", section1.subheading)
				paragraph1 = section1.paragraphs.first
				expected = "Chlorphenamin wird nach oraler Verabreichung gut resorbiert und w\344hrend seiner Resorption durch die gastrointestinale Schleimhaut und in der Leber (First-pass-Effekt) metabolisiert. Es erscheint nach 30-60 Min. im Plasma, wobei die maximale Plasmakonzentration nach 2-6 Std. erreicht wird. Es geht in den Speichel \374ber. Die Ausscheidung erfolgt haupts\344chlich \374ber die Nieren."
				assert_equal(expected, paragraph1.text)
				paragraph2 = section1.paragraphs.at(1)
				expected = 'Phenylephrin wird unregelmässig aus dem Magen-Darm-Trakt resorbiert und bewirkt nach 15-20 Min. ein Abschwellen der Nasenschleimhäute, das 2-4 Std. anhält. Es wird über die MAO in der Leber und im Darm rasch metabolisiert. Einzelheiten über die Verteilung in der Muttermilch und die Ausscheidung sind nicht bekannt.'
				assert_equal(expected, paragraph2.text)
			end
			def test_preclinic
				chapter = @fachinfo.preclinic
				assert_equal('Präklinische Daten', chapter.heading)

				section1 = chapter.sections.first
				assert_equal('', section1.subheading)
				assert_equal(1, section1.paragraphs.size)
				paragraph1 = section1.paragraphs.first
				expected = 'Es sind keine für die Anwendung relevanten präklinischen Daten der im Arzneimittel enthaltenen Wirkstoffkombination vorhanden.'
				assert_equal(expected, paragraph1.text)
			end
			def test_other_advice
				chapter = @fachinfo.other_advice
				assert_equal('Sonstige Hinweise', chapter.heading)

				section1 = chapter.sections.first
				assert_equal("Haltbarkeit\n", section1.subheading)
				assert_equal(1, section1.paragraphs.size)
				paragraph1 = section1.paragraphs.first
				expected = 'Verfalldatum auf der Packung beachten.'
				assert_equal(expected, paragraph1.text)


				section2 = chapter.sections.last
				assert_equal("Besondere Lagerungshinweise\n", section2.subheading)
				assert_equal(1, section2.paragraphs.size)
				paragraph2 = section2.paragraphs.first
				expected = 'Bei Raumtemperatur (15-25 °C) und vor Licht geschützt aufbewahren.'
				assert_equal(expected, paragraph2.text)
			end
			def test_iksnrs
				chapter = @fachinfo.iksnrs
				assert_equal('Zulassungsvermerk', chapter.heading)
				section1 = chapter.sections.first
				assert_equal('', section1.subheading)
				assert_equal(1, section1.paragraphs.size)
				paragraph1 = section1.paragraphs.first
				expected = '57183 (Swissmedic).'
				assert_equal(expected, paragraph1.text)
			end
			def test_registration_owner
				chapter = @fachinfo.registration_owner
				assert_equal('Zulassungsinhaberin', chapter.heading)
				section1 = chapter.sections.first
				assert_equal('', section1.subheading)
				paragraph1 = section1.paragraphs.first
				expected = 'Pfizer AG, Zürich.'
				assert_equal(expected, paragraph1.text)
			end
			def test_date
				chapter = @fachinfo.date
				assert_equal('Stand der Information', chapter.heading)
				section1 = chapter.sections.first
				assert_equal('', section1.subheading)
				paragraph1 = section1.paragraphs.first
				expected = 'Oktober 2003.'
				assert_equal(expected, paragraph1.text)
				paragraph2 = section1.paragraphs.at(1)
				paragraph3 = section1.paragraphs.at(2)
				assert_equal(nil, paragraph3)
			end
			def test_format
				writer = FachinfoPDFWriter.new
				chapter = Text::Chapter.new	
				section = chapter.next_section
				paragraph = section.next_paragraph
				writer.instance_variable_set('@chapter', chapter)
				writer.instance_variable_set('@section', section)
				writer.instance_variable_set('@paragraph', paragraph)
				font = YAML.load <<-EOS
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  !ruby/sym subtype: "/TrueType"
  !ruby/sym widths: 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "0"
    - "278"
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  !ruby/sym basefont: "/JEMPEI+Arial"
  !ruby/sym lastchar: "252"
  !ruby/sym fontdescriptor: 199 0 R
  !ruby/sym encoding: "/WinAnsiEncoding"
  !ruby/sym firstchar: "32"
  !ruby/sym type: "/Font"
oid: 200
src: "200 0 obj\r<< \r/Type /Font \r/Subtype /TrueType \r/FirstChar 32 \r/LastChar 252 \r/Widths [ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 \r556 556 556 556 0 278 278 0 0 0 0 0 667 667 722 722 667 611 778 \r722 278 500 667 556 833 722 778 667 0 722 667 611 722 667 944 0 \r0 611 0 0 0 0 0 0 556 556 500 556 556 278 556 556 222 222 500 222 \r833 556 556 556 0 333 500 278 556 500 722 500 500 500 0 0 0 0 0 \r0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 \r0 0 0 0 0 0 0 0 0 0 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 \r0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 \r722 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 \r0 0 0 556 ] \r/Encoding /WinAnsiEncoding \r/BaseFont /JEMPEI+Arial \r/FontDescriptor 199 0 R \r>> \rendobj\r"
target_encoding: latin1
				EOS
				writer.new_font(font)
				writer.send_flowing_data("Normaler ")
				writer.send_flowing_data("text ")
				font = YAML.load <<-EOS
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  !ruby/sym subtype: "/TrueType"
  !ruby/sym widths: 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "278"
    - "333"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "0"
    - "778"
    - "722"
    - "0"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "0"
    - "667"
    - "0"
    - "722"
    - "667"
    - "0"
    - "0"
    - "667"
    - "944"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "0"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "0"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  !ruby/sym basefont: "/JENBGD+Arial,Italic"
  !ruby/sym lastchar: "246"
  !ruby/sym fontdescriptor: 208 0 R
  !ruby/sym encoding: "/WinAnsiEncoding"
  !ruby/sym firstchar: "32"
  !ruby/sym type: "/Font"
oid: 207
src: "207 0 obj\r<< \r/Type /Font \r/Subtype /TrueType \r/FirstChar 32 \r/LastChar 246 \r/Widths [ 278 0 0 0 0 0 0 0 0 0 0 0 278 333 0 0 0 556 556 0 0 0 0 0 0 0 278 \r0 0 0 0 0 0 667 667 722 722 667 0 778 722 0 500 667 556 833 722 \r0 667 0 722 667 0 0 667 944 0 0 611 0 0 0 0 0 0 556 556 500 556 \r556 278 556 556 222 0 500 222 833 556 556 556 0 333 500 278 556 \r500 722 0 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 \r0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 \r0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 \r0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 \r0 0 0 0 0 556 ] \r/Encoding /WinAnsiEncoding \r/BaseFont /JENBGD+Arial,Italic \r/FontDescriptor 208 0 R \r>> \rendobj\r"
target_encoding: latin1
				EOS
				writer.new_font(font)
				writer.send_flowing_data("ich bin ")
				writer.send_flowing_data("kursiv ")
				font = YAML.load <<-EOS
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  !ruby/sym subtype: "/TrueType"
  !ruby/sym widths: 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "0"
    - "278"
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  !ruby/sym basefont: "/JEMPEI+Arial"
  !ruby/sym lastchar: "252"
  !ruby/sym fontdescriptor: 199 0 R
  !ruby/sym encoding: "/WinAnsiEncoding"
  !ruby/sym firstchar: "32"
  !ruby/sym type: "/Font"
oid: 200
src: "200 0 obj\r<< \r/Type /Font \r/Subtype /TrueType \r/FirstChar 32 \r/LastChar 252 \r/Widths [ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 \r556 556 556 556 0 278 278 0 0 0 0 0 667 667 722 722 667 611 778 \r722 278 500 667 556 833 722 778 667 0 722 667 611 722 667 944 0 \r0 611 0 0 0 0 0 0 556 556 500 556 556 278 556 556 222 222 500 222 \r833 556 556 556 0 333 500 278 556 500 722 500 500 500 0 0 0 0 0 \r0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 \r0 0 0 0 0 0 0 0 0 0 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 \r0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 \r722 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 \r0 0 0 556 ] \r/Encoding /WinAnsiEncoding \r/BaseFont /JEMPEI+Arial \r/FontDescriptor 199 0 R \r>> \rendobj\r"
target_encoding: latin1
				EOS
				writer.new_font(font)
				writer.send_flowing_data("wieder normaler text ")
				writer.send_paragraph
				section1 = chapter.sections.first
				assert_equal(section, section1)
				assert_equal('', section1.subheading)
				paragraph1 = section1.paragraphs.first
				assert_equal(3, paragraph1.formats.size)
				assert_equal([:italic], paragraph1.formats.at(1).values)
				expected = 'Normaler text ich bin kursiv wieder normaler text'	
				assert_equal(expected, paragraph1.text)
			end
		end
		class TestFachinfoPDFWriterPre < Test::Unit::TestCase
			def setup
				@writer = FachinfoPDFWriter.new
				path = File.expand_path('../test/data/method_calls_pre.rb',File.dirname(__FILE__))
				eval(File.read(path))
				@fachinfo = @writer.to_fachinfo
			end
			def test_unwanted_effects_pre
				chapter = @fachinfo.unwanted_effects
				assert_equal('Unerwünschte Wirkungen', chapter.heading)
				section1 = chapter.sections.first
				assert_equal("Erfahrungen aus klinischen Studien\n", section1.subheading)
				#assert_equal(1, section1.paragraphs.size)
				paragraph1 = section1.paragraphs.first
				expected = 'In den beiden massgebenden Studien erhielten die Patienten Herceptin entweder als Monotherapie oder in Kombination mit Paclitaxel. Nebenwirkungen sind bei ungefähr 50% der Patienten zu erwarten. Am häufigsten wurden infusionsbedingte Symptome wie Fieber und Schüttelfrost beobachtet, meist im Anschluss an die erste Infusion von Herceptin.'
				assert_equal(expected, paragraph1.text)
				paragraph2 = section1.paragraphs.at(1)
				expected = 'Folgende unerwünschte Wirkungen wurden beobachtet:'
				assert_equal(expected, paragraph2.text)
				section2 = chapter.sections.at(1)
				assert_equal("Tabelle 1\n", section2.subheading)
				paragraph1 = section2.paragraphs.first
				#space wird beötigt! nicht löschen!
				expected = "Nebenwirkungen, die bei \2635% der Patienten oder in der randomisierten Studie in erhöhter Inzidenz bei der Behandlungsgruppe mit Herceptin auftraten (Anteil der Patienten in %)"
				assert_equal(expected, paragraph1.text)
				assert_equal(3, paragraph1.formats.size)
				assert_equal([:symbol], paragraph1.formats.at(1).values)
				paragraph2 = section2.paragraphs.at(1)
				expected = <<-'EOS'
---------------------------------------------------- 
             Mono-   Hercep-  Pacli-  Herce-  AC*    
             the-    tin +    taxel   ptin    allein 
             rapie   Pacli-   allein  + AC*          
                     taxel                           
             n= 352  n= 91    n= 95   n= 143  n= 135 
---------------------------------------------------- 
Blut und Lymphsystem                                 
Anämie       4       14       9       36      26     
Leuko-       3       24       17      52      34     
 penie                                               
----------------------------------------------------
Stoffwechselstörungen                                

Periphere    10      22       20      20      17     
 Ödeme                                               
Ödeme        8       10       8       11      5      
---------------------------------------------------- 
Nervensystem                                         
Schlaf-      14      25       13      29      15     
störungen                                            
Benommenheit 13      22       24      24      18     
Parästhesie  9       48       39      17      11     
Depression   6       12       13      20      12     
Periphere    2       23       16      2       2      
 Neuritis                                            
Neuropathie  1       13       5       4       4      
---------------------------------------------------- 
Herz/Kreislauf                                       
Tachykardie  5       12       4       10      5      
Chronische   7       11       1       28      7      
 Herzin-                                             
 suffizienz                                          
---------------------------------------------------- 
Atmungsorgane                                        
Vermehrtes                                           
 Husten      26      41       22      43      29     
Dyspnoe      22      27       26      42      25     
Rhinitis     14      22       5       22      16     
Pharyngitis  12      22       14      30      18     
Sinusitis    9       21       7       13      6      
---------------------------------------------------- 
Gastrointestinale Störungen                          
Übelkeit     33      51       9       76      77     
Diarrhöe     25      45       29      45      26     
Erbrechen    23      37       28      53      49     
Übelkeit     8       14       11      18      9      
 und Er-                                             
 brechen                                             
Appetit-     14      24       16      31      26     
 verlust                                             
---------------------------------------------------- 
Haut                                                 
Hautaus-     18      38       18      27      17     
 schlag                                              
Herpes       2       12       3       7       9      
 simplex                                             
Akne         2       11       3       3       <1     
---------------------------------------------------- 
Muskelskelettsystem                                  
Knochen-     7       24       18      7       7      
 schmerzen                                           
Arthralgie   6       37       21      8       9      
---------------------------------------------------- 
Nieren u. Harnwege                                   
Harnwegs-                                            
 infektionen 5       18       14      13      7      
---------------------------------------------------- 
Allgemeine Reaktionen                                
Schmerzen    47      61       62      57      42     
Asthenie     42      62       57      54      55     
Fieber       36      49       23      56      34     
Schüttel-    32      41       4       35      11     
 frost                                               
Kopf-        26      36       28      44      31     
 schmerzen                                           
Bauch-       22      34       22      23      18     

 schmerzen                                           
Rücken-      22      34       30      27      15     
 schmerzen                                           
Infektion    20      47       27      47      31     
Grippe-      10      12       5       12      6      
 ähnliches                                           
 Syndrom                                             
Versehent-   6       13       3       9       4      
 liche                                               
 Verletzung  3       8        2       4       2      
Allergische                                          
 Reaktion                                            
----------------------------------------------------
				EOS
				expected = <<-'EOS'
----------------------------------------------------
             Mono-   Hercep-  Pacli-  Herce-  AC*
             the-    tin +    taxel   ptin    allein
             rapie   Pacli-   allein  + AC*
                     taxel
             n= 352  n= 91    n= 95   n= 143  n= 135
----------------------------------------------------
Blut und Lymphsystem
Anämie       4       14       9       36      26
Leuko-       3       24       17      52      34
 penie
----------------------------------------------------
Stoffwechselstörungen

Periphere    10      22       20      20      17
 Ödeme
Ödeme        8       10       8       11      5
----------------------------------------------------
Nervensystem
Schlaf-      14      25       13      29      15
störungen
Benommenheit 13      22       24      24      18
Parästhesie  9       48       39      17      11
Depression   6       12       13      20      12
Periphere    2       23       16      2       2
 Neuritis
Neuropathie  1       13       5       4       4
----------------------------------------------------
Herz/Kreislauf
Tachykardie  5       12       4       10      5
Chronische   7       11       1       28      7
 Herzin-
 suffizienz
----------------------------------------------------
Atmungsorgane
Vermehrtes
 Husten      26      41       22      43      29
Dyspnoe      22      27       26      42      25
Rhinitis     14      22       5       22      16
Pharyngitis  12      22       14      30      18
Sinusitis    9       21       7       13      6
----------------------------------------------------
Gastrointestinale Störungen
Übelkeit     33      51       9       76      77
Diarrhöe     25      45       29      45      26
Erbrechen    23      37       28      53      49
Übelkeit     8       14       11      18      9
 und Er-
 brechen
Appetit-     14      24       16      31      26
 verlust
----------------------------------------------------
Haut
Hautaus-     18      38       18      27      17
 schlag
Herpes       2       12       3       7       9
 simplex
Akne         2       11       3       3       <1
----------------------------------------------------
Muskelskelettsystem
Knochen-     7       24       18      7       7
 schmerzen
Arthralgie   6       37       21      8       9
----------------------------------------------------
Nieren u. Harnwege
Harnwegs-
 infektionen 5       18       14      13      7
----------------------------------------------------
Allgemeine Reaktionen
Schmerzen    47      61       62      57      42
Asthenie     42      62       57      54      55
Fieber       36      49       23      56      34
Schüttel-    32      41       4       35      11
 frost
Kopf-        26      36       28      44      31
 schmerzen
Bauch-       22      34       22      23      18

 schmerzen
Rücken-      22      34       30      27      15
 schmerzen
Infektion    20      47       27      47      31
Grippe-      10      12       5       12      6
 ähnliches
 Syndrom
Versehent-   6       13       3       9       4
 liche
 Verletzung  3       8        2       4       2
Allergische
 Reaktion
----------------------------------------------------

				EOS
				result = paragraph2.text.split(/\n/)
				expected.split(/\n/).each_with_index { |line, idx|
					assert_equal(line.rstrip, result.at(idx).rstrip)
				}
			end
		end
		class TestFachinfoPDFWriterCetrin < Test::Unit::TestCase
			def setup
				@writer = FachinfoPDFWriter.new
				path = File.expand_path('../test/data/method_calls_certin.rb',File.dirname(__FILE__))
				eval(File.read(path))
				@fachinfo = @writer.to_fachinfo
			end
			def test_usage_certin
				chapter = @fachinfo.usage
				result = chapter.sections[2].subheading
				assert_equal("Kinder von 6-12 Jahren:", result)
				assert_equal("Saisonale Rhinitis, allergische Konjunktivitis: w\344hrend maximal 4 Wochen 1-mal t\344glich 1 Filmtablette oder 2-mal t\344glich \275 Filmtablette.", chapter.sections[2].paragraphs.first.text)
			end
		end
		class TestFachinfoPDFWriterVelcade < Test::Unit::TestCase
			def setup
				@writer = FachinfoPDFWriter.new
				path = File.expand_path('../test/data/method_calls_velcade.rb',
					File.dirname(__FILE__))
				eval(File.read(path))
				@fachinfo = @writer.to_fachinfo
			end
			def test_valid_until_velcade
				chapter = @fachinfo.date
				assert_equal(1, chapter.sections.size, chapter)
				section = chapter.sections.first
				assert_equal(1, section.paragraphs.size, section)
				assert_equal("Juni 2004.", section.to_s)
			end
		end
		class TestFachinfoPDFWriterFursol < Test::Unit::TestCase
			def setup
				@writer = FachinfoPDFWriter.new
				path = File.expand_path('../test/data/method_calls_fursol.rb',
					File.dirname(__FILE__))
				eval(File.read(path))
				@fachinfo = @writer.to_fachinfo
			end
			def test_valid_until_fursol
				chapter = @fachinfo.date
				assert_equal(1, chapter.sections.size, chapter.inspect)
				section = chapter.sections.first
				assert_equal(1, section.paragraphs.size, section.inspect)
				assert_equal("Dezember 2003.", section.to_s)
			end
			def test_no_page_numbers
				@fachinfo.each_chapter { |chapter|
					ch_str = chapter.to_s
					assert_nil(/seite \d+/i.match(ch_str), ch_str)
					assert_nil(/.*kompendium.*/i.match(ch_str), ch_str)
				}
			end
			def test_correct_chapters
				assert_equal("AMZV 9.11.2001", @fachinfo.amzv.heading)
				assert_equal("Zusammensetzung", @fachinfo.composition.heading)
				assert_equal("Galenische Form und Wirkstoffmenge pro Einheit",
					@fachinfo.galenic_form.heading)
				assert_equal("Indikationen/Anwendungsmöglichkeiten", 
					@fachinfo.indications.heading)
				assert_equal("Dosierung/Anwendung", @fachinfo.usage.heading)
				assert_equal("Kontraindikationen", 
					@fachinfo.contra_indications.heading)
				assert_equal("Warnhinweise und Vorsichtsmassnahmen", 
					@fachinfo.restrictions.heading)
				assert_equal("Interaktionen", @fachinfo.interactions.heading)
				assert_equal("Schwangerschaft/Stillzeit", 
					@fachinfo.pregnancy.heading)
				assert_equal("Wirkung auf die Fahrtüchtigkeit und auf das Bedienen von Maschinen", 
					@fachinfo.driving_ability.heading)
				assert_equal("Unerwünschte Wirkungen", 
					@fachinfo.unwanted_effects.heading)
				assert_equal("Überdosierung", @fachinfo.overdose.heading)
				assert_equal("Eigenschaften/Wirkungen", 
					@fachinfo.effects.heading)
				assert_equal("Pharmakokinetik", @fachinfo.kinetic.heading)
				assert_equal("Präklinische Daten", @fachinfo.preclinic.heading)
				assert_equal("Sonstige Hinweise", 
					@fachinfo.other_advice.heading)
				assert_equal("Zulassungsvermerk", @fachinfo.iksnrs.heading)
				assert_equal("Zulassungsinhaberin", 
					@fachinfo.registration_owner.heading)
				assert_equal("Stand der Information", @fachinfo.date.heading)
			end
			def test_linebreaks
				chapter = @fachinfo.indications
				assert_equal(2, chapter.sections.size)
				section = chapter.sections.first
				assert_equal(4, section.paragraphs.size)
				section = chapter.sections.last
				assert_equal(8, section.paragraphs.size)
			end
		end
		class TestFachinfoPDFWriterFursolFr < Test::Unit::TestCase
			def setup
				@writer = FachinfoPDFWriter.new
				path = File.expand_path('../test/data/method_calls_fursol_fr.rb',
					File.dirname(__FILE__))
				eval(File.read(path))
				@fachinfo = @writer.to_fachinfo
			end
			def test_no_page_numbers
				@fachinfo.each_chapter { |chapter|
					ch_str = chapter.to_s
					assert_nil(/page \d+/i.match(ch_str), ch_str)
					assert_nil(/.*compendium.*/i.match(ch_str), ch_str)
				}
			end
		end
		class TestFachinfoPDFWriterTrileptal < Test::Unit::TestCase
			def setup
				@writer = FachinfoPDFWriter.new
				path = File.expand_path('../test/data/method_calls_trileptal.rb',
					File.dirname(__FILE__))
				eval(File.read(path))
				@fachinfo = @writer.to_fachinfo
			end
			def test_galenic_form
				assert_equal("Trileptal\256", @fachinfo.name)
				chapter = @fachinfo.galenic_form
				assert_equal('', chapter.heading)
				assert_equal(1, chapter.sections.size)
				section = chapter.sections.first
				assert_equal("Antiepileptikum\n", section.subheading)
			end
		end
	end
end
