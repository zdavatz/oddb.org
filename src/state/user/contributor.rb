#!/usr/bin/env ruby
# encoding: utf-8
# State::User::Contributor -- oddb -- 29.11.2005 -- hwyss@ywesee.com

require 'state/admin/user'
require 'state/admin/registration'
require 'state/admin/sequence'
require 'state/admin/package'
require 'state/admin/activeagent'

module ODDB
	module State
		module User
			class SuggestRegistration < Global; end
			class SuggestSequence < Global; end
			class SuggestPackage < Global; end
			class SuggestActiveAgent < Global; end
module Contributor
	include State::Admin::User
	RESOLVE_STATES = {
	}
	def resolve_state(pointer, type=:standard)
		if(klass = @viral_module::RESOLVE_STATES[pointer.skeleton])
			@session[:allowed] ||= []
			test = [pointer, pointer.parent]
			if(@session[:allowed].any? { |obj| 
				test.include?(obj.pointer) })
				klass
			end
		else
			super
		end
	end
end
		end
	end
end
