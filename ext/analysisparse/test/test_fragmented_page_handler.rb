#!/usr/bin/env ruby
#  TestFragmentedPageHandler-- oddb.org -- 18.05.2006 -- sfrischknecht@ywesee.com


$: << File.expand_path('../src', File.dirname(__FILE__))

require 'test/unit'
require 'fragmented_page_handler'

module ODDB
	module AnalysisParse
		class TestFragmentedPageHandler < Test::Unit::TestCase
			def setup
				@handler = FragmentedPageHandler.new
			end
			def	test_each_fragment__1
				src = <<-EOS
5.1.3 Analysen der Grundversorgung im engern Sinn

Die Analysen der Grundversorgung im engern Sinn sind in zwei Teillisten unterteilt. Diese Unterteilung ist eine rein tarifliche und be-
trifft nur das ärztliche Praxislaboratorium.

Teilliste 1
Für diese Analysen kann für das ärztliche Praxislaboratorium
der Taxpunktwert in Tarifverträgen festgesetzt werden, wobei die Taxpunktzahl der Analysenliste gilt. Fehlt eine solche vertragliche Regelung, so gilt der Taxpunktwert der Analysenliste.
Rev. Pos.-Nr. A TP Bezeichnung (Liste Grundversorgung, Teilliste 1) 8259.00 9 Glukose, im Blut/Plasma/Serum C 8273.00 7 Hämatokrit, manuelle Bestimmung, kumulierbar mit 8210.00 Erythrozyten-Zählung, 8275.00 Hämoglobin, 8406.00 Leukozyten-Zählung und 8560.00 Thrombozyten-Zählung bis max. Taxpunktzahl 15 (Hämatogramm II)
Limitation: nicht mit QBC-Methode
C 8275.00 7 Hämoglobin, manuelle Bestimmung, kumulierbar mit 8210.00 Erythrozyten-Zählung, 8273.00 Hämatokrit, 8406.00 Leukozyten-Zählung und 8560.00 Thrombozyten-Zählung bis max. Taxpunktzahl 15 (Hämatogramm II)
Limitation: nicht mit QBC-Methode
8387.00 9 Kreatinin, im Blut/Plasma/Serum
		25
				EOS
				expected = [
					<<-EOS,
5.1.3 Analysen der Grundversorgung im engern Sinn

Die Analysen der Grundversorgung im engern Sinn sind in zwei Teillisten unterteilt. Diese Unterteilung ist eine rein tarifliche und be-
trifft nur das ärztliche Praxislaboratorium.

					EOS
					<<-EOS,
Teilliste 1
Für diese Analysen kann für das ärztliche Praxislaboratorium
der Taxpunktwert in Tarifverträgen festgesetzt werden, wobei die Taxpunktzahl der Analysenliste gilt. Fehlt eine solche vertragliche Regelung, so gilt der Taxpunktwert der Analysenliste.
Rev. Pos.-Nr. A TP Bezeichnung (Liste Grundversorgung, Teilliste 1) 8259.00 9 Glukose, im Blut/Plasma/Serum C 8273.00 7 Hämatokrit, manuelle Bestimmung, kumulierbar mit 8210.00 Erythrozyten-Zählung, 8275.00 Hämoglobin, 8406.00 Leukozyten-Zählung und 8560.00 Thrombozyten-Zählung bis max. Taxpunktzahl 15 (Hämatogramm II)
Limitation: nicht mit QBC-Methode
C 8275.00 7 Hämoglobin, manuelle Bestimmung, kumulierbar mit 8210.00 Erythrozyten-Zählung, 8273.00 Hämatokrit, 8406.00 Leukozyten-Zählung und 8560.00 Thrombozyten-Zählung bis max. Taxpunktzahl 15 (Hämatogramm II)
Limitation: nicht mit QBC-Methode
8387.00 9 Kreatinin, im Blut/Plasma/Serum
		25
					EOS
				]
				begin
					positions = []
					result = @handler.each_fragment(src) { |fragment|
						check = expected.shift
						assert_equal(check, fragment)
					}
				end
			end
			def test_each_fragment__2
				src = <<-EOS
