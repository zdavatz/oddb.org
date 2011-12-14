#!/usr/bin/env ruby
# encoding: utf-8
# State::Interactions::Init -- oddb -- 26.05.2004 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/interactions/search'

module ODDB
	module State
		module Interactions
class Init < State::Interactions::Global
	VIEW = View::Interactions::Search
	DIRECT_EVENT = :home_interactions
end
		end
	end
end
