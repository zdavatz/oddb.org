#!/usr/bin/env ruby
# State::Drugs::RecentRegs -- oddb -- 01.09.2003 -- mhuggler@ywesee.com

require 'state/drugs/global'
require 'view/drugs/recentregs'
require 'util/resultsort'

module ODDB
	module State
		module Drugs
class RecentRegs < State::Drugs::Global
	include ResultStateSort
	class PackageMonth 
		include ResultSort
		attr_reader :date, :packages
		def initialize(date, regs, session)
			@date = date
			packages = []
			regs.each { |reg|
				reg.each_package { |pack|
					packages.push(pack)
				}
			}
			@packages = sort_result(packages, session)
		end
		def package_count
			@packages.size
		end
	end
	attr_reader :years, :months, :date
	VIEW = View::Drugs::RecentRegs
	DIRECT_EVENT = :recent_registrations
	LIMITED = true
	def init
		@model = nil
		if(loggroup = @session.app.log_group(:swissmedic_journal))
			if((month = @session.user_input(:month)) \
				 && (year = @session.user_input(:year)))
				@date = Date.new(year.to_i, month.to_i)
				@model = [
					create_package_month(@date)
				]
			elsif(@date = loggroup.newest_date)
				@model = [
					create_package_month(date), 
					#create_package_month(date << 1), 
				]
			end
			@model.delete_if { |month| 
				month.package_count == 0
			}
			@years = loggroup.years
			@months = loggroup.months(@date.year)
		end
	end
	def create_package_month(date)
		PackageMonth.new(date, regs_by_month(date), @session)
	end
	def regs_by_month(month)
		ODBA.cache.retrieve_from_index('date_index_registration',
			month.strftime('%Y-%m'))
	end
end
		end
	end
end
