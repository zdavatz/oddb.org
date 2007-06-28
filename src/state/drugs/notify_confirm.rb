#!/usr/bin/env ruby
# Notify -- oddb -- 08.04.2005 -- usenguel@ywesee.com, jlang@ywesee.com

require 'state/drugs/global'
require 'view/notify_confirm'
require 'util/logfile'

module ODDB
	module State
		module Drugs
class NotifyConfirm < State::Drugs::Global
	VIEW = View::NotifyConfirm
end
		end
	end
end
