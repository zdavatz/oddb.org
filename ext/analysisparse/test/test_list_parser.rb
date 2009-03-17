#!/usr/bin/env ruby
# AnalysisParse::TestListParser -- oddb -- 10.11.2005 -- hwyss@ywesee.com

$: << File.expand_path('../src', File.dirname(__FILE__))

require 'test/unit'
require 'list_parser'

module ODDB
	module AnalysisParse
		class TestListParser < Test::Unit::TestCase
			def setup
				@parser = ListParser.new
			end
			def test_parse_line__1
				src = <<-EOS
		 8006.00  9  Alanin-Aminotransferase (ALAT)                     C 
				EOS
				result = @parser.parse_line(src)
				expected = {
					:code						=>	'8006.00',
					:group					=>	'8006',
					:position				=>	'00',
					:taxpoints			=>	9,
					:description		=>	'Alanin-Aminotransferase (ALAT)',
					:lab_areas			=>	['C'],
					:list_title			=>	nil,
					:permission			=>	nil,
					:taxpoint_type	=>	nil,
				}
				assert_equal(expected, result)
			end

			def test_parse_line__3
				src = <<-EOS
C    8021.00  200  Alpha-Amanitin (Urin)                                              C 
				EOS
				result = @parser.parse_line(src)
				expected = {
					:analysis_revision	=>	'C',
					:code								=>	'8021.00',
					:group							=>	'8021',
					:position						=>	'00',
					:taxpoints					=>	200,
					:description				=>	'Alpha-Amanitin (Urin)',
					:lab_areas					=>	['C'],
					:permission					=>	nil,
					:taxpoint_type			=>	nil,
					:list_title					=>	nil,
				}
				assert_equal(expected, result)
			end
			def test_parse_line__4
				src = <<-EOS
		 8003.01 * 100  Acetylcholinesterase-Isoenzyme                        C 
				EOS
				result = @parser.parse_line(src)
				expected = {
					:anonymous					=>	true,
					:code								=>	'8003.01',
					:group							=>	'8003',
					:position						=>	'01',
					:taxpoints					=>	100,
					:taxpoint_type			=>	nil,
					:permission					=>	nil,
					:list_title					=>	nil,
					:description				=>	'Acetylcholinesterase-Isoenzyme',
					:lab_areas					=>	['C'],
				}
				assert_equal(expected, result)
			end
			def test_parse_line__5
				src = <<-EOS
		 8040.00  60  Angiotensin I                                                              C 
				EOS
				result = @parser.parse_line(src)
				description = ""
				expected = {
					:code							=>	'8040.00',
					:group						=>	'8040',
					:position					=>	'00',
					:taxpoints				=>	60,
					:description			=>	'Angiotensin I',
					:lab_areas				=>	['C'],
					:list_title				=>	nil,
					:permission				=>	nil,
					:taxpoint_type		=>	nil,
				}
				assert_equal(expected, result)
			end
			def test_parse_line__6
				src = <<-EOS
		 8043.00   300  Anti-HLA Alloantikörper, Nachweis mit           HI 
Test-Panel 
				EOS
				result = @parser.parse_line(src)
				expected = {
					:code							=>	'8043.00',
					:group						=>	'8043',
					:position					=>	'00',
					:taxpoints				=>	300,
					:description			=>	'Anti-HLA Alloantikörper, Nachweis mit Test-Panel',
					:lab_areas				=>	['H', 'I'],
					:list_title				=>	nil,
					:permission				=>	nil,
					:taxpoint_type		=>	nil,
				}
				assert_equal(expected, result)
			end
			def test_parse_line__7
				src = <<-EOS
C    8179.00  25  D-Dimere, ql; Limitation: nur zum Aus-                  H 
schluss der dissem    inierten intravasalen 
Gerinnung (DIC)
				EOS
				result = @parser.parse_line(src)
				expected = {
					:code								=>	'8179.00',
					:analysis_revision	=>	'C',
					:group							=>	'8179',
					:position						=>	'00',
					:taxpoints					=>	25,
					:description				=>	'D-Dimere, ql',
					:lab_areas					=>	['H'],
					:limitation					=>	'nur zum Ausschluss der dissem inierten intravasalen Gerinnung (DIC)',
					:list_title					=>	nil,
					:permission					=>	nil,
					:taxpoint_type			=>	nil,
				}
				assert_equal(expected, result)
			end
			def test_parse_line__8
				src = <<-EOS
		 8059.10    80   Natriuretisches Peptid (BNP, NT-                       C 
proBNP)  
	Limitation: Abklärung der akuten Dyspnoe 
zum Ausschluss der akuten oder chronischen 
Herzinsuffizienz   ; nicht zur Therapie-
überwachung
				EOS
				result = @parser.parse_line(src)
				expected = {
					:code							=>	'8059.10',
					:group						=>	'8059',
					:position					=>	'10',
					:taxpoints				=>	80,
					:description			=>	'Natriuretisches Peptid (BNP, NT-proBNP)',
					:lab_areas				=>	['C'],
					:limitation				=>	'Abklärung der akuten Dyspnoe zum Ausschluss der akuten oder chronischen Herzinsuffizienz; nicht zur Therapieüberwachung',
					:list_title				=>	nil,
					:permission				=>	nil,
					:taxpoint_type		=>	nil,
				}
				assert_equal(expected, result)
			end
			def test_parse_line__9
				src = <<-EOS
S    8144.00 *  50  CA 50                                                                             CI 
				EOS
				result = @parser.parse_line(src)
				expected = {
					:code								=>	'8144.00',
					:anonymous					=>	true,
					:group							=>	'8144',
					:analysis_revision	=>	'S',
					:position						=>	'00',
					:taxpoints					=>	50,
					:description				=>	'CA 50',
					:lab_areas					=>	['C', 'I'],
					:list_title					=>	nil,
					:permission					=>	nil,
					:taxpoint_type			=>	nil,
				}
				assert_equal(expected, result)
			end
			def test_parse_line__10
				src = <<-EOS
		 9300.00    60  n   Blutkultur (2 Flaschen, inkl.                                M 
Anaerobier-Nachweis) 
				EOS
				result = @parser.parse_line(src)
				expected = {
					:code							=>	'9300.00',
					:finding					=>	'n',
					:group						=>	'9300',
					:position					=>	'00',
					:taxpoints				=>	60,
					:description			=>	'Blutkultur (2 Flaschen, inkl. Anaerobier-Nachweis)',
					:lab_areas				=>	['M'],
					:list_title				=>	nil,
					:permission				=>	nil,
					:taxpoint_type		=>	nil,
				}
				assert_equal(expected, result)
			end
			def test_parse_line__11
				src = <<-EOS
