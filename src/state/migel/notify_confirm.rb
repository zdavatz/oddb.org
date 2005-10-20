#!/usr/bin/env ruby
#  -- oddb -- 20.10.2005 -- ffricker@ywesee.com

require 'state/migel/global'
require 'view/drugs/notify_confirm'
require 'util/logfile'

module ODDB
	module State
		module Migel
class NotifyConfirm < State::Migel::Global
	VIEW = View::Drugs::NotifyConfirm
end
		end
	end
end
