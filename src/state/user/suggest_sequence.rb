#!/usr/bin/env ruby
# State::User::SuggestSequence -- oddb -- 29.11.2005 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'state/admin/sequence'
require 'view/admin/incompletesequence'

module ODDB
	module State
		module User
class SuggestSequence < Global
	include State::Admin::SequenceMethods
	VIEW = View::Admin::IncompleteSequence
	def update_incomplete
		update
		(@session[:allowed] ||= []).push(@model).uniq!
		self
	end
end
		end
	end
end
