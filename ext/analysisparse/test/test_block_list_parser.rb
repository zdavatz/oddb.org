#!/usr/bin/env ruby
# AnalysisParse::TestBlockListParser -- oddb -- 10.11.2005 -- hwyss@ywesee.com

$: << File.expand_path('../src', File.dirname(__FILE__))

require 'test/unit'
require 'block_list_parser'

module ODDB
	module AnalysisParse
		class TestBlockListParser < Test::Unit::TestCase
			def setup
				@parser = BlockListParser.new
			end
			def test_parse_line__1
				src = <<-EOS
8129.00 30 Blutgase C
pH
pCO2
pO2
Bikarbonat
Inkl. abgeleitete Werte
				EOS
				begin
					result = @parser.parse_line(src)
				end
				expected = {
					:code					=>	'8129.00',
					:group				=>	'8129',
					:position			=>	'00',
					:taxpoints		=>	30,
					:lab_areas		=>	['C'],
					:description	=>	'Blutgase pH pCO2 pO2 Bikarbonat Inkl. abgeleitete Werte',
					:list_title		=>	nil,
					:permission		=>	nil,
					:taxpoint_type	=>	nil,
				}
				assert_equal(expected, result)
			end
			def test_parse_line__2
				src =<<-EOS
8614.00 25 Lipidblock C
8158.00 Cholesterin total
8288.00 HDL-Cholesterin, ohne separate Füllung
8572.00 Triglyceride
				EOS
				begin
					result = @parser.parse_line(src)
				end
				expected = {
					:code						=>	'8614.00',
					:group					=>	'8614',
					:position				=>	'00',
					:taxpoints			=>	25,
					:description		=>	'Lipidblock 8158.00 Cholesterin total 8288.00 HDL-Cholesterin, ohne separate Füllung 8572.00 Triglyceride',
				:lab_areas			=>	['C'],
				:list_title			=>	nil,
				:taxpoint_type	=>	nil,
				:permission			=>	nil,
				}
				assert_equal(expected, result)
			end
			def test_parse_page__1
				src = <<-EOS
4.3 Fixe Analysenblöcke

Rev. Pos.-Nr. TP Bezeichnung des Blocks B

8129.00 30 Blutgase C
pH
pCO2
pO2
Bikarbonat
Inkl. abgeleitete Werte
8129.10
50  Oxymetrieblock CH
Oxyhämoglobin
Carboxyhämoglobin
Methämoglobin
8613.00 35 Hämodialysebloc C
8149.00 Calcium total
8284.00 Harnstoff
8343.00 Kalium
8387.00 Kreatinin
8438.00 Natrium
8462.00 Phosphat
8614.00 25 Lipidblock C
8158.00 Cholesterin total
8288.00 HDL-Cholesterin, ohne
separate Füllung
8572.00 Triglyceride
 120
				EOS
				begin
					result = @parser.parse_page(src,120)
				end
				expected_first = {
				:code						=>	'8129.00',
				:group					=>	'8129',
				:position				=>	'00',
				:taxpoints			=>	30,
				:lab_areas			=>	['C'],
				:description		=>	'Blutgase pH pCO2 pO2 Bikarbonat Inkl. abgeleitete Werte',
				:list_title			=>	nil,
				:taxpoint_type	=>	nil,
				:permission			=>	nil,
				}
				expected_last = {
				:code						=>	'8614.00',
				:group					=>	'8614',
				:position				=>	'00',
				:taxpoints			=>	25,
				:lab_areas			=>	['C'],
				:description		=>	'Lipidblock 8158.00 Cholesterin total 8288.00 HDL-Cholesterin, ohne separate Füllung 8572.00 Triglyceride',
				:list_title			=>	nil,
				:permission			=>	nil,
				:taxpoint_type	=>	nil,
				}
				expected_size	=	4
				assert_equal(expected_first, result.first)
				assert_equal(expected_last, result.last)
				assert_equal(expected_size, result.size)
			end
			def test_fr_parse_line__1
				src = <<-EOS
				      8129.00     30   Bloc gazométrie                                             C
				pH
				pCO2
				pO2
				Bicarbonate
				valeurs dérivées incl.

				EOS
				begin
					result = @parser.parse_line(src)
				end
				expected = {
					:code						=>	'8129.00',
					:group					=>	'8129',
					:position				=>	'00',
					:description		=>	'Bloc gazométrie pH pCO2 pO2 Bicarbonate valeurs dérivées incl.',
					:taxpoints			=>	30,
					:lab_areas			=>	['C'],
					:list_title			=>	nil,
					:taxpoint_type	=>	nil,
					:permission			=>	nil,
				}
				assert_equal(expected, result)
			end
			def test_fr_parse_page__1
				src = <<-EOS
