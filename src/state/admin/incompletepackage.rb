#!/usr/bin/env ruby
# State::Admin::IncompletePackage -- oddb -- 23.06.2003 -- hwyss@ywesee.com 

require 'state/admin/package'
require 'view/admin/incompletepackage'

module ODDB
	module State
		module Admin
class IncompletePackage < State::Admin::Package
	VIEW = View::Admin::IncompletePackage
	unless(instance_methods.include?("do_update"))
		alias :do_update :update
	end
	def update
		result_state = self
		if((reg = @session.app.registration(@model.iksnr)) \
			&& (pack = reg.package(@model.ikscd)))
			incomplete = @model
			@model = pack
			result_state = do_update
			@model = incomplete
		end
		result_state
	end
	def update_incomplete
		do_update
	end
end
		end
	end
end
