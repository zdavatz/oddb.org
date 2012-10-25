#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View:Rss::Recall -- oddb.org -- 25.10.2012 -- yasaka@ywesee.com

require 'view/latin1'
require 'rss/maker'

module ODDB
  module View
    module Rss
class Recall < HtmlGrid::Component
  include View::Latin1
  def init
    @title       = :recall_feed_title
    @description = :recall_feed_description
    super
  end
  def to_html(context)
    RSS::Maker.make('2.0') { |feed|
      feed.channel.title       = @lookandfeel.lookup(@title)
      feed.channel.link        = @lookandfeel._event_url(:home)
      feed.channel.description = @lookandfeel.lookup(@description)
      feed.channel.language    = @session.language
      feed.image.url           = @lookandfeel.resource(:logo_rss)
      feed.image.title         = @lookandfeel.lookup(:logo)
      feed.encoding            = 'UTF-8'
      feed.xml_stylesheets.new_xml_stylesheet.href = @lookandfeel.resource(:css)
      language = @session.language
      @model.each { |entry|
        item = feed.items.new_item
        item.author           = "ODDB.org"
        item.title            = sanitize(entry[:title])
        item.link             = entry[:link]
        item.date             = entry[:date] unless entry[:date].empty?
        item.description      = sanitize(entry[:description])
        item.guid.content     = item.link
        item.guid.isPermaLink = true
      }
    }.to_s
  end
end
    end
  end
end
