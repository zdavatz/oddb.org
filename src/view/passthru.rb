#!/usr/bin/env ruby
# PassThruView -- ODDB -- 21.10.2003 -- hwyss@ywesee.com

require 'htmlgrid/passthru'
require 'util/logfile'

module ODDB
	class PassThruView < HtmlGrid::PassThru
		def passthru
			href = @session.user_input(:destination)
			if(href.nil? || /https?:\/\//.match(href))
				href
			else
				"http://" + href
			end
		end
		def http_headers
			{
				"Location"	=>	passthru,
			}
		end
		def to_html(context)
			line = [
				nil,
				passthru,
				@session.remote_addr,
			].join(';')
			LogFile.append(:passthru, line, Time.now)
			super
		end
	end
end
