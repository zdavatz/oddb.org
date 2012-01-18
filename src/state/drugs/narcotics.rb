#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Drugs::Narcotics  -- oddb.org -- 18.01.2012 -- mhatakeyama@ywesee.com
# ODDB::State::Drugs::Narcotics  -- oddb.org -- 16.11.2005 -- spfenninger@ywesee.com

require 'state/global_predefine'
require 'util/interval'
require 'view/drugs/narcotics'

module ODDB
	module State
		module Drugs
class Narcotics < State::Drugs::Global
	include IndexedInterval
	VIEW = View::Drugs::Narcotics
	DIRECT_EVENT = :narcotics
	PERSISTENT_RANGE  = true
	LIMITED = true
  def init
    @range = if range = @session.user_input(:range)
               range
             else
               ''
             end
    @session.set_persistent_user_input(:search_query, @range)
    @model = @session.app.search_btm(@range)
    @model.session = @session
  end
	def index_name
    "narcotics_de"
	end
end
		end
	end
end
