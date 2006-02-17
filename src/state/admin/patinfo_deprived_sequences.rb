#!/usr/bin/env ruby
# State::Admin::PatinfoDeprivedSequences -- oddb -- 08.12.2003 -- rwaltert@ywesee.com

require 'view/admin/patinfo_deprived_sequences'
require 'state/admin/assign_deprived_sequence'
require 'util/interval'

module ODDB
	module State
		module Admin
class PatinfoDeprivedSequences < State::Admin::Global
	include Interval
	VIEW = View::Admin::PatinfoDeprivedSequences
	PERSISTENT_RANGE = true
	DIRECT_EVENT = :patinfo_deprived_sequences
	def init
		filter_interval
	end
	def select_seq
		keys = [:pointer, :state_id]
		values = user_input(keys, keys)
		if(error?)
			self
		else
			pointer = values[:pointer]
			seq =	pointer.resolve(@session.app)
			State::Admin::AssignDeprivedSequence.new(@session, seq)
		end
	end
	def shadow_pattern
		begin
			if(str = @session.user_input(:pattern))
				pattern = Regexp.new(str)
				@session.each_sequence { |seq|
					if(pattern.match(seq.name_base))
						@session.app.update(seq.pointer, {:patinfo_shadow => true}, unique_email)
					end
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
