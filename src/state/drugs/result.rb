#!/usr/bin/env ruby
# State::Drugs::Result -- oddb -- 03.03.2003 -- hwyss@ywesee.com 

require 'state/global_predefine'
require 'state/drugs/register_download'
require 'state/drugs/payment_method'
require 'view/drugs/result'
require 'model/registration'
require 'model/invoice'
require 'state/page_facade'
require 'state/admin/registration'
require 'state/user/limit'

module ODDB
	module State
		module Drugs
class Result < State::Drugs::Global
	DIRECT_EVENT = :result
	VIEW = View::Drugs::Result
	LIMITED = true
	ITEM_LIMIT = 100
	REVERSE_MAP = View::Drugs::ResultList::REVERSE_MAP
	attr_reader :package_count, :pages
	attr_accessor :search_query, :search_type
	include ResultStateSort
	def init
		@model.session = @session
		if(@model.atc_classes.nil? || @model.atc_classes.empty?)
			@default_view = View::Drugs::EmptyResult
		else
			sorted_atc_classes = @model.atc_sorted
			@pages = []
			page  = 0
			count = 0
			@package_count = 0
			sorted_atc_classes.each { |atc|
				@pages[page] ||= State::PageFacade.new(page) 
				@pages[page].push(atc)
				@package_count += atc.package_count
				count += atc.package_count	
				if(count >= ITEM_LIMIT)
					page += 1
					count = 0
				end	
			}
			@filter = Proc.new { |model|
				page()
			}
		end
	end
	def export_csv
		if(creditable?)
			PaymentMethod.new(@session, @model)
		else
			RegisterDownload.new(@session, @model)
		end
	end
	def get_sortby!
		super
		if(@sortby.first == :dsp)
			sortvalue = [:most_precise_dose, :comparable_size, :price_public]
			if(@sortby[1,3] == sortvalue)
				## @sort_reverse has already been reset at this stage, 
				## correct it with dedicated instance variable
				@sort_reverse = @sort_reverse_dsp = !@sort_reverse_dsp
				@sortby.shift
			else
				@sort_reverse_dsp = @sort_reverse
				@sortby[0,1] = sortvalue
			end
		end
		@sortby.uniq!
	end
	def limit_state
		count = @package_count
		model = if(@search_type == "st_sequence")
			@model
		else
			_search_drugs(@search_query, "st_sequence")
		end
		result = model.atc_classes.inject([]) { |mdl, atc|
			mdl += atc.active_packages
		}
		state = State::Drugs::ResultLimit.new(@session, result)
		state.package_count = count
		state
	end
	def page
		pge = nil
		if(@session.event == :search)
			## reset page-input
			pge = @session.user_input(:page)
			@session.set_persistent_user_input(:page, pge)
		else
			pge = @session.persistent_user_input(:page)
		end
		@page = @pages[pge || 0]
	end
	def search
		query = query.to_s.downcase
		stype = @session.user_input(:search_type) 
		if(@search_type != stype || @search_query != query)
			super
		else
			self
		end
	end
end
		end
	end
end
