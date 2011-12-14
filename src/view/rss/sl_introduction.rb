#!/usr/bin/env ruby
# encoding: utf-8
# View::Rss::SlIntroduction -- oddb.org -- 02.12.2008 -- hwyss@ywesee.com

require 'view/rss/package'
require 'view/latin1'

module ODDB
  module View
    module Rss
class SlIntroduction < Package
  def init
    @title = :sl_introduction_feed_title
    @description = :sl_introduction_feed_description
    super
  end
end
    end
  end
end
