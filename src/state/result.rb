#!/usr/bin/env ruby
# ResultState -- oddb -- 03.03.2003 -- hwyss@ywesee.com 

require 'delegate'
require 'state/global_predefine'
require 'view/result'
require 'model/registration'
require 'state/registration'

module ODDB
	class ResultState < GlobalState
		include ResultStateSort
		class AtcFacade < SimpleDelegator
			include ResultSort
			attr_reader :packages, :package_count
			def initialize(atc, session)
				@atc = atc
				super(@atc)
				@packages = @atc.active_packages
				@session = session
				@package_count = @packages.size
				@packages_sorted = false
			end
			def empty?
				@packages.empty?
			end
			def packages
				unless(@packages_sorted)
					@packages = sort_result(@packages, @session)
					@packages_sorted = true
				end
				@packages
			end
		end
		class PageFacade < Array
			def initialize(int)
				super()
				@int = int
			end
			def next
				PageFacade.new(@int.next)
			end
			def previous
				PageFacade.new(@int-1)
			end
			def to_s
				@int.next.to_s
			end
			def to_i
				@int
			end
		end
		VIEW = ResultView
		REVERSE_MAP = ResultList::REVERSE_MAP
		ITEM_LIMIT = 150
		attr_reader :package_count, :pages
		def init
			if(@model.nil? || @model.empty?)
				@default_view = EmptyResultView
			else
				@model = @model.collect { |atc| 
					AtcFacade.new(atc, @session) 
				}.delete_if { |atc|
					atc.empty?
				}.sort_by { |atc| 
					atc.package_count 
				}.reverse
				@pages = []
				page  = 0
				count = 0
				@package_count = 0
				@model.each { |atc|
					@pages[page] ||= PageFacade.new(page) 
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
		def result
			self
		end
	end
end
