#!/usr/bin/env ruby
# PowerLinkView -- ODDB -- 21.10.2003 -- hwyss@ywesee.com

require 'htmlgrid/passthru'
require 'util/logfile'

module ODDB
	class PowerLinkView < HtmlGrid::PassThru
		def powerlink
			pl = @model.powerlink
			if(pl.nil? || /https?:\/\//.match(pl))
				pl
			else
				"http://" + pl
			end
		end
		def http_headers
			{
				"Location"	=>	powerlink,
			}
		end
		def to_html(context)
			line = [
				nil,
				@model.oid,
				powerlink,
				@session.remote_addr,
				nil,
			].join(';')
			LogFile.append(:powerlink, line, Time.now)
			super
		end
	end
end
