#!/usr/bin/env ruby
# AnalysisParse::TestExtendedListParser -- oddb -- 10.11.2005 -- hwyss@ywesee.com

$: << File.expand_path('../src', File.dirname(__FILE__))

require 'test/unit'
require 'extended_list_parser'

module ODDB
	module AnalysisParse
		class TestExtendedListParser < Test::Unit::TestCase
			def setup
				@parser = ExtendedListParser.new
			end
			def test_parse_line__1
				src = <<-EOS
8317.00 35 Immunglobulin IgE total, qn
				EOS
				begin
					result = @parser.parse_line(src)
				rescue AmbigousParseException	=>	e
					puts e.inspect
				end
				expected = {
				:group				=>	'8317',
				:position			=>	'00',
				:taxpoints		=>	35,
				:description	=>	'Immunglobulin IgE total, qn'
				}
				assert_equal(expected, result)
			end
			def test_parse_line__2
				src = <<-EOS
C 8272.00 30 Hämatogramm V (automatisiert): wie
Hämatogramm IV, flowzytometrische
Differenzierung der Leukozyten
Limitation: nicht mit QBC-Methode
				EOS
				begin
					result = @parser.parse_line(src)
				rescue AmbigousParseException => e
					puts e.inspect
				end
				expected = {
				:group					=>	'8272',
				:position				=>	'00',
				:revision				=>	'C',
				:taxpoints			=>	30,
				:description		=>	'Hämatogramm V (automatisiert): wie Hämatogramm IV, flowzytometrische Differenzierung der Leukozyten',
				:limitation			=>	'nicht mit QBC-Methode',
				}
				assert_equal(expected, result)
			end
			def test_parse_line__3
				src = <<-EOS
8317.01 25(1) Immunglobulin IgE - multispezifischer oder gruppenspezifischer Atopie-Screeningtest, ql/sq, ohne Unterscheidung einzelner spez. IgE
(1) analog abgestuftem Blocktarif gemäss Punkt 5.7 der Vorbemerkungen, je nach Anzahl Allergene im verwendeten Testsystem
				EOS
				begin
					result = @parser.parse_line(src)
				rescue AmbigousParseException	=> e
					puts e.inspect
				end
				expected = {
				:group				=>	'8317',
				:position			=>	'01',
				:taxpoints		=>	25,
				:description	=>	'Immunglobulin IgE - multispezifischer oder gruppenspezifischer Atopie-Screeningtest, ql/sq, ohne Unterscheidung einzelner spez. IgE',
				:taxnumber		=>	'1',
				:taxnote			=>	'analog abgestuftem Blocktarif gemäss Punkt 5.7 der Vorbemerkungen, je nach Anzahl Allergene im verwendeten Testsystem',
				}
				assert_equal(expected, result)
			end
			def test_parse_line__4
				src = <<-EOS
8317.02 45(1) Immunglobulin IgE - monospezifischer Multi-
Screeningtest, mindestens sq, mit
Unterscheidung einzelner spez. IgE (nicht 
kumulierbar mit 8317.04)
(1) analog abgestuftem Blocktarif gemäss Punkt 5.7
der Vorbemerkungen, je nach Anzahl Allergene im
verwendeten Testsystem
				EOS
				begin
					result = @parser.parse_line(src)
				rescue AmbigousParseException => e
					puts e.inspect
				end
				expected = {
				:group				=>	'8317',
				:position			=>	'02',
				:taxpoints		=>	45,
				:taxnumber		=>	'1',
				:description	=>	'Immunglobulin IgE - monospezifischer Multi-Screeningtest, mindestens sq, mit Unterscheidung einzelner spez. IgE (nicht kumulierbar mit 8317.04)',
				:taxnote			=>	'analog abgestuftem Blocktarif gemäss Punkt 5.7 der Vorbemerkungen, je nach Anzahl Allergene im verwendeten Testsystem',
				}
				assert_equal(expected, result)
			end
			def test_parse_line__5
				src = "      8572.00          9  Triglyceride\n"
				begin
					result = @parser.parse_line(src)
				rescue AmbigousParseException => e
					puts e.inspect
				end
				expected = {
					:description=>"Triglyceride", 
					:position=>"00", 
					:taxpoints=>9, 
					:group=>"8572"
				}
				assert_equal(expected, result)
			end
			def test_parse_line__6
				src = <<-EOS
