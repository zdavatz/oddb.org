#!/usr/bin/env ruby
# encoding: utf-8
# State::Admin::Orphaned_pantinfos -- oddb -- 20.11.2003 -- rwaltert@ywesee.com

require 'view/admin/orphaned_patinfos'
require 'util/interval'

module ODDB
	module State
		module Admin
class OrphanedPatinfos < State::Admin::Global
	include Interval
	DIRECT_EVENT = :orphaned_patinfos
	PERSISTENT_RANGE = true
	VIEW = View::Admin::OrphanedPatinfos
	def init
		filter_interval
	end
	def symbol
		:names
	end
end
		end
	end
end
