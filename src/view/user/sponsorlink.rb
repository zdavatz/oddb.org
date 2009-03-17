#!/usr/bin/env ruby
# View::User::SponsorLink -- oddb -- 18.10.2005 -- hwyss@ywesee.com

module ODDB
	module View
		module User
class SponsorLink < HtmlGrid::PassThru
	def sponsorlink
		sl = @model.url(@session.language)
		if(sl.nil? || /https?:\/\//u.match(sl))
			sl
		else
			"http://" + sl
		end
	end
	def http_headers
		{
			"Location"	=>	sponsorlink,
		}
	end
	def to_html(context)
		line = [
			nil,
			sponsorlink,
			@session.remote_addr,
			nil,
		].join(';')
		LogFile.append("sponsor_#{@session.flavor}", line, Time.now)
		super
	end
end
		end
	end
end
