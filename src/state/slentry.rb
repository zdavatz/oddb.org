#!/usr/bin/env ruby
# SlEntryState -- oddb -- 22.04.2003 -- benfay@ywesee.com

require 'state/global_predefine'
require 'state/package'
require 'view/slentry'

module ODDB
	class SlEntryState < GlobalState
		VIEW = RootSlEntryView
		def delete
			package = @model.parent(@session.app)
			@session.app.delete(@model.pointer)
			PackageState.new(@session, package)
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
	class CompanySlEntryState < SlEntryState
		def init
			super
			unless(allowed?)
				@default_view = SlEntryView
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
