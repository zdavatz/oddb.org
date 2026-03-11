#!/usr/bin/env ruby

# ODDB::State::Interactions::InteractionDetail -- oddb.org -- 21.02.2012 -- mhatakeyama@ywesee.com

require "state/global_predefine"
require "view/interactions/interaction_detail"
require "model/sdif_interaction"

module ODDB
  module State
    module Interactions
      class InteractionDetail < State::Interactions::Global
        VIEW = View::Interactions::InteractionDetail
        DIRECT_EVENT = :interaction_detail
        LIMITED = false
        def init
          @model = {}
          if atc_codes = @session.user_input(:atc_code).split(",") and atc_codes.length == 2
            # interaction title
            atc_subs = []
            atc_codes.each do |atc_code|
              i = @session.interaction_basket_atc_codes.index(atc_code)
              sub_name = if sub = @session.interaction_basket[i]
                sub.send(@session.language)
              else
                ""
              end
              atc_subs << atc_code + " (" + sub_name + ")"
            end
            und = case @session.language
            when "en"
              " and "
            when "fr"
              " et "
            else
              " und "
            end
            @model.store(:title, atc_subs.join(und))

            # Try EPha curated interaction first (ATC-to-ATC)
            epha = EphaInteractions.find_epha_interaction(atc_codes[0], atc_codes[1])
            epha ||= EphaInteractions.find_epha_interaction(atc_codes[1], atc_codes[0])

            if epha
              severity = epha["severity_score"].to_s
              effect_text = epha["risk_label"]
              effect_text += " — #{epha["effect"]}" unless epha["effect"].to_s.empty?
              @model.store(:effect, effect_text)
              @model.store(:mechanism, epha["mechanism"])
              @model.store(:clinic, epha["measures"]) unless epha["measures"].to_s.empty?
            else
              # Fall back to substance-level lookup
              substances = @session.interaction_basket
              if substances && substances.length >= 2
                sub1_name = substances[0]&.name.to_s
                sub2_name = substances[1]&.name.to_s
                row = EphaInteractions.get_interaction_detail(sub1_name, sub2_name)
                row ||= EphaInteractions.get_interaction_detail(sub2_name, sub1_name)
                if row
                  @model.store(:mechanism, row["description"])
                  severity = row["severity_score"].to_s
                  @model.store(:effect, "#{row["severity_label"]} (#{EphaInteractions::Ratings[severity]})")
                  if row["interacting_brands"] && !row["interacting_brands"].empty?
                    @model.store(:clinic, "Betroffene Präparate: #{row["interacting_brands"]}")
                  end
                end
              end
            end
            @model.store(:references, [])
          end
        end
      end
    end
  end
end
