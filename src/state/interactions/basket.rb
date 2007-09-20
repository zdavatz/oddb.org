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
    def eql?(other)
      @fachinfo.eql? other.fachinfo
    end
    def hash
      @fachinfo.hash
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
      # interaction may be a ODBA::Stub 
      case interaction.odba_instance
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
    values = _observed_interactions_chemical(sub, other)
    values += _observed_interactions_effective(sub, other)
    values.uniq!
    values
  end
  def _observed_interactions_chemical(sub, other)
    values = _observed_interactions(sub, other)
    sub.chemical_forms.each { |chm|
      values += _observed_interactions_chemical(chm, other)
    }
    values
  end
  def _observed_interactions_effective(sub, other)
    values = _observed_interactions(sub, other)
    if(sub.has_effective_form? && !sub.is_effective_form?)
      values += _observed_interactions_effective(sub.effective_form, other)
    end
    values
  end
  def _observed_interactions(sub, other)
    keys = (other.names - sub.names).join('|').gsub(' ', '[\s-]')
    return [] if(keys.empty?)
    ptrn = /(^|[\s\(])((#{keys})[esn]{0,2})([\s,.\)-]|$)/i
    found = []
    match = nil
    sub.sequences.each { |seq|
      if(seq.substances.size == 1 && (fi = seq.fachinfo) \
         && (doc = fi.send(@session.language)) && (chapter = doc.interactions) \
         && (match = chapter.match(ptrn)))
        found.push(ObservedInteraction.new(other, fi, ptrn.source, match[2]))
      end
    }
    found.uniq
  end
end
class EmptyBasket < State::Interactions::Basket
	VIEW = View::Interactions::Basket
end
		end
	end
end
