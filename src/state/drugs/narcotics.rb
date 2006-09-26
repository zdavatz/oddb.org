#!/usr/bin/env ruby
#State::Drugs::Narcotics  -- oddb -- 16.11.2005 -- spfenninger@ywesee.com

require 'state/global_predefine'
require 'util/interval'
require 'view/drugs/narcotics'

module ODDB
	module State
		module Drugs
class Narcotics < State::Drugs::Global
	include IndexedInterval
	VIEW = View::Drugs::Narcotics
	DIRECT_EVENT = :narcotics
	PERSISTENT_RANGE  = true
	LIMITED = true
	def index_name
		if(@session.language == 'en')
			lang = 'de'
		else
			lang = @session.language
		end
		"narcotics_#{lang}"
	end
end
		end
	end
end
