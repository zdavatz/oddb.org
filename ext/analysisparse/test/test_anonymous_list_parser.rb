#!/usr/bin/env ruby
# AnalysisParse::TestAnonymousListParser -- oddb -- 10.11.2005 -- hwyss@ywesee.com

$: << File.expand_path('../src', File.dirname(__FILE__))

require 'test/unit'
require 'anonymous_list_parser'

module ODDB
	module AnalysisParse
		class TestAnonymousListParser < Test::Unit::TestCase
			def setup
				@parser = AnonymousListParser.new
			end
			def test_parse_line__1
				src = <<-EOS
		 8531.00    50 Sqamous Cell Carcinoma (SCC).....?   9800.22
				EOS
				begin
					result = @parser.parse_line(src)
				end
				expected = {
					:code							=>	'8531.00',
					:group						=>	'8531',
					:position					=>	'00',
					:taxpoints				=>	50,
					:description			=>	'Sqamous Cell Carcinoma (SCC)',
					:anonymousgroup		=>	'9800',
					:anonymouspos			=>	'22',
					:list_title				=>	nil,
					:permission				=>	nil,
					:taxpoint_type		=>	nil,
				}
				assert_equal(expected,result)
			end
			def test_parse_line__2
				src = <<-EOS
8804.00  50 Chromosomenuntersuchung, Zuschlag für Benützung von zusätzlicher Färbung (G-,Q-,R- oder C-Bänderung, Ag-NOR, hohe Auflösung, andere), pro Färbung...?   9800.22
				EOS
				begin
					result = @parser.parse_line(src)
				end
				expected = {
					:code						=>	'8804.00',
					:group					=>	'8804',
					:position				=>	'00',
					:taxpoints			=>	50,
					:description		=>	'Chromosomenuntersuchung, Zuschlag für Benützung von zusätzlicher Färbung (G-,Q-,R- oder C-Bänderung, Ag-NOR, hohe Auflösung, andere), pro Färbung',
					:anonymousgroup =>	'9800',
					:anonymouspos		=>	'22',
					:list_title			=>	nil,
					:permission			=>	nil,
					:taxpoint_type	=>	nil,

				}
				assert_equal(expected, result)
			end
			def test_parse_line__3
				src =<<-EOS
8485.00  45 Prostata spezifisches Antigen (PSA) ?   9800.20
				EOS
				begin
					result = @parser.parse_line(src)
				end
				expected = {
					:code						=>	'8485.00',
					:group					=>	'8485',
					:position				=>	'00',
					:taxpoints			=>	45,
					:description		=>	'Prostata spezifisches Antigen (PSA)',
					:anonymousgroup	=>	'9800',
					:anonymouspos		=>	'20',
					:list_title			=>	nil,
					:permission			=>	nil,
					:taxpoint_type	=>	nil,
				}
				assert_equal(expected, result)
			end
			def test_parse_line__4
				src = <<-EOS
8806.00 300 In situ-Hybridisierung an Inter- phasekernen inkl. Präparation und Analyse von 20 oder mehr Zellen..? 9800.48
				EOS
				begin
					result = @parser.parse_line(src)
				end
				expected = {
					:code						=>	'8806.00',
					:group					=>	'8806',
					:position				=>	'00',
					:taxpoints			=>	300,
					:description		=>	'In situ-Hybridisierung an Interphasekernen inkl. Präparation und Analyse von 20 oder mehr Zellen',
					:anonymousgroup	=>	'9800',
					:anonymouspos		=>	'48',
					:list_title			=>	nil,
					:permission			=>	nil,
					:taxpoint_type	=>	nil,
				}
				assert_equal(expected, result)
			end
			def test_parse_line__5
				src = <<-EOS
8477.01 70 Primidon, inkl. Phenobarbital (Blut). ? 9800.26
				EOS
				begin
					result = @parser.parse_line(src)
				end
				expected = {
					:code						=>	'8477.01',
					:group					=>	'8477',
					:position				=>	'01',
					:taxpoints			=>	70,
					:description		=>	'Primidon, inkl. Phenobarbital (Blut)',
					:anonymousgroup	=>	'9800',
					:anonymouspos		=>	'26',
					:list_title			=>	nil,
					:permission			=>	nil,
					:taxpoint_type	=>	nil,
				}
				assert_equal(expected, result)
			end
			def test_parse_line__6
				src = <<-EOS