1
8317.01 25(1) Immunglobulin IgE - multispezifischer
oder
gruppenspezifischer Atopie-Screeningtest, ql/sq, ohne Unterscheidung einzelner spez.
IgE
(1) analog abgestuftem Blocktarif gemäss Punkt 5.7
der Vorbemerkungen, je nach Anzahl Allergene im
verwendeten Testsystem
8543.00 1 40 Theophyllin (Blut)
1________________________________________________________________________________
 Nur bei Kindern bis zu 6 Jahren
* anonyme Position

 Physikalische Medizin und Rehabilitation
Rev. Pos.-Nr. A TP Bezeichnung (Liste physik. Medizin und Rehabilitation)
8388.00 20 Kristallnachweis mit polarisiertem Licht
8600.00 25 Zellzählung, sowie Differenzierung nach Anreicherung und Färbung von Körperflüssigkeiten

EOS
				expected = [
<<-EOS,
1
8317.01 25(1) Immunglobulin IgE - multispezifischer
oder
gruppenspezifischer Atopie-Screeningtest, ql/sq, ohne Unterscheidung einzelner spez.
IgE
(1) analog abgestuftem Blocktarif gemäss Punkt 5.7
der Vorbemerkungen, je nach Anzahl Allergene im
verwendeten Testsystem
8543.00 1 40 Theophyllin (Blut)
1________________________________________________________________________________
 Nur bei Kindern bis zu 6 Jahren
* anonyme Position

EOS
<<-EOS,
 Physikalische Medizin und Rehabilitation
Rev. Pos.-Nr. A TP Bezeichnung (Liste physik. Medizin und Rehabilitation)
8388.00 20 Kristallnachweis mit polarisiertem Licht
8600.00 25 Zellzählung, sowie Differenzierung nach Anreicherung und Färbung von Körperflüssigkeiten

EOS
				]
				begin
					result = @handler.each_fragment(src) { |fragment|
					check = expected.shift
					assert_equal(check, fragment)
					}
				end
			end
			def test_parse_fragment__1
				src = <<-EOS
Gynäkologie und Geburtshilfe
Rev. Pos.-Nr. A TP Bezeichnung (Liste Gynäkologie und Geburtshilfe)
8455.20 60 Penetrationstest
8528.01 30 Spermiennachweis nach Vasektomie
9343.50 16 Pilznachweis mit kommerziellen Medien
9356.30 25 Spezielle Mikroskopie (Acridineorange, Ziehl-Neelsen, Auramin-Rhodamin, inklusive Dunkelfeld, Phasenkontrast etc., KOH, Pilze)

				EOS
				begin
					result = @handler.parse_fragment(src, 111)
				end
				expected = [
					{
					:code						=> '8455.20',
					:group					=> '8455',
					:position				=> '20',
					:taxpoints			=> 60,
					:description		=> 'Penetrationstest',
					:list_title			=>	nil,
					:permission			=>	nil,
					:taxpoint_type	=>	nil,
				},
				{
					:group					=> '8528',
					:code						=> '8528.01',
					:position				=> '01',
					:taxpoints			=> 30,
					:description		=> 'Spermiennachweis nach Vasektomie',
					:list_title			=>	nil,
					:taxpoint_type	=>	nil,
					:permission			=>	nil,
				},
				{
					:code						=> '9343.50',
					:group					=> '9343',
					:position				=> '50',
					:taxpoints			=> 16,
					:description		=> 'Pilznachweis mit kommerziellen Medien',
					:list_title			=>	nil,
					:permission			=>	nil,
					:taxpoint_type	=>	nil,
				},
				{
					:code						=> '9356.30',
					:group					=> '9356',
					:position				=> '30',
					:taxpoints			=> 25,
					:description		=> 'Spezielle Mikroskopie (Acridineorange, Ziehl-Neelsen, Auramin-Rhodamin, inklusive Dunkelfeld, Phasenkontrast etc., KOH, Pilze)',
					:list_title			=>	nil,
					:permission			=>	nil,
					:taxpoint_type	=>	nil,
				},
				]
					assert_equal(expected, result)
				expected_first = {
					:code					=>	'8455.20',
					:group				=>	'8455',
					:position			=>	'20',
					:taxpoints		=>	60,
					:description	=>	'Penetrationstest',
					:list_title			=>	nil,
					:permission			=>	nil,
					:taxpoint_type	=>	nil,
				}
				assert_equal(expected_first, result.first)
			end
			def test_parse_page__1
				src = <<-EOS

