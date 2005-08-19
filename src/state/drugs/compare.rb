#!/usr/bin/env ruby
# State::Drugs::Compare -- oddb -- 20.03.2003 -- hwyss@ywesee.com 

require 'state/drugs/global'
require 'view/drugs/compare'

module ODDB
	module State
		module Drugs
class Compare < State::Drugs::Global
	VIEW = View::Drugs::Compare
	LIMITED = true
	VOLATILE = true
	def init
		if(@model.atc_class.nil?)
			@default_view = View::Drugs::EmptyCompare
		else
			@default_view = View::Drugs::Compare
		end
	end
end
		end
	end
end
