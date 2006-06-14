#!/usr/bin/env ruby
# AnalysisParse::TestSimpleListParser -- oddb -- 10.11.2005 -- hwyss@ywesee.com

$: << File.expand_path('../src', File.dirname(__FILE__))

require 'test/unit'
require 'simple_list_parser'

module ODDB
	module AnalysisParse
		class TestSimpleListParser < Test::Unit::TestCase
			def setup
				@parser = SimpleListParser.new
			end
			def test_parse_line__1
				src = <<-EOS
          8606.00    30  Guthrie-Test
				EOS
				begin
					result = @parser.parse_line(src)
				end
				expected = {
				:group				=>	'8606',
				:position			=>	'00',
				:taxpoints		=>	30,
				:description	=>	'Guthrie-Test',
				}
				assert_equal(expected, result)
end
			def test_parse_line__2
				src = <<-EOS
				     9700.00    12  Bearbeitungstaxe für Auftragnehmer von externen Aufträgen, pro Patient und Auftrag; nur anwendbar durch Spitallaboratorien nach Artikel 54 Absatz 1 Buchstabe c und Absatz 2 KVV, durch Laboratorien nach Artikel 54 Absatz 3 KVV und durch die Offizin eines Apothekers oder einer Apothekerin nach Artikel 54 Absatz 1 Buchstabe c KVV
				EOS
				begin
					result = @parser.parse_line(src)
				rescue AmbigousParseException => e
					puts e.inspect
				end
				expected = {
					:group				=>	'9700',
					:position			=>	'00',
					:taxpoints		=>	12,
					:description	=>	'Bearbeitungstaxe für Auftragnehmer von externen Aufträgen, pro Patient und Auftrag; nur anwendbar durch Spitallaboratorien nach Artikel 54 Absatz 1 Buchstabe c und Absatz 2 KVV, durch Laboratorien nach Artikel 54 Absatz 3 KVV und durch die Offizin eines Apothekers oder einer Apothekerin nach Artikel 54 Absatz 1 Buchstabe c KVV'
				}
				assert_equal(expected, result)
			end
			def test_parse_page__1
				src = <<-EOS
4.Kapitel:  Übrige
	
	4.1 Allgemeine Positionen
	
	Bemerkungen
	
	Diese allgemeinen Positionen dürfen nur bei ambulanter Behand-
	lung angewendet werden, bei stationärer Behandlung sind die
	Analysen grundsätzlich in der Pauschale inbegriffen (Art. 49 KVG).
	Im ärztlichen Praxislaboratorium dürfen diese allgemeinen Positio-
	nen nicht verrechnet werden.
	
	Rev.    Pos.-Nr.        TP    Bezeichnung (allgemeine Positionen)

			 9700.00    12  Bearbeitungstaxe für Auftragnehmer von
			 externen Aufträgen, pro Patient und Auftrag;
			 nur anwendbar durch Spitallaboratorien
			 nach Artikel 54 Absatz 1 Buchstabe c und
			 Absatz 2 KVV, durch Laboratorien nach
			 Artikel 54 Absatz 3 KVV und durch die
			 Offizin eines Apothekers oder einer
			 Apothekerin nach Artikel 54 Absatz 1
			 Buchstabe c KVV
						9701.00     8    Blutentnahme, Kapillarblut oder
						Venenpunktion; nur anwendbar durch
						Spitallaboratorien nach Artikel 54 Absatz 1
						Buchstabe c und Absatz 2 KVV, durch
						Laboratorien nach Artikel 54 Absatz 3 KVV
						und durch die Offizin eines Apothekers oder
						einer Apothekerin nach Artikel 54 Absatz 1
						Buchstabe c KVV
								 9703.00    25  Zuschlag für Entnahme zu Hause, im Umkreis
								 von 3 km; nur anwendbar durch
								 Laboratorien nach Artikel 54 Absatz 3 KVV
								 9704.00     4    Zuschlag für jeden weiteren km; nur anwendbar durch Laboratorien nach Artikel 54 Absatz 3 KVV
																																																																					109 
				EOS
				begin
					result = @parser.parse_page(src,109)
				rescue AmbigousParseException => e
					puts e.inspect
				end
				expected_first = {
					:group				=>	'9700',
					:position			=>	'00',
					:taxpoints		=>	12,
					:description	=>	'Bearbeitungstaxe für Auftragnehmer von externen Aufträgen, pro Patient und Auftrag; nur anwendbar durch Spitallaboratorien nach Artikel 54 Absatz 1 Buchstabe c und Absatz 2 KVV, durch Laboratorien nach Artikel 54 Absatz 3 KVV und durch die Offizin eines Apothekers oder einer Apothekerin nach Artikel 54 Absatz 1 Buchstabe c KVV',
				}
				expected_last = {
					:group				=>	'9704',
					:position			=>	'00',
					:taxpoints		=>	4,
					:description	=>	'Zuschlag für jeden weiteren km; nur anwendbar durch Laboratorien nach Artikel 54 Absatz 3 KVV',
				}
				expected_size = 4
				assert_equal(expected_size, result.size)
				assert_equal(expected_first, result.first)
				assert_equal(expected_last, result.last)
			end
		end
	end
end