4.3 Blocs d'analyses fixes
Rév.   No. pos.    TP    Dénomination du bloc                                                   B

8129.00 30 Bloc gazométrie
C
pH
pCO2
pO2
Bicarbonate
valeurs dérivées incl.
8129.10 50 Bloc oxymétrie
CH
Oxyhémoglobine
Carboxyhémoglobine
Methémoglobine
8613.00 35 Bloc hémodialyse
C
8149.00 Calcium total
8284.00 Urée
8343.00 Potassium
8387.00 Créatinine
8438.00 Sodium
8462.00 Phosphate
8614.00 25 Bloc lipides
C
8158.00 Cholestérol total
8288.00 Cholestérol HDL, sans
précipitation séparée
8572.00 Triglycérides

				120

				EOS
				begin
					result = @parser.parse_page(src, 120)
				end
				expected_first = {
					:code						=>	'8129.00',
					:group					=>	'8129',
					:position				=>	'00',
					:description		=>	'Bloc gazométrie pH pCO2 pO2 Bicarbonate valeurs dérivées incl.',
					:lab_areas			=>	['C'],
					:taxpoints			=>	30,
					:taxpoint_type	=>	nil,
					:list_title			=>	nil,
					:permission			=>	nil,
				}
				expected_second = {
					:code						=>	'8129.10',
					:group					=>	'8129',
					:position				=>	'10',
					:description		=>	'Bloc oxymétrie Oxyhémoglobine Carboxyhémoglobine Methémoglobine',
					:lab_areas			=>	['C', 'H'],
					:taxpoints			=>	50,
					:taxpoint_type	=>	nil,
					:list_title			=>	nil,
					:permission			=>	nil,
				}
				expected_third = {
					:code						=>	'8613.00',
					:group					=>	'8613',
					:position				=>	'00',
					:description		=>	'Bloc hémodialyse 8149.00 Calcium total 8284.00 Urée 8343.00 Potassium 8387.00 Créatinine 8438.00 Sodium 8462.00 Phosphate',
					:lab_areas			=>	['C'],
					:taxpoints			=>	35,
					:taxpoint_type	=>	nil,
					:list_title			=>	nil,
					:permission			=>	nil,
				}
				expected_last = {
					:code						=>	'8614.00',
					:group					=>	'8614',
					:position				=>	'00',
					:description		=>	'Bloc lipides 8158.00 Cholestérol total 8288.00 Cholestérol HDL, sans précipitation séparée 8572.00 Triglycérides',
					:lab_areas			=>	['C'],
					:taxpoints			=>	25,
					:taxpoint_type	=>	nil,
					:list_title			=>	nil,
					:permission			=>	nil,
				}
				assert_equal(expected_first, result.first)
				assert_equal(expected_second, result.at(1))
				assert_equal(expected_third, result.at(2))
				assert_equal(expected_last, result.last)
			end
			def test_fr_parse_page__2
				src = <<-EOS
				      8129.00     30   Bloc gazométrie                                             C
				pH
				pCO2
				pO2
				Bicarbonate
				valeurs dérivées incl.
				      8129.10     50   Bloc oxy                   métrie                                             CH
				Oxyhémoglobine
				Carboxyhémoglobine
				Methémoglobine
				45

				EOS
				begin
					result = @parser.parse_page(src, 45)
				end
				expected = [
					{
						:code						=>	'8129.00',
						:group					=>	'8129',
						:position				=>	'00',
						:description		=>	'Bloc gazométrie pH pCO2 pO2 Bicarbonate valeurs dérivées incl.',
						:taxpoints			=>	30,
						:lab_areas			=>	['C'],
						:list_title			=>	nil,
						:permission			=>	nil,
						:taxpoint_type	=>	nil,
				},
					{
						:code						=>	'8129.10',
						:group					=>	'8129',
						:position				=>	'10',
						:description		=>	'Bloc oxy métrie Oxyhémoglobine Carboxyhémoglobine Methémoglobine',
						:taxpoints			=>	50,
						:lab_areas			=>	['C','H'],
						:list_title			=>	nil,
						:permission			=>	nil,
						:taxpoint_type	=>	nil,
				}
				]
				assert_equal(expected, result)
			end
			def test_fr_parse_page__3
				src = <<-EOS
				4.3 Blocs d'analyses fixes

				Rév.   No. pos.    TP    Dénomination du bloc                                                   B

				      8129.00     30   Bloc gazométrie                                             C
				pH
				pCO2
				pO2
				Bicarbonate
				valeurs dérivées incl.
				      8129.10     50   Bloc oxy                   métrie                                             CH
				Oxyhémoglobine
				Carboxyhémoglobine
				Methémoglobine
				      8613.00     35   Bloc hémodialyse
				C
				8149.00 Calcium total
				8284.00 Urée
				8343.00 Potassium
				8387.00 Créatinine
				8438.00 Sodium
				8462.00 Phosphate
				8614.00     25   Bloc lipides

				                C
				8158.00 Cholestérol total
				8288.00 Cholestérol HDL, sans
				précipitation séparée
				8572.00 Triglycérides

				120
				
				EOS
				begin
					result = @parser.parse_page(src, 120)
				end
				expected = [	
				{
					:code						=>	'8129.00',
					:group					=>	'8129',
					:position				=>	'00',
					:description		=>	'Bloc gazométrie pH pCO2 pO2 Bicarbonate valeurs dérivées incl.',
					:lab_areas			=>	['C'],
					:taxpoints			=>	30,
					:taxpoint_type	=>	nil,
					:list_title			=>	nil,
					:permission			=>	nil,
				},
				{
					:code						=>	'8129.10',
					:group					=>	'8129',
					:position				=>	'10',
					:description		=>	'Bloc oxy métrie Oxyhémoglobine Carboxyhémoglobine Methémoglobine',
					:lab_areas			=>	['C', 'H'],
					:taxpoints			=>	50,
					:taxpoint_type	=>	nil,
					:list_title			=>	nil,
					:permission			=>	nil,
				},
				{
					:code						=>	'8613.00',
					:group					=>	'8613',
					:position				=>	'00',
					:description		=>	'Bloc hémodialyse 8149.00 Calcium total 8284.00 Urée 8343.00 Potassium 8387.00 Créatinine 8438.00 Sodium 8462.00 Phosphate',
					:lab_areas			=>	['C'],
					:taxpoints			=>	35,
					:taxpoint_type	=>	nil,
					:list_title			=>	nil,
					:permission			=>	nil,
				},
				{
					:code						=>	'8614.00',
					:group					=>	'8614',
					:position				=>	'00',
					:description		=>	'Bloc lipides 8158.00 Cholestérol total 8288.00 Cholestérol HDL, sans précipitation séparée 8572.00 Triglycérides',
					:lab_areas			=>	['C'],
					:taxpoints			=>	25,
					:taxpoint_type	=>	nil,
					:list_title			=>	nil,
					:permission			=>	nil,
				},
				]
				assert_equal(expected.first, result.first)
				assert_equal(expected.at(1), result.at(1))
				assert_equal(expected.at(2), result.at(2))
				assert_equal(expected.last, result.last)
			end
		end
	end
end
