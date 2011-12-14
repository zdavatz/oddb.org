#!/usr/bin/env ruby
# encoding: utf-8
# State::Migel::Subgroup -- oddb -- 05.10.2005 -- ffricker@ywesee.com

require 'view/migel/subgroup'

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
