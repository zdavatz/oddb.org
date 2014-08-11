#!/usr/bin/env ruby
# encoding: utf-8

require 'state/global'
require 'view/zsr'
module ODDB
  module State
		class Zsr < State::Global
			DIRECT_EVENT = :zsr
			VIEW = View::Zsr
		end
	end
end
