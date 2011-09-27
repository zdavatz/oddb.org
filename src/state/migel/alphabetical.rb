#!/usr/bin/env ruby
# State::Migel::Alphabetical -- oddb -- 02.02.2006 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'view/migel/alphabetical'

module ODDB
	module State
		module Migel
class Alphabetical < Global
	include IndexedInterval
	VIEW = View::Migel::Alphabetical
	DIRECT_EVENT = :migel_alphabetical
	PERSISTENT_RANGE = true
	LIMITED = true
	def index_name
		if(@session.language == 'en')
			lang = 'de'
		else
			lang = @session.language
		end
		"migel_index_#{lang}"
	end
  def index_lookup(query)
		if(@session.language == 'en')
			lang = 'de'
		else
			lang = @session.language
		end
    @session.app.search_migel_alphabetical(query, lang)
  end
end
		end
	end
end
