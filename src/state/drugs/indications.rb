#!/usr/bin/env ruby
# State::Drugs::Indications -- oddb -- 03.07.2003 -- hwyss@ywesee.com 

require 'state/drugs/global'
require 'util/interval'
require 'view/drugs/indications'

module ODDB
	module State
		module Drugs
class Indications < State::Drugs::Global
	include Interval
	VIEW = View::Drugs::Indications
	DIRECT_EVENT = :indications
	def symbol
		@session.language
	end
end
		end
	end
end
