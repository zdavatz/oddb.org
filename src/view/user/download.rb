#!/usr/bin/env ruby
# View::User::Download -- ODDB -- 29.10.2003 -- hwyss@ywesee.com

require 'htmlgrid/passthru'
require 'util/logfile'
require 'plugin/yaml'

module ODDB
	module View
		module User
class Download < HtmlGrid::PassThru
	def init
		if(filename = @session.user_input(:filename))
			@path = @lookandfeel.resource_global(:downloads, filename)
		end
	end
	def to_html(context)
		line = [
			nil,
			@session.remote_addr,
			@path,
		].join(';')
		LogFile.append(:download, line, Time.now)
		@session.passthru(@path)
		''
	end
end
		end
	end
end
