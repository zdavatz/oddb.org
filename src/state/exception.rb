#!/usr/bin/env ruby
# ExceptionState -- oddb -- 12.03.2003 -- andy@jetnet.ch

require 'state/global_predefine'
require 'view/exception'

module ODDB
	class ExceptionState < GlobalState
		VIEW = ExceptionView
	end
end
