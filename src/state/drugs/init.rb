#!/usr/bin/env ruby
# State::Drugs::Init -- oddb -- 22.10.2002 -- hwyss@ywesee.com 

require 'state/global_predefine'
require 'view/drugs/search'
require 'ostruct'

module ODDB
	module State
		module Drugs
class Init < State::Drugs::Global
	VIEW = View::Drugs::Search
	DIRECT_EVENT = :home_drugs
  def init
    super
    minifis = @session.app.sorted_minifis
    newest = minifis.first
    @model = OpenStruct.new
    @model.minifis = minifis.select { |minifi| 
      minifi.publication_date == newest.publication_date }

    fachinfos = @session.app.sorted_fachinfos
    newest = fachinfos.first
    revision = newest ? newest.revision : nil
    @model.fachinfo_news = fachinfos.select { |fi|
      rev = fi.revision
      rev.year == revision.year && rev.month == revision.month \
        && rev.day == revision.day
    }
  end
end
		end
	end
end
