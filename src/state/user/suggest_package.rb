#!/usr/bin/env ruby
# State::User::SuggestPackage -- oddb -- 29.11.2005 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'state/admin/package'
require 'view/user/suggest_package'

module ODDB
	module State
		module User
class SuggestPackage < Global
	include State::Admin::PackageMethods
	VIEW = View::User::SuggestPackage
	def update_incomplete
		mandatory = [:size, :ikscat]
		user_input(mandatory, mandatory)
		newstate = update
		if((reg = @session.app.registration(@model.iksnr)) \
			&& (pac = reg.package(@model.ikscd)))
			filled = @model.fill_blanks(pac)
			@model.odba_store unless(filled.empty?)
			filled.each { |key| @errors.delete(key) }
		end
		newstate
	end
end
		end
	end
end
