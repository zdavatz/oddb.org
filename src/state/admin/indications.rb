#!/usr/bin/env ruby
# encoding: utf-8
# State::Admin::Indications -- oddb -- 03.07.2003 -- hwyss@ywesee.com 

require 'state/admin/global'
require 'util/interval'
require 'view/admin/indications'

module ODDB
	module State
		module Admin
class Indications < State::Admin::Global
	include Interval
	VIEW = View::Admin::Indications
	DIRECT_EVENT = :indications
	def init
		filter_interval
	end
	def symbol
		@session.language
	end
end
		end
	end
end
