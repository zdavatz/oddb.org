#!/usr/bin/env ruby
# Mnemonic -- oddb -- 01.04.2003 -- hwyss@ywesee.com 

require 'mnemonic/Mnemonic'

class Mnemonic
	private
	def recoverCommands
		while(!@commandIO.eof?)
			command = @commandIO.nextCommand
			begin
				command.execute(system)
			rescue Exception
			end
		end
	end
end
