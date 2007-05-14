#!/usr/bin/env ruby
# State::Drugs::MiniFiRss -- oddb.org -- 11.05.2007 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'view/drugs/minifi_rss'

module ODDB
  module State
    module Drugs
class MiniFiRss < Global
  VIEW = View::Drugs::MiniFiRss
  VOLATILE = true
end
    end
  end
end
