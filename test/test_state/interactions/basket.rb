#!/usr/bin/env ruby
# State::Interactions::Basket -- oddb -- 21.06.2004 -- maege@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'state/interactions/basket'
require 'mock'

module ODDB
	module State
		module Interactions
class Basket < State::Interactions::Global
	attr_reader :model
end

class TestBasketState < Test::Unit::TestCase
	class App
		def substance_by_connection_key(substance)
			substance
		end
	end
	class Session
		attr_accessor :interaction_basket
		def initialize
			@interaction_basket = []
		end
		def app
			App.new
		end
	end
	def test_calculate_interactions
		substance1 = Mock.new('substance1')
		substance2 = Mock.new('substance2')
		connection1 = Mock.new('connection1')
		connection2 = Mock.new('connection2')
		connection3 = ODDB::CyP450InhibitorConnection.new('substance_name')
		substance1.__next(:interaction_connections) { {} } 
		substance2.__next(:interaction_connections) { 
			{ 
				'cyp1'	=> [ connection1, connection2 ],
				'cyp2'	=> [ connection3 ],
			}
		}
		connection1.__next(:substance_name) { '' }
		substance2.__next(:same_as?) { true }
		connection2.__next(:substance_name) { '' }
		substance2.__next(:same_as?) { true }
		substance2.__next(:same_as?) { false }
		session = Session.new
		session.interaction_basket = [ substance1, substance2 ] 
		state = State::Interactions::Basket.new(session, 'model')
		assert_equal(2, state.model.size)
		assert_equal(2, state.model.last.cyp450s.size)
		assert_equal(1, state.model.last.inhibitors.size)
		substance1.__verify
		substance2.__verify
		connection1.__verify
		connection2.__verify
	end
end
		end
	end
end
