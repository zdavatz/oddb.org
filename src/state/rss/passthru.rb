#!/usr/bin/env ruby
# State:Rss::Passthru -- oddb.org -- 23.05.2007 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'htmlgrid/passthru'

module ODDB
  module State
    module Rss
class PassThru < Global
  VIEW = HtmlGrid::PassThru
  VOLATILE = true
  def init
    path = File.join(RSS_PATH,  @session.language, @model)
    @session.passthru(path, 'inline')
  end
end
    end
  end
end
