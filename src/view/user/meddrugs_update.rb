#!/usr/bin/env ruby
# View::User::MeddrugsUpdate -- oddb -- 11.11.2005 -- hwyss@ywesee.com

require 'htmlgrid/passthru'

module ODDB
	module View
		module User
class MeddrugsUpdate < HtmlGrid::PassThru
	def init
		file = Dir['../../../data/xls/med-drugs*'].sort.reverse.first
		@path = File.join('..', 'data', 'xls', File.basename(file))
		puts @path
	end
end
		end
	end
end
