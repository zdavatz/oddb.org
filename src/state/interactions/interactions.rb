#!/usr/bin/env ruby

# ODDB::State::Interactions::Interactions -- oddb.org -- 21.02.2012 -- mhatakeyama@ywesee.com

require "state/global_predefine"
require "view/interactions/interactions"
require "view/pointervalue"
require "model/sdif_interaction"

module ODDB
  module State
    module Interactions
      class Interactions < State::Interactions::Global
        VIEW = View::Interactions::Interactions
        DIRECT_EVENT = :interactions
        LIMITED = false
        def init
          @model = []
          if atc_codes = @session.interaction_basket_atc_codes and !atc_codes.empty? \
            and substances = @session.interaction_basket and !substances.empty?

            # Build interactions from SQLite DB using substance names
            substance_names = substances.map { |s| s&.name.to_s }.compact
            substance_names.combination(2).each do |sub1, sub2|
              row = EphaInteractions.get_interaction_detail(sub1, sub2)
              row ||= EphaInteractions.get_interaction_detail(sub2, sub1)
              next unless row

              active_idx = substance_names.index(sub1)
              passive_idx = substance_names.index(sub2)
              severity = row["severity_score"].to_s

              @model << {
                substance_active: sub1,
                substance_passive: sub2,
                active: atc_codes[active_idx],
                passive: atc_codes[passive_idx],
                info: row["severity_label"],
                rating: severity
              }
            end
          end
        end
      end
    end
  end
end
