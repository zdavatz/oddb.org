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
			unless(@sequences.include?(seq))
				@sequences.push(seq) 
				@sequences.odba_isolated_store
			end
			odba_isolated_store
			seq
		end
		def remove_sequence(seq)
			if(@sequences.delete(seq))
				@sequences.odba_isolated_store
			end
			odba_isolated_store
			seq
		end
		def empty?
			@sequences.empty?
		end
	end
end