Endokrinologie - Diabetologie
Rev. Pos.-Nr. A TP Bezeichnung (Liste Endokrinologie - Diabetologie)
8149.00 9 Calcium, total, im Blut/Plasma/Serum
8243.00 25 Fruktosamin

Gastroenterologie
Rev. Pos.-Nr. A TP Bezeichnung (Liste Gastroenterologie)
9366.00 15 Urease-Test (Helicobacter pylori)

Gynäkologie und Geburtshilfe
Rev. Pos.-Nr. A TP Bezeichnung (Liste Gynäkologie und Geburtshilfe)
8455.20 60 Penetrationstest
8528.01 30 Spermiennachweis nach Vasektomie

12
				EOS
				begin
					result = @handler.parse_page(src, 12)
				end
				expected = [
					{
					:code					=>	'8149.00',
					:group				=>	'8149',
					:position			=>	'00',
					:taxpoints		=>	9,
					:description	=>	'Calcium, total, im Blut/Plasma/Serum',
					:permission			=>	'Endokrinologie - Diabetologie',
					:list_title			=>	nil,
					:taxpoint_type	=>	nil,
				},
				{
					:code					=>	'8243.00',
					:group				=>	'8243',
					:position			=>	'00',
					:taxpoints		=>	25,
					:description	=>	'Fruktosamin',
					:permission		=>	'Endokrinologie - Diabetologie',
					:list_title			=>	nil,
					:taxpoint_type	=>	nil,
				},
				{
					:code					=>	'9366.00',
					:group				=>	'9366',
					:position			=>	'00',
					:taxpoints		=>	15,
					:description	=>	'Urease-Test (Helicobacter pylori)',
					:permission		=>	'Gastroenterologie',
					:list_title			=>	nil,
					:taxpoint_type	=>	nil,
				},
				{
					:code					=>	'8455.20',
					:group				=>	'8455',
					:position			=>	'20',
					:taxpoints		=>	60,
					:description	=>	'Penetrationstest',
					:permission		=>	'Gynäkologie und Geburtshilfe',
					:list_title			=>	nil,
					:taxpoint_type	=>	nil,
				},
				{
					:code					=>	'8528.01',
					:group				=>	'8528',
					:position			=>	'01',
					:taxpoints		=>	30,
					:description	=>	'Spermiennachweis nach Vasektomie',
					:permission		=>	'Gynäkologie und Geburtshilfe',
					:list_title			=>	nil,
					:taxpoint_type	=>	nil,
				},
				]
				assert_equal(expected, result)
			end
			def	test_parse_page__2
				src1 = <<-EOS
Teilliste 1
Rev. Pos.-Nr. A TP Bezeichnung (Liste Grundversorgung, Teilliste 1)
8259.00 9 Glukose, im Blut/Plasma/Serum
C 8273.00 7 Hämatokrit, manuelle Bestimmung, kumu-
lierbar mit 8210.00 Erythrozyten-Zählung, 
8275.00 Hämoglobin, 8406.00 Leukozyten-
Zählung und 8560.00 Thrombozyten-
Zählung bis max. Taxpunktzahl 15
(Hämatogramm II)
Limitation: nicht mit QBC-Methode

24
			EOS
				src2 = <<-EOS
Rev. Pos.-Nr. A TP Bezeichnung (Liste Grundversorgung, Teilliste 1)
8579.00 16 Urin-Status (5-10 Parameter)
9309.00 4 Urin-Teilstatus (5-10 Parameter)

Teilliste 2
Rev. Pos.-Nr. A TP Bezeichnung (Liste Grundversorgung, Teilliste 2)
C 8000.00 8 ABO/D-Antigen, Kontrolle nach Empfehlun-
gen BSD SRK "Erythrozytenserologische
Untersuchungen an Patientenproben"

