#!/usr/bin/env ruby
# AnalysisParse::TestAppendixListParser -- oddb -- 10.11.2005 -- hwyss@ywesee.com

$: << File.expand_path('../src', File.dirname(__FILE__))

require 'test/unit'
require 'appendix_list_parser'

module ODDB
	module AnalysisParse
		class TestAppendixListParser < Test::Unit::TestCase
			def setup
				@parser = AppendixListParser.new
			end
			def test_parse_line__1
				src = <<-EOS
C 8001.00 18 ABO-Blutgruppen und Antigen D Bestimmung (inkl. Ausschluss schwaches D Antigen bei Rhesus D negativ) nach Empfehlungen BSD SRK "Erythrozytenserologische Unter- suchungen an Patientenproben"
				EOS
				begin
					result = @parser.parse_line(src)
				rescue AmbigousParseException	=> e
					puts e.inspect
				end
				expected = {
				:group				=>	'8001',
				:position			=>	'00',
				:taxpoints		=>	18,
				:revision			=>	'C',
				:description	=>	'ABO-Blutgruppen und Antigen D Bestimmung (inkl. Ausschluss schwaches D Antigen bei Rhesus D negativ) nach Empfehlungen BSD SRK "Erythrozytenserologische Untersuchungen an Patientenproben"',
				}
				assert_equal(expected, result)
			end
			def test_parse_line__2
				src =<<-EOS
8017.00 * 45 Alpha-1-Fetoprotein (AFP)
				EOS
				begin
					result = @parser.parse_line(src)
				rescue AmbigousParseException	=>	e
					puts e.inspect
				end
				expected = {
				:group				=>	'8017',
				:position			=>	'00',
				:taxpoints		=>	45,
				:description	=>	'Alpha-1-Fetoprotein (AFP)',
				:anonymous		=>	true
				}
				assert_equal(expected, result)
			end
			def test_parse_line__3
				src = <<-EOS
8606.00 30 Guthrie-Test
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
			def test_parse_line__4
				src = <<-EOS
C 8269.00 15 Hämatogramm II (automatisiert): Hämatogramm I, plus Thrombozyten 
Limitation: nicht mit QBC-Methode
				EOS
				src = "C 8269.00 15 H\344matogramm II (automatisiert): H\344matogramm I, plus Thrombozyten Limitation: nicht mit QBC-Methode\n"
				begin
					result = @parser.parse_line(src)
				rescue AmbigousParseException	=> e
					puts e.inspect
				end
				expected = {
				:group				=>	'8269',
				:position			=>	'00',
				:taxpoints		=>	15,
				:revision			=>	'C',
				:description	=>	'Hämatogramm II (automatisiert): Hämatogramm I, plus Thrombozyten',
				:limitation		=>	'nicht mit QBC-Methode',
				}
				assert_equal(expected, result)
			end
			def test_parse_page__1
				src = <<-EOS
5.3 Anhang C: Von Hebammen veranlasste Analysen (Art. 62 Abs. 1 Bst. c KVV)
Bemerkungen
Hebammen haben mit der Durchführung der Analysen dieser Liste die Laboratorien gemäss Artikel 54 Absatz 3 KVV zu betrauen.
Liste der Analysen
Rev. Pos.-Nr. A TP Bezeichnung (Liste Hebammen)
C 8001.00 18 ABO-Blutgruppen und Antigen D Bestimmung (inkl. Ausschluss schwaches D Antigen bei Rhesus D negativ) nach Empfehlungen BSD SRK "Erythrozytenserologische Unter- suchungen an Patientenproben"
8017.00 * 45 Alpha-1-Fetoprotein (AFP)
C 8200.00 35 Erythrozyten-Alloantikörper, Suchtest nach Empfehlungen BSD SRK "Erythrozyten- serologische Untersuchungen an Patienten- proben"
C 8269.00 15 Hämatogramm II (automatisiert): Hämatogramm I, plus Thrombozyten Limitation: nicht mit QBC-Methode
8580.00 4 Urin-Teilstatus (5-10 Parameter)
8606.00 30 Guthrie-Test
9108.01 35 Hepatitis-B-Virus-HBc-Antikörper (IG), ql
9108.40 35 Hepatitis-B-Virus-HBs-Antigennachweis EIA/RIA, ql
9116.40 * 12 HIV 1+2 -Antikörper (Screening) Schnelltest, ql
9132.01 35 Rubellavirus-Antik\uffffrper (IG oder IgG), ql
9564.81 * 20 Treponema VDRL, qn
9645.10 32 Toxoplasma gondii (Ig oder IgG)
9645.30 45 Toxoplasma gondii (IgM)

