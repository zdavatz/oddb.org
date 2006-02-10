#!/usr/bin/env ruby
# State::Drugs::Sequences -- oddb -- 08.02.2005 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'state/page_facade'
require 'util/interval'
require 'view/drugs/sequences'

module ODDB
	module State
		module Drugs
class Sequences < State::Drugs::Global
	include IndexedInterval
	VIEW = View::Drugs::Sequences
	DIRECT_EVENT = :sequences
	PERSISTENT_RANGE = true
	ITEM_LIMIT = 100
	ITEM_SLACK = 20
	LIMITED = true
	attr_reader :pages
	def init
		super
		@model = load_model
		@pages = []
		msize = @model.size
		num_pages = ((msize - ITEM_SLACK) / ITEM_LIMIT).next
		num_pages.times { |pagenum|
			page = OffsetPageFacade.new(pagenum)
			offset = pagenum * ITEM_LIMIT
			size = ITEM_LIMIT
			if(pagenum.next == num_pages)
				size = msize - offset
			end
			page.offset = offset
			page.size = size
			page.concat(@model[offset, size])
			@pages.push(page)
		}
	end
	def index_lookup(range)
		sequences = @session.search_sequences(range, false) 
		sequences.delete_if { |seq| seq.public_packages.empty? }
		sequences
	end
	def filter(model)
		page()
	end
	def page
		@page = @pages[@session.user_input(:page).to_i] || []
	end
	def sequences
		if(@range == user_range)
			self
		else
			Sequences.new(@session, [])
		end
	end
end
		end
	end
end
