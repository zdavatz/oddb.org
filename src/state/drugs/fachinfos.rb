#!/usr/bin/env ruby
# State::Drugs::Fachinfos -- oddb -- 17.11.2005 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'view/drugs/fachinfos'
require 'util/interval'

module ODDB
	module State
		module Drugs
class Fachinfos < Global
	include Interval
	VIEW = View::Drugs::Fachinfos
	LIMITED = false
	DIRECT_EVENT = :fachinfos
	PERSISTENT_RANGE = true
	def init
		lang = @session.language
		@model = @session.fachinfos.values.sort_by { |fi|
			fi.localized_name(lang).downcase
		}
		filter_interval
	end
	def init
		super
		@filter = Proc.new { |model|
			@range = user_range
			lang = @session.language
			parts = @range.to_s.split('-')
			if(parts.size > 1)
				parts = (parts.first..parts.last).to_a
			end
			parts.inject([]) { |inj, part|
				inj + @session.fachinfos_by_name(part, lang) 
			}
		}
	end
	def interval
		@range
	end
	def intervals
		RANGE_PATTERNS.keys.sort
	end
	def symbol 
		[:localized_name, @session.language]
	end
end
		end
	end
end
