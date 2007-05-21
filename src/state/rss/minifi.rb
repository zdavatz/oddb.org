#!/usr/bin/env ruby
# State::Rss::MiniFi.org -- 11.05.2007 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'htmlgrid/passthru'

module ODDB
  module State
    module Rss
class MiniFi < SBSM::State
  VIEW = HtmlGrid::PassThru
  VOLATILE = true
  def init
    path = File.join(RSS_PATH,  @session.language, 'minifi.rss')
    @session.passthru(path, 'inline')
  end
end
    end
  end
end