25
			EOS
				begin
					res1 = @handler.parse_page(src1, 24)
					res2 = @handler.parse_page(src2, 25)
				end
				expected1 = [
					{
					:code						=>	'8259.00',
					:group					=>	'8259',
					:position				=>	'00',
					:taxpoints			=>	9,
					:description		=>	'Glukose, im Blut/Plasma/Serum',
					:taxpoint_type			=>	:fixed,
					:list_title					=>	nil,
					:permission				=>	'Teilliste 1',
				},
				{
					:code						=>	'8273.00',
					:group					=>	'8273',
					:position				=>	'00',
					:analysis_revision				=>	'C',
					:taxpoints			=>	7,
					:description		=>	'Hämatokrit, manuelle Bestimmung, kumulierbar mit 8210.00 Erythrozyten-Zählung, 8275.00 Hämoglobin, 8406.00 Leukozyten-Zählung und 8560.00 Thrombozyten-Zählung bis max. Taxpunktzahl 15 (Hämatogramm II)',
					:limitation			=>	'nicht mit QBC-Methode',
					:taxpoint_type			=>	:fixed,
					:list_title					=>	nil,
					:permission				=>	'Teilliste 1',
				},
				]
				expected2 = [
					{
					:code						=>	'8579.00',
					:group					=>	'8579',
					:position				=>	'00',
					:taxpoints			=>	16,
					:description		=>	'Urin-Status (5-10 Parameter)',
					:taxpoint_type			=>	:fixed,
					:list_title					=>	nil,
					:permission				=>	'Teilliste 1',
				},
				{
					:code						=>	'9309.00',
					:group					=>	'9309',
					:position				=>	'00',
					:taxpoints			=>	4,
					:description		=>	'Urin-Teilstatus (5-10 Parameter)',
					:taxpoint_type			=>	:fixed,
					:list_title					=>	nil,
					:permission				=>	'Teilliste 1',
				},
				{
					:code						=>	'8000.00',
					:group					=>	'8000',
					:position				=>	'00',
					:analysis_revision				=>	'C',
					:description		=>	'ABO/D-Antigen, Kontrolle nach Empfehlungen BSD SRK "Erythrozytenserologische Untersuchungen an Patientenproben"',
					:taxpoint_type			=>	:default,
					:taxpoints			=>	8,
					:list_title			=>	nil,
					:permission		=>	'Teilliste 2',
				},
				]
				expected_res2_first = {
					:code						=>	'8579.00',
					:group					=>	'8579',
					:position				=>	'00',
					:taxpoints			=>	16,
					:description		=>	'Urin-Status (5-10 Parameter)',
					:taxpoint_type			=>	:fixed,
					:list_title					=>	nil,
					:permission				=>	'Teilliste 1',
				}
				expected_res2_last = {
					:code						=>	'8000.00',
					:group					=>	'8000',
					:position				=>	'00',
					:analysis_revision				=>	'C',
					:description		=>	'ABO/D-Antigen, Kontrolle nach Empfehlungen BSD SRK "Erythrozytenserologische Untersuchungen an Patientenproben"',
					:taxpoint_type			=>	:default,
					:taxpoints			=>	8,
					:list_title			=>	nil,
					:permission		=>	'Teilliste 2',
				}
				expected_res2_at1 = {
					:code						=>	'9309.00',
					:group					=>	'9309',
					:position				=>	'00',
					:taxpoints			=>	4,
					:description		=>	'Urin-Teilstatus (5-10 Parameter)',
					:taxpoint_type			=>	:fixed,
					:list_title					=>	nil,
					:permission				=>	'Teilliste 1',
				}
				expected_res1_first = 
					{
					:code						=>	'8259.00',
					:group					=>	'8259',
					:position				=>	'00',
					:taxpoints			=>	9,
					:description		=>	'Glukose, im Blut/Plasma/Serum',
					:taxpoint_type			=>	:fixed,
					:list_title					=>	nil,
					:permission				=>	'Teilliste 1',
				}
				assert_equal(expected1, res1)
				assert_equal(expected_res1_first, res1.first)
				assert_equal(expected2, res2)
				assert_equal(expected_res2_first, res2.first)
				assert_equal(expected_res2_last, res2.last)
				assert_equal(expected_res2_at1, res2.at(1))
			end
			def test_parse_page__3
				src1 =<<-EOS
Kinder- und Jugendmedizin
Rev. Pos.-Nr. A TP Bezeichnung (Liste Kinder- und Jugendmedizin)
1
8317.01 25(1) Immunglobulin IgE - multispezifischer
oder gruppenspezifischer Atopie-Screeningtest,
ql/sq, ohne Unterscheidung einzelner spez.
IgE
(1) analog abgestuftem Blocktarif gemäss Punkt 5.7
der Vorbemerkungen, je nach Anzahl Allergene im
verwendeten Testsystem
8543.00 1 40 Theophyllin (Blut)
1_______________________________________________________________________________
 Nur bei Kindern bis zu 6 Jahren
