#!/usr/bin/env ruby
# encoding: utf-8
#  State::Notify-- oddb -- 20.10.2005 -- ffricker@ywesee.com

require 'state/migel/global'
require 'view/notify_confirm'
require 'util/logfile'

module ODDB
	module State
		module Migel
class NotifyConfirm < State::Migel::Global
	VIEW = View::NotifyConfirm
end
		end
	end
end
