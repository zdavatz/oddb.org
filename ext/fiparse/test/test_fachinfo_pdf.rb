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
				assert_equal('Relative Kontraindikationen', section1.subheading)
				assert_equal(2, section1.paragraphs.size)
				paragraph1 = section1.paragraphs.first
				expected = 'Bei schwerer Krankheit der Koronargefässe oder stark erhöhtem Blutdruck darf Rhinopront N nur nach Rücksprache mit einem Arzt eingenommen werden.'
				assert_equal(expected, paragraph1.text)
			end
			def test_interaction
				chapter = @fachinfo.interactions
				assert_equal('Interaktionen',chapter.heading)
				section1 = chapter.sections.first
				assert_equal('', section1.subheading)
				paragraph1 = section1.paragraphs.first
				expected = 'MAO-Hemmer und trizyklische Antidepressiva verstärken den Vasokonstriktoreffekt des Phenylephrins. Antihistaminika verstärken die  Sedativa, Analgetika, Hypnotika). Beruhigungsmitteln (z.B. Barbiturate,Wirkung von Alkohol und von zentralwirkenden'
				assert_equal(expected, paragraph1.text)
			end
			def test_pregnancy
				chapter = @fachinfo.pregnancy
				assert_equal('Schwangerschaft/Stillzeit',chapter.heading)
				section1 = chapter.sections.first
				assert_equal('', section1.subheading)
				paragraph1 = section1.paragraphs.first
				expected = 'Die Sicherheit von Chlorphenamin und Phenylephrin oder ihrer Kombination während der ersten beiden Schwangerschaftstrimester wurde nicht erwiwährend der Stillzeit bergen diese Präparate das Risiko schwerer unerwünschter Wirkungen, wie z.B. esen. Im letzten Schwangerschaftstrimester und durch Chlorphenamin bewirkte Krämpfe beim Fötudiesem Stadium der Schwangerschaft kontraindiziert. s und beim Neugeborenen. Folglich sind sie in'
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
				
				section4 = chapter.sections.last
				assert_equal('Vereinzelt:', section4.subheading)
				paragraph1 = section4.paragraphs.first
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
				assert_equal('Symptome in Zusammenhang mit Chlorphenamin', section1.subheading)
				paragraph1 = section1.paragraphs.first
				expected = 'Stimulierung (Kinder) oder Dämpfung (Erwachsene) des ZNS.'
				assert_equal(expected, paragraph1.text)
				section2 = chapter.sections.at(1)
				assert_equal('Symptome in Zusammenhang mit Phenylephrin', section2.subheading)
				paragraph1 = section2.paragraphs.first
				expected = 'Hohe Hypertonie und Bradykardie.'
				assert_equal(expected, paragraph1.text)
				section3 = chapter.sections.at(2)
				assert_equal('Behandlung:', section3.subheading)
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
				assert_equal('Wirkungsmechanismus', section2.subheading)
				paragraph1 = section2.paragraphs.first
				expected = 'Rhinopront N vereinigt die Wirkung von:'
				assert_equal(expected, paragraph1.text)
				paragraph2 = section2.paragraphs.at(1)
				expected = 'einem Antihistaminikum, Chlorphenaminmaleat. Es ist gut verträglich und bringt rasche Linderung der lästigen Erscheinungen des Schnupfens wie Nasenrinnen, Niesen, Kribbeln und Tränenfluss;'
				assert_equal(expected, paragraph2.text)
				paragraph3 = section2.paragraphs.at(2)
				expected = 'einem Vasokonstriktor, Phenylephrinhydrochlorid, der abschwellend auf entzündete gänge befreit und dadurch die Atmung erleichtert. Nasenschleimhaut wirkt, die verstopften Nasen'
				assert_equal(expected, paragraph3.text)
				paragraph4 = section2.paragraphs.at(3)
				expected = 'Die 10-12 Stunden anhaltende Langzeitwirkung von Rhinopront N beruht auf der Dialyse der Wirkstoffe (Diffucap®), welche in den Hunderten von Mikrogranula jeder Kapsel enthalten sind. Somit verschafft eine Kapsel, morgens beim Aufstehen eingenommen, eine währgleichmässig anhaltende Erleichterung; eine zweite, vor dem Schlafengehen, gewährleistet eine end des ganzen Tages ungestörte Nachtruhe und am nächsten Morgen ein Aufwachen ohne Verstopfung der Nase.'
				assert_equal(expected, paragraph4.text)
			end
			def test_kinetic
				chapter = @fachinfo.kinetic
				assert_equal('Pharmakokinetik',chapter.heading)
				section1 = chapter.sections.first
				assert_equal('Absorption, Distribution, Metabolismus, Elimination', section1.subheading)
				paragraph1 = section1.paragraphs.first
				expected = 'Chlorphenamin wird nach oraler Verabreichung gut resorbiert und während seiner Resorption durch 30-60 Min. im Plasma, wobei die maximale Plasmakoirst-pass-Effekt) metabolisiert. Es erscheint nach die gastrointestinale Schleimhaut und in der Leber (Fnzentration nach 2-6 Std. erreicht wird. Es geht in den Speichel über. Die Ausscheidung erfolgt hauptsächlich über die Nieren.'
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
				assert_equal('Haltbarkeit', section1.subheading)
				assert_equal(1, section1.paragraphs.size)
				paragraph1 = section1.paragraphs.first
				expected = 'Verfalldatum auf der Packung beachten.'
				assert_equal(expected, paragraph1.text)


				section2 = chapter.sections.last
				assert_equal('Besondere Lagerungshinweise', section2.subheading)
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
				writer.send_flowing_data(" ich bin ")
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
				writer.new_font(font)
				section1 = chapter.sections.first
				assert_equal(section, section1)
				assert_equal('', section1.subheading)
				paragraph1 = section1.paragraphs.first
				#puts paragraph1.text[paragraph1.formats.at(1).range]
				assert_equal(3, paragraph1.formats.size)
				assert_equal([:italic], paragraph1.formats.at(1).values)
				expected = 'Normaler text ich bin kursiv wieder normaler text'	
				assert_equal(expected, paragraph1.text)
			end
		end
	end
end
