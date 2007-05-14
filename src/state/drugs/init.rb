#!/usr/bin/env ruby
# State::Drugs::Init -- oddb -- 22.10.2002 -- hwyss@ywesee.com 

require 'state/global_predefine'
#require 'state/admin/root'
#require 'state/admin/companyuser'
require 'view/drugs/search'
#require 'view/admin/login'

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
    @model = minifis.select { |minifi| 
      minifi.publication_date == newest.publication_date }
  end
end
		end
	end
end
