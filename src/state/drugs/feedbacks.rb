#!/usr/bin/env ruby
# encoding: utf-8
# Feedbacks -- oddb -- 28.10.2004 -- jlang@ywesee.com, usenguel@ywesee.com

require 'state/drugs/global'
require 'view/drugs/feedbacks'
require 'util/logfile'
require 'state/feedbacks'

module ODDB
	module State
		module Drugs
class Feedbacks < State::Drugs::Global
	VIEW = View::Drugs::Feedbacks
	include State::Feedbacks
end
		end
	end
end
