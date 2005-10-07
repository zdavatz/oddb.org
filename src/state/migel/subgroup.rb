#!/usr/bin/env ruby
# State::Migel::Subgroup -- oddb -- 05.10.2005 -- ffricker@ywesee.com

require 'view/migel/subgroup'
require 'delegate'

module ODDB
	module State
		module Migel
class Subgroup < Global
	VIEW = View::Migel::Subgroup
	LIMITED = true
end
		end
	end
end
	
