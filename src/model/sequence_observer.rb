#!/usr/bin/env ruby
# SequenceObserver -- oddb -- 28.11.2003 -- rwaltert@ywesee.com

module ODDB
	module SequenceObserver
		attr_reader :sequences
		def initialize
			@sequences = []
			super
		end
		def add_sequence(seq)
			@sequences.push(seq) unless @sequences.include?(seq)
		end
		def remove_sequence(seq)
			@sequences.delete(seq)
		end
		def empty?
			@sequences.empty?
		end
	end
end
