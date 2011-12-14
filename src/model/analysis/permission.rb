#!/usr/bin/env ruby
# encoding: utf-8
# Analysis::Permission -- oddb.org -- 19.06.2006 -- sfrischknecht@ywesee.com

require 'util/persistence'
require 'util/language'
require 'model/text'

module ODDB
	module Analysis
		class Permission
			attr_reader :specialization, :restriction
			def initialize(specialization, restriction=nil)
				@specialization = specialization
				@restriction = restriction
			end
		end
	end
end