C   9367.001    90      Helicobacter pylori, Atemtest mit 13C-        CM 
Harnstoff inkl. 13C-Harnstoff 
	Das 13C-Harnstoff-Präparat muss beim 
Schweizerischen Heilmittelinstitut 
(Swissmedic) registriert sein. 
				EOS
				begin
					result = @parser.parse_line(src)
				rescue AmbigousParseException => e
					puts e.inspect
				end
				expected = {
					:code								=>	'9367.00',
					:footnote						=>	'1',
					:analysis_revision	=>	'C',
					:group							=>	'9367',
					:position						=>	'00',
					:taxpoints					=>	90,
					:description				=>	'Helicobacter pylori, Atemtest mit 13C-Harnstoff inkl. 13C-Harnstoff Das 13C-Harnstoff-Präparat muss beim Schweizerischen Heilmittelinstitut (Swissmedic) registriert sein.',
					:lab_areas					=>	['C', 'M'],
					:list_title					=>	nil,
					:permission					=>	nil,
					:taxpoint_type			=>	nil,
				}
				assert_equal(expected, result)
			end
			def test_parse_line__12
				src = <<-EOS
		 9504.80    40      Borrelia burgdorferi anti-p39                             M 
				EOS
				begin
					result = @parser.parse_line(src)
				rescue AmbigousParseException => e
					puts e.inspect
				end
				expected = {
					:code						=>	'9504.80',
					:group					=>	'9504',
					:position				=>	'80',
					:taxpoints			=>	40,
					:description		=>	'Borrelia burgdorferi anti-p39',
					:lab_areas			=>	['M'],
					:permission			=>	nil,
					:list_title			=>	nil,
					:taxpoint_type	=>	nil
				}
				assert_equal(expected, result)
			end
			def test_parse_line__13
				src = <<-EOS
				9356.31    35      Immunologische Färbung Fluoreszenz/      M
				Peroxydase, kumulierbar mit Spezial-
				mikroskopie, nicht kumulierbar mit
				Kultur
				EOS
				begin
					result = @parser.parse_line(src)
				rescue AmbigousParseException => e
					puts e.inspect
				end
				expected = {
					:code						=>	'9356.31',
					:group					=>	'9356',
					:position				=>	'31',
					:taxpoints			=>	35,
					:description		=>	'Immunologische Färbung Fluoreszenz/Peroxydase, kumulierbar mit Spezialmikroskopie, nicht kumulierbar mit Kultur',
					:lab_areas			=>	['M'],
					:permission			=>	nil,
					:list_title			=>	nil,
					:taxpoint_type	=>	nil,
				}
				assert_equal(expected, result)
			end	
			def test_parse_line__14
				src = <<-EOS
				8064.01    40   Autoantikörper gegen GAD (Glutamat-             I
				Decarboxylase), ql
				EOS
				begin
					result = @parser.parse_line(src)
				rescue AmbigousParseException => e
					puts e.inspect
				end
				expected = {
					:code								=>	'8064.01',
					:group							=>	'8064',
					:position						=>	'01',
					:taxpoints					=>	40,
					:description				=>	'Autoantikörper gegen GAD (Glutamat-Decarboxylase), ql',
					:lab_areas					=>	['I'],
					:permission					=>	nil,
					:list_title					=>	nil,
					:taxpoint_type			=>	nil,
				}
				assert_equal(expected, result)
			end
			def test_parse_line__15
				src = <<-EOS
8619.00  65  Dihydropteridinreduktase (DHPR)-                     C
Aktivität in Erythrozyten;
Limitation: in Stoffwechsellaboratorien der
Universitätskliniken
				EOS
				begin
					result = @parser.parse_line(src)
				rescue AmbigousParseException => e
					puts e.inspect
				end
				expected = {
					:code								=>	'8619.00',
					:group							=>	'8619',
					:position						=>	'00',
					:taxpoints					=>	65,
					:description				=>	'Dihydropteridinreduktase (DHPR)-Aktivität in Erythrozyten',
					:limitation					=>	'in Stoffwechsellaboratorien der Universitätskliniken',
					:lab_areas					=>	['C'],
					:permission					=>	nil,
					:list_title					=>	nil,
					:taxpoint_type			=>	nil,
				}
				assert_equal(expected, result)
			end
			def test_parse_line__17
				src = <<-EOS
			9115.01 * 800    HIV 1-Resistenz gegen antiretrovirale          IM
			Substanzen: genotypische Testung inklusive Interpretationshilfe. Limitation: Indikation und Durchfuffffhrung gemuffffss den Richtlinien der "EuroGuidelines Group for HIV Resistance" vom November 2000 (AIDS 2001 ; 15:309-320), maximal 3 Tests pro Patient und Jahr, nicht kumulierbar mit Position 9115.02 In folgenden Laboratorien: 1. Universitufffft Basel, Institut fuffffr Medizinische Mikrobiologie 2. HUG, Laboratoire Central de Virologie 3. CHUV, Duffffp. de muffffdecine de laboratoire, Service d~Rimmunologie et d~Qallergie 4. Universitufffft Zuffffrich, Nationales Zentrum f Retroviren Guffffltig ab 1.1.2003 bis 31.12.2005 In Evaluation (Monitoring, systematische Literaturreview, Kosten-Nutzen-Analyse)
			EOS
				begin
					result = @parser.parse_line(src)
				rescue AmbigousParseException => e
					puts e.inspect
				end
				expected = {
					:code								=>	'9115.01',
					:group							=>	'9115',
					:position						=>	'01',
					:taxpoints					=>	800,
					:description				=>	'HIV 1-Resistenz gegen antiretrovirale Substanzen: genotypische Testung inklusive Interpretationshilfe',
					:lab_areas					=>	['I', 'M'],
					:limitation					=>	'Indikation und Durchfuffffhrung gemuffffss den Richtlinien der "EuroGuidelines Group for HIV Resistance" vom November 2000 (AIDS 2001; 15:309-320), maximal 3 Tests pro Patient und Jahr, nicht kumulierbar mit Position 9115.02 In folgenden Laboratorien: 1. Universitufffft Basel, Institut fuffffr Medizinische Mikrobiologie 2. HUG, Laboratoire Central de Virologie 3. CHUV, Duffffp. de muffffdecine de laboratoire, Service d~Rimmunologie et d~Qallergie 4. Universitufffft Zuffffrich, Nationales Zentrum f Retroviren Guffffltig ab 1.1.2003 bis 31.12.2005 In Evaluation (Monitoring, systematische Literaturreview, Kosten-Nutzen-Analyse)',
					:anonymous					=>	true,
					:permission					=>	nil,
					:list_title					=>	nil,
					:taxpoint_type			=>	nil,
				}
				assert_equal(expected, result)
			end
			def test_parse_line__18
				src = "     8810.10 * 50    Hämatologische Erkrankungen, maligne      GH\n(Leukämien, Lymphome); Nachweis \neines Fusionsgens oder Fusions-\nTranskripts oder eines Rearrange-\nments, ql oder qn, nämlich: \n - t(9;22) BCR-ABL \n - t(8;21) AML1-ETO \n - t(15;17) PML-RARa \n - inv(16) CBF-b-MYH11 \n - t(4;11) MLL-AF4 \n - FLT3 ITD \n - t(12;21) TEL-AML1 \n - t(1;19) E2A-PBX1 \n - t(11;14) BCL-1 \n - t(14;18) BCL-2 \n - IgH rearrangement \n - TCR rearrangement \n"
				begin
					result = @parser.parse_line(src)
				rescue AmbigousParseException => e
					puts e.inspect
				end
				expected = {
					:code								=>	'8810.10',
					:group							=>	'8810',
					:position						=>	'10',
					:taxpoints					=>	50,
					:description				=>	"Hämatologische Erkrankungen, maligne (Leukämien, Lymphome); Nachweis eines Fusionsgens oder Fusions-Transkripts oder eines Rearrangements, ql oder qn, nämlich:\n- t(9; 22) BCR-ABL\n- t(8; 21) AML1-ETO\n- t(15; 17) PML-RARa\n- inv(16) CBF-b-MYH11\n- t(4; 11) MLL-AF4\n- FLT3 ITD\n- t(12; 21) TEL-AML1\n- t(1; 19) E2A-PBX1\n- t(11; 14) BCL-1\n- t(14; 18) BCL-2\n- IgH rearrangement\n- TCR rearrangement",
					:lab_areas					=>	['G', 'H'],
					:anonymous					=>	true,
					:permission					=>	nil,
					:list_title					=>	nil,
					:taxpoint_type			=>	nil,
				}
				assert_equal(expected, result)
			end
			def test_parse_line__19
				src = <<-EOS
				 8535.03  125  Suchtstoffe (in der AL aufgeführt), Such-        C
				und Bestätigungsanalytik, HPLC-MS/
				GC-MS (Blut, Urin)

				EOS
				begin
					result = @parser.parse_line(src)
				end
				expected = {
					:code								=>	'8535.03',
					:group							=>	'8535',
					:position						=>	'03',
					:taxpoints					=>	125,
					:lab_areas					=>	['C'],
					:description				=>	'Suchtstoffe (in der AL aufgeführt), Such- und Bestätigungsanalytik, HPLC-MS/GC-MS (Blut, Urin)',
					:permission					=>	nil,
					:list_title					=>	nil,
					:taxpoint_type			=>	nil,
				}
				assert_equal(expected, result)
			end
			def test_parse_line__20
				src = <<-EOS
