#!/usr/bin/env ruby
#  State::Migel:Init -- oddb -- 04.10.2005 -- ffricker@ywesee.com

require 'state/global_predefine'
require 'view/migel/search'

module ODDB
	module State
		module Migel
class Init < State::Migel::Global
	VIEW = View::Migel::Search
	DIRECT_EVENT = :home_migel	
end
		end
	end
end
