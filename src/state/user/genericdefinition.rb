#!/usr/bin/env ruby
# State::User::GenericDefinition -- oddb -- 05.01.2004 -- mhuggler@ywesee.com

require 'state/user/global'
require 'view/user/genericdefinition'

module ODDB
	module State
		module User
class GenericDefinition < State::User::Global
	VIEW = View::User::GenericDefinition
	VOLATILE = true
end
		end
	end
end