8535.02    80  Suchtstoffe (in der AL aufgeführt), Such-        C
				und Bestätigungsanalytik, HPLC, GC
				(Blut, Urin)
				EOS
				begin
					result = @parser.parse_line(src)
				rescue AmbigousParseException	=>	e
					puts e.inspect
				end
				expected = {
					:code						=>	'8535.02',
					:group					=>	'8535',
					:position				=>	'02',
					:taxpoints			=>	80,
					:lab_areas			=>	['C'],
					:description		=>	'Suchtstoffe (in der AL aufgeführt), Such- und Bestätigungsanalytik, HPLC, GC (Blut, Urin)',
					:list_title			=>	nil,
					:permission			=>	nil,
					:taxpoint_type	=>	nil,
				}
				assert_equal(expected, result)
			end
			def test_parse_line__21
				src = <<-EOS
						 8017.00 * 45  Alpha-1-Fetoprotein (AFP)                                  CI

				EOS
				begin
					result = @parser.parse_line(src)
				end
				expected = {
					:code						=>	'8017.00',
					:group					=>	'8017',
					:position				=>	'00',
					:taxpoints			=>	45,
					:lab_areas			=>	['C','I'],
					:description		=>	'Alpha-1-Fetoprotein (AFP)',
					:anonymous			=>	true,
					:list_title			=>	nil,
					:permission			=>	nil,
					:taxpoint_type	=>	nil,
				}
				assert_equal(result, expected)
			end
			def test_parse_line__22
				src = <<-EOS

C 8000.00 8 ABO/D-Antigen, Kontrolle nach Empfeh- H
lungen BSD SRK "Erythrozyten-
serologische Untersuchungen an
Patientenproben"
				EOS
			begin
				result = @parser.parse_line(src)
			end
				expected = {
					:code								=>	'8000.00',
					:group							=>	'8000',
					:position						=>	'00',
					:taxpoints					=>	8,
					:description				=>	'ABO/D-Antigen, Kontrolle nach Empfehlungen BSD SRK "Erythrozytenserologische Untersuchungen an Patientenproben"',
					:lab_areas					=>	['H'],
					:analysis_revision	=>	'C',
					:list_title					=>	nil,
					:permission					=>	nil,
					:taxpoint_type			=>	nil,
				}
				assert_equal(expected, result)
			end
			def test_parse_line__23
				src = <<-EOS
				     9365.50  170     Bartonella henselae / quintana,                      M
				Nukleinsäureamplifikation, inkl.
				Amplifikatnachweis
				EOS
				begin
					result = @parser.parse_line(src)
				end
				expected = {
				:code						=>	'9365.50',
				:group					=>	'9365',
				:position				=>	'50',
				:taxpoints			=>	170,
				:description		=>	'Bartonella henselae/quintana, Nukleinsäureamplifikation, inkl. Amplifikatnachweis',
				:lab_areas			=>	['M'],
				:list_title			=>	nil,
				:permission			=>	nil,
				:taxpoint_type	=>	nil,
				}
				assert_equal(expected, result)
			end
			def test_parse_line__24
				src = <<-EOS
			    9366.001   15    Urease-Test (Helicobacter pylori)              CM
				EOS
				begin
					result = @parser.parse_line(src)
				end
				expected = {
					:code						=>	'9366.00',
					:group					=>	'9366',
					:position				=>	'00',
					:taxpoints			=>	15,
					:lab_areas			=>	['C','M'],
					:description		=>	'Urease-Test (Helicobacter pylori)',
					:footnote				=>	'1',
					:list_title			=>	nil,
					:permission			=>	nil,
					:taxpoint_type	=>	nil,
				}
				assert_equal(expected, result)
			end
			def test_parse_line__25
				src = <<-EOS
