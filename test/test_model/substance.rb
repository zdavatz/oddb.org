#!/usr/bin/env ruby
# TestSubstance	-- oddb -- 25.02.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'model/substance'

module ODDB
	class Substance
		attr_writer :sequences
	end
end

class TestSubstance < Test::Unit::TestCase
	def setup
		@substance = ODDB::Substance.new('ACIDUM ACETYLSALICYLICUM')
	end
	def test_initialize
		assert_not_nil(@substance.oid)
	end
	def test_add_sequence
		@substance.add_sequence("holla")
		assert_equal(["holla"], @substance.sequences)
	end
	def test_remove_sequence
		@substance.sequences = ["alloa"]
		@substance.remove_sequence("alloa")
		assert_equal([], @substance.sequences)
	end
	def test_name
		assert_equal('Acidum Acetylsalicylicum', @substance.name)
	end
	def test_equal_string
		assert_equal(@substance, 'Acidum Acetylsalicylicum', 'Substance did not equal exact String')
		assert_equal(@substance, 'ACIDUM ACETYLSALICYLICUM', 'Substance did not equal uppercase String')
		assert_equal(@substance, 'acidum acetylsalicylicum', 'Substance did not equal lowercase String')
	end
	def test_equal_substance
		substance = ODDB::Substance.new('acidum acetylsalicylicum')
		assert_equal(@substance, substance)
		substance = ODDB::Substance.new('ACIDUM ACETYLSALICYLICUM')
		assert_equal(@substance, substance)
	end
	def test_similar_name
		assert_equal(false, @substance.similar_name?("ACIDUM MEFENAMICUM"))
		assert_equal(true, @substance.similar_name?("ACIDU ACETYLSALIKUM"))
	end
	def test_compare #test_<=>
		assert_equal(0, @substance <=> "ACIDUM ACETYLSALICYLICUM")
		assert_equal(-1, @substance <=> "BCIDUM ACETYLSALICYLICUM")
		assert_equal(+1, @substance <=> "AbIDUM ACETYLSALICYLICUM")
		assert_equal(0, @substance <=> @substance)
	end
end
