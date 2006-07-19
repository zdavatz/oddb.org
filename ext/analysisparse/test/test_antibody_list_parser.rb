#!/usr/bin/env ruby
# AnalysisParse::TestAntibodyListParser -- oddb -- 10.11.2005 -- hwyss@ywesee.com

$: << File.expand_path('../src', File.dirname(__FILE__))

require 'test/unit'
require 'antibody_list_parser'

module ODDB
	module AnalysisParse
		class TestAntibodyListParser < Test::Unit::TestCase
			def setup
				@parser = AntibodyListParser.new
			end
			def test_parse_line__1
				src =<<-EOS
Autoantikörper gegen b2-Glykoprotein I (IgA)
				EOS
				begin
					result = @parser.parse_line(src)
				rescue AmbigousParseException => e
				end
				expected = {
					:description	=>	'Autoantikörper gegen b2-Glykoprotein I (IgA)'
				}
				assert_equal(expected, result)
			end
			def test_parse_line__2
				src =<<-EOS
S Autoantikörper gegen CCP (Cyclisches Citrulliniertes Peptid)? Kapitel 1, Pos. 8113.20
				EOS
				begin
					result = @parser.parse_line(src)
				rescue AmbigousParseException	=> e
					puts e.inspect
				end
				expected = {
					:description	=>	'Autoantikörper gegen CCP (Cyclisches Citrulliniertes Peptid)? Kapitel 1, Pos. 8113.20',
					:revision			=>	'S',
				}
				assert_equal(expected, result)
			end
			def test_parse_page__1
				src = <<-EOS
4.4 Liste seltener Autoantikörper
Tarifierung: siehe Pos. 8110.00 ~V 8111.01
Rev. Bezeichnung der Antikörper
Autoantikörper gegen b2-Glykoprotein I (IgA)
Autoantikörper gegen b2-Glykoprotein I (IgG)
Autoantikörper gegen b2-Glykoprotein I (IgM)
Autoantikörper gegen 21-Hydroxylase
Autoantikörper gegen 68 KD (hsp-70)
Autoantikörper gegen Becherzellen
Autoantikörper gegen BPI (IgA)
Autoantikörper gegen BPI (IgG)
S Autoantikörper gegen CCP (Cyclisches Citrulliniertes Peptid)? Kapitel 1, Pos. 8113.20
Autoantikörper gegen Chondrozyten
Autoantikörper gegen Chromatin
Autoantikörper gegen Cytokeratin 8/18
Autoantikörper gegen Desmoglein 1
Autoantikörper gegen Desmoglein 3
Autoantikörper gegen Elastase
Autoantikörper gegen Filaggrin (Keratin)
Autoantikörper gegen Fodrin
Autoantikörper gegen Gangliosid GQ1B
Autoantikörper gegen G-S-T
Autoantikörper gegen Herzmuskel
Autoantikörper gegen Hu, Yo, Ri
Autoantikörper gegen IA2
Autoantikörper gegen Kathepsin
Autoantikörper gegen Ku
Autoantikörper gegen Laktoferrin
Autoantikörper gegen MAG IgM
Autoantikörper gegen Mi 2
Autoantikörper gegen Myelin
Autoantikörper gegen Nukleosomen
Autoantikörper gegen p53
Autoantikörper gegen Parathyreoidea
Autoantikörper gegen PM-Scl
Autoantikörper gegen Recoverin
Autoantikörper gegen Retina
Autoantikörper gegen ribosomale P-Proteine
Autoantikörper gegen Sulfatidil
121
				EOS
				begin
					result = @parser.parse_page(src, 121)
				rescue AmbigousParseException => e
					puts e.inspect
				end
				expected_first = {
					:description	=>	'Autoantikörper gegen b2-Glykoprotein I (IgA)'
				}
				expected_last = {
					:description	=>	'Autoantikörper gegen Sulfatidil'
				}
				expected_size = 36
				assert_equal(expected_first, result.first)
				assert_equal(expected_last, result.last)
				assert_equal(expected_size, result.size)
			end
		end
	end
end
