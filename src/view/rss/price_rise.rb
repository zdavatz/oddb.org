#!/usr/bin/env ruby
# View::Rss::PriceRise -- oddb.org -- 23.05.2007 -- hwyss@ywesee.com

require 'view/drugs/package'
require 'view/latin1'

module ODDB
  module View
    module Rss
class PriceRise < Package
  def init
    @title = :price_rise_feed_title
    @description = :price_rise_feed_description
    super
  end
end
    end
  end
end
