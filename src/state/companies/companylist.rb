#!/usr/bin/env ruby
# State::Companies::CompanyList -- oddb -- 26.05.2003 -- maege@ywesee.com

require 'state/companies/global'
require 'state/companies/company'
require 'view/companies/companylist'
require 'model/company'
require 'model/user'
require 'sbsm/user'

module ODDB
	module State
		module Companies
				module AlphaInterval
				RANGE_PATTERNS = {
					'a-d'			=>	'a-däÄáÁàÀâÂçÇ',
					'e-h'			=>	'e-hëËéÉèÈêÊ',
					'i-l'			=>	'i-l',
					'm-p'			=>	'm-pöÖóÓòÒôÔ',
					'q-t'			=>	'q-t',
					'u-z'			=>	'u-züÜúÚùÙûÛ',
					'unknown'	=>	'unknown',
				}
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
					def filter_interval
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
					def interval
						@interval ||= self::class::RANGE_PATTERNS.index(@range)
					end
					def intervals
						@intervals ||= get_intervals
					end
				end
			#class User < SBSM::KnownUser; end
			#class UnknownUser < SBSM::UnknownUser; end
			#class CompanyUser < State::Companies::User; end
			#class AdminUser < State::Companies::User; end
class CompanyResult < State::Companies::Global
	include AlphaInterval
	attr_reader :range
	DIRECT_EVENT = :search
	VIEW = {
		ODDB::UnknownUser	=>	View::Companies::UnknownCompanies,
		ODDB::CompanyUser	=>	View::Companies::UnknownCompanies,
		ODDB::RootUser		=>	View::Companies::RootCompanies,
		ODDB::AdminUser		=>	View::Companies::RootCompanies,
	}	
	#REVERSE_MAP = ResultList::REVERSE_MAP
	def init
		if(!@model.is_a?(Array) || @model.empty?)
			@default_view = View::Companies::EmptyResult
		end
	end
end
class CompanyList < CompanyResult
	DIRECT_EVENT = :companylist
	def init
		@model = @session.app.companies.values
		filter_interval
		super
		if(@session.user.is_a?(ODDB::AdminUser))
		elsif(@session.user.is_a?(ODDB::CompanyUser))
			@model = @model.select { |company|
				company.listed? || (company == @session.user.model)
			}
		else
			@model = @model.select { |company|
				company.listed?
			}
		end
	end
end
		end
	end
end
