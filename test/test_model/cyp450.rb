#!/usr/bin/env ruby
# TestCytochrome -- oddb -- 04.05.2004 -- maege@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'model/cyp450'
require 'mock'

module ODDB
	class Cytochrome
		attr_accessor :inducers, :inhibitors, :interactions
	end
end

class TestCyP450 < Test::Unit::TestCase
	def setup
		@cytochrome = ODDB::CyP450.new("foo")
	end
	def test_create_cyp450inducer
		@cytochrome.create_cyp450inducer('connection')
		assert_equal(1, @cytochrome.inducers.size)
	end
	def test_create_cyp450inhibitor
		@cytochrome.create_cyp450inhibitor('connection')
		assert_equal(1, @cytochrome.inhibitors.size)
	end
	def test_cyp450inducer
		@cytochrome.inducers = {
			'inducer_id_1'	=>	'inducer_1',
			'inducer_id_2'	=>	'inducer_2',
			'inducer_id_3'	=>	'inducer_3',
		}
		result = @cytochrome.cyp450inducer('inducer_id_2')
		assert_equal('inducer_2', result)
	end
	def test_cyp450inhibitor
		@cytochrome.inhibitors = {
			'inhibitor_id_1'	=>	'inhibitor_1',
			'inhibitor_id_2'	=>	'inhibitor_2',
			'inhibitor_id_3'	=>	'inhibitor_3',
		}
		result = @cytochrome.cyp450inhibitor('inhibitor_id_2')
		assert_equal('inhibitor_2', result)
	end
	def test_delete_cyp450inducer
		@cytochrome.inducers = {
			'inducer_id'	=>	'inducer_1',
		}
		@cytochrome.delete_cyp450inducer('inducer_id')
		assert_equal({}, @cytochrome.inducers)
	end
	def test_delete_cyp450inhibitor
		@cytochrome.inhibitors = {
			'inhibitor_id'	=>	'inhibitor_1',
		}
		@cytochrome.delete_cyp450inhibitor('inhibitor_id')
		assert_equal({}, @cytochrome.inhibitors)
	end
end