8606.00 30 Guthrie-Test
				EOS
				begin
					result = @parser.parse_line(src)
				end
				expected = {
					:group				=>	'8606',
					:position			=>	'00',
					:taxpoints		=>	'30',
					:description	=>	'Guthrie-Test',
					:line					=>	src,
				}
				expected.each { |key, val|
					assert_equal(val, result[key])
				}
				assert_kind_of(Exception, result[:error])
			end
			def test_parse_page__1
				src = <<-EOS
				Rev.    Pos.-Nr. A TP  Bezeichnung (Chemie/Hömatologie/Immunologie) B

						 8069.00    50  Autoantikörper gegen glomerulöre                       I
				Basalmembran, qn
						 8070.00    40  Autoantikörper gegen Haut, ql                               I
						 8070.01    50  Autoantikörper gegen Haut, qn                              I
						 8071.00    50  Autoantikörper gegen Histon, ql                            I
						 8072.00    60  Autoantikörper gegen Histon, qn                          I
						 8073.00    60  Autoantikörper gegen Hodengewebe                 I
						 8073.11    40  Autoantikörper gegen Inselzellen, ql                   I
						 8073.12    50  Autoantikörper gegen Inselzellen, qn                 I
						 8074.00    40  Autoantikörper gegen Insulin, ql                           I
						 8074.01    50  Autoantikörper gegen Insulin, qn                          I
						 8074.02    40  Autoantikörper gegen Intrinsic-Faktor, ql          I
						 8074.03    50  Autoantikörper gegen Intrinsic-Faktor, qn         I
						 8074.04    40  Autoantikörper gegen Jo-1 (histidyl-                    I
				tRNA-synthetase), ql
						 8074.05    50  Autoantikörper gegen Jo-1 (histidyl-                    I
				tRNA-synthetase), qn
						 8075.00    40  Autoantikörper gegen Kardiolipin IgG, ql           I
						 8076.00    50  Autoantikörper gegen Kardiolipin IgG, qn         I
						 8077.00    40  Autoantikörper gegen Kardiolipin IgM, ql          I
						 8078.00    50  Autoantikörper gegen Kardiolipin IgM, qn         I
						 8078.01    40  Autoantikörper gegen Kardiolipin IgA, ql           I
						 8078.02    50  Autoantikörper gegen Kardiolipin IgA, qn          I
						 8078.03    40  Autoantikörper gegen LKM (liver-kidney           I
				mikrosomales Antigen), ql
						 8078.04    50  Autoantikörper gegen LKM (liver-kidney           I
				mikrosomales Antigen), qn
						 8079.00    40  Autoantikörper gegen Magenparietal-                 I
				zellen, ql
						 8079.01    50  Autoantikörper gegen Magenparietal-                 I
				zellen, qn
						 8080.00    40  Autoantikörper gegen mikrosomale                     I
				Antigene, ql
						 8081.00    50  Autoantikörper gegen TPO (mikrosomale         I
				Antigene), qn
						 8082.00    40  Autoantikörper gegen Mitochondrien, ql            I
						 8083.00    50  Autoantikörper gegen Mitochondrien,qn            I
						 8083.01    40  Autoantikörper gegen M2 (Mitochondrial),        I
				ql
						 8083.02    50  Autoantikörper gegen M2 (Mitochondrial),        I
				qn
				44

			EOS
				begin
					result = @parser.parse_page(src, 44)
				end
				expected_last = {
					:code						=>	'8083.02',
					:group					=>	'8083',
					:position				=>	'02',
					:taxpoints			=>	50,
					:description		=>	'Autoantikörper gegen M2 (Mitochondrial), qn',
					:lab_areas			=>	['I'],
					:list_title			=>	nil,
					:permission			=>	nil,
					:taxpoint_type	=>	nil,
				}
				expected_first = {
					:code					=>	'8069.00',
					:group				=>	'8069',
					:position			=>	'00',
					:taxpoints		=>	50,
					:lab_areas		=>	['I'],
					:description	=>	'Autoantikörper gegen glomerulöre Basalmembran, qn',
					:list_title			=>	nil,
					:permission			=>	nil,
					:taxpoint_type	=>	nil,
				}
				expected_size	= 30
				assert_equal(expected_first, result.first)
				assert_equal(expected_last, result.last)
				assert_equal(expected_size, result.size)
			end
			def test_parse_page__2
				src =<<-EOS
				Rev.    Pos.-Nr. A TP  Bezeichnung (Chemie/Hämatologie/Immunologie) B

						 8523.00    40  Sideroblasten, Färbung und Zählung inkl.      H
				Beurteilung
						 8524.00    60  Somatomedin C (IGF-1)                                          C
						 8525.00    80  Wachstumshormon (HGH, STH)                         C
						 8526.00    35  Sorbit-Dehydrogenase (SDH)                             C
						 8528.00  150  Spermiocytogramm (Beurteilung von pH,       C
				Viskosität, Zellzahl, Motilität, Motilitäts-
				verminderung, Vitalität, Morphologie,
				Fremdzellenelemente, inkl. verschiede-
				ne Färbungen)
						 8528.01    30  Spermiennachweis nach Vasektomie             C
				(Nativsediment)
						 8529.00     3    Spezifisches Gewicht, Dichte                               C
						 8531.00 * 50  Sqamous Cell Carcinoma (SCC)                        CI
						 8532.00    50  Streptokinasetoleranztest                                     H
						 8534.00    35  Stuhl-Status (Blutnachweis,                                 C
				makroskopische und mikroskopische
				Untersuchung ohne Anreicherung)
						 8535.00  150  Stuhlfett                                                                         C
						 8535.01    50  Suchtstoffe (in der AL aufgeführt), Such-         C
				analytik, einfache chromatographische
				Methoden
						 8535.02    80  Suchtstoffe (in der AL aufgeführt), Such-        C
				und Bestätigungsanalytik, HPLC, GC
				(Blut, Urin)
						 8535.03  125  Suchtstoffe (in der AL aufgeführt), Such-        C
				und Bestätigungsanalytik, HPLC-MS/
				GC-MS (Blut, Urin)
						 8535.04    16  Suchtstoffe, Screening, bis 4 Suchtstoffe        C
				(Urin), je (Ausnahme für Opiate und
				Cocain : je 14 TP)
						 8535.05    10  Suchtstoffe, Screening, jeder weitere               C
				Suchtstoff (Urin), max. 10
																																																															 63


				EOS
				begin
					result = @parser.parse_page(src, 63)
				rescue AmbigousParseException	=> e
					puts e.inspect
				end
				expected_first = {
					:code					=>	'8523.00',
					:group				=>	'8523',
					:position			=>	'00',
					:taxpoints		=>	40,
					:description	=>	'Sideroblasten, Färbung und Zählung inkl. Beurteilung',
					:lab_areas		=>	['H'],
					:list_title			=>	nil,
					:permission			=>	nil,
					:taxpoint_type	=>	nil,
				}
				expected_last = {
					:code					=>	'8535.05',
					:group				=>	'8535',
					:position			=>	'05',
					:taxpoints		=>	10,
					:description	=>	'Suchtstoffe, Screening, jeder weitere Suchtstoff (Urin), max. 10',
					:lab_areas		=>	['C'],
					:list_title			=>	nil,
					:permission			=>	nil,
					:taxpoint_type	=>	nil,
				}
				expected_size =	16
				assert_equal(expected_first, result.first)
				assert_equal(expected_last, result.last)
				assert_equal(expected_size, result.size)
			end
			def test_parse_page__3
				src = <<-EOS
				Rev.    Pos.-Nr. A TP  Bezeichnung (Chemie/Hämatologie/Immunologie) B

						 8017.00 * 45  Alpha-1-Fetoprotein (AFP)                                  CI
						 8017.01    25  Alpha-1-Mikroglobulin                                            C
						 8018.00    30  Alpha-1-saures Glykoprotein                              C
						 8020.00    30  Alpha-2-Makroglobulin                                           C
						 8021.00  200  Alpha-Amanitin (Urin)                                              C
						 8026.00    80  Alpha-Naphthylacetatesterase                           H
						 8027.00  100  Aluminium, mit AAS                                                  C
						 8029.00    60  Aminosäurenchromatographie (z.B. nach       C
				Stein und Moore, Kurzprogramm), qn
						 8030.00  200  Aminosäurenchromatographie (z.B. nach       C
				Stein u. Moore, vollständig), qn,
				und/oder Acylcarnitine (Tandem-
				Massenspektrometrie, min. 6
				Komponenten), qn
						 8032.00    60  Aminosäurenchromatographie, ql                       C
						 8035.00    50  Ammoniak                                                                   C
						 8036.00    16  Amphetamine, ql (Urin) (im Screening mit      C
				anderen Suchtstoffen: siehe
				8535.04/05)
						 8037.00     9  Amylase, im Blut/Plasma/Serum                      C
						 8037.01  100  Amylase-Isoenzyme (elektrophoretische         C
				Differenzierung)
						 8037.02     9  Amylase, in einer weiteren Körper-                    C
				flüssigkeit
						 8038.00    60  Androstendion                                                           C
						 8039.00    60  Androsteron                                                                C
						 8040.00    60  Angiotensin I                                                              C
						 8041.00    60  Angiotensin II                                                             C
						 8042.00    80  Angiotensin-Converting-Enzym                         C
						 8043.00  300  Anti-HLA Alloantikörper, Nachweis mit            HI
				Test-Panel
						 8044.00    60  Antidiuretisches Hormon (Vasopressin,           C
				ADH)
						 8046.00    60  Antikörper gegen Wachstumshormon              CI
						 8048.00    45  Antiplasmin, immunologisch                                H
						 8049.00    50  Antiplasmin, funktionell                                          H
						 8050.00    50  Antithrombin III, funktionell                                   H
						 8051.00    45  Antithrombin III, immunologisch                         H
						 8052.00    25  Apolipoprotein A1                                                    C
						 8053.00    25  Apolipoprotein A2                                                    C
						 8054.00    25  Apolipoprotein B                                                       C
				42

				EOS
				begin
					result = @parser.parse_page(src, 42)
				rescue AmbigousParseException	=> e
					puts e.inspect
				end
				expected_first = {
					:code					=>	'8017.00',
					:group				=>	'8017',
					:position			=>	'00',
					:anonymous		=>	true,
					:taxpoints		=>	45,
					:description	=>	'Alpha-1-Fetoprotein (AFP)',
					:lab_areas		=>	['C','I'],
					:list_title			=>	nil,
					:permission			=>	nil,
					:taxpoint_type	=>	nil,
				}
				expected_last  = {
					:code					=>	'8054.00',
					:group				=>	'8054',
					:position			=>	'00',
					:taxpoints		=>	25,
					:description	=>	'Apolipoprotein B',
					:lab_areas			=>	['C'],
					:list_title			=>	nil,
					:permission			=>	nil,
					:taxpoint_type	=>	nil,
				}
				expected_size	 = 30
				assert_equal(expected_first, result.first)
				assert_equal(expected_last, result.last)
				assert_equal(expected_size, result.size)
			end
			def test_parse_page__4
				src =<<-EOS
				Systematische Auflistung der Analysen
				inkl. Anhänge


				1. Kapitel:  Chemie/Hämatologie/Immunologie

							Zu anonymisierende Positionen (A) = * (mit Stern bezeichnet) ?   Kapitel 4.2
							Fachbereiche (B) = Suffix C (klinische Chemie), H (Hämatologie),
							I (klinische Immunologie), M (medizinische Mikrobiologie)

				Rev.    Pos.-Nr. A TP  Bezeichnung (Chemie/Hämatologie/Immunologie) B

