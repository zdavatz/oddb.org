#!/usr/bin/env ruby
# State::User::YamlExport -- oddb -- 05.09.2003 -- hwyss@ywesee.com

require 'state/user/global'
require 'view/user/yamlexport'

module ODDB
	module State
		module User
class YamlExport < State::User::Global
	VIEW = View::User::YamlExport
end
		end
	end
end
