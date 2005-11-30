#!/usr/bin/env ruby
# State::User::SuggestPackage -- oddb -- 29.11.2005 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'state/admin/package'
require 'view/admin/incompletepackage'

module ODDB
	module State
		module User
class SuggestPackage < Global
	include State::Admin::PackageMethods
	VIEW = View::Admin::IncompletePackage
	def update_incomplete
		update
		(@session[:allowed] ||= []).push(@model).uniq!
		self
	end
end
		end
	end
end
