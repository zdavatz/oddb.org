#!/usr/bin/env ruby
# encoding: utf-8

require 'state/setpass'
require 'state/hc_providers/global'

module ODDB
	module State
		module HC_providers
class SetPass < State::HC_providers::Global
	include State::SetPass
end
		end
	end
end
