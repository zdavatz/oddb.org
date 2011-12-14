#!/usr/bin/env ruby
# encoding: utf-8
# State::Admin::Confirm -- ODDB -- 26.01.2005 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'view/confirm'

module ODDB
	module State
		module Admin
class Confirm < State::Admin::Global
	VIEW = View::Confirm
end
		end
	end
end
