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
					:code					=>	'8606.00',
					:group				=>	'8606',
					:position			=>	'00',
					:taxpoints		=>	30,
					:description	=>	'Guthrie-Test',
					:list_title		=>	nil,
					:permission		=>	nil,
					:taxpoint_type	=>	nil,
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
					:code					=>	'9700.00',
					:position			=>	'00',
					:taxpoints		=>	12,
					:description	=>	'Bearbeitungstaxe für Auftragnehmer von externen Aufträgen, pro Patient und Auftrag; nur anwendbar durch Spitallaboratorien nach Artikel 54 Absatz 1 Buchstabe c und Absatz 2 KVV, durch Laboratorien nach Artikel 54 Absatz 3 KVV und durch die Offizin eines Apothekers oder einer Apothekerin nach Artikel 54 Absatz 1 Buchstabe c KVV',
					:list_title		=>	nil,
					:permission		=>	nil,
					:taxpoint_type	=>	nil,
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
					:code					=>	'9700.00',
					:group				=>	'9700',
					:position			=>	'00',
					:taxpoints		=>	12,
					:description	=>	'Bearbeitungstaxe für Auftragnehmer von externen Aufträgen, pro Patient und Auftrag; nur anwendbar durch Spitallaboratorien nach Artikel 54 Absatz 1 Buchstabe c und Absatz 2 KVV, durch Laboratorien nach Artikel 54 Absatz 3 KVV und durch die Offizin eines Apothekers oder einer Apothekerin nach Artikel 54 Absatz 1 Buchstabe c KVV',
					:list_title		=>	nil,
					:permission		=>	nil,
					:taxpoint_type	=>	nil,
				}
				expected_last = {
					:code					=>	'9704.00',
					:group				=>	'9704',
					:position			=>	'00',
					:taxpoints		=>	4,
					:description	=>	'Zuschlag für jeden weiteren km; nur anwendbar durch Laboratorien nach Artikel 54 Absatz 3 KVV',
					:list_title		=>	nil,
					:permission		=>	nil,
					:taxpoint_type	=>	nil,
				}
				expected_size = 4
				assert_equal(expected_size, result.size)
				assert_equal(expected_first, result.first)
				assert_equal(expected_last, result.last)
			end
			def test_fr_parse_page__1
				src = <<-EOS
Chapitre 4:  Autres

4.1 Positions générales

Remarques

Ces positions générales ne doivent être utilisées que pour les
traitements ambulatoires; pour les traitements effectués durant une
hospitalisation, le forfait comprend aussi les analyses (art. 49
LAMal). Elles ne doivent pas non plus être facturées dans un
laboratoire de cabinet médical.

Rév. No. pos.    TP    Dénomination (positions générales)

9700.00 12 Taxe administrative applicable aux demandes
externes, par patient et par prescription ;
uniquement pour les laboratoires d'hôpitaux
au sens de l'art. 54, al. 1, let c, et al. 2,
OAMal, les laboratoires au sens de l'art. 54,
al. 3, OAMal et les officines de pharmaciens
au sens de l'art. 54, al. 1, let. c, OAMal.
9701.00 8 Prélèvement de sang capillaire ou de sang
veineux ; uniquement pour les laboratoires
d'hôpitaux au sens de l'art. 54, al. 1, let. c, et
al. 2, OAMal, les laboratoires au sens de
l'art. 54, al. 3, OAMal et les officines de
pharmaciens au sens de l'art. 54, al. 1,
let. c, OAMal
9703.00 25 Supplément pour prélèvement de sang à
domicile, dans un rayon de 3 km ;
uniquement pour les laboratoires au sens de
l'art. 54, al. 3, OAMal
9704.00 4 Supplément pour chaque km en plus ;
uniquement pour les laboratoires au sens de
l'art. 54, al. 3, OAMal
9706.00     50   Supplément pour nuit (de 19 h à 7 h),
dimanche et jours fériés : par prescription (et
non par résultat) ; uniquement pour les
laboratoires d'hôpitaux au sens de l'art. 54,
al. 1, let. c et al. 2 OAMal et les laboratoires
au sens de l'art. 54, al. 3, OAMal

				                                                          109
				
				EOS
				begin
					result = @parser.parse_page(src, 109)
				end
				expected_first = {
					:code						=>	'9700.00',
					:group					=>	'9700',
					:position				=>	'00',
					:description		=>	'Taxe administrative applicable aux demandes externes, par patient et par prescription; uniquement pour les laboratoires d\'hôpitaux au sens de l\'art. 54, al. 1, let c, et al. 2, OAMal, les laboratoires au sens de l\'art. 54, al. 3, OAMal et les officines de pharmaciens au sens de l\'art. 54, al. 1, let. c, OAMal.',
					:taxpoints			=>	12,
					:taxpoint_type	=>	nil,
					:list_title			=>	nil,
					:permission			=>	nil,
				}
				expected_last = {
					:code						=>	'9706.00',
					:group					=>	'9706',
					:position				=>	'00',
					:description		=>	'Supplément pour nuit (de 19 h à 7 h), dimanche et jours fériés : par prescription (et non par résultat); uniquement pour les laboratoires d\'hôpitaux au sens de l\'art. 54, al. 1, let. c et al. 2 OAMal et les laboratoires au sens de l\'art. 54, al. 3, OAMal',
					:taxpoints			=>	50,
					:taxpoint_type	=>	nil,
					:list_title			=>	nil,
					:permission			=>	nil,
				}
				assert_equal(expected_first, result.first)
				assert_equal(expected_last, result.last)
			end
		end
	end
end