9356.30 * 25 Spezielle Mikroskopie (Acridineorange, 
Ziehl-Neelsen, Auramin Phasenkontrast etc., KOH, Pilze)
				EOS
				begin
					result = @parser.parse_line(src)
				end
				expected = {
				:group					=>	'9356',
				:anonymous			=>	true,
				:position				=>	'30',
				:taxpoints			=>	25,
				:description		=>	'Spezielle Mikroskopie (Acridineorange, Ziehl-Neelsen, Auramin Phasenkontrast etc., KOH, Pilze)',
				}
				assert_equal(expected, result)
			end
			def test_parse_line__7
				src = <<-EOS
S 9710.00 8 Blutentnahme, Kapillarblut oder Venenpunktion, nur anwendbar durch
ärztliches Praxislaboratorium im Rahmen
der Präsenzdiagnostik nach Artikel 54
Absatz 1 Buchstabe a KVV und Kapitel
5.1.2 der Analysenliste
Limitation: gültig ab 1.5.2004 bis 31.12.2005
				EOS
				begin
					result = @parser.parse_line(src)
				end
				expected = {
				:group				=>	'9710',
				:position			=>	'00',
				:taxpoints		=>	8,
				:revision			=>	'S',
				:description	=>	'Blutentnahme, Kapillarblut oder Venenpunktion, nur anwendbar durch ärztliches Praxislaboratorium im Rahmen der Präsenzdiagnostik nach Artikel 54 Absatz 1 Buchstabe a KVV und Kapitel 5.1.2 der Analysenliste',
				:limitation		=>	'gültig ab 1.5.2004 bis 31.12.2005',
				}
				assert_equal(expected, result)
			end
			def test_parse_footnotes__1
				src = <<-EOS
1____________________________________________________________________________
 Nur bei Kindern bis zu 6 Jahren
* anonyme Position
				EOS
				begin
					result = @parser.parse_footnotes(src)
				end
				expected = {
				'1'			=>	'Nur bei Kindern bis zu 6 Jahren',
				'*'			=>	'anonyme Position',
				}
				assert_equal(expected, result)
			end
			def test_parse_footnotes__2
				src = <<-EOS
*Anonyme Position
1  Nur für Spitäler
2 Nur für autorisierte Medizinalpersonen in Substitutions- oder Entzugsbehandlungen
3 Nur für Spitäler und Pneumologen
4 Nur für Spitäler, Pneumologen und Hämatologen
				EOS
				begin
					result = @parser.parse_footnotes(src)
				end
				expected = {
				'*'				=>	'Anonyme Position',
				'1'				=>	'Nur für Spitäler',
				'2'				=>	'Nur für autorisierte Medizinalpersonen in Substitutions- oder Entzugsbehandlungen',
				'3'				=>	'Nur für Spitäler und Pneumologen',
				'4'				=>	'Nur für Spitäler, Pneumologen und Hämatologen',
				}
				assert_equal(expected, result)
			end
			def test_parse_footnotes__3
				src = <<-EOS
___________________________
*anonyme Position
1 Whatever!
				EOS
				begin
					result = @parser.parse_footnotes(src)
				end
				expected = {
				'*'			=>	'anonyme Position',
				'1'			=>	'Whatever!',
				}
				assert_equal(expected, result)
			end
			def test_parse_page__1
				src = <<-EOS
Physikalische Medizin und Rehabilitation Rev. Pos.-Nr. A TP Bezeichnung (Liste physik. Medizin und Rehabilitation)
8388.00 20 Kristallnachweis mit polarisiertem Licht 
8600.00 25 Zellzählung, sowie Differenzierung nach Anreicherung und Färbung von Körper- flüssigkeiten

EOS
				begin
					result = @parser.parse_page(src, 95)
				end
				expected = [
					{
				:group				=>	'8388',
				:position			=>	'00',
				:taxpoints		=>	20,
				:description	=>	'Kristallnachweis mit polarisiertem Licht',
				},
					{
				:group				=>	'8600',
				:position			=>	'00',
				:taxpoints		=>	25,
				:description	=>	'Zellzählung, sowie Differenzierung nach Anreicherung und Färbung von Körperflüssigkeiten',
				}
				]
				assert_equal(expected, result)
			end
			def test_parse_page__2
				src = <<-EOS
