#!/usr/bin/env ruby
# ODDB::AnalysisParse::TestPageHandler -- oddb.org -- 12.04.2011 -- mhatakeyama@ywesee.com
# ODDB::AnalysisParse::TestPageHandler -- oddb.org -- 12.04.2006 -- sfrischknecht@ywesee.com

$: << File.expand_path('../src', File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'pagehandler'
require 'extended_list_parser'
require 'fragmented_page_handler'

module ODDB
	module AnalysisParse
		class TestIndexFinder < Test::Unit::TestCase
			def setup
				@index = {}
				@handler = IndexFinder.new
				@index_handler = IndexHandler.new(@index)
				@parser = FragmentedPageHandler.new
			end
			
			def test_index_finder__1
				src = <<-EOS
Systematische Auflistung der Analysen inkl. Anhänge
1. Kapitel: Chemie/Hämatologie/Immunologie............................. 41
				EOS
				begin
					result = @handler.next_pagehandler(src)
					assert_kind_of(IndexFinder, result)
					expected = {
						41	=>	'Chemie/Hämatologie/Immunologie'
					}
					assert_equal(expected, result.index)
				end
			end
			def test_index_finder__2
				src = <<-EOS
				Systematische Auflistung der Analysen inkl. Anhänge
				1. Kapitel: Chemie/H\uffffmatologie/Immunologie............................. 41
				2. Kapitel: Genetik
				2.1 Bemerkungen........................................................................ 75
				EOS
				begin
					result = @handler.next_pagehandler(src)
					assert_kind_of(IndexFinder, result)
					expected = {
						75	=>	'Genetik',
						41	=>	'Chemie/Huffffmatologie/Immunologie'
					}
					assert_equal(expected, result.index)
				end
			end
			def test_index_finder__3
				src = <<-EOS
				Inhaltsübersicht
				Vorbemerkungen
				1. Rechtsgrundlagen ....................................................................... 5
				1.1 Auszug aus dem Bundesgesetz vom 18. März 1994
				über die Krankenversicherung (KVG) .................................. 5
				1.2 Auszug aus der Verordnung über die
				Krankenversicherung vom 27. Juni 1995 (KVV) ................ 13
				1.3 Auszug aus der Krankenpflege-Leistungsverordnung
				(KLV) vom 29. September 1995 ........................................ 20
				2. Erläuterungen zu einzelnen Bestimmungen des KVG sowie
				der KVV und der KLV................................................................ 24
				EOS
				begin
					result = @handler.next_pagehandler(src)
					assert_kind_of(IndexFinder, result)
					expected = {
						24	=>	'Erläuterungen zu einzelnen Bestimmungen des KVG sowie der KVV und der KLV',
						5		=>	'Rechtsgrundlagen'
					}
					assert_equal(expected, result.index)
				end
			end
			def test_index_finder__4
				src = <<-EOS
				Analysenliste
				Anhang 3 der Krankenpflege-Leistungsverordnung (KLV) vom
				29. September 1995
				Liste der von den Krankenversicherern im Rahmen der
				obligatorischen Krankenpflegeversicherung als Pflichtleistung zu
				vergütenden Analysen
				Fassung vom 1. Januar 2006
				Die vorliegende Analysenliste ersetzt diejenige vom 1. Januar 2005
				Herausgegeben vom Eidgenössischen Departement des Innern
				Vertrieb:
				Bundesamt für Bauten und Logistik BBL, Vertrieb Publikationen,
				3003 Bern, Fax 031 325 50 58
				(Bestell-Nr. 316.935 d)
				http://www.bbl.admin.ch/internet/produkte_und_dienstleistungen/online_shop/alle/index
				.html?lang=de (Sucheingabe: Analysenliste)
				Die Analysenliste ist auch auf der Webseite des Bundesamtes für Gesundheit unter
				http://www.bag.admin.ch/kv/gesetze/d/index.htm veröffentlicht.

				3
				Inhaltsübersicht
				Vorbemerkungen
				1. Rechtsgrundlagen ....................................................................... 5
				1.1 Auszug aus dem Bundesgesetz vom 18. M?rz 1994
				?ber die Krankenversicherung (KVG) .................................. 5
				1.2 Auszug aus der Verordnung ?ber die
				Krankenversicherung vom 27. Juni 1995 (KVV) ................ 13
				1.3 Auszug aus der Krankenpflege-Leistungsverordnung
				(KLV) vom 29. September 1995 ........................................ 20
				2. Erl?uterungen zu einzelnen Bestimmungen des KVG sowie
				der KVV und der KLV................................................................ 24
				2.1 Allgemeine Zulassungsbedingungen f?r Laboratorien....... 24
				2.2 Spezielle Zulassungsbedingungen f?r die
				verschiedenen Laboratoriumstypen................................... 25
				2.2.1 Laboratorien, die nur Analysen der Grundversorgung
				durchf?hren d?rfen ................................ 25
				2.2.2 Laboratorien, die ausser den Analysen der
				Grundversorgung weitere Analysen durchf?hren
				d?rfen........................................................................ 25
				2.2.3 Laboratorien, die Analysen des Kapitels Genetik
				der Analysenliste durchf?hren d?rfen ....................... 26
				2.2.4 Laboratorien, die Analysen des Kapitels Mikrobiologie
				der Analysenliste durchf?hren d?rfen.......... 27
				2.2.5 Speziallaboratorien ................................................... 27
				2.3 Anh?nge zur Analysenliste ................................................ 28
				2.4 Qualit?tssicherung als Voraussetzung der Verg?tung....... 29
				2.5 Durchf?hrung von Laboranalysen im Ausland ................... 29
				2.6 Vermittlung von Laboranalysen ......................................... 31
				2.7 Rechnungstellung .............................................................. 31
				2.8 ?berpr?fung der Verordnung von Laboranalysen.............. 31
				2.9 Auskunfterteilung ............................................................... 32
				3. Medizinprodukte f?r die In-vitro-Diagnostik (IVD) ..................... 33
				EOS
				begin
					result = @handler.next_pagehandler(src)
					assert_kind_of(IndexFinder, result)
					expected = {
						33	=>	'Medizinprodukte f?r die In-vitro-Diagnostik (IVD)',
						5		=>	'Rechtsgrundlagen',
						24	=>	'Erl?uterungen zu einzelnen Bestimmungen des KVG sowie der KVV und der KLV'
					}
					assert_equal(expected, result.index)
				end
			end
			def test_index_finder__5
				src = <<-EOS
				Inhalts?bersicht
				Vorbemerkungen
				1. Rechtsgrundlagen ....................................................................... 5
				1.1 Auszug aus dem Bundesgesetz vom 18. M?rz 1994
				?ber die Krankenversicherung (KVG) .................................. 5
				1.2 Auszug aus der Verordnung ?ber die
				Krankenversicherung vom 27. Juni 1995 (KVV) ................ 13
				1.3 Auszug aus der Krankenpflege-Leistungsverordnung
				(KLV) vom 29. September 1995 ........................................ 20
				2. Erl?uterungen zu einzelnen Bestimmungen des KVG sowie
				der KVV und der KLV................................................................ 24
				EOS
				begin
					result = @handler.next_pagehandler(src)
					assert_kind_of(IndexFinder, result)
					expected = {
						5		=>	'Rechtsgrundlagen',
						24	=>	'Erl?uterungen zu einzelnen Bestimmungen des KVG sowie der KVV und der KLV'
					}
					assert_equal(expected, result.index)
				end
			end
			def test_index_finder__6
				src = <<-EOS 
        Inhaltsübersicht
        Vorbemerkungen
        1. Rechtsgrundlagen ....................................................................... 5
        1.1 Auszug aus dem Bundesgesetz vom 18. März 1994
        über die Krankenversicherung (KVG) .................................. 5
        1.2 Auszug aus der Verordnung über die
        Krankenversicherung vom 27. Juni 1995 (KVV) ................ 13
        1.3 Auszug aus der Krankenpflege-Leistungsverordnung
        (KLV) vom 29. September 1995 ........................................ 20
        2. Erläuterungen zu einzelnen Bestimmungen des KVG sowie
        der KVV und der KLV................................................................ 24
        2.1 Allgemeine Zulassungsbedingungen für Laboratorien....... 24
        2.2 Spezielle Zulassungsbedingungen für die
        verschiedenen Laboratoriumstypen................................... 25
        2.2.1 Laboratorien, die nur Analysen der Grundversorgung
        durchführen dürfen ................................ 25
        2.2.2 Laboratorien, die ausser den Analysen der
        Grundversorgung weitere Analysen durchführen
        dürfen........................................................................ 25
        2.2.3 Laboratorien, die Analysen des Kapitels Genetik
        der Analysenliste durchführen dürfen ....................... 26
        2.2.4 Laboratorien, die Analysen des Kapitels Mikrobiologie
        der Analysenliste durchführen dürfen.......... 27
        2.2.5 Speziallaboratorien ................................................... 27
        2.3 Anhänge zur Analysenliste ................................................ 28
        2.4 Qualitätssicherung als Voraussetzung der Vergütung....... 29
        2.5 Durchführung von Laboranalysen im Ausland ................... 29
        2.6 Vermittlung von Laboranalysen ......................................... 31
        2.7 Rechnungstellung .............................................................. 31
        2.8 Überprüfung der Verordnung von Laboranalysen.............. 31
        2.9 Auskunfterteilung ............................................................... 32
        3. Medizinprodukte für die In-vitro-Diagnostik (IVD) ..................... 33
        4. Anträge auf Änderungen der Eidgenössischen Analysenliste
        (AL) ........................................................................................... 33
        5. Tarif ........................................................................................... 35
        6. Systematik der Analysenlistenpositionen.................................. 37
        7. Abkürzungen ............................................................................. 37
        8. Bemerkungen zur vorliegenden Ausgabe ................................. 39
        4
        Systematische Auflistung der Analysen inkl. Anhänge
        1. Kapitel: Chemie/Hämatologie/Immunologie............................. 41
        2. Kapitel: Genetik
        2.1 Bemerkungen........................................................................ 75
        2.2 Liste der Analysen ................................................................ 76
        2.2.1 Chromosomenanalysen.............................................. 76
        2.2.2 Molekulargenetische Analysen ................................... 78
        3. Kapitel: Mikrobiologie
        3.1 Virologie ................................................................................ 85
        3.2 Bakteriologie/Mykologie ........................................................ 96
        3.2.1 Bemerkungen ............................................................. 96
        3.2.2 Liste der Analysen ...................................................... 96
        3.3 Parasitologie ...................................................................... 105
        4. Kapitel: Übrige
        4.1 Allgemeine Positionen ....................................................... 109
        4.2 Anonyme Positionen.......................................................... 111
        4.3 Fixe Analysenblöcke.......................................................... 120
        4.4 Liste seltener Autoantikörper ............................................. 121
        5. Kapitel: Anhänge zur Analysenliste ....................................... 123
        5.1 Anhang A
        Im Rahmen der Grundversorgung durchgeführte Analysen
        5.1.1 Allgemeines .............................................................. 123
        5.1.2 Ärztliches Praxislaboratorium
        5.1.2.1 Definition "Analysen im Rahmen der
        Grundversorgung" bezogen auf das ärztliche
        Praxislaboratorium........................................... 124
        5.1.2.2 Definition "Ärztliches Praxislaboratorium"........ 124
        5.1.2.3 Definition "Präsenzdiagnostik"......................... 125
        5.1.3 Analysen der Grundversorgung im engern Sinn....... 127
        5.1.4 Erweiterte Liste für Fachärzte oder Fachärztinnen... 132
        5.2 Anhang B
        Von Chiropraktoren oder Chiropraktorinnen veranlasste
        Analysen ............................................................................ 139
        5.3 Anhang C
        Von Hebammen veranlasste Analysen.............................. 141
        Alphabetisches Verzeichnis der Analysen
        (inkl. Synonyme) ........................................................................... 143
				EOS
				begin
					result = @handler.next_pagehandler(src)
					assert_kind_of(IndexFinder, result)
					expected = {
						75	=>	'Genetik',
						41	=>	'Chemie/Hämatologie/Immunologie',
						5		=>	'Rechtsgrundlagen',
						24	=>	'Erläuterungen zu einzelnen Bestimmungen des KVG sowie der KVV und der KLV',
						33	=>	'Anträge auf Änderungen der Eidgenössischen Analysenliste (AL)',
						35	=>	'Tarif',
						37	=>	'Abkürzungen',
						39	=>	'Bemerkungen zur vorliegenden Ausgabe',
						85	=>	'Mikrobiologie',
						109	=>	'Allgemeine Positionen',
						111	=>	'Anonyme Positionen',
						120	=>	'Fixe Analysenblöcke',
						121	=>	'Liste seltener Autoantikörper',
						123	=>	'Im Rahmen der Grundversorgung durchgeführte Analysen',
						139	=>	'Von Chiropraktoren oder Chiropraktorinnen veranlasste Analysen',
						141	=>	'Von Hebammen veranlasste Analysen'
					}
					assert_equal(expected.sort, result.index.sort)
				end
			end
			def test_index_finder__7
				src = <<-EOS
4.1 Allgemeine Positionen.......................................................109
				EOS
				begin
					result = @handler.next_pagehandler(src)
				end
					assert_kind_of(IndexFinder, result)
					expected = {
				    109	=>	'Allgemeine Positionen',
					} 
					assert_equal(expected, result.index)
			end
			def test_parse_pages__1
				page_1 = <<-EOS
5.1.3 Analysen der Grundversorgung im engern Sinn


Teilliste 2

F?r diese Analysen gilt auch f?r das ?rztliche Praxislaboratorium der
Analysenlistentarif (Taxpunktwert und Taxpunktzahl).

Rev. Pos. Nr.  A TP  Bezeichnung (Liste Grundversorgung, Teilliste 2)

1
C     8000.00 1       8    ABO/D-Antigen, Kontrolle nach Empfehlun-
gen BSD SRK "Erythrozytenserologische
Untersuchungen an Patientenproben"
				8006.00          9  Alanin-Aminotransferase (ALAT)
			8007.00          9  Albumin, chemisch
			8036.00 2      16   Amphetamine, ql (Urin) (im Screening mit
anderen Suchtstoffen: siehe 8535.04/05)
			8129.00 3      30   Blutgase (pH, pCO, pO
abgeleitete Werte)
			8129.10 4      50  Oxymetrieblock (Oxyh?moglobin,
Carboxyh?moglobin, Meth?moglobin)
N     8191.00         10   Spezielle Mikroskopie, Nativpr?parat
(Dunkelfeld, Polarisation, Phasenkontrast)
																																																										129
				EOS
				page_2 = <<-EOS
Rev. Pos. Nr.  A TP  Bezeichnung (Liste Grundversorgung, Teilliste 2)

N     8560.10
		6    H?matologische Untersuchungen mit QBC-
Methode
Limitation: nur f?r H?moglobin und H?matokrit.
G?ltig ab 1.1.2006 bis 31.12.2006.
			8572.00          9  Triglyceride
			8574.11         16  Troponin (T oder I), Schnelltest, nicht
kumulierbar mit 8384.00 Kreatin-Kinase
(CK), total
			8578.00          9  Urat
C     8587.00       25   Vertr?glichkeitsprobe: Kreuzprobe nach
Empfehlungen BSD SRK "Erythrozyten-
serologische Untersuchungen an Patien-
tenproben", pro Erythrozytenkonzentrat
			9116.40    *  12   HIV-1+2 -Antik?rper (Screening) Schnelltest,
ql
S     9710.00          8  Blutentnahme, Kapillarblut oder
Venenpunktion, nur anwendbar durch
?rztliches Praxislaboratorium im Rahmen
der Pr?senzdiagnostik nach Artikel 54
Absatz 1 Buchstabe a KVV und Kapitel
5.1.2 der Analysenliste
	Limitation: g ?ltig ab 1.5.2004 bis 31.12.2005
___________________________________________________________
*Anonyme Position
1  Nur f?r Spit?ler
2 Nur f?r autorisierte Medizinalpersonen in Substitutions- oder Entzugsbehandlungen
ihrer eigenen Patienten
3 Nur f?r Spit?ler und Pneumologen
4 Nur f?r Spit?ler, Pneumologen und H?matologen
																																																										130
				EOS
				begin
					res1 = @index_handler.parse_page(page_1, 129, @parser)
					res2 = @index_handler.parse_page(page_2, 130, @parser)
				end
				item1 = res1.last
				item2 = res2.first
				expected_res_1 = [
					{
					:code							=>		'8000.00',
					:group						=>		'8000',
					:position					=>		'00',
					:taxpoints				=>		8,
					:description			=>		'ABO/D-Antigen, Kontrolle nach Empfehlungen BSD SRK "Erythrozytenserologische Untersuchungen an Patientenproben"',
					:taxpoint_type		=>		:default,
					:permissions			=>		[['Teilliste 2','Nur f?r Spit?ler']],
					:list_title				=>		nil,
					:analysis_revision	=>	'C',
				},
				{
					:code						=>		'8006.00',
					:group					=>		'8006',
					:position				=>		'00',
					:taxpoints			=>		9, 
					:description		=>		'Alanin-Aminotransferase (ALAT)',
					:taxpoint_type	=>		:default,
					:permissions		=>		[['Teilliste 2', nil]],
					:list_title			=>		nil,
				},
				{
					:code						=>		'8007.00',
					:group					=>		'8007',
					:position				=>		'00',
					:taxpoints			=>		9,
					:description		=>		'Albumin, chemisch',
					:taxpoint_type	=>		:default,
					:permissions		=>		[['Teilliste 2', nil]],
					:list_title			=>		nil,
				},
				{
					:code						=>		'8036.00',
					:group					=>		'8036',
					:position				=>		'00',
					:taxpoints			=>		16,
					:description		=>		'Amphetamine, ql (Urin) (im Screening mit anderen Suchtstoffen: siehe 8535.04/05)',
					:taxpoint_type	=>		:default,
					:permissions		=>		[['Teilliste 2','Nur f?r autorisierte Medizinalpersonen in Substitutions- oder Entzugsbehandlungen ihrer eigenen Patienten']],
					:list_title			=>		nil,
				},
				{    
					:code						=>		'8129.00',
					:group					=>		'8129',
					:position				=>		'00',
					:taxpoints			=>		30,
					:description		=>		'Blutgase (pH, pCO, pO abgeleitete Werte)',
					:taxpoint_type	=>		:default,
					:permissions		=>		[['Teilliste 2','Nur f?r Spit?ler und Pneumologen']],
					:list_title			=>		nil,
				},
				{
					:code							=>		'8129.10',
					:group						=>		'8129',
					:position					=>		'10',
					:description			=>		'Oxymetrieblock (Oxyh?moglobin, Carboxyh?moglobin, Meth?moglobin)',
					:taxpoints				=>		50,
					:list_title				=>		nil,
					:permissions			=>		[['Teilliste 2', 'Nur f?r Spit?ler, Pneumologen und H?matologen']],
					:taxpoint_type		=>		:default
				},
					{
					:code								=>	'8191.00',
					:group							=>	'8191',
					:position						=>	'00',
					:taxpoints					=>	10,
					:description				=>	'Spezielle Mikroskopie, Nativpr?parat (Dunkelfeld, Polarisation, Phasenkontrast)',
					:analysis_revision	=>	"N",
					:list_title					=>	nil,
					:permissions				=>	[['Teilliste 2', nil]],
					:taxpoint_type			=>	:default,
				}
				]
				expected = {
					:code								=>	'8191.00',
					:group							=>	'8191',
					:position						=>	'00',
					:taxpoints					=>	10,
					:description				=>	'Spezielle Mikroskopie, Nativpr?parat (Dunkelfeld, Polarisation, Phasenkontrast)',
					:analysis_revision	=>	"N",
					:list_title					=>	nil,
					:permissions				=>	[['Teilliste 2',nil]],
					:taxpoint_type			=>	:default,
				}
				assert_equal(expected[:analysis_revision], item1[:analysis_revision])
				assert_equal(7, res1.size)
				assert_equal(expected_res_1.first, res1.first)
				assert_equal(expected_res_1.last, res1.last)
				assert_equal(expected_res_1.at(4), res1.at(4))
				assert_equal(expected_res_1, res1)
				expected = [
					{
					:code									=>	'8560.10',	
					:analysis_revision		=>	'N',
					:group								=>	'8560',
					:position							=>	'10',
					:taxpoints						=>	6,
					:description					=>	'H ?matologische Untersuchungen mit QBC-Methode',
					:limitation						=>	'nur f?r H?moglobin und H?matokrit. G?ltig ab 1.1.2006 bis 31.12.2006.',
					:list_title						=>	nil,
					:permissions					=>	[['Teilliste 2', nil]],
					:taxpoint_type				=>	:default,
				},
				{
					:code									=>	'8572.00',
					:group								=>	'8572',
					:position							=>	'00',
					:taxpoints						=>	9,
					:description					=>	'Triglyceride',
					:list_title						=>	nil,
					:permissions					=>	[['Teilliste 2', nil]],
					:taxpoint_type				=>	:default,
				},
				{
					:code									=>	'8574.11',
					:group								=>	'8574',
					:position							=>	'11',
					:taxpoints						=>	16,
					:description					=>	'Troponin (T oder I), Schnelltest, nicht kumulierbar mit 8384.00 Kreatin-Kinase (CK), total',
					:list_title						=>	nil,
					:permissions					=>	[['Teilliste 2', nil]],
					:taxpoint_type				=>	:default,
				},
				{
					:code									=>	'8578.00',
					:group								=>	'8578',
					:position							=>	'00',
					:taxpoints						=>	9,
					:description					=>	'Urat',
					:list_title						=>	nil,
					:taxpoint_type				=>	:default,
					:permissions					=>	[['Teilliste 2', nil]],
				},
				{
					:code									=>	'8587.00',
					:group								=>	'8587',
					:position							=>	'00',
					:taxpoints						=>	25,
					:description					=>	'Vertr ?glichkeitsprobe: Kreuzprobe nach Empfehlungen BSD SRK "Erythrozytenserologische Untersuchungen an Patientenproben", pro Erythrozytenkonzentrat',
					:list_title						=>	nil,
					:permissions					=>	[['Teilliste 2', nil]],
					:taxpoint_type				=>	:default,
					:analysis_revision		=>	'C',
				},
				{
					:code									=>	'9116.40',
					:group								=>	'9116',
					:position							=>	'40',
					:taxpoints						=>	12,
					:permissions					=>	[['Teilliste 2', nil]],
					:list_title						=>	nil,
					:description					=>	'HIV-1+2-Antik?rper (Screening) Schnelltest, ql',
					:taxpoint_type				=>	:default,
					:anonymous						=>	true,
				},
				{
					:analysis_revision		=>	'S',
					:code									=>	'9710.00',
					:group								=>	'9710',
					:position							=>	'00',
					:taxpoints						=>	8,
					:description					=>	'Blutentnahme, Kapillarblut oder Venenpunktion, nur anwendbar durch ?rztliches Praxislaboratorium im Rahmen der Pr?senzdiagnostik nach Artikel 54 Absatz 1 Buchstabe a KVV und Kapitel 5.1.2 der Analysenliste',
					:limitation						=>	'g ?ltig ab 1.5.2004 bis 31.12.2005',
					:taxpoint_type				=>	:default,
					:permissions					=>	[['Teilliste 2', nil]],
					:list_title						=>	nil,
				},
				] 
				expected_res2_first = {	
					:code									=>	'8560.10',	
					:analysis_revision		=>	'N',
					:group								=>	'8560',
					:position							=>	'10',
					:taxpoints						=>	6,
					:description					=>	'H ?matologische Untersuchungen mit QBC-Methode',
					:limitation						=>	'nur f?r H?moglobin und H?matokrit. G?ltig ab 1.1.2006 bis 31.12.2006.',
					:list_title						=>	nil,
					:permissions					=>	[['Teilliste 2', nil]],
					:taxpoint_type				=>	:default,
				}
				expected_res2_fifth = {
					:code									=>	'8587.00',
					:group								=>	'8587',
					:position							=>	'00',
					:taxpoints						=>	25,
					:description					=>	'Vertr ?glichkeitsprobe: Kreuzprobe nach Empfehlungen BSD SRK "Erythrozytenserologische Untersuchungen an Patientenproben", pro Erythrozytenkonzentrat',
					:list_title						=>	nil,
					:permissions					=>	[['Teilliste 2', nil]],
					:taxpoint_type				=>	:default,
					:analysis_revision		=>	'C',
				}
				assert_equal(expected_res2_fifth, res2.at(4))
				assert_equal(expected_res2_first, res2.first)
				assert_equal(expected, res2)
			end
			def test_fr_index_finder__1
				src = <<-EOS
Liste systématique des analyses et annexes

Chapitre 1: Chimie / Hématologie / Immunologie....................41
Chapitre 2: Génétique
2.1 Remarques.................75
2.2 Liste des analyses..................76
2.2.1 Analyses des chromosomes.....................76
Chapitre 3: Microbiologie
3.1 Virologie...................85
3.2 Bactériologie / mycologie
Chapitre 4: Autres
4.1 Positions générales...............109
				EOS
				begin
					result = @handler.next_pagehandler(src)
				end
				expected = {
					41	=>	'Chimie/Hématologie/Immunologie',
					75	=>	'Génétique',
					85	=>	'Microbiologie',
					109	=>	'Positions générales',
				}
				assert_equal(expected, result.index)
			end
			def test_fr_index_finder__2
				src = <<-EOS
5.1 Annexe A: Analyses effectu?es dans le cadre des soins de base
5.1.1 Consid?rations g?n?rales......................123
5.1.2 Laboratoire de cabinet m?dical...........124
5.2 Annexe B: Analyses prescrites par des chiropraticiens.........139
5.3 Annexe C: Analyses prescrites par des sages-femmes....141

Liste alphab?tique des analyses (avec synonymes)...143
				EOS
				begin
					result = @handler.next_pagehandler(src)
				end
				expected = {
				123	=>	'Analyses effectu?es dans le cadre des soins de base',
				139	=>	'Analyses prescrites par des chiropraticiens',
				141	=>	'Analyses prescrites par des sages-femmes',
				}
				assert_equal(expected, result.index)
			end
			def test_fr_index_finder__3
				src = <<-EOS

Table des matières

                Remarques préliminaires

                1. Bases légales..............................................................................5
                     1.1  Extraits de la loi fédérale du 18 mars 1994 sur
                   l~Rassurance-maladie (LAMal)...............................................5
                     1.2  Extraits de l~Rordonnance du 27 juin 1995 sur
                   l~Rassurance-maladie (OAMal).............................................13
                     1.3  Extraits de l~Rordonnance du 29 septembre 1995
                            sur les prestations dans l~Rassurance obligatoire des
                            soins en cas de maladie (OPAS).......................................20
                  2.  Commentaires des dispositions particulières de la LAMal,
                     de l'OAMal et de l'OPAS...........................................................24
                     2.1  Conditions générales d~Radmission pour les laboratoires....24
                     2.2  Conditions d~Radmission particulières pour les différents
                            types de laboratoires..........................................................25
                   2.2.1 Laboratoires autorisés à effectuer uniquement
                                     des analyses des soins de base..............................25
                   2.2.2 Laboratoires autorisés à effectuer d~Rautres ana-
                                     lyses en plus des analyses des soins de base........25
                   2.2.3 Laboratoires autorisés à effectuer des analyses
                                     du chapitre Génétique de la liste des analyses........26
                   2.2.4 Laboratoires autorisés à effectuer des analyses
                                     du chapitre Microbiologie de la liste des analyses...27
                   2.2.5 Laboratoires spéciaux..............................................28
                     2.3  Annexes à la liste des analyses.........................................28
                     2.4  La garantie de la qualité, condition de remboursement.....29
                     2.5  Analyses de laboratoire effectuées à l~Rétranger.................30
                     2.6  Intermédiaires des analyses de laboratoire.......................31
                 2.7  Facturation.........................................................................31
                     2.8  Contrôle de la prescription des analyses...........................32
                     2.9  Communication des renseignements.................................32
                 3.  Dispositifs médicaux pour le diagnostic in vitro (DIV)...............33
                4. Demandes de modifications de la liste des analyses................33
                 5. Tarif ...........................................................................................35
                6.                    Systématique des numéros de position dans la liste des
                 analyses ....................................................................................37
                 7. Abréviations..............................................................................37
                8. Remarques concernant la présente édition..............................39
                Chapitre 1:  Chimie / Hématologie / Immunologie..........................41
                
                Chapitre 2:  Génétique
                 2.1                                       Remarques..........................................................................75
                    2.2  Liste des analyses...............................................................76
                              2.2.1  Analyses des chromosomes.....................................76
                                   2.2.2 Analyses moléculaires..............................................78
                                   
                                   Chapitre 3:  Microbiologie
                                    3.1                                       Virologie...............................................................................85
                                       3.2  Bactériologie / mycologie.....................................................97
                                            3.2.1 Remarques...............................................................97
                                                      3.2.2  Liste des analyses....................................................97
                                                       3.3 Parasitologie......................................................................106
                                                       
                                                       Chapitre 4:  Autres
                                                        4.1                                       Positions générales...........................................................109
                                                         4.2 Positions anonymes...........................................................111
                                                          4.3 Blocs d\'analyses fixes........................................................120
                                                             4.4  Liste des auto-anticorps rares...........................................121
                                                             
                                                             Chapitre 5:  Annexes à la liste des analyses................................123
                                                               5.1 Annexe A: Analyses effectuées dans le cadre des
                                                                         soins de base
                                                                              5.1.1 Considérations générales.......................................123
                                                                                        5.1.2  Laboratoire de cabinet médical...............................124
                                                                                                       5.1.2.1 Définition des "analyses dans le cadre des
                                                                                                            soins de base" pour le laboratoire de
                                                                                                                 cabinet médical................................................124
                                                                                                                        5.1.2.2 Définition: "laboratoire de cabinet médical".....124
                                                                                                                               5.1.2.3 Définition: "diagnostic en présence du
                                                                                                                                    patient".............................................................125
                                                                                                                                              5.1.3  Analyses dans le cadre des soins de base
                                                                                                                                                                  au sens strict...........................................................127
                                                                                                                                                                            5.1.4  Liste élargie pour les médecins spécialistes...........132
        5.2 Annexe B:  Analyses prescrites par des chiropraticiens....139
        5.3 Annexe C:  Analyses prescrites par des sages-femmes...141
                
                Liste alphabétique des analyses (avec synonymes).........143
                
				EOS
				begin
					result = @handler.next_pagehandler(src)
				end
				expected = {
				5		=>	'Bases légales',
				24	=>	'Commentaires des dispositions particulières de la LAMal, de l\'OAMal et de l\'OPAS',
				33	=>	'Demandes de modifications de la liste des analyses',
				35	=>	'Tarif',
				37	=>	'Abréviations',
				39	=>	'Remarques concernant la présente édition',
				41	=>	'Chimie/Hématologie/Immunologie',
				75	=>	'Génétique',
				85	=>	'Microbiologie',
				109	=>	'Positions générales',
				111	=>	'Positions anonymes',
				120	=>	'Blocs d\'analyses fixes',
				121	=>	'Liste des auto-anticorps rares',
				123	=>	'Analyses effectuées dans le cadre des soins de base',
				139	=>	'Analyses prescrites par des chiropraticiens',
				141	=>	'Analyses prescrites par des sages-femmes',
				}
				assert_equal(expected, result.index)
			end
			def test_fr_index_finder__4
				src = <<-EOS
Chapitre 4: Autres
4.1                                       Positions générales.................................109
4.2 Positions anonymes..........................................................111
 4.3 Blocs d~Ranalyses fixes..............................................................120
				EOS
				begin
					result = @handler.next_pagehandler(src) 
				end
				expected = {
					#109	=>	'Positions g?n?rales',
					109	=>	'Positions générales',
					111	=>	'Positions anonymes',
					120	=>	'Blocs d\'analyses fixes',
				}
				assert_equal(expected, result.index)
			end
			def test_fr_index_finder__5
				src = <<-EOS
4.3 Blocs d'analyses fixes........................................................120 
4.4 Liste des auto-anticorps rares...........................................121
EOS
				begin
					result = @handler.next_pagehandler(src)
				end
				expected = {
					120	=>	'Blocs d\'analyses fixes',
					121	=>	'Liste des auto-anticorps rares',
				}
				assert_equal(expected, result.index)
			end
			def test_fr_parse_pages__1
				page_1 = <<-EOS
				Liste partielle 2

				Pour les analyses suivantes, le tarif de la liste des analyses (valeur
				du point et nombre de points) s'applique ?galement aux laboratoires
				de cabinets m?dicaux.

				R?v.    No pos.     A   TP     D?nomination (liste des soins de base, liste partielle 2)

				C     8000.00 1       8  ABO/D, contr?le selon les recommandations
				STS CRS "S?rologie ?rythrocytaire chez le
				patient"
				      8006.00          9 Alanine-aminotransf?rase (ALAT)
				      8007.00          9 Albumine, chimique
				      8008.50         12 Albumine urinaire, sq
				      8012.00          9 Phosphatase alcaline
				      8036.00 2      16   Amph ?tamines, ql (urine) (screening avec
				d'autres drogues: cf. 8535.04/05)
				130
				EOS
				page_2 = <<-EOS
R?v.    No pos.     A   TP     D?nomination (liste des soins de base, liste partielle 2)

				C     8560.00          9 Thrombocytes, num?ration, d?termination
				manuelle, cumulable avec 8210.00
				?rythrocytes (num?ration), 8273.00
				h?matocrite, 8275.00 h?moglobine et
				8406.00 leucocytes (num?ration), jusqu'?
				un total de max. 15 points (h?mogramme
				II)
				Limitation: pas avec la m?thode QBC
				N     8560.10          6    Examens h?matologiques avec m?thode
				QBC
				Limitation: uniquement pour h?moglobine et
				h?matocrite. Valable du 1.1.2006 au 31.12.2006
				      8572.00          9 Triglyc?rides
				      8574.11         16   Troponine (T ou I), test rapide, non cumula-
				ble avec 8384.00 Cr?atine-kinase (CK),
				total
				      8578.00          9 Urate
				C     8587.00       25   Test de compatibilit?: compatibilit? crois?e,
				par concentr? ?rythrocitaire, selon les
				recommandations STS CRS "S?rologie
				?rythrocytaire chez le patient"
				      9116.40    *  12   HIV 1 + 2, d?pistage des anticorps (par test
				rapide), ql
				S     9710.00          8    Pr?l?vement de sang capillaire ou de sang
				                                             veineux, uniquement pour les laboratoires
				de cabinets m?dicaux dans le cadre d'un
				diagnostic en pr?sence du patient au sens
				de l'art. 54, al. 1, lt. a, OAMal et du chapitre
				5.1.2 de la liste des analyses
				  Limitation: valable du 1.5.2004 au 31.12.2005

				______________________________________________    __________________
				* position anonyme
				1 seulement pour h?pitaux
				2 seulement pour les personnes m?dicales autoris?es, dans le cadre de traitements de
				substitution ou de sevrage de leurs propres patients
				3 seulement pour h?pitaux et pneumologues
				4 seulement pour h?pitaux, pneumologues et h?matologues
				                                                                                                   131
				
				EOS
				begin
					res1 = @index_handler.parse_page(page_1, 130, @parser)
					res2 = @index_handler.parse_page(page_2, 131, @parser)
				end
				expected_res1 = [
					{
					:code									=>	'8000.00',	
					:analysis_revision		=>	'C',
					:group								=>	'8000',
					:position							=>	'00',
					:taxpoints						=>	8,
					:description					=>	'ABO/D, contr?le selon les recommandations STS CRS "S?rologie ?rythrocytaire chez le patient"',
					:list_title						=>	nil,
					:permissions					=>	[['Liste partielle 2', 'seulement pour h?pitaux']],
					:taxpoint_type				=>	:default,
				},
					{
					:code									=>	'8006.00',	
					:group								=>	'8006',
					:position							=>	'00',
					:taxpoints						=>	9,
					:description					=>	'Alanine-aminotransf?rase (ALAT)',
					:list_title						=>	nil,
					:permissions					=>	[['Liste partielle 2', nil]],
					:taxpoint_type				=>	:default,
				},
					{
					:code									=>	'8007.00',	
					:group								=>	'8007',
					:position							=>	'00',
					:taxpoints						=>	9,
					:description					=>	'Albumine, chimique',
					:list_title						=>	nil,
					:permissions					=>	[['Liste partielle 2', nil]],
					:taxpoint_type				=>	:default,
				},
					{
					:code									=>	'8008.50',	
					:group								=>	'8008',
					:position							=>	'50',
					:taxpoints						=>	12,
					:description					=>	'Albumine urinaire, sq',
					:list_title						=>	nil,
					:permissions					=>	[['Liste partielle 2', nil]],
					:taxpoint_type				=>	:default,
				},
					{
					:code									=>	'8012.00',	
					:group								=>	'8012',
					:position							=>	'00',
					:taxpoints						=>	9,
					:description					=>	'Phosphatase alcaline',
					:list_title						=>	nil,
					:permissions					=>	[['Liste partielle 2', nil]],
					:taxpoint_type				=>	:default,
				},
					{
					:code									=>	'8036.00',	
					:group								=>	'8036',
					:position							=>	'00',
					:taxpoints						=>	16,
					:description					=>	'Amph ?tamines, ql (urine) (screening avec d\'autres drogues: cf. 8535.04/05)',
					:list_title						=>	nil,
					:permissions					=>	[['Liste partielle 2', 'seulement pour les personnes m?dicales autoris?es, dans le cadre de traitements de substitution ou de sevrage de leurs propres patients']],
					:taxpoint_type				=>	:default,
				},
				]
				expected_res2 = [
					{
					:code									=>	'8560.00',	
					:group								=>	'8560',
					:position							=>	'00',
					:taxpoints						=>	9,
					:description					=>	'Thrombocytes, num?ration, d?termination manuelle, cumulable avec 8210.00 ?rythrocytes (num?ration), 8273.00 h?matocrite, 8275.00 h?moglobine et 8406.00 leucocytes (num?ration), jusqu\'? un total de max. 15 points (h?mogramme II)',
					:limitation						=>	'pas avec la m?thode QBC',
					:analysis_revision		=>	'C',
					:list_title						=>	nil,
					:permissions					=>	[['Liste partielle 2', nil]],
					:taxpoint_type				=>	:default,
				},
					{
					:code									=>	'8560.10',	
					:group								=>	'8560',
					:position							=>	'10',
					:taxpoints						=>	6,
					:description					=>	'Examens h?matologiques avec m?thode QBC',
					:analysis_revision		=>	'N',
					:limitation						=>	'uniquement pour h?moglobine et h?matocrite. Valable du 1.1.2006 au 31.12.2006',
					:list_title						=>	nil,
					:permissions					=>	[['Liste partielle 2', nil]],
					:taxpoint_type				=>	:default,
				},
					{
					:code									=>	'8572.00',	
					:group								=>	'8572',
					:position							=>	'00',
					:taxpoints						=>	9,
					:description					=>	'Triglyc?rides',
					:list_title						=>	nil,
					:permissions					=>	[['Liste partielle 2', nil]],
					:taxpoint_type				=>	:default,
				},
					{
					:code									=>	'8574.11',	
					:group								=>	'8574',
					:position							=>	'11',
					:taxpoints						=>	16,
					:description					=>	'Troponine (T ou I), test rapide, non cumulable avec 8384.00 Cr?atine-kinase (CK), total',
					:list_title						=>	nil,
					:permissions					=>	[['Liste partielle 2', nil]],
					:taxpoint_type				=>	:default,
				},
					{
					:code									=>	'8578.00',	
					:group								=>	'8578',
					:position							=>	'00',
					:taxpoints						=>	9,
					:description					=>	'Urate',
					:list_title						=>	nil,
					:permissions					=>	[['Liste partielle 2', nil]],
					:taxpoint_type				=>	:default,
				},
					{
					:code									=>	'8587.00',	
					:group								=>	'8587',
					:position							=>	'00',
					:taxpoints						=>	25,
					:description					=>	'Test de compatibilit?: compatibilit? crois?e, par concentr? ?rythrocitaire, selon les recommandations STS CRS "S?rologie ?rythrocytaire chez le patient"',
					:analysis_revision		=>	'C',
					:list_title						=>	nil,
					:permissions					=>	[['Liste partielle 2', 'seulement pour h?pitaux']],
					:taxpoint_type				=>	:default,
				},
					{
					:code									=>	'9116.40',	
					:group								=>	'9116',
					:position							=>	'40',
					:taxpoints						=>	12,
					:description					=>	'HIV 1 + 2, d?pistage des anticorps (par test rapide), ql',
					:list_title						=>	nil,
					:anonymous						=>	true,
					:permissions					=>	[['Liste partielle 2', nil]],
					:taxpoint_type				=>	:default,
				},
					{
					:code									=>	'9710.00',	
					:group								=>	'9710',
					:position							=>	'00',
					:taxpoints						=>	8,
					:description					=>	'Pr?l?vement de sang capillaire ou de sang veineux, uniquement pour les laboratoires de cabinets m?dicaux dans le cadre d\'un diagnostic en pr?sence du patient au sens de l\'art. 54, al. 1, lt. a, OAMal et du chapitre 5.1.2 de la liste des analyses',
					:limitation						=>	'valable du 1.5.2004 au 31.12.2005',
					:list_title						=>	nil,
					:analysis_revision		=>	'S',
					:permissions					=>	[['Liste partielle 2', nil]],
					:taxpoint_type				=>	:default,
				},
				]
				assert_equal(expected_res1.at(5), res1.at(5))
		#		assert_equal(expected_res2, res2)
			end
			def test_fr_parse_page__1
				page_1 = <<-EOS
Allergologie et immunologie clinique
R?v. No pos. A TP D?nomination (liste allergologie et immunologie clin.)
8317.00 35 Immunoglobuline IgE totale, qn

Dermatologie et v?n?rologie
8306.01 35 Test de gonflement hyposmotique (spermatozo?des)

Endocrinologie - diab?tologie
8149.00 9 Calcium total (sang, plasma, s?rum)

Gastro-ent?rologie
9366.00 15 Ur?ase, test ? l'~ (Helicobacter pylori)

Gyn?cologie et obst?trique
8455.20 60 P?n?tration, test de ~

H?matologie
C 8000.00 8 ABO/D, contr?le selon les recommandations STS CRS "S?rologie ?rythrocytaire chez le patient"

M?decine physique et r?adaptation
8388.00 20 Cristaux, recherche en lumi?re polaris?e

M?decine tropicale
9356.30 25 Microscopie sp?ciale, examen par ~ (orange acridine, Ziehl-Neelsen, auramin-rhodamine, y compris sur fond noir, contraste de phase, etc., KOH, recherche de champignons)

P?diatrie
8543.00 40 Th?ophylline (sang)

Rhumatologie
8388.01 20 Cristaux, recherche en lumi?re polaris?e
				134
				EOS
				page_2 = <<-EOS
8600.00 25 Cellules, num?ration et diff?rentiation apr?s enrichissement et coloration de liquides biologiques

8006.00 9 Alanine-aminotransf?rase (ALAT)
				135
				EOS
				begin
					res = @index_handler.parse_page(page_1, 134, @parser)
					res2 = @index_handler.parse_page(page_2, 135, @parser)
				end
				expected = [
					{
					:code									=>	'8317.00',	
					:group								=>	'8317',
					:position							=>	'00',
					:taxpoints						=>	35,
					:description					=>	'Immunoglobuline IgE totale, qn',
					:list_title						=>	nil,
					:permissions					=>	[['Allergologie et immunologie clinique', nil]],
					:taxpoint_type				=>	nil,
				},
					{
					:code									=>	'8306.01',	
					:group								=>	'8306',
					:position							=>	'01',
					:taxpoints						=>	35,
					:description					=>	'Test de gonflement hyposmotique (spermatozo?des)',
					:list_title						=>	nil,
					:permissions					=>	[['Dermatologie et v?n?rologie', nil]],
					:taxpoint_type				=>	nil,
				},
					{
					:code									=>	'8149.00',	
					:group								=>	'8149',
					:position							=>	'00',
					:taxpoints						=>	9,
					:description					=>	'Calcium total (sang, plasma, s?rum)',
					:list_title						=>	nil,
					:permissions					=>	[['Endocrinologie - diab?tologie', nil]],
					:taxpoint_type				=>	nil,
				},
					{
					:code									=>	'9366.00',	
					:group								=>	'9366',
					:position							=>	'00',
					:taxpoints						=>	15,
					:description					=>	'Ur?ase, test ? l\'~ (Helicobacter pylori)',
					:list_title						=>	nil,
					:permissions					=>	[['Gastro-ent?rologie', nil]],
					:taxpoint_type				=>	nil,
				},
					{
					:code									=>	'8455.20',	
					:group								=>	'8455',
					:position							=>	'20',
					:taxpoints						=>	60,
					:description					=>	'P?n?tration, test de ~',
					:list_title						=>	nil,
					:permissions					=>	[['Gyn?cologie et obst?trique', nil]],
					:taxpoint_type				=>	nil,
				},
					{
					:code									=>	'8000.00',	
					:group								=>	'8000',
					:position							=>	'00',
					:analysis_revision		=>	'C',
					:taxpoints						=>	8,
					:description					=>	'ABO/D, contr?le selon les recommandations STS CRS "S?rologie ?rythrocytaire chez le patient"',
					:list_title						=>	nil,
					:permissions					=>	[['H?matologie', nil]],
					:taxpoint_type				=>	nil,
				},
					{
					:code									=>	'8388.00',	
					:group								=>	'8388',
					:position							=>	'00',
					:taxpoints						=>	20,
					:description					=>	'Cristaux, recherche en lumi?re polaris?e',
					:list_title						=>	nil,
					:permissions					=>	[['M?decine physique et r?adaptation', nil]],
					:taxpoint_type				=>	nil,
				},
					{
					:code									=>	'9356.30',	
					:group								=>	'9356',
					:position							=>	'30',
					:taxpoints						=>	25,
					:description					=>	'Microscopie sp?ciale, examen par ~ (orange acridine, Ziehl-Neelsen, auramin-rhodamine, y compris sur fond noir, contraste de phase, etc., KOH, recherche de champignons)',
					:list_title						=>	nil,
					:permissions					=>	[['M?decine tropicale', nil]],
					:taxpoint_type				=>	nil,
				},
					{
					:code									=>	'8543.00',	
					:group								=>	'8543',
					:position							=>	'00',
					:taxpoints						=>	40,
					:description					=>	'Th?ophylline (sang)',
					:list_title						=>	nil,
					:permissions					=>	[['P?diatrie', nil]],
					:taxpoint_type				=>	nil,
				},
					{
					:code									=>	'8388.01',	
					:group								=>	'8388',
					:position							=>	'01',
					:taxpoints						=>	20,
					:description					=>	'Cristaux, recherche en lumi?re polaris?e',
					:list_title						=>	nil,
					:permissions					=>	[['Rhumatologie', nil]],
					:taxpoint_type				=>	nil,
				}
				]
				expected_2 = [
					{
					:code						=>	'8600.00',
					:group					=>	'8600',
					:position				=>	'00',
					:taxpoints			=>	25,
					:taxpoint_type	=>	nil,
					:list_title			=>	nil,
					:permissions		=>	[['Rhumatologie', nil]],
					:description		=>	'Cellules, num?ration et diff?rentiation apr?s enrichissement et coloration de liquides biologiques',
				},
					{
					:code						=>	'8006.00',
					:group					=>	'8006',
					:position				=>	'00',
					:description		=>	'Alanine-aminotransf?rase (ALAT)',
					:taxpoints			=>	9,
					:taxpoint_type	=>	nil,
					:list_title			=>	nil,
					:permissions		=>	[['Rhumatologie', nil]]
					},
				]
#				assert_equal(expected, res)
				assert_equal(expected_2, res2)
			end
			def test_fr_parse_page__2
				src = <<-EOS
Analyses prescrites par des chiropraticiens
(art. 62 1er al. let. b OAMal)

Liste des analyses
R?v. No pos. A TP D?nomination (list chiropraticiens)
8006.001 9 Alanine-aminotransf?rase (ALAT)
8012.00 9 Phosphatase alcaline
8013.01 60 Phosphatase alcaline, osseuse
1 test restriction
139
				EOS
				begin
					result = @index_handler.parse_page(src, 139, @parser)
				end
				expected = [
					{
						:code						=>	'8006.00',
						:group					=>	'8006',
						:position				=>	'00',
						:description		=>	'Alanine-aminotransf?rase (ALAT)',
						:permissions		=>	[],
						:list_title			=>	nil,
						:taxpoint_type	=>	nil,
						:taxpoints			=>	9,
				},
					{
						:code						=>	'8012.00',
						:group					=>	'8012',
						:position				=>	'00',
						:description		=>	'Phosphatase alcaline',
						:permissions		=>	[],
						:list_title			=>	nil,
						:taxpoint_type	=>	nil,
						:taxpoints			=>	9,
				},
					{
						:code						=>	'8013.01',
						:group					=>	'8013',
						:position				=>	'01',
						:description		=>	'Phosphatase alcaline, osseuse',
						:permissions		=>	[],
						:list_title			=>	nil,
						:taxpoint_type	=>	nil,
						:taxpoints			=>	60,
				},
				]
				assert_equal(expected, result)
			end
      def test_next_pagehandler
        txt = "vorbemerkungen"
        @handler.instance_eval('@index = "index"')
        assert_kind_of(ODDB::AnalysisParse::IndexHandler, @handler.next_pagehandler(txt))
      end
		end
	end
end

module ODDB
  module AnalysisParse
    class TestPageHandler < Test::Unit::TestCase
      include FlexMock::TestCase
      def setup
        @handler = ODDB::AnalysisParse::PageHandler.new
      end
      def test_next_pagehandler
        assert_equal(@handler, @handler.next_pagehandler('txt'))
      end
      def test_analyze
        page = flexmock('page', :text => 'text')
        assert_equal(@handler, @handler.analyze(page, 'pagenum'))
      end
    end

    class TestIndexHandler < Test::Unit::TestCase
      include FlexMock::TestCase
      def setup
        index = [
          'Chimie/Hématologie/Immunologie',
          'genetik',
          'mikrobiologie',
          'allgemeine positionen',
          'Anonyme Positionen',
          'Fixe Analysenblöcke',
          'Liste seltener Autoantikörper',
          'analyses effectuées dans le cadre des soins de base',
          'Von Chiropraktoren oder Chiropraktorinnen veranlasste Analysen',
          'Von Hebammen veranlasste Analysen',
        ]
        @page    = flexmock('page', :text => nil)
        @handler = ODDB::AnalysisParse::IndexHandler.new(index)
      end
      def test_analayze__page_0
        assert_kind_of(ODDB::AnalysisParse::IndexHandler, @handler.analyze(@page, 0))
      end
      def test_analayze__page_1
        assert_kind_of(ODDB::AnalysisParse::IndexHandler, @handler.analyze(@page, 1))
      end
      def test_analayze__page_2
        assert_kind_of(ODDB::AnalysisParse::IndexHandler, @handler.analyze(@page, 2))
      end
      def test_analayze__page_3
        assert_kind_of(ODDB::AnalysisParse::IndexHandler, @handler.analyze(@page, 3))
      end
      def test_analayze__page_4
        assert_kind_of(ODDB::AnalysisParse::IndexHandler, @handler.analyze(@page, 4))
      end
      def test_analayze__page_5
        assert_kind_of(ODDB::AnalysisParse::IndexHandler, @handler.analyze(@page, 5))
      end
      def test_analayze__page_6
        assert_kind_of(ODDB::AnalysisParse::IndexHandler, @handler.analyze(@page, 6))
      end
      def test_analayze__page_7
        assert_kind_of(ODDB::AnalysisParse::IndexHandler, @handler.analyze(@page, 7))
      end
      def test_analayze__page_8
        assert_kind_of(ODDB::AnalysisParse::IndexHandler, @handler.analyze(@page, 8))
      end
      def test_analayze__page_9
        assert_kind_of(ODDB::AnalysisParse::IndexHandler, @handler.analyze(@page, 9))
      end
      def test_positions
        assert_equal([], @handler.positions)
      end
      def test_parse_page
        ps     = {:code => 123, :abc => nil}
        parser = flexmock('parser',
                         :list_title= => nil,
                         :list_title  => 'list_title',
                         :permission= => nil,
                         :permission  => 'permission',
                         :parse_page  => [ps],
                         :footnotes   => {}
                         )
        positions = {123 => {}}
        @handler.instance_eval('@positions = positions')
        expected = [{:code=>123}]
        assert_equal(expected , @handler.parse_page('text', 0, parser))
      end
    end
  end # AnalysisParse
end # ODDB
