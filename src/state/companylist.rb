#!/usr/bin/env ruby
# CompanyListState -- oddb -- 26.05.2003 -- maege@ywesee.com

require 'state/global_predefine'
require 'view/companylist'
require 'model/company'
require 'state/company'
require 'sbsm/user'

module ODDB
	class User < SBSM::KnownUser; end
	class UnknownUser < SBSM::UnknownUser; end
	class CompanyUser < User; end
	class RootUser < User; end
	class CompanyListState < GlobalState
		attr_reader :intervals, :range
		DIRECT_EVENT = :companylist
		VIEW = {
			UnknownUser	=>	UnknownCompanyListView,
			CompanyUser	=>	CompanyUserListView,
			RootUser		=>	RootCompanyListView,
		}	
		RANGE_PATTERNS = {
			'a-d'			=>	'a-däÄáÁàÀâÂçÇ',
			'e-h'			=>	'e-hëËéÉèÈêÊ',
			'i-l'			=>	'i-l',
			'm-p'			=>	'm-pöÖóÓòÒôÔ',
			'q-t'			=>	'q-t',
			'u-z'			=>	'u-züÜúÚùÙûÛ',
			'unknown'	=>	'unknown',
		}
		#REVERSE_MAP = ResultList::REVERSE_MAP
		def init
			super
			@model = @session.app.companies.values
			if(@session.user.is_a? RootUser)
				userrange = @session.user_input(:range) || default_interval
				range = RANGE_PATTERNS.fetch(userrange)
				@filter = Proc.new { |model|
					model.select { |comp| 
						if(range=='unknown')
							comp.name =~ /^[^'a-zäÄáÁàÀâÂçÇëËéÉèÈêÊüÜúÚùÙûÛ']/i
						else
							/^[#{range}]/i.match(comp.name)
						end
					}
				}
				@range = range
			end
		end
		def default_interval
			intervals.first
		end
		def get_intervals
			@model.collect { |company| 
				rng = RANGE_PATTERNS.select { |key, pattern| 
					/^[#{pattern}]/i.match(company.name)
				}.first
				rng.nil? ? 'unknown' : rng.first
			}.compact.uniq.sort
		end
		def interval
			@interval ||= self::class::RANGE_PATTERNS.index(@range)
		end
		def intervals
			@intervals ||= get_intervals
		end
	end
end
