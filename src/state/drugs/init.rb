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
    @model = OpenStruct.new
    fachinfos = @session.app.sorted_fachinfos
    if newest = fachinfos.first
      revision = newest.revision
      date = Time.local(revision.year, revision.month, revision.day)
      day = 24 * 3600
      range = (date-day)...(date+day)
      @model.fachinfo_news = fachinfos.select { |fi|
        range.include? fi.revision
      }
    end
    @model.feedbacks = @session.app.sorted_feedbacks[0,5]
  end
end
		end
	end
end
