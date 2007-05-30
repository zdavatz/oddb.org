#!/usr/bin/env ruby
# State::Interactions::Basket -- oddb -- 07.06.2004 -- mhuggler@ywesee.com

require	'state/global_predefine'
require	'view/interactions/basket'
require 'model/cyp450connection'

module ODDB
	module State
		module Interactions
class Basket < State::Interactions::Global
	VIEW = View::Interactions::Basket
	DIRECT_EVENT = :interaction_basket
	LIMITED = false
	class Check
		attr_reader :substance, :cyp450s, :inducers, :inhibitors
		def initialize(substance)#, cyp450s)
			@substance = substance
			@cyp450s = substance.substrate_connections.keys
      if(substance.has_effective_form?)
        @cyp450s.concat substance.effective_form.substrate_connections.keys
        @cyp450s = @cyp450s.uniq
      end
			@inducers = {}
			@inhibitors = {}
		end
		def add_interaction(interaction)
			case interaction
			when ODDB::CyP450InhibitorConnection
				store_interaction(@inhibitors, interaction)
			when ODDB::CyP450InducerConnection
				store_interaction(@inducers, interaction)
			end
		end
		def store_interaction(storage, interaction)
			(storage[interaction.substance] ||= []).push(interaction)
		end
	end
	def init
		@model = [] 
		calculate_interactions
	end
	def delete
		init
	end
	def calculate_interactions
# work in progress
		subs = @session.interaction_basket
		@model = subs.collect { |sub|
			check = Check.new(sub)
			(subs - [sub]).each { |other|
				sub.interactions_with(other).each { |interaction|
					check.add_interaction(interaction)
				}
			}
			check
		}
	end
end
class EmptyBasket < State::Interactions::Basket
	VIEW = View::Interactions::Basket
end
		end
	end
end
