#!/usr/bin/env ruby
# SelectSubstance -- oddb -- 05.05.2003 -- mhuggler@ywesee.com

require 'util/persistence'

module ODDB
	class SelectSubstance
		attr_reader :user_input, :active_agent, :selection
		def initialize(user_input, selection, active_agent)
			@user_input = user_input
			@selection = selection
			@active_agent = active_agent
		end
		def pointer
			@active_agent.pointer
		end
		def ancestors(app)
			@active_agent.ancestors(app)
		end
		def	assigned 
			@active_agent.sequence.substances
		end
		def new_substance
			pointer = Persistence::Pointer.new([:substance, @user_input[:substance]]) 
			Persistence::CreateItem.new(pointer)
		end
	end
end
