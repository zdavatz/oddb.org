#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Migel:Items -- oddb.org -- 15.08.2011 -- mhatakeyama@ywesee.com

require 'state/global_predefine'
require 'view/migel/items'

module ODDB
	module State
		module Migel
class Items < State::Migel::Global
	VIEW = ODDB::View::Migel::Items
  def sort
    get_sortby!
    @model.sort! { |a, b| compare_entries(a, b) }
    @model.reverse! if(@sort_reverse)
    self
  end
end
		end
	end
end
