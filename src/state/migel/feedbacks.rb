#!/usr/bin/env ruby
# encoding: utf-8
#  -- oddb -- 25.10.2005 -- ffricker@ywesee.com

require 'state/migel/global'
require 'view/migel/feedbacks'
require 'util/logfile'
require 'state/feedbacks'

module ODDB
	module State
		module Migel
class Feedbacks < State::Migel::Global
	VIEW = View::Migel::Feedbacks
	include State::Feedbacks
end
		end
	end
end
