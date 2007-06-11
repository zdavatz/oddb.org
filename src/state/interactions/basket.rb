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
  class ObservedInteraction
    attr_reader :substance, :fachinfo, :pattern, :match
    def initialize(substance, fachinfo, pattern, match)
      @substance, @fachinfo, @pattern, @match = substance, fachinfo, pattern, match
    end
  end
	class Check
		attr_reader :substance, :cyp450s, :inducers, :inhibitors, :observed
		def initialize(substance)#, cyp450s)
			@substance = substance
			@cyp450s = substance.substrate_connections
      while(substance.has_effective_form? && !substance.is_effective_form?)
				substance = substance.effective_form
        @cyp450s = substance.substrate_connections.merge @cyp450s
      end
			@inducers = {}
			@inhibitors = {}
      @observed = {}
		end
		def add_interaction(interaction)
			case interaction
			when ODDB::CyP450InhibitorConnection
				store_interaction(@inhibitors, interaction)
			when ODDB::CyP450InducerConnection
				store_interaction(@inducers, interaction)
      when ObservedInteraction
				store_interaction(@observed, interaction)
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
    subs = @session.interaction_basket
    @model = subs.collect { |sub|
      check = Check.new(sub)
      (subs - [sub]).each { |other|
        sub.interactions_with(other).each { |interaction|
          check.add_interaction(interaction)
        }
        observed_interactions(sub, other).each { |observed|
          check.add_interaction(observed)
        }
      }
      check
    }
  end
  def observed_interactions(sub, other)
    keys = other.search_keys.join('|').gsub(' ', '[\s-]')
    ptrn = /(^|\s)(#{keys})(\s|$)/i
    found = {}
    match = nil
    sub.sequences.each { |seq|
      if(seq.substances.size == 1 && (fi = seq.fachinfo) \
         && (doc = fi.send(@session.language)) && (chapter = doc.interactions) \
         && (match = chapter.match(ptrn)))
        found.store(fi, ObservedInteraction.new(other, fi, 
                                                ptrn.source, match.to_s.strip))
      end
    }
    found.values
  end
end
class EmptyBasket < State::Interactions::Basket
	VIEW = View::Interactions::Basket
end
		end
	end
end
