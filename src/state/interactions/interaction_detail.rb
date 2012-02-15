#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Interactions::InteractionDetail -- oddb.org -- 15.02.2012 -- mhatakeyama@ywesee.com

require	'state/global_predefine'
require	'view/interactions/interaction_detail'
require 'rexml/document'
require 'net/https'

module ODDB
	module State
		module Interactions
class InteractionDetail < State::Interactions::Global
	VIEW = View::Interactions::InteractionDetail
	DIRECT_EVENT = :interaction_detail
	LIMITED = false
	def init
    @model = {}
    if atc_codes = @session.user_input(:atc_code).split(/,/) and atc_codes.length == 2
      # interaction title
      atc_subs = []
      atc_codes.each do |atc_code|
        i = @session.interaction_basket_atc_codes.index(atc_code)
        sub_name = if sub = @session.interaction_basket[i]
                     sub.send(@session.language)
                   else
                     ''
                   end
        atc_subs << atc_code + ' (' + sub_name + ')'
      end
      und = case @session.language 
            when 'en'
              ' and '
            when 'fr'
              ' et '
            else
              ' und '
            end
      @model.store(:title, atc_subs.join(und))

      # get xml document
      server_url = "api.epha.ch"
      interaction_key = if ODDB.config.respond_to?(:interaction_key)
                          ODDB.config.interaction_key
                        else
                          '79VVZ51XJKSEN1G'
                        end
      base_url = "/1.0/interaction/#{atc_codes.first}/#{atc_codes.last}?key=#{interaction_key}"
      https = Net::HTTP.new(server_url, 443)
      https.use_ssl = true
      https.ssl_version = :SSLv3

      xml = ""
      https.start {|w|
        response = w.get(base_url)
        xml = response.body
      }

      # parse xml document
      doc = REXML::Document.new(xml)
      if mechanism = doc.elements['/EPha/Response/Interactions/Interaction/Mechanism']
        @model.store(:mechanism, mechanism.text)
      end
      if effect = doc.elements['/EPha/Response/Interactions/Interaction/Effect']
        @model.store(:effect, effect.text)
      end
      if clinic = doc.elements['/EPha/Response/Interactions/Interaction/Clinic']
        @model.store(:clinic, clinic.text)
      end
      @model.store(:references, [])
      if references = doc.elements['/EPha/Response/Interactions/Interaction/References']
        references.each do |element|
          @model[:references] << {
            :author  => element.attributes['author'],
            :journal => element.attributes['journal'],
            :year    => element.attributes['year'],
            :title   => element.attributes['title']
          }
        end
      end
    end
	end
end
		end
	end
end
