#!/usr/bin/env ruby
# State::Interactions::Init -- oddb -- 26.05.2004 -- maege@ywesee.com

require 'state/interactions/init'
require 'view/interactions/search.rb'

module ODDB
	module State
		module Interactions
class Init < State::Interactions::Global
	VIEW = View::Interactions::Search
	DIRECT_EVENT = :home
end
		end
	end
end
