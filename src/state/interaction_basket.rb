#!/usr/bin/env ruby
# InteractionBasketState -- oddb -- 07.06.2004 -- maege@ywesee.com

require	'state/global_predefine'
require	'view/interaction_basket'
require 'model/cyp450connection'

module ODDB
	class InteractionBasketState < GlobalState
		VIEW = InteractionBasketView
		class InteractionCheck
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
				interaction_check = InteractionCheck.new(substance, cyp450s)
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
	class EmptyInteractionBasketState < InteractionBasketState
		VIEW = InteractionBasketView
	end
end
