#!/usr/bin/env ruby
# encoding: utf-8
#  -- oddb -- 04.10.2005 -- ffricker@ywesee.com

require 'state/global_predefine'
require 'view/migel/limitationtext'

module ODDB
	module State
		module Migel
class LimitationText < State::Migel::Global
	VIEW = View::Migel::LimitationText
	LIMITED = true
end
		end
	end
end