8810.19 50 1. Krebserkrankungen, familiäre
Prädisposition; direkte oder
indirekte Mutationsanalyse bei
- hereditärem Brust- oder
Ovarialkrebs-Syndrom, Gene
BRCA1 und BRCA2
- Polyposis coli oder attenuierter
Form der Polyposis coli, Gen
APC
- hereditärem Colon-Carcinom-
Syndrom ohne Polyposis
(hereditary non polypotic colon
cancer HNPCC), Gene MLH1,
MSH2, MSH6 und PMS2
- Multiplen endokrinen Neoplasien ? 9800.22
				EOS
				begin
					result = @parser.parse_line(src)
				end
				expected = {
					:code							=>	'8810.19',
					:group						=>	'8810',
					:position					=>	'19',
					:taxpoints				=>	50,
					:description			=>	'1. Krebserkrankungen, familiäre Prädisposition; direkte oder indirekte Mutationsanalyse bei
- hereditärem Brust- oder Ovarialkrebs-Syndrom, Gene BRCA1 und BRCA2
- Polyposis coli oder attenuierter Form der Polyposis coli, Gen APC
- hereditärem Colon-Carcinom-Syndrom ohne Polyposis (hereditary non polypotic colon cancer HNPCC), Gene MLH1, MSH2, MSH6 und PMS2
- Multiplen endokrinen Neoplasien',
					:anonymousgroup		=>	'9800',
					:anonymouspos			=>	'22',
					:list_title				=>	nil,
					:taxpoint_type		=>	nil,
					:permission				=>	nil,
				}
				assert_equal(expected, result)
			end
			def test_parse_page__1
				src = <<-EOS
Rev. Pos.-Nr. TP Bezeichnung Anonyme Nr.
8800.04 100 Chromosomenuntersuchung, maligne Hämopathien, Zuschlag für Zelltrennung und Einfrieren......? 9800.30
8801.00 400 Chromosomenuntersuchung,konstitutioneller Karyotyp..............? 9800.56
8801.01 50 Chromosomenuntersuchung, konstitutioneller Karyotyp, Zuschlag für über 25 analysierte Zellen.............................................? 9800.22
8801.02 100 Chromosomenuntersuchung, konstitutioneller Karyotyp, Zuschlag für über 50 analysierte Zellen.............................................? 9800.30
8802.00 600 Chromosomenuntersuchung, maligne Hämopathien, 10 karyo- typisierte Metaphasen oder 5 karyotypisierte Metaphasen und 15 analysierte Metaphasen...........? 9800.68
8802.01 300 Chromosomenuntersuchung,maligne Hämopathien, Zuschlag für zusätzliche analysierte Zellen, 5 karyotypisierte Metaphasen oder 10 analysierte Metaphasen...........? 9800.48
8802.02 150 Chromosomenuntersuchung, maligne Hämopathien, Zuschlag für komplexe Anomalien (³ 3 Anomalien)....................................? 9800.36 
8802.03 150 Chromosomenuntersuchung, maligne Hämopathien, Zuschlag für schwierige Analyse...................? 9800.36
8804.00 50 Chromosomenuntersuchung, Zuschlag für Benützung von zusätzlicher Färbung (G-,Q-,R- oder C-Bänderung, Ag-NOR, hohe Auflösung, andere), pro Färbung...? 9800.22
8805.00 250 Chromosomenuntersuchung, Zuschlag für in-situ Hybridisierung, pro Sonde......................................? 9800.44
8806.00 300 In situ-Hybridisierung an Inter- phasekernen inkl. Präparation und Analyse von 20 oder mehr Zellen..? 9800.48 112
				EOS
				begin
					result = @parser.parse_page(src,112)
				rescue AmbigousParseException => e
				end
				expected_first = {
					:code							=>	'8800.04',
					:group						=>	'8800',
					:position					=>	'04',
					:taxpoints				=>	100,
					:description			=>	'Chromosomenuntersuchung, maligne Hämopathien, Zuschlag für Zelltrennung und Einfrieren',
					:anonymousgroup		=>	'9800',
					:anonymouspos			=>	'30',
					:list_title				=>	nil,
					:permission				=>	nil,
					:taxpoint_type		=>	nil,
				}
				expected_last = {
					:code							=>	'8806.00',
					:group						=>	'8806',
					:position					=>	'00',
					:taxpoints				=>	300,
					:description			=>	'In situ-Hybridisierung an Interphasekernen inkl. Präparation und Analyse von 20 oder mehr Zellen',
					:anonymousgroup		=>	'9800',
					:anonymouspos			=>	'48',
					:list_title				=>	nil,
					:permission				=>	nil,
					:taxpoint_type		=>	nil,
				}
				expected_size = 11
				assert_equal(expected_first, result.first)
				assert_equal(expected_last, result.last)
				assert_equal(expected_size, result.size)
			end
		end
	end
end
