#!/usr/bin/env ruby
# encoding: utf-8
# State::Hospitals::Limit -- oddb -- 31.10.2005 -- hwyss@ywesee.com

require 'state/limit'

module ODDB
	module State
		module Hospitals
class Limit < Global
	include State::Limit
end
		end
	end
end