C 8000.00 8 ABO/D-Antigen, Kontrolle nach Empfeh-         H
				lungen BSD SRK "Erythrozyten-
				serologische Untersuchungen an
				Patientenproben"
				C    8001.00    18  ABO-Blutgruppen und Antigen D                        H
				Bestimmung (inkl. Ausschluss
				schwaches D Antigen bei Rhesus D
				negativ) nach Empfehlungen BSD SRK
				"Erythrozytenserologische
				Untersuchungen an Patientenproben"
				S    8002.00    12  ABO-Blutgruppen und -Antigen D                       H
				Bestimmung (ohne Du) nach Richtlinien
				BSD SRK 8.3.2/8.3.3
						 8003.01 * 100  Acetylcholinesterase-Isoenzyme                        C
						 8004.00    60  ADP in Thrombozyten                                              H
						 8006.00     9  Alanin-Aminotransferase (ALAT)                     C
						 8007.00     9  Albumin, chemisch                                                 C
						 8008.00    25  Albumin, immunologisch                                       C
						 8008.50    12  Albumin im Urin, sq                                                   C
						 8009.00    25  Aldolase                                                                       C
						 8010.00    60  Aldosteron                                                                   C
						 8011.00    50  Alkalische Phosphatase in Leukozyten            H
						 8012.00     9  Alkalische Phosphatase                                       C
						 8013.00  100  Alkalische Phosphatase-Isoenzyme                 C
				(elektrophoretische Differenzierung)
						 8013.01    60  Alkalische Phosphatase,                                       C
				knochenspezifisch
						 8014.00    30  Alpha-1-Antichymotrypsin                                    C
						 8015.00    30  Alpha-1-Antitrypsin                                                  C
						 8016.00    80  Alpha-1-Antitrypsin Typisierung                         C
																																																															 41
				EOS
				begin
					result = @parser.parse_page(src, 41)
				end
				expected_first = {
					:code								=>		'8000.00',
					:group							=>		'8000',
					:position						=>		'00',
					:taxpoints					=>		8,
					:lab_areas					=>		['H'],
					:analysis_revision	=>		'C',
					:description				=>		'ABO/D-Antigen, Kontrolle nach Empfehlungen BSD SRK "Erythrozytenserologische Untersuchungen an Patientenproben"',
					:list_title					=>	nil,
					:permission					=>	nil,
					:taxpoint_type			=>	nil,
				}
				expected_last = {
					:code								=>		'8016.00',
					:group							=>		'8016',
					:position						=>		'00',
					:taxpoints					=>		80,
					:lab_areas					=>		['C'],
					:description				=>		'Alpha-1-Antitrypsin Typisierung',
					:list_title					=>	nil,
					:permission					=>	nil,
					:taxpoint_type			=>	nil,
				}
				expected_size = 18
				assert_equal(expected_first, result.first)
				assert_equal(expected_last, result.last)
				assert_equal(expected_size, result.size)
			end
			def test_parse_page__5
				src = <<-EOS
				Rev.      Pos. Nr. A   TP   R   Bezeichnung (Bakteriologie/Mykologie)                        B

						 9354.40 * 35    Neisseria gonorrhoeae, IF oder                      M
				Hybridisierung
						 9354.50 * 80    Neisseria gonorrhoeae, Nukleinsüure-        M
				amplifikation, inkl. Amplifikatnachweis
						 9355.30    20    Traditionelle Mikroskopie (Gram,                 M
				Giemsa, Methylenblau, etc.), Fürbung
				inbegriffen, nicht kumulierbar mit
				Kultur
						 9356.30    25      Spezielle Mikroskopie (Acridineorange,      M
				Ziehl-Neelsen, Auramin-Rhodamin,
				inklusive Dunkelfeld, Phasenkontrast
				etc., KOH, Pilze)
						 9356.31    35      Immunologische Fürbung Fluoreszenz/      M
				Peroxydase, kumulierbar mit Spezial-
				mikroskopie, nicht kumulierbar mit
				Kultur
						 9357.50  170     Borrelia burgdorferi, Nukleinsüure-               M
				amplifikation, inkl. Amplifikatnachweis
						 9358.00    40 n   Pilznachweis, Blutkultur, auf Verlangen      M
						 9358.10  100 p Pilznachweis, Blutkultur, auf Verlangen      M
						 9359.00    80 n   Bronchoalveolüre Lavage (Kultur qn)           M
						 9359.10  135 p   Bronchoalveolüre Lavage (Kultur qn)           M
						 9360.50    80    Chlamydia trachomatis, Nukleinsüure-        M
				Amplifikation inkl. Amplifikatnachweis
						 9361.50  170      Chlamydia pneumoniae, Nukleinsüure-       M
				amplifikation, inkl. Amplifikatnachweis
						 9362.83    10    Cyto-Zentrifugation (kumulierbar)                  M
						 9363.84    10    Quantitative Bakt. (andere Mat. als               M
				Urin), kumulierbar
						 9364.00    40      Bartonella Henselae IgG                                   M
						 9365.00    45      Bartonella Henselae IgM                                   M
						 9365.50  170     Bartonella henselae / quintana,                      M
				Nukleinsüureamplifikation, inkl.
				Amplifikatnachweis
						9366.001   15    Urease-Test (Helicobacter pylori)              CM

				1 Zur Durchführung dieser Analyse ist keine Anerkennung des Bundesamtes für Gesundheit im
				Sinne des Art. 5 Abs. 1 des Epidemiengesetzes vom 18. Dezember 1970 erforderlich

																																																														 101


				EOS
				begin
					result = @parser.parse_page(src, 101)
				rescue AmbigousParseException => e
					puts e.inspect
				end
				expected_first = {
					:code					=>	'9354.40',
					:group				=>	'9354',
					:position			=>	'40',
					:taxpoints		=>	35,
					:anonymous		=>	true,
					:lab_areas		=>	['M'],
					:description	=>	'Neisseria gonorrhoeae, IF oder Hybridisierung',
					:list_title			=>	nil,
					:permission			=>	nil,
					:taxpoint_type	=>	nil,
				}
				expected_last = {
					:code					=>	'9366.00',
					:group				=>	'9366',
					:position			=>	'00',
					:taxpoints		=>	15,
					:lab_areas		=>	['C','M'],
					:description	=>	'Urease-Test (Helicobacter pylori)',
					:footnote			=>	'Zur Durchführung dieser Analyse ist keine Anerkennung des Bundesamtes für Gesundheit im Sinne des Art. 5 Abs. 1 des Epidemiengesetzes vom 18. Dezember 1970 erforderlich',
					:list_title			=>	nil,
					:permission			=>	nil,
					:taxpoint_type	=>	nil,
				}
				expected_size = 18
				assert_equal(expected_first, result.first)
				assert_equal(expected_last, result.last)
				assert_equal(expected_size, result.size)
			end
			def test_parse_page__6
				src = <<-EOS
