#!/usr/bin/env ruby
# encoding: utf-8
# State::Admin::Addresses -- oddb -- 09.08.2005 -- jlang@ywesee.com

require 'state/global_predefine'
require 'view/admin/addresses'

module ODDB
	module State
		module Admin
class Addresses < Global
	VIEW = View::Admin::Addresses
	DIRECT_EVENT = :addresses
end
		end
	end
end
