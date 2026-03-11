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

            # Try EPha curated interactions first (ATC-to-ATC), then fall back to substance lookup
            atc_codes.combination(2).each do |atc1, atc2|
              idx1 = atc_codes.index(atc1)
              idx2 = atc_codes.index(atc2)
              sub1 = substances[idx1]&.name.to_s
              sub2 = substances[idx2]&.name.to_s

              epha = EphaInteractions.find_epha_interaction(atc1, atc2)
              epha ||= EphaInteractions.find_epha_interaction(atc2, atc1)

              if epha
                severity = epha["severity_score"].to_s
                @model << {
                  substance_active: sub1,
                  substance_passive: sub2,
                  active: atc1,
                  passive: atc2,
                  info: epha["risk_label"],
                  rating: severity
                }
                next
              end

              # Fall back to substance-level lookup
              row = EphaInteractions.get_interaction_detail(sub1, sub2)
              row ||= EphaInteractions.get_interaction_detail(sub2, sub1)
              next unless row

              severity = row["severity_score"].to_s
              @model << {
                substance_active: sub1,
                substance_passive: sub2,
                active: atc1,
                passive: atc2,
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
