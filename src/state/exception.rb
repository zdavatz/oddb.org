#!/usr/bin/env ruby
# encoding: utf-8
# State::Exception -- oddb -- 12.03.2003 -- andy@jetnet.ch

require 'state/global_predefine'
require 'view/exception'

module ODDB
	module State
		class Exception < State::Global
			VIEW = View::Exception
		end
	end
end
