#!/usr/bin/env ruby
# encoding: utf-8
# Notify -- oddb -- 21.03.2005 -- jlang@ywesee.com, usenguel@ywesee.com

require 'state/drugs/global'
require 'state/notify'
require 'view/notify'
require 'state/drugs/notify_confirm'
require 'util/logfile'
require 'date'

module ODDB
	module State
		module Drugs
			class Notify < State::Drugs::Global
				include State::Notify
				VIEW = View::Notify
				CODE_KEY = :ikskey
				CONFIRM_STATE = NotifyConfirm
				ITEM_TYPE = :drugs
			end
		end
	end
end
