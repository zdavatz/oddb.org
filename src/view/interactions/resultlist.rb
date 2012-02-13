#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Interactions::ResultList -- oddb.org -- 13.02.2012 -- mhatakeyama@ywesee.com
# ODDB::View::Interactions::ResultList -- oddb.org -- 01.06.2004 -- mhuggler@ywesee.com

require 'htmlgrid/list'
require 'htmlgrid/value'
require 'htmlgrid/datevalue'
require 'htmlgrid/popuplink'
require 'htmlgrid/urllink'
require 'view/additional_information'
require 'view/pointervalue'
require 'view/publictemplate'
require 'view/dataformat'
require 'view/resultcolors'
require 'view/descriptionvalue'

require 'cgi'

module ODDB
	module View
		module Interactions
class ResultList < HtmlGrid::List
	COMPONENTS = {
		[0,0]	=>	:name,
		[1,0]	=>	:search_oddb,
		[2,0]	=>	:interaction_basket_status,
	}
	REVERSE_MAP = {
		:name												=>	false,
		:search_oddb								=>	false,
		:interaction_basket_status	=>	false,
	}
	CSS_MAP = {
		[0,0]	=>	'list big',
		[1,0]	=>	'list',
		[2,0]	=>	'list big',
	}
	COMPONENT_CSS_MAP = { }
	CSS_CLASS = 'composite'
	DEFAULT_CLASS = HtmlGrid::Value
	DEFAULT_HEAD_CLASS = 'th'
	SORT_DEFAULT = nil
	STRIPED_BG = true
	def interaction_basket_status(model, session)
		if(session.interaction_basket.include?(model))
			link = HtmlGrid::Link.new(:interaction_basket, model, session, self)
      ids = @session.interaction_basket.collect { |sub| sub.oid }
			link.href = @session.interaction_basket_link
			link.value = @lookandfeel.lookup(:in_interaction_basket)
			link.set_attribute('font-weight', 'bold')
			link
		end
	end
	def name(model, session)
		name = model.send(@session.language)
		if(session.interaction_basket.include?(model))
			name
		else
			link = HtmlGrid::Link.new(:add_to_interaction_basket, model, session, self)
      atc_codes = @session.interaction_basket_atc_codes 
      if query = @session.persistent_user_input(:search_query)\
        and atc_code = @session.search_exact_sequence(query).atc_classes.map{|atc| atc.code}
        atc_codes << atc_code
      end
      ids = if basket_ids = @session.interaction_basket_ids and !basket_ids.empty?
              basket_ids << "," << model.oid.to_s
            else
              model.oid.to_s
            end
      args = [:substance_ids, ids, :atc_code, atc_codes.join(",")]
      link.href = @lookandfeel._event_url(:interaction_basket, args) do |args|
        args.map!{|arg| CGI.unescape(arg)}
      end
			link.value = name
			link.set_attribute('class', 'list big')
			link
		end
	end
	def search_oddb(model, session)
		active_sequences = model.sequences.select { |seq| 
			seq.active_package_count > 0 
		}
		unless(active_sequences.empty?)
			link = HtmlGrid::Link.new(:substance_result, model, session, self)
			link.href = @lookandfeel._event_url(:search, 'search_query' => model.name, 
                                                   'zone'	=> :drugs)
			link.value = @lookandfeel.lookup(:search_oddb)
      link.css_class = 'small'
			link
		end
	end
end
		end
	end
end
