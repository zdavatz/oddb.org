#!/usr/bin/env ruby
# PluginState -- oddb -- 11.08.2003 -- maege@ywesee.com

require 'state/global_predefine'
require 'view/plugin'

module ODDB
	class PluginState < GlobalState
		VIEW = PluginView
	end
end