____*   _________________________________________
				 anonyme Position

				                                                                                                                     141
				EOS
				begin
					result = @parser.parse_page(src, 141)
				rescue AmbigousParseException => e
					puts e.inspect
				end
				expected_first = {
				:group					=>	'8001',
				:revision				=>	'C',
				:position				=>	'00',
				:taxpoints			=>	18,
				:description		=>	'ABO-Blutgruppen und Antigen D Bestimmung (inkl. Ausschluss schwaches D Antigen bei Rhesus D negativ) nach Empfehlungen BSD SRK "Erythrozytenserologische Untersuchungen an Patientenproben"',
				}
				expected_last = {
				:group					=>	'9645',
				:position				=>	'30',
				:taxpoints			=>	45,
				:description		=>	'Toxoplasma gondii (IgM)',
				}
				expected_size = 13
				assert_equal(expected_first, result.first)
				assert_equal(expected_last, result.last)
				assert_equal(expected_size, result.size)
			end
			def test_parse_page__2
				src = <<-EOS
trifft nur das ärztliche Praxislaboratorium.
Teilliste 1
Für diese Analysen kann für das ärztliche Praxislaboratorium der 
Taxpunktwert in Tarifverträgen festgesetzt werden, wobei die Tax-
punktzahl der Analysenliste gilt. Fehlt eine solche vertragliche
Regelung, so gilt der Taxpunktwert der Analysenliste.
Rev. Pos.-Nr. A TP Bezeichnung (Liste Grundversorgung, Teilliste 1)
8259.00 9 Glukose, im Blut/Plasma/Serum
C 8273.00 7 Hämatokrit, manuelle Bestimmung, kumu-
lierbar mit 8210.00 Erythrozyten-Zählung, 8275.00 Hämoglobin, 8406.00 Leukozyten-
Zählung und 8560.00 Thrombozyten-
Zählung bis max. Taxpunktzahl 15
(Hämatogramm II)
Limitation: nicht mit QBC-Methode
C 8275.00 7 Hämoglobin, manuelle Bestimmung,
kumulierbar mit 8210.00 Erythrozyten-
Zählung, 8273.00 Hämatokrit, 8406.00
Leukozyten-Zählung und 8560.00
Thrombozyten-Zählung bis max. Tax-
punktzahl 15 (Hämatogramm II)
Limitation: nicht mit QBC-Methode
8387.00 9 Kreatinin, im Blut/Plasma/Serum
C 8406.00 9 Leukozyten-Zählung, manuelle Bestimmung,
kumulierbar mit 8210.00 Erythrozyten-
Zählung, 8273.00 Hämatokrit, 8275.00
Hämoglobin und 8560.00 Thrombozyten-
Zählung bis max. Taxpunktzahl 15
(Hämatogramm II)
Limitation: nicht mit QBC-Methode
8517.00 12 Sediment: mikroskopische Untersuchung
8519.00 6 Senkungsreaktion, exkl. Blutentnahme
8548.00 14 Thromboplastinzeit nach Quick
 127
EOS
				begin
					result = @parser.parse_page(src, 127)
				end
				expected_first = {
				:group					=> '8259',
				:position				=> '00',
				:taxpoints			=> 9,
				:description		=> 'Glukose, im Blut/Plasma/Serum',
				}
				expected_last = {
				:group					=> '8548',
				:position				=> '00',
				:taxpoints			=> 14,
				:description		=> 'Thromboplastinzeit nach Quick',
				}
				expected_size = 8
				assert_equal(expected_first, result.first)
				assert_equal(expected_last, result.last)
				assert_equal(expected_size, result.size)
			end
		end
	end
end
