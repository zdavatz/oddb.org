#!/usr/bin/env ruby
# TestPageHandler -- oddb.org -- 12.04.2006 -- sfrischknecht@ywesee.com

$: << File.expand_path('../src', File.dirname(__FILE__))

require 'test/unit'
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
				EOS
				begin
					result = @handler.next_pagehandler(src)
					assert_kind_of(IndexFinder, result)
					expected = {
						33	=>	'Medizinprodukte für die In-vitro-Diagnostik (IVD)',
						5		=>	'Rechtsgrundlagen',
						24	=>	'Erläuterungen zu einzelnen Bestimmungen des KVG sowie der KVV und der KLV'
					}
					assert_equal(expected, result.index)
				end
			end
			def test_index_finder__5
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
						5		=>	'Rechtsgrundlagen',
						24	=>	'Erläuterungen zu einzelnen Bestimmungen des KVG sowie der KVV und der KLV'
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

Für diese Analysen gilt auch für das ärztliche Praxislaboratorium der
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
			8129.10 4      50  Oxymetrieblock (Oxyhämoglobin,
Carboxyhämoglobin, Methämoglobin)
N     8191.00         10   Spezielle Mikroskopie, Nativpräparat
(Dunkelfeld, Polarisation, Phasenkontrast)
																																																										129
				EOS
				page_2 = <<-EOS
Rev. Pos. Nr.  A TP  Bezeichnung (Liste Grundversorgung, Teilliste 2)

N     8560.10
		6    Hämatologische Untersuchungen mit QBC-
Methode
Limitation: nur für Hämoglobin und Hämatokrit.
Gültig ab 1.1.2006 bis 31.12.2006.
			8572.00          9  Triglyceride
			8574.11         16  Troponin (T oder I), Schnelltest, nicht
kumulierbar mit 8384.00 Kreatin-Kinase
(CK), total
			8578.00          9  Urat
C     8587.00 1      25   Verträglichkeitsprobe: Kreuzprobe nach
Empfehlungen BSD SRK "Erythrozyten-
serologische Untersuchungen an Patien-
tenproben", pro Erythrozytenkonzentrat
			9116.40    *  12   HIV-1+2 -Antikörper (Screening) Schnelltest,
ql
S     9710.00          8  Blutentnahme, Kapillarblut oder
Venenpunktion, nur anwendbar durch
ärztliches Praxislaboratorium im Rahmen
der Präsenzdiagnostik nach Artikel 54
Absatz 1 Buchstabe a KVV und Kapitel
5.1.2 der Analysenliste
	Limitation: gültig ab 1.5.2004 bis 31.12.2005
___________________________________________________________
*Anonyme Position
1  Nur für Spitäler
2 Nur für autorisierte Medizinalpersonen in Substitutions- oder Entzugsbehandlungen
ihrer eigenen Patienten
3 Nur für Spitäler und Pneumologen
4 Nur für Spitäler, Pneumologen und Hämatologen
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
					:permissions			=>		[['Teilliste 2','Nur für Spitäler']],
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
					:permissions		=>		[['Teilliste 2','Nur für autorisierte Medizinalpersonen in Substitutions- oder Entzugsbehandlungen ihrer eigenen Patienten']],
					:list_title			=>		nil,
				},
				{    
					:code						=>		'8129.00',
					:group					=>		'8129',
					:position				=>		'00',
					:taxpoints			=>		30,
					:description		=>		'Blutgase (pH, pCO, pO abgeleitete Werte)',
					:taxpoint_type	=>		:default,
					:permissions		=>		[['Teilliste 2','Nur für Spitäler und Pneumologen']],
					:list_title			=>		nil,
				},
				{
					:code							=>		'8129.10',
					:group						=>		'8129',
					:position					=>		'10',
					:description			=>		'Oxymetrieblock (Oxyhämoglobin, Carboxyhämoglobin, Methämoglobin)',
					:taxpoints				=>		50,
					:list_title				=>		nil,
					:permissions			=>		[['Teilliste 2', 'Nur für Spitäler, Pneumologen und Hämatologen']],
					:taxpoint_type		=>		:default
				},
					{
					:code								=>	'8191.00',
					:group							=>	'8191',
					:position						=>	'00',
					:taxpoints					=>	10,
					:description				=>	'Spezielle Mikroskopie, Nativpräparat (Dunkelfeld, Polarisation, Phasenkontrast)',
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
					:description				=>	'Spezielle Mikroskopie, Nativpräparat (Dunkelfeld, Polarisation, Phasenkontrast)',
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
					:description					=>	'Hämatologische Untersuchungen mit QBC-Methode',
					:limitation						=>	'nur für Hämoglobin und Hämatokrit. Gültig ab 1.1.2006 bis 31.12.2006.',
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
					:description					=>	'Verträglichkeitsprobe: Kreuzprobe nach Empfehlungen BSD SRK "Erythrozytenserologische Untersuchungen an Patientenproben", pro Erythrozytenkonzentrat',
					:list_title						=>	nil,
					:permissions					=>	[['Teilliste 2','Nur für Spitäler']],
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
					:description					=>	'HIV-1+2-Antikörper (Screening) Schnelltest, ql',
					:taxpoint_type				=>	:default,
					:anonymous						=>	true,
				},
				{
					:analysis_revision		=>	'S',
					:code									=>	'9710.00',
					:group								=>	'9710',
					:position							=>	'00',
					:taxpoints						=>	8,
					:description					=>	'Blutentnahme, Kapillarblut oder Venenpunktion, nur anwendbar durch ärztliches Praxislaboratorium im Rahmen der Präsenzdiagnostik nach Artikel 54 Absatz 1 Buchstabe a KVV und Kapitel 5.1.2 der Analysenliste',
					:limitation						=>	'gültig ab 1.5.2004 bis 31.12.2005',
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
					:description					=>	'Hämatologische Untersuchungen mit QBC-Methode',
					:limitation						=>	'nur für Hämoglobin und Hämatokrit. Gültig ab 1.1.2006 bis 31.12.2006.',
					:list_title						=>	nil,
					:permissions					=>	[['Teilliste 2', nil]],
					:taxpoint_type				=>	:default,
				}
				expected_res2_fifth = {
					:code									=>	'8587.00',
					:group								=>	'8587',
					:position							=>	'00',
					:taxpoints						=>	25,
					:description					=>	'Verträglichkeitsprobe: Kreuzprobe nach Empfehlungen BSD SRK "Erythrozytenserologische Untersuchungen an Patientenproben", pro Erythrozytenkonzentrat',
					:list_title						=>	nil,
					:permissions					=>	[['Teilliste 2', 'Nur für Spitäler']],
					:taxpoint_type				=>	:default,
					:analysis_revision		=>	'C',
				}
				assert_equal(expected_res2_fifth, res2.at(4))
				assert_equal(expected_res2_first, res2.first)
				assert_equal(expected, res2)
			end
		end
	end
end
