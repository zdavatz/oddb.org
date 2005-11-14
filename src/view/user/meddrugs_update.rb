#!/usr/bin/env ruby
# View::User::MeddrugsUpdate -- oddb -- 11.11.2005 -- hwyss@ywesee.com

require 'htmlgrid/passthru'

module ODDB
	module View
		module User
class MeddrugsUpdate < HtmlGrid::PassThru
	def init
		dir = File.expand_path('../../../data/xls', File.dirname(__FILE__))
		if(file = Dir["#{dir}/med-drugs*"].sort.reverse.first)
			@path = File.join('..', 'data', 'xls', File.basename(file))
		end
	end
	def http_headers
		{
			'Content-Type'	=> 'application/vnd.ms-excel',
		}
	end
	def to_html(context)
		line = [
			nil,
			@session.remote_addr,
			@path,
		].join(';')
		LogFile.append(:meddrugs_update, line, Time.now)
		@session.passthru(@path)
		''
	end
end
		end
	end
end
