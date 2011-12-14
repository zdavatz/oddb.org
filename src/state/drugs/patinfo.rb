#!/usr/bin/env ruby
# encoding: utf-8
# State::Drugs::Patinfo -- oddb -- 11.11.2003 -- rwaltert@ywesee.com

require 'state/drugs/global'
require 'view/drugs/patinfo'


module ODDB
	module State
		module Drugs
class Patinfo < State::Drugs::Global
	class PatinfoWrapper < DelegateClass(ODDB::Patinfo)
		attr_accessor :pointer_descr
	end
	VIEW = View::Drugs::Patinfo
	def init
		@patinfo = @model
		@model = PatinfoWrapper.new(@patinfo)
		descr = @session.lookandfeel.lookup(:patinfo_descr, 
			@model.name_base)
		@model.pointer_descr = descr
	end
end
class PatinfoPrint < State::Drugs::Global
	VIEW = View::Drugs::PatinfoPrint
	VOLATILE = true
end
		end
	end
end
