#!/usr/bin/env ruby
# State::Drugs::AtcChooser  -- oddb -- 14.07.2003 -- maege@ywesee.com

require 'state/drugs/global'
require 'view/drugs/atcchooser'

module ODDB
	module State
		module Drugs
class AtcChooser < State::Drugs::Global
	attr_reader :user_code
	DIRECT_EVENT = :atc_chooser
	VIEW = View::Drugs::AtcChooser
end
		end
	end
end
