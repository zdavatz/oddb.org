#!/usr/bin/env ruby
# encoding: utf-8

require 'state/global'
require 'view/zsr_json'
module ODDB
  module State
		class Zsr < State::Global
			DIRECT_EVENT = :zsr
			VIEW = View::ZsrJson
		end
	end
end
