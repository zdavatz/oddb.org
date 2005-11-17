#!/usr/bin/env ruby
# State::Drugs::Fachinfos -- oddb -- 17.11.2005 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'view/drugs/fachinfos'
require 'util/interval'

module ODDB
	module State
		module Drugs
class Fachinfos < Global
	include IndexedInterval
	VIEW = View::Drugs::Fachinfos
	LIMITED = true
	DIRECT_EVENT = :fachinfos
	PERSISTENT_RANGE = true
	def index_lookup(range)
		fis = @session.fachinfos_by_name(range, @session.language) 
		fis.delete_if { |fi| fi.registrations.empty? }
		fis
	end
	def symbol 
		[:localized_name, @session.language]
	end
end
		end
	end
end
