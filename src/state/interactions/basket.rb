#!/usr/bin/env ruby
# State::Interactions::Basket -- oddb -- 07.06.2004 -- maege@ywesee.com

require	'state/interactions/global'
require	'view/interactions/basket'
require 'model/cyp450connection'

module ODDB
	module State
		module Interactions
class Basket < State::Interactions::Global
	VIEW = View::Interactions::Basket
	DIRECT_EVENT = :interaction_basket
	class Check
		attr_reader :substance, :cyp450s, :inducers, :inhibitors
		def initialize(substance, cyp450s)
			@substance = substance
			@cyp450s = cyp450s
			@inducers = {}
			@inhibitors = {}
		end
		def add_inhibitor(inhibitor)
			unless(@inhibitors.keys.include?(inhibitor.substance_name))
				@inhibitors.store(inhibitor.substance_name, inhibitor)
			end
		end 
		def add_inducer(inducer)
			unless(@inducers.keys.include?(inducer.substance_name))
				@inducers.store(inducer.substance_name, inducer)
			end
		end
	end
	def init
		@model = [] 
		calculate_interactions
	end
	def delete
		pointers = user_input(:pointers)
		calculate_interactions
	end
	def calculate_interactions
		@session.interaction_basket.each { |substance|
			connections = substance.interaction_connections(@session.interaction_basket)
			cyp450s = []
			interactions = []
			connections.each { |cyp450_id, connection|
				cyp450s.push(cyp450_id)
				interactions.concat(connection)
			}
			interaction_check = Check.new(substance, cyp450s)
			interactions.each { |interaction|
				unless(substance.same_as?(interaction.substance_name))
					case interaction
					when ODDB::CyP450InhibitorConnection
						interaction_check.add_inhibitor(interaction)
					when ODDB::CyP450InducerConnection
						interaction_check.add_inducer(interaction)
					end
				end
			}
			@model.push(interaction_check)
		}
	end
end
class EmptyBasket < State::Interactions::Basket
	VIEW = View::Interactions::Basket
end
		end
	end
end