8543.00 1 40 Theophyllin (Blut)
1_________________________________________________________________________
 Nur bei Kindern bis zu 6 Jahren
* anonyme Position
				EOS
				begin
					result = @parser.parse_page(src, 11) 
				end
				expected = [
					{
				:group				=>	'8543',
				:position			=>	'00',
				:taxpoints		=>	40,
				:description	=>	'Theophyllin (Blut)',
				:footnote			=>	'Nur bei Kindern bis zu 6 Jahren',
				}
				]
				assert_equal(expected, result)
			end
			def test_parse_page__3
				src = <<-EOS
Kinder- und Jugendmedizin
Rev. Pos.-Nr. A TP Bezeichnung (Liste Kinder- und Jugendmedizin)
1
8317.01 * 25(1) Immunglobulin IgE - multispezifischer oder gruppenspezifischer Atopie-Screeningtest, ql/sq, ohne Unterscheidung einzelner spez. IgE
(1) analog abgestuftem Blocktarif gemäss Punkt 5.7 der Vorbemerkungen, je nach Anzahl Allergene im Verwendeten Testsystem
8543.00 1 40 Theophyllin (Blut)
1____________________________________________________________________________
 Nur bei Kindern bis zu 6 Jahren
* anonyme Position
	1
				EOS
				begin
					result = @parser.parse_page(src, 1)
				end
				expected = [
					{
				:group					=>	'8317',
				:position				=>	'01',
				:taxpoints			=>	25,
				:anonymous			=>	true,
				:description		=>	'Immunglobulin IgE - multispezifischer oder gruppenspezifischer Atopie-Screeningtest, ql/sq, ohne Unterscheidung einzelner spez. IgE',
				:taxnumber			=>	'1',
				:taxnote				=>	'analog abgestuftem Blocktarif gemäss Punkt 5.7 der Vorbemerkungen, je nach Anzahl Allergene im Verwendeten Testsystem',
				},
					{
				:group					=>	'8543',
				:position				=>	'00',
				:taxpoints			=>	40,
				:description		=>	'Theophyllin (Blut)',
				:footnote				=>	'Nur bei Kindern bis zu 6 Jahren',
				}
				]
				assert_equal(expected, result)
			end
			def test_parse_page__4
				src = <<-EOS
8249.00 9 Gamma-Glutamyltranspeptidase (GGT)
8265.00 1 30 Glykiertes Hämoglobin (HbA1c)
C 8268.00 12 Hämatogramm I (automatisiert)
___________________
*anonyme Position
1 Nur für mich

12

				EOS
				begin
					result = @parser.parse_page(src, 12)
				end
				expected = [
					{
					:group				=>	'8249',
					:position			=>	'00',
					:taxpoints		=>	9,
					:description	=>	'Gamma-Glutamyltranspeptidase (GGT)',
				},
				{
					:group				=>	'8265',
					:position			=>	'00',
					:taxpoints		=>	30,
					:description	=>	'Glykiertes Hämoglobin (HbA1c)',
					:footnote			=>	'Nur für mich',
				},
				{
					:group				=>	'8268',
					:position			=>	'00',
					:revision			=>	'C',
					:taxpoints		=>	12,
					:description	=>	'Hämatogramm I (automatisiert)',
				}
				]
				assert_equal(expected, result)
			end
			def test_update_footnotes__1
				data = [
					{
				:group					=>	'8317',
				:position				=>	'00',
				:description		=>	'Immunglobulin IgE',
				:footnote				=>	'1',
				}
				]
				footnotes = {
				'1'							=>	'analog wie etwas anderes',
				}
				begin
					result = @parser.update_footnotes(data, footnotes)
				end
				expected = [
					{
				:group					=>	'8317',
				:position				=>	'00',
				:description		=>	'Immunglobulin IgE',
				:footnote				=>	'analog wie etwas anderes',
				}
				]
				assert_equal(expected, result)
			end
		end
	end
end