* anonyme Position

Medizinische Onkologie
Vorläufig wie Hämatologie

Physikalische Medizin und Rehabilitation
Rev. Pos.-Nr. A TP Bezeichnung (Liste physik. Medizin und Rehabilitation)
8388.00 20 Kristallnachweis mit polarisiertem Licht
8600.00 25 Zellzählung, sowie Differenzierung nach
Anreicherung und Färbung von Körper- flüssigkeiten

100
			EOS
				src2 =<<-EOS
Tropenmedizin
Rev. Pos.-Nr. A TP Bezeichnung (Liste Tropenmedizin)
9356.30 25 Spezielle Mikroskopie (Acridineorange, Ziehl-Neelsen, Auramin-Rhodamin, inklusive Dunkelfeld, Phasenkontrast etc.,
KOH, Pilze)
9652.00 25 Mikroskopischer Nachweis von Parasiten
(z.B. Klebestreifenmethode), nativ

101
			EOS
				begin
					res1 = @handler.parse_page(src1, 100)
					res2 = @handler.parse_page(src2, 101)
				end
				expected1 = [
					{
					:code							=>	'8317.01',
					:group						=>	'8317',
					:position					=>	'01',
					:taxnumber				=>	'1',
					:taxpoints				=>	25,
					:description			=>	'Immunglobulin IgE - multispezifischer oder gruppenspezifischer Atopie-Screeningtest, ql/sq, ohne Unterscheidung einzelner spez. IgE',
					:taxnote					=>	'analog abgestuftem Blocktarif gemäss Punkt 5.7 der Vorbemerkungen, je nach Anzahl Allergene im verwendeten Testsystem',
					:permission				=>	'Kinder- und Jugendmedizin',
					:list_title					=>	nil,
					:taxpoint_type			=>	nil,
				},
				{
					:code							=>	'8543.00',
					:group						=>	'8543',
					:position					=>	'00',
					:footnote					=>	'Nur bei Kindern bis zu 6 Jahren',
					:taxpoints				=>	40,
					:description			=>	'Theophyllin (Blut)',
					:permission				=>	'Kinder- und Jugendmedizin',
					:list_title					=>	nil,
					:taxpoint_type			=>	nil,
				},
				{
					:code							=>	'8388.00',
					:group						=>	'8388',
					:position					=>	'00',
					:taxpoints				=>	20,
					:description				=>	'Kristallnachweis mit polarisiertem Licht',
					:permission				=>	'Physikalische Medizin und Rehabilitation',
					:list_title					=>	nil,
					:taxpoint_type			=>	nil,
				},
				{
					:code							=>	'8600.00',
					:group						=>	'8600',
					:position					=>	'00',
					:taxpoints				=>	25,
					:description			=>	'Zellzählung, sowie Differenzierung nach Anreicherung und Färbung von Körperflüssigkeiten',
					:permission				=>	'Physikalische Medizin und Rehabilitation',
					:list_title					=>	nil,
					:taxpoint_type			=>	nil,
				}
				]
				expected2 = [
					{
					:code							=>	'9356.30',
					:group						=>	'9356',
					:position					=>	'30',
					:taxpoints				=>	25,
					:description			=>	'Spezielle Mikroskopie (Acridineorange, Ziehl-Neelsen, Auramin-Rhodamin, inklusive Dunkelfeld, Phasenkontrast etc., KOH, Pilze)',
					:permission				=>	'Tropenmedizin',
					:list_title					=>	nil,
					:taxpoint_type			=>	nil,
				},
				{
					:code							=>	'9652.00',
					:group						=>	'9652',
					:position					=>	'00',
					:taxpoints				=>	25,
					:description			=>	'Mikroskopischer Nachweis von Parasiten (z.B. Klebestreifenmethode), nativ',
					:permission				=>	'Tropenmedizin',
					:list_title					=>	nil,
					:taxpoint_type			=>	nil,
				}
				]
				assert_equal(expected1, res1)
				assert_equal(expected2, res2)
			end
		end
	end
end
