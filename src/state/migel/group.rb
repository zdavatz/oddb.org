#!/usr/bin/env ruby
# State::Migel::Group -- oddb -- 05.10.2005 -- ffricker@ywesee.com

require 'view/migel/group'

module ODDB
	module State
		module Migel
class Group < Global
	VIEW = View::Migel::Group
	LIMITED = true
end
		end
	end
end