Rev.    Pos.-Nr. A TP  Bezeichnung (Chemie/Hämatologie/Immunologie) B

			8055.00    25  Apolipoprotein E                                           C
			8056.00    70  Apolipoprotein E Phänotypen                        C
			8056.01   100  Arsen, mit AAS                                               C
			8058.00     9  Aspartat-Aminotransferase (ASAT)             C
			8059.10    80   Natriuretisches Peptid (BNP, NT-                  C
proBNP)  
	Limitation: Abklärung der akuten Dyspnoe 
zum Ausschluss der akuten oder chronischen 
Herzinsuffizien z; nicht zur Therapie-
überwachung
			8060.00    40  Autoantikörper gegen Colon-Epithel               I
			8060.01    40  Autoantikörper gegen                                    I
Acetylcholinrezeptoren, ql 
			8060.02    50  Autoantikörper gegen                                    I
Acetylcholinrezeptoren, qn 
			8060.03    40   Autoantikörper gegen Actin, ql                        I
			8060.04    50  Autoantikörper gegen Actin, qn                       I
			8060.05    40   Autoantikörper gegen Centromer, ql               I
			8060.06    50  Autoantikörper gegen Centromer, qn              I
			8061.00    50   Autoantikörper gegen DNA, ql                        I
			8062.00    60   Autoantikörper gegen DNA, qn                       I
			8063.00    40  Autoantikörper gegen Endomysium, ql           I
			8064.00    50   Autoantikörper gegen Endomysium, qn          I
			8064.01    40  Autoantikörper gegen GAD (Glutamat-           I
Decarboxylase), ql 
			8064.02    50  Autoantikörper gegen GAD (Glutamat-           I
Decarboxylase), qn 
			8064.03    40   Autoantikörper gegen Gangliosid, ql               I
			8064.04    50  Autoantikörper gegen Gangliosid, qn              I
			8064.05    50   Autoantikörper gegen Gangliosid GM1           I
			8064.06    50   Autoantikörper gegen Gangliosid GM2           I
			8064.07    50   Autoantikörper gegen Gangliosid GD1           I
			8064.50    50  Autoantikörper gegen Gewebstrans-              I
