#!/usr/bin/env ruby
# State::Admin::SlEntry -- oddb -- 22.04.2003 -- benfay@ywesee.com

require 'state/admin/global'
require 'state/admin/package'
require 'view/admin/slentry'

module ODDB
	module State
		module Admin
class SlEntry < State::Admin::Global
	VIEW = View::Admin::RootSlEntry
	def delete
		package = @model.parent(@session.app)
		@session.app.delete(@model.pointer)
		State::Admin::Package.new(@session, package)
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
class CompanySlEntry < State::Admin::SlEntry
	def init
		super
		unless(allowed?)
			@default_view = View::Admin::SlEntry
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
		@session.user.allowed?(@model.parent(@session.app))
	end
end
		end
	end
end
