#!/usr/bin/env ruby
# State::Drugs::PatinfoDeprivedSequences -- oddb -- 08.12.2003 -- rwaltert@ywesee.com

require 'view/drugs/patinfo_deprived_sequences'
require 'state/drugs/assign_deprived_sequence'
require 'util/interval'

module ODDB
	module State
		module Drugs
class PatinfoDeprivedSequences < State::Drugs::Global
	include Interval
	VIEW = View::Drugs::PatinfoDeprivedSequences
	PERSISTENT_RANGE = true
	DIRECT_EVENT = :patinfo_deprived_sequences
	def select_seq
		keys = [:pointer, :state_id]
		values = user_input(keys, keys)
		if(error?)
			self
		else
			pointer = values[:pointer]
			seq =	pointer.resolve(@session.app)
			State::Drugs::AssignDeprivedSequence.new(@session, seq)
		end
	end
	def shadow_pattern
		begin
			if(str = @session.user_input(:pattern))
				pattern = Regexp.new(str)
				@session.app.registrations.each_value { |reg|
					reg.sequences.each_value { |seq|
						if(pattern.match(seq.name_base))
							@session.app.update(seq.pointer, {:patinfo_shadow => true})
						end
					}
				}
				patinfo_deprived_sequences
			else
				self
			end
		rescue RegexpError
			self
		end
	end
	def symbol
		:name
	end
end
		end
	end
end
