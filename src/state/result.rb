#!/usr/bin/env ruby
# ResultState -- oddb -- 03.03.2003 -- hwyss@ywesee.com 

require 'state/global_predefine'
require 'view/result'
require 'model/registration'
require 'state/page_facade'
require 'state/registration'

module ODDB
	class ResultState < GlobalState
		include ResultStateSort
		VIEW = ResultView
		REVERSE_MAP = ResultList::REVERSE_MAP
		ITEM_LIMIT = 150
		attr_reader :package_count, :pages
		def init
			@model.session = @session
			if(@model.atc_classes.nil? || @model.atc_classes.empty?)
				@default_view = EmptyResultView
			else
				sorted_atc_classes = @model.atc_sorted
=begin
				@model = @model.atc_classes.delete_if { |atc|
					atc.active_packages.empty?
				}.sort_by { |atc|
					atc.package_count
				}.reverse
=end
				@pages = []
				page  = 0
				count = 0
				@package_count = 0
				sorted_atc_classes.each { |atc|
					puts "in each"
					@pages[page] ||= ODDB::PageFacade.new(page) 
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
	end
end
