#!/usr/bin/env ruby
# State::Substances::Init -- oddb -- 23.08.2004 -- maege@ywesee.com

require 'view/substances/search'

module ODDB
	module State
		module Substances
class Init < State::Substances::Global
	VIEW = View::Substances::Search
	DIRECT_EVENT = :home
end
		end
	end
end