glutaminase, qn, nicht kumulierbar mit 
8063.00 und 8064.00 
			8065.00    40  Autoantikörper gegen glatte Muskulatur         I
			8066.00    35   Gliadin, Antikörper gegen ~, IgG                     I
			8067.00    35   Gliadin, Antikörper gegen ~, IgA                     I
			8068.00    40  Autoantikörper gegen glomeruläre                  I
Basalmembran, ql 
																																																		 43

				EOS
				begin
					result = @parser.parse_page(src, 43)
				rescue AmbigousParseException => e
					puts e.inspect
				end
				expected_first = {
					:code					=>	'8055.00',
					:group				=>	'8055',
					:position			=>	'00',
					:taxpoints		=>	25,
					:lab_areas		=>	['C'],
					:description	=>	'Apolipoprotein E',
					:list_title			=>	nil,
					:permission			=>	nil,
					:taxpoint_type	=>	nil,
				}
				expected_last = {
					:code					=>	'8068.00',
					:group				=>	'8068',
					:position			=>	'00',
					:taxpoints		=>	40,
					:lab_areas		=>	['I'],
					:description	=>	'Autoantikörper gegen glomeruläre Basalmembran, ql',
					:list_title			=>	nil,
					:permission=>	nil,
					:taxpoint_type	=>	nil,
				}
				expected_fifth = {
					:code						=>	'8059.10',
					:group					=>	'8059',
					:position				=>	'10',
					:description		=>	'Natriuretisches Peptid (BNP, NT-proBNP)',
					:lab_areas			=>	['C'],
					:taxpoints			=>	80,
					:limitation			=>	'Abklärung der akuten Dyspnoe zum Ausschluss der akuten oder chronischen Herzinsuffizien z; nicht zur Therapieüberwachung',
					:list_title			=>	nil,
					:taxpoint_type	=>	nil,
					:permission		=>	nil,
				}

					
				expected_size = 28
				assert_equal(expected_fifth, result.at(4))
				assert_equal(expected_first, result.first)
				assert_equal(expected_last, result.last)
				assert_equal(expected_size, result.size)
			end
			def test_fr_parse_line__1
				src = <<-EOS
C 8272.00 30 Hémogramme V (automatisé): comme  H 
hémogramme IV, répartition des leucocytes par cytométrie de flux
Limitation: pas avec la méthode QBC
				EOS
				begin
					result = @parser.parse_line(src)
				end
				expected = {
					:code					=>	'8272.00',
					:group				=>	'8272',
					:position			=>	'00',
					:lab_areas		=>	['H'],
					:analysis_revision	=>	'C',
					:taxpoints		=>	30,
					:description	=>	'Hémogramme V (automatisé): comme hémogramme IV, répartition des leucocytes par cytométrie de flux',
					:limitation		=>	'pas avec la méthode QBC',
					:list_title		=>	nil,
					:permission		=>	nil,
					:taxpoint_type	=>	nil,
				}
				assert_equal(expected, result)
			end
			def test_fr_parse_line__2
				src = <<-EOS
				      8179.00    25  D-dimère, ql; limitation: uniquement pour             H
				l'exclusion de la coagulopathie intravasculaire
				disséminée (DIC)

				EOS
				 begin
					 result = @parser.parse_line(src)
				 end
				expected = {
					:code					=>	'8179.00',
					:group				=>	'8179',
					:position			=>	'00',
					:taxpoints		=>	25,
					:description	=>	'D-dimère, ql',
					:limitation		=>	'uniquement pour l\'exclusion de la coagulopathie intravasculaire disséminée (DIC)',
					:lab_areas		=>	['H'],
					:taxpoint_type	=>	nil,
					:list_title			=>	nil,
					:permission			=>	nil,
				}
				assert_equal(expected, result)
			end
			def test_fr_parse_line__3
				src = <<-EOS
				      8059.10    80  Peptide natriurétique (BNP, NT-proBNP);     C
				limitation: recherche d'une dyspnée aiguë
				EOS
				begin
					result = @parser.parse_line(src)
				end
				expected = {
					:code						=>	'8059.10',
					:group					=>	'8059',
					:position				=>	'10',
					:taxpoints			=>	80,
					:description		=>	'Peptide natriurétique (BNP, NT-proBNP);',
					:lab_areas			=>	['C'],
					:limitation			=>	'recherche d\'une dyspnée aiguë',
					:taxpoint_type	=>	nil,
					:list_title			=>	nil,
					:permission			=>	nil,
				}
				assert_equal(expected, result)
			end
			def test_fr_parse_page__1
				src = <<-EOS
Rév. No pos. A TP Dénomination (chimie/hématologie/immunologie) B
8252.00   150  Culture lymphocytaire mixte, pour                 HI
chaque donneur supplémentaire
8256.00    40   Tests globaux des inhibiteurs (type               H
				PIVKA)
8258.00    60  Glucagon                                                      C
8259.00     9    Glucose (sang, plasma, sérum)                     C
8259.01     9    Glucose (autre liquide biologique)                 C
8260.00    35  Glucose-6-phosphate-déshydrogénase       C
		(G-6-PDH)
8261.00    25   Glucose, test de surcharge, selon OMS        C
			(uniquement les analyses)
