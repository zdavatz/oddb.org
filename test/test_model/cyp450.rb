#!/usr/bin/env ruby
# encoding: utf-8
# TestCytochrome -- oddb -- 04.05.2004 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'stub/odba'
require 'test/unit'
require 'model/cyp450'
require 'flexmock'

module ODDB
	class CyP450
		attr_accessor :inducers, :inhibitors
	end
end

class TestCyP450 < Test::Unit::TestCase
	def setup
		@cyp450 = ODDB::CyP450.new("foo")
	end
	def test_create_cyp450inducer
		@cyp450.create_cyp450inducer('connection')
		assert_equal(1, @cyp450.inducers.size)
	end
	def test_create_cyp450inhibitor
		@cyp450.create_cyp450inhibitor('connection')
		assert_equal(1, @cyp450.inhibitors.size)
	end
	def test_cyp450inducer
		@cyp450.inducers = {
			'inducer_id_1'	=>	'inducer_1',
			'inducer_id_2'	=>	'inducer_2',
			'inducer_id_3'	=>	'inducer_3',
		}
		result = @cyp450.cyp450inducer('inducer_id_2')
		assert_equal('inducer_2', result)
	end
	def test_cyp450inhibitor
		@cyp450.inhibitors = {
			'inhibitor_id_1'	=>	'inhibitor_1',
			'inhibitor_id_2'	=>	'inhibitor_2',
			'inhibitor_id_3'	=>	'inhibitor_3',
		}
		result = @cyp450.cyp450inhibitor('inhibitor_id_2')
		assert_equal('inhibitor_2', result)
	end
	def test_delete_cyp450inducer
		@cyp450.inducers = {
			'inducer_id'	=>	'inducer_1',
		}
		@cyp450.delete_cyp450inducer('inducer_id')
		assert_equal({}, @cyp450.inducers)
	end
	def test_delete_cyp450inhibitor
		@cyp450.inhibitors = {
			'inhibitor_id'	=>	'inhibitor_1',
		}
		@cyp450.delete_cyp450inhibitor('inhibitor_id')
		assert_equal({}, @cyp450.inhibitors)
	end
	def test_interactions_with
		result = @cyp450.interactions_with(nil)
		assert_equal([], result)
	end
	def test_interactions_with2
		substance = FlexMock.new('substance')
		inh_connection1 = FlexMock.new('inh_connection1')
		inh_connection2 = FlexMock.new('inh_connection2')
		ind_connection1 = FlexMock.new('ind_connection1')
		ind_connection2 = FlexMock.new('ind_connection2')
		@cyp450.inhibitors = {
			'inh_conn1'	=>	inh_connection1,	
			'inh_conn2'	=>	inh_connection2,	
		}
		@cyp450.inducers = {
			'ind_conn1'	=>	ind_connection1,	
			'ind_conn2'	=>	inh_connection2,	
		}
		substance.should_receive(:connection_keys).and_return { [ 'connection_key' ] }
		substance.should_receive(:_search_keys).and_return { [ 'substance' ] }
		result = @cyp450.interactions_with(substance)
		assert_equal([], result)
	end
	def test_interactions_with3
		substance = FlexMock.new('substance')
		inh_connection1 = FlexMock.new('inh_connection1')
		inh_connection2 = FlexMock.new('inh_connection2')
		ind_connection1 = FlexMock.new('ind_connection1')
		ind_connection2 = FlexMock.new('ind_connection2')
		@cyp450.inhibitors = {
			'inh_conn1'	=>	inh_connection1,	
			'inh_conn2'	=>	inh_connection2,	
		}
		@cyp450.inducers = {
			'ind_conn1'	=>	ind_connection1,	
			'ind_conn2'	=>	ind_connection2,	
		}
		substance.should_receive(:connection_keys).and_return {
      [ 'inh_conn2', 'ind_conn1', 'ind_conn2' ]
    }
		substance.should_receive(:_search_keys).and_return { [ 'substance' ] }
		result = @cyp450.interactions_with(substance)
		expected = [ inh_connection2, ind_connection1, ind_connection2 ]
		assert_equal(expected, result)
	end
end
