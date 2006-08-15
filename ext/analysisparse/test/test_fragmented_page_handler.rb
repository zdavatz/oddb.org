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
					:taxpoints				=>	40,
					:description			=>	'Theophyllin (Blut)',
					:permission				=>	'Kinder- und Jugendmedizin',
					:restriction			=>	'1',
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
			def test_fr_each_fragment__1
				src = <<-EOS
5.1.3  Analyses dans le cadre des soins de base au sens strict
Les analyses effectuées dans le cadre des soins de base au sens strict sont subdivisées dans deux listes partielles. Cette subdivision est de nature tarifaire est ne concerne que les laboratoires de cabinets médicaux.
Liste partielle 1
Pour les laboratoires de cabinets médicaux, la valeur du point des analyses suivantes peut être fixée dans des conventions tarifaires, mais le nombre de points indiqué dans la liste des analyses doit être maintenu. En l'absence d'une convention tarifaire, la valeur du point de la liste des analyses est applicable.
Rév. No pos. A TP Dénomination (liste des soins de base, liste partielle 1)
8259.00 9 Glucose (sang, plasma, sérum)
C 8273.00 7 Hématocrite, détermination manuelle, cumulable avec 8210.00 érythrocytes (numération), 8275.00 hémoglobine, 8406.00 leucocytes (numération) et 8560.00 thrombocytes (numération), jusqu'à un total de max. 15 points (hémogramme II) Limitation: pas avec la méthode QBC
				EOS
				expected = [
				<<-EOS,
5.1.3  Analyses dans le cadre des soins de base au sens strict
Les analyses effectuées dans le cadre des soins de base au sens strict sont subdivisées dans deux listes partielles. Cette subdivision est de nature tarifaire est ne concerne que les laboratoires de cabinets médicaux.
				EOS
				<<-EOS,
Liste partielle 1
Pour les laboratoires de cabinets médicaux, la valeur du point des analyses suivantes peut être fixée dans des conventions tarifaires, mais le nombre de points indiqué dans la liste des analyses doit être maintenu. En l'absence d'une convention tarifaire, la valeur du point de la liste des analyses est applicable.
Rév. No pos. A TP Dénomination (liste des soins de base, liste partielle 1)
8259.00 9 Glucose (sang, plasma, sérum)
C 8273.00 7 Hématocrite, détermination manuelle, cumulable avec 8210.00 érythrocytes (numération), 8275.00 hémoglobine, 8406.00 leucocytes (numération) et 8560.00 thrombocytes (numération), jusqu'à un total de max. 15 points (hémogramme II) Limitation: pas avec la méthode QBC
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
			def test_fr_parse_fragment__1
			src = <<-EOS
Allergologie et immunologie clinique
Rév. No pos. A TP Dénomination (list allergologie et immunologie clin.)
8317.00 35 Immunoglobuline IgE totale, qn
8317.01 25(1) Immunoglobuline IgE - test de dépistage groupé ou multispécifique de l'atopie, ql/sq, sans différentiation des IgE spécif.
(1) analogue au tarif échelonné des blocs d'analyses selon point 5.7 des remarques préliminaires, selon le nombre d'allergènes du test utilisé
			113
			EOS
			begin
				result = @handler.parse_fragment(src,113)
			end
			expected = [
					{
					:code						=> '8317.00',
					:group					=> '8317',
					:position				=> '00',
					:taxpoints			=> 35,
					:description		=> 'Immunoglobuline IgE totale, qn',
					:list_title			=>	nil,
					:permission			=>	nil,
					:taxpoint_type	=>	nil,
				},
				{
					:code						=>	'8317.01',
					:group					=>	'8317',
					:position				=>	'01',
					:taxpoints			=>	25,
					:description		=>	'Immunoglobuline IgE - test de dépistage groupé ou multispécifique de l\'atopie, ql/sq, sans différentiation des IgE spécif.',
					:list_title			=>	nil,
					:permission			=>	nil,
					:taxpoint_type	=>	nil,
					:taxnumber			=>	'1',
					:taxnote				=>	'analogue au tarif échelonné des blocs d\'analyses selon point 5.7 des remarques préliminaires, selon le nombre d\'allergènes du test utilisé',
			},
			]
			assert_equal(expected, result)
			end
			def test_fr_parse_page__1
				src1 = <<-EOS
Liste partielle 1
8259.00 9 Glucose (sang, plasma, sérum)
C 8273.00 7 Hematocrite, détermination manuelle
Limitation: pas avec la méthode QBC
				110
				EOS
				src2 = <<-EOS
9355.30 20 Microscopie conventionelle, examen par ~, coloration comprise (Gram, Giemsa, bleu de méthylène, etc.)
Liste partielle 2
C 8000.00 8 ABO/D, contrôle selon les recommandations STS CRS "Sérologie érythrocytaire chez le patient"
				111
				EOS
				begin
					res1 = @handler.parse_page(src1, 110)
					res2 = @handler.parse_page(src2, 111)
				end
				expected1 = [
					{
				:code						=>	'8259.00',
				:group					=>	'8259',
				:position				=>	'00',
				:taxpoints			=>	9,
				:description		=>	'Glucose (sang, plasma, sérum)',
				:list_title			=>	nil,
				:taxpoint_type	=>	:fixed,
				:permission			=>	'Liste partielle 1',
				},
					{
				:code						=>	'8273.00',
				:group					=>	'8273',
				:position				=>	'00',
				:taxpoints			=>	7,
				:analysis_revision				=>	'C',
				:description		=>	'Hematocrite, détermination manuelle',
				:limitation			=>	'pas avec la méthode QBC',
				:list_title			=>	nil,
				:taxpoint_type	=>	:fixed,
				:permission			=>	'Liste partielle 1',
				},
				]
				expected2 = [
					{
				:code						=>	'9355.30',
				:group					=>	'9355',
				:position				=>	'30',
				:taxpoints			=>	20,
				:description		=>	'Microscopie conventionelle, examen par ~, coloration comprise (Gram, Giemsa, bleu de méthylène, etc.)',
				:list_title			=>	nil,
				:taxpoint_type	=>	:fixed,
				:permission			=>	'Liste partielle 1',
				},
					{
				:code						=>	'8000.00',
				:group					=>	'8000',
				:position				=>	'00',
				:taxpoints			=>	8,
				:description		=>	'ABO/D, contrôle selon les recommandations STS CRS "Sérologie érythrocytaire chez le patient"',
				:analysis_revision				=>	'C',
				:list_title			=>	nil,
				:taxpoint_type	=>	:default,
				:permission			=>	'Liste partielle 2',
				},
				]
				assert_equal(expected1, res1)
				assert_equal(expected2, res2)
			end
			def test_fr_parse_page__2
				src = <<-EOS
Allergologie et immunologie clinique
Rév. No pos. A TP Dénomination (liste allergologie et immunologie clin.)
8317.00 35 Immunoglobuline IgE totale, qn
8317.01 25 Immunoglobuline IgE - test de dépistage groupé ou multispécifique de l'atopie, ql,sq,
sans différentiation des IgE spécif.
				55
				EOS
				begin
					result = @handler.parse_page(src, 55)
				end
				expected = [
					{
					:code						=>	'8317.00',
					:group					=>	'8317',
					:position				=>	'00',
					:taxpoints			=>	35,
					:description		=>	'Immunoglobuline IgE totale, qn',
					:permission			=>	'Allergologie et immunologie clinique',
					:taxpoint_type	=>	nil,
					:list_title			=>	nil,
				},
					{
					:code						=>	'8317.01',
					:group					=>	'8317',
					:position				=>	'01',
					:taxpoints			=>	25,
					:description		=>	'Immunoglobuline IgE - test de dépistage groupé ou multispécifique de l\'atopie, ql,sq, sans différentiation des IgE spécif.',
					:permission			=>	'Allergologie et immunologie clinique',
					:taxpoint_type	=>	nil,
					:list_title			=>	nil,
				},
				]
				assert_equal(expected, result)
			end
			def test_fr_parse_page__3
				src = <<-EOS
				Médecine physique et réadaptation

Rév. No pos. A TP Dénomination (liste médicine physique et réadaption)

				            8388.00       20    Cristaux, recherche en lumière polarisée
				            8600.00       25    Cellules, numération et différentiation après
				enrichissement et coloration de liquides
				biologiques
				56
				EOS
				begin
					result = @handler.parse_page(src, 56)
				end
				expected = [
					{
					:code						=>	'8388.00',
					:group					=>	'8388',
					:position				=>	'00',
					:taxpoints			=>	20,
					:description		=>	'Cristaux, recherche en lumière polarisée',
					:permission			=>	'Médecine physique et réadaptation',
					:taxpoint_type	=>	nil,
					:list_title			=>	nil,
				},
					{
					:code						=>	'8600.00',
					:group					=>	'8600',
					:position				=>	'00',
					:taxpoints			=>	25,
					:description		=>	'Cellules, numération et différentiation après enrichissement et coloration de liquides biologiques',
					:permission			=>	'Médecine physique et réadaptation',
					:taxpoint_type	=>	nil,
					:list_title			=>	nil,
				},
				]
				assert_equal(expected, result)
			end
		end
	end
end
