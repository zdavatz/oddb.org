#!/usr/bin/env ruby
# State::Drugs::MiniFi -- oddb.org -- 26.04.2007 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'view/drugs/minifi'

module ODDB
  module State
    module Drugs
class MiniFi < Global
  VIEW = View::Drugs::MiniFi
end
    end
  end
end
