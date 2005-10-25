#!/usr/bin/env ruby
#  State::Notify-- oddb -- 20.10.2005 -- ffricker@ywesee.com

require 'state/migel/global'
require 'view/migel/notify_confirm'
require 'util/logfile'

module ODDB
	module State
		module Migel
class NotifyConfirm < State::Migel::Global
	VIEW = View::Migel::NotifyConfirm
end
		end
	end
end