8262.00    25  Glutamate-déshydrogénase (GLDH)             C
8262.01    25  Glutamate-décarboxylase                            C
8263.00    35  Glutathion réduit                                           C
8265.00    30   Hémoglobine glyquée (HbA1c)                      C
8266.00   100  Or, par AAS                                                    C
8267.00    60  Elastase granulocytaire plasmatique          CH
C     8268.00     12  Hémogramme I (automatisé):                        H
				érythrocytes, leucocytes, hémoglobine,
				hématocrite et indices
				Limitation: pas avec la méthode QBC
C     8269.00     15   Hémogramme II (automatisé):                       H
				hémogramme I, plus thrombocytes
				Limitation: pas avec la méthode QBC
C     8270.00     20  Hémogramme III (automatisé):                     H
				hémogramme II, plus 3 sous-
				populations de  leucocytes
				Limitation: pas avec la méthode QBC
C     8271.00     25   Hémogramme IV (automatisé):                      H
				hémogramme III, plus 5 ou plus de
				sous-populations de leucocytes
				Limitation: pas avec la méthode QBC
C     8272.00     30  Hémogramme V (automatisé): comme          H
 hémogramme IV, répartition des leucocytes par cytométrie de flux
Limitation: pas avec la méthode QBC

52
				EOS
				begin
					result = @parser.parse_page(src, 52)
				end
				expected_first = {}
				expected_last = {
				:analysis_revision				=>	'C',
				:lab_areas								=>	['H'],
				:group										=>	'8272',
				:position									=>	'00',
				:code											=>	'8272.00',
				:description							=>	'Hémogramme V (automatisé): comme hémogramme IV, répartition des leucocytes par cytométrie de flux',
				:limitation								=>	'pas avec la méthode QBC',
				:taxpoints								=>	30,
				:taxpoint_type						=>	nil,
				:list_title								=>	nil,
				:permission								=>	nil,
				}
				assert_equal(expected_last, result.last)
			end
			def test_fr_parse_page__2
				src = <<-EOS
Rév. No pos. A TP Dénomination (chimie/hématologie/immunologie) B
8059.10 80 Peptide natriurétique (BNP, NT-proBNP); C
limitation: recherche d'une dyspnée aiguë pour l'élimination d'une insuffisance cardiaque aiguë ou chronique; pas pour le suivi d'une thérapie
8060.00 40 Auto-anticorps anti-épithélium du côlon I
8060.01 40 Auto-anticorps anti-récepteurs de I
l'acétylcholine, ql
8060.02 50 Auto-anticorps anti-récepteurs de I
l'acétylcholine, qn
8060.03 40 Auto-anticorps anti-actine, ql
I
8060.04 50 Auto-anticorps anti-actine, qn
I
56
				EOS
				begin
					result = @parser.parse_page(src, 56)
				end
				expected = [
					{
					:code					=>	'8059.10',
					:group				=>	'8059',
					:position			=>	'10',
					:taxpoints		=>	80,
					:lab_areas		=>	['C'],
					:description	=>	'Peptide natriurétique (BNP, NT-proBNP);',
					:limitation		=>	'recherche d\'une dyspnée aiguë pour l\'élimination d\'une insuffisance cardiaque aiguë ou chronique; pas pour le suivi d\'une thérapie',
					:list_title			=>	nil,
					:permission			=>	nil,
					:taxpoint_type	=>	nil,
				},
				{  
					:code						=>	'8060.00',
					:group					=>	'8060',
					:position				=>	'00',
					:taxpoints			=>	40,
					:lab_areas			=>	['I'],
					:description		=>	'Auto-anticorps anti-épithélium du côlon',
					:taxpoint_type	=>	nil,
					:list_title			=>	nil,
					:permission			=>	nil,
				},
			{  
				:code						=>	'8060.01',
				:group					=>	'8060',
				:position				=>	'01',
				:taxpoints			=>	40,
				:lab_areas			=>	['I'],
				:description		=>	'Auto-anticorps anti-récepteurs de l\'acétylcholine, ql',
				:taxpoint_type	=>	nil,
				:list_title			=>	nil,
				:permission			=>	nil,
			},
			{  
				:code						=>	'8060.02',
				:group					=>	'8060',
				:position				=>	'02',
				:taxpoints			=>	50,
				:lab_areas			=>	['I'],
				:description		=>	'Auto-anticorps anti-récepteurs de l\'acétylcholine, qn',
				:taxpoint_type	=>	nil,
				:list_title			=>	nil,
				:permission			=>	nil,
			},
			{  
				:code						=>	'8060.03',
				:group					=>	'8060',
				:position				=>	'03',
				:taxpoints			=>	40,
				:lab_areas			=>	['I'],
				:description		=>	'Auto-anticorps anti-actine, ql',
				:taxpoint_type	=>	nil,
				:list_title			=>	nil,
				:permission			=>	nil,
			},
			{  
				:code						=>	'8060.04',
				:group					=>	'8060',
				:position				=>	'04',
				:taxpoints			=>	50,
				:lab_areas			=>	['I'],
				:description		=>	'Auto-anticorps anti-actine, qn',
				:taxpoint_type	=>	nil,
				:list_title			=>	nil,
				:permission			=>	nil,
			},
				]
				assert_equal(expected, result)
			end
			def test_fr_parse_page__3
				src = <<-EOS
      9365.50   170 Bartonella henselae/quintana, amplifi-        M
				cation et détection des acides
				nucléiques
				     9366.001    15      Uréase, test à l~R~ (Helicobacter pylori)      CM
				     9367.001    90     Helicobacter pylori, test respiratoire à       CM
				l~Rurée 13C, y.c. l'urée 13C
				  La préparation à l'urée 13C doit être
				enregistrée par l'Institut suisse des
				produits thérapeutiques (Swissmedic).
				      9368.50   170    Tropheryma whippelii, amplification et        M
				détection des acides nucléiques
				1 L'exécution de cette analyse ne nécessite pas de reconnaissance par l'Office fédéral de la
				santé publique au sens de l'art. 5, al. 1, de la loi sur les épidémies du 18 décembre 1970
				103
				EOS
				begin
					result = @parser.parse_page(src, 103)
				end
				expected_second = {
					:code						=>	'9366.00',
					:group					=>	'9366',
					:position				=>	'00',
					:taxpoints			=>	15,
					:description		=>	'Uréase, test à l~R~ (Helicobacter pylori)',
					:lab_areas			=>	['C','M'],
					:footnote				=>	'L\'exécution de cette analyse ne nécessite pas de reconnaissance par l\'Office fédéral de la santé publique au sens de l\'art. 5, al. 1, de la loi sur les épidémies du 18 décembre 1970',
					:list_title			=>	nil,
					:taxpoint_type	=>	nil,
					:permission			=>	nil,
				}
				assert_equal(expected_second, result.at(1))
			end
		end
	end
end
