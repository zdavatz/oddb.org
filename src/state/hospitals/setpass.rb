#!/usr/bin/env ruby
# encoding: utf-8
# State::Hospitals::SetPass -- oddb -- 29.09.2005 -- hwyss@ywesee.com

require 'state/setpass'
require 'state/hospitals/global'

module ODDB
	module State
		module Hospitals
class SetPass < State::Hospitals::Global
	include State::SetPass
end
		end
	end
end
