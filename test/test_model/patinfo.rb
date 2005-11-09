#!/usr/bin/env ruby
# TestPatinfo -- oddb -- 29.10.2003 -- rwaltert@ywesee.com


$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'model/patinfo'
require 'stub/odba'

module ODDB
	class Patinfo
		attr_accessor :sequences
	end
end

class TestPatinfo < Test::Unit::TestCase
	class StubSequence
		include ODDB::Persistence
		def patinfo=(patinfo)
			if(@patinfo.respond_to?(:remove_sequence))
				@patinfo.remove_sequence(self)
			end
			patinfo.add_sequence(self)
			@patinfo = patinfo
		end
	end
	def setup
		@patinfo = ODDB::Patinfo.new
	end
	def test_add_sequence
		@patinfo.sequences = []
		prod = StubSequence.new
		@patinfo.add_sequence(prod)
		assert_equal([prod], @patinfo.sequences)
	end
	def test_remove_sequence
		prod = StubSequence.new
		@patinfo.sequences = [prod]
		@patinfo.remove_sequence(prod)
		assert_equal([],@patinfo.sequences)
	end
end
class TestPatinfoDocument < Test::Unit::TestCase
	def test_to_s1
		doc = ODDB::PatinfoDocument.new
		doc.name = "name"
		doc.company = "company"
		doc.galenic_form = "galenic_form"
		doc.effects = "effects"
		doc.purpose = "purpose"
		doc.amendments = "amendments"
		doc.contra_indications = "contra_indications"
		doc.precautions = "precautions"
		doc.pregnancy = "pregnancy"
		doc.usage = "usage"
		doc.unwanted_effects = "unwanted_effects"
		doc.general_advice = "general_advice"
		doc.other_advice = "other_advice"
		doc.composition = "composition"
		doc.packages = "packages"
		doc.distribution = "distribution"
		doc.date = "date"
		doc.iksnrs = "iksnrs" 
		expected = <<-EOS
name
company
galenic_form
effects
purpose
amendments
contra_indications
precautions
pregnancy
usage
unwanted_effects
general_advice
other_advice
composition
packages
distribution
date
		EOS
		assert_equal(expected.strip, doc.to_s)
	end
	def test_to_s2
		doc = ODDB::PatinfoDocument.new
		doc.name = "name"
		doc.company = "company"
		doc.galenic_form = "galenic_form"
		doc.effects = "effects"
		doc.contra_indications = "contra_indications"
		doc.precautions = "precautions"
		doc.unwanted_effects = "unwanted_effects"
		doc.general_advice = "general_advice"
		doc.packages = "packages"
		doc.date = "date"
		doc.iksnrs = "iksnrs" 
		expected = <<-EOS
name
company
galenic_form
effects
contra_indications
precautions
unwanted_effects
general_advice
packages
date
		EOS
		assert_equal(expected.strip, doc.to_s)
	end
end
