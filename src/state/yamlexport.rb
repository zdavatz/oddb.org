#!/usr/bin/env ruby
# YamlExportState -- oddb -- 05.09.2003 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'view/yamlexport'

module ODDB
	class YamlExportState < GlobalState
		VIEW = YamlExportView
	end
end
