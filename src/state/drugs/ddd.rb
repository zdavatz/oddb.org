#!/usr/bin/env ruby
# State::Drugs::DDD -- ODDB -- 01.03.2004 -- hwyss@ywesee.com

require 'state/drugs/global'
require 'view/drugs/ddd'

module ODDB
	module State
		module Drugs
class DDD < State::Drugs::Global
	VIEW = View::Drugs::DDD
	LIMITED = true
	def init
		if((pointer = @session.user_input(:pointer)))
			@model = pointer.resolve(@session.app)
		end
=begin
		if((pointer = @session.user_input(:pointer)) \
			&& (atc = pointer.resolve(@session.app)))
			@model = [atc]
			while((code = atc.parent_code) \
				&& (atc = @session.app.atc_class(code)))
				@model.unshift(atc) if(atc.has_ddd?)
			end
		else
			@model = []
		end
=end
	end
end
		end
	end
end
