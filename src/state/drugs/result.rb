#!/usr/bin/env ruby
# State::Drugs::Result -- oddb -- 03.03.2003 -- hwyss@ywesee.com 

require 'state/drugs/global'
require 'view/drugs/result'
require 'model/registration'
require 'state/page_facade'
require 'state/admin/registration'

module ODDB
	module State
		module Drugs
class Result < State::Drugs::Global
	DIRECT_EVENT = :search
	VIEW = View::Drugs::Result
	REVERSE_MAP = View::Drugs::ResultList::REVERSE_MAP
	ITEM_LIMIT = 150
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
	def page
		if(pge = @session.user_input(:page))
			@page = @pages[pge]
		else
			@page ||= @pages.first
		end
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
