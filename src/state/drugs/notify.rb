#!/usr/bin/env ruby
# Notify -- oddb -- 21.03.2005 -- jlang@ywesee.com, usenguel@ywesee.com

require 'state/drugs/global'
require 'view/drugs/notify'
require 'state/drugs/notify_confirm'
require 'util/logfile'
require 'date'

module ODDB
	module State
		module Drugs
			class Notify < State::Drugs::Global
				VIEW = View::Drugs::Notify
				CODE_KEY = :ikskey
			end
		end
	end
end
