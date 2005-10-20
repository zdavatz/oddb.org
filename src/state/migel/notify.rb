#!/usr/bin/env ruby
#  -- oddb -- 17.10.2005 -- ffricker@ywesee.com

require 'state/migel/global'
require 'view/drugs/notify'
require 'state/migel/notify_confirm'
require 'state/notify'
require 'util/logfile'
require 'date'

module ODDB
	module State
		module Migel
			class Notify < State::Migel::Global
				include State::Notify
				VIEW = View::Drugs::Notify
				CODE_KEY = :migel_code
				CONFIRM_STATE = NotifyConfirm
			end
		end
	end
end
