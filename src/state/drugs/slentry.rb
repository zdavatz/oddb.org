#!/usr/bin/env ruby
# State::Drugs::SlEntry -- oddb -- 22.04.2003 -- benfay@ywesee.com

require 'state/drugs/global'
require 'state/drugs/package'
require 'view/drugs/slentry'

module ODDB
	module State
		module Drugs
class SlEntry < State::Drugs::Global
	VIEW = View::Drugs::RootSlEntry
	def delete
		package = @model.parent(@session.app)
		@session.app.delete(@model.pointer)
		State::Drugs::Package.new(@session, package)
	end
	def update
		keys = [
			:introduction_date, 
			:limitation, 
			:limitation_points
		]
		input = user_input(keys)
		@model = @session.app.update(@model.pointer, input) unless error?
		self
	end
end
class CompanySlEntry < State::Drugs::SlEntry
	def init
		super
		unless(allowed?)
			@default_view = View::Drugs::SlEntry
		end
	end
	def delete
		if(allowed?)
			super
		end
	end
	def update
		if(allowed?)
			super
		end
	end
	private
	def allowed?
		((pac = @model.parent(@session.app)) \
			&& (seq = pac.sequence) \
			&& (@session.user_equiv?(seq.company)))
	end
end
		end
	end
end
