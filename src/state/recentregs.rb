#!/usr/bin/env ruby
# RecentRegs -- oddb -- 01.09.2003 -- maege@ywesee.com

require 'state/global_predefine'
require 'view/recentregs'
require 'util/resultsort'

module ODDB
	class RecentRegsState < GlobalState
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
		attr_accessor :regs_this_month, :regs_last_month
		VIEW = RecentRegsView
		def init
			date = @session.app.log_group(:swissmedic_journal).newest_date
			if(date.nil?)
				@model = nil
			else
				@model = [
					create_package_month(date), 
					create_package_month(date << 1), 
				]
				@model.delete_if { |month| 
					month.package_count == 0
				}
			end
		end
		def create_package_month(date)
			month = month_range(date)
			PackageMonth.new(date, regs_by_month(month), @session)
		end
		def month_range(date)
			first = Date.new(date.year, date.month)
			first...(first >> 1)
		end
		def regs_by_month(month)
			@session.app.registrations.values.select { |reg|
				month.include?(reg.registration_date)
			}
		end
	end
end
