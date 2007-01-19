#!/usr/bin/env ruby
# State::Drugs::Result -- oddb -- 03.03.2003 -- hwyss@ywesee.com 

require 'state/global_predefine'
require 'state/page_facade'
require 'state/drugs/register_download'
require 'state/drugs/payment_method'
require 'view/drugs/result'
require 'model/registration'
require 'model/invoice'
require 'state/admin/registration'
require 'state/user/limit'

module ODDB
	module State
		module Drugs
class Result < State::Drugs::Global
	SNAPBACK_EVENT = :result
	VIEW = View::Drugs::Result
	LIMITED = true
	ITEM_LIMIT = 100
	REVERSE_MAP = View::Drugs::ResultList::REVERSE_MAP
	attr_accessor :search_query, :search_type
  attr_reader :pages
	include ResultStateSort
	def init
    @pages = []
		@model.session = @session
		@model.atc_classes.delete_if { |atc| atc.package_count == 0 }
		if(@model.atc_classes.nil? || @model.atc_classes.empty?)
			@default_view = View::Drugs::EmptyResult
    elsif(@model.overflow?)
 			query = @session.persistent_user_input(:search_query).to_s.downcase
			page  = 0
			count = 0
      @model.each { |atc|
        @pages[page] ||= State::PageFacade.new(page) 
        @pages[page].push(atc)
        count += atc.package_count
        if(count >= ITEM_LIMIT)
          page += 1
          count = 0
        end	
      }
      @filter = Proc.new { |model|
        if(@session.cookie_set_or_get(:resultview) == 'pages')
          page()
        else
          @model
        end
      }
		end
	end
	def export_csv
		if(creditable?('org.oddb.download'))
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
		model = if(@search_type == "st_sequence")
			@model
		else
			_search_drugs(@search_query, "st_sequence")
		end
		result = model.atc_classes.inject([]) { |mdl, atc|
			mdl += atc.active_packages
		}
		state = State::Drugs::ResultLimit.new(@session, result)
		state.package_count = @model.package_count
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
    page = @pages[pge || 0]
    page.model = @model
    page
  end
	def request_path
		if(@request_path)
			@request_path + '#best_result'
		end
	end
	def search
		query = @session.persistent_user_input(:search_query).to_s.downcase
		stype = @session.user_input(:search_type) 
		if(@search_type != stype || @search_query != query)
			super
		else
			@request_path = @session.request_path
			self
		end
	end
end
		end
	end
end
