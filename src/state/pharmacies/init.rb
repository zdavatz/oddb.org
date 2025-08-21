#!/usr/bin/env ruby

# State::Pharmacies::Init -- oddb -- 15.02.2005 -- jlang@ywesee.com, usenguel@ywesee.com

require "state/global_predefine"
require "view/pharmacies/search"

module ODDB
  module State
    module Pharmacies
      class Init < State::Pharmacies::Global
        VIEW = View::Pharmacies::Search
        DIRECT_EVENT = :home_pharmacies
      end
    end
  end
end
