#!/usr/bin/env ruby
# encoding: utf-8
#  State::Notify-- oddb -- 17.10.2005 -- ffricker@ywesee.com

require 'state/migel/global'
require 'state/notify'
require 'view/notify'
require 'state/migel/notify_confirm'
require 'util/logfile'
require 'date'

module ODDB
	module State
		module Migel
			class Notify < State::Migel::Global
				include State::Notify
				VIEW = View::Notify
				CODE_KEY = :migel_code
				CONFIRM_STATE = NotifyConfirm
				ITEM_TYPE = :migel
			end
		end
	end
end
