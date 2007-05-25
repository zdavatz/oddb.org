#!/usr/bin/env ruby
# View::Rss::PriceCut -- oddb.org -- 23.05.2007 -- hwyss@ywesee.com

require 'view/rss/package'
require 'view/latin1'

module ODDB
  module View
    module Rss
class PriceCut < Package
  def init
    @title = :price_cut_feed_title
    @description = :price_cut_feed_description
    super
  end
end
    end
  end
end
