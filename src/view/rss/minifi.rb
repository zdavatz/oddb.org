#!/usr/bin/env ruby
# View::Rss::MiniFi -- oddb.org -- 11.05.2007 -- hwyss@ywesee.com

require 'rss/maker'
require 'view/drugs/minifi'

module ODDB
  module View
    module Rss
class MiniFiItem < View::Drugs::MiniFiChapter
  def header(context)
    if(@registration)
      context.h3 { self.escape(@registration.company_name) }
    end
  end
  def to_html(context)
    header(context).to_s << super
  end
end
class MiniFiTemplate < HtmlGrid::Template
  LEGACY_INTERFACE = false
  COMPONENTS = {
    [0,0] => MiniFiItem, 
  }
end
class MiniFi < HtmlGrid::Component
  include View::Latin1
  HTTP_HEADERS = {
    "Content-Type"  => "application/rss+xml",
  }
  def to_html(context)
    RSS::Maker.make('2.0') { |feed|
      feed.channel.title = @lookandfeel.lookup(:minifi_feed_title)
      feed.channel.link = @lookandfeel._event_url(:home)
      feed.channel.description = @lookandfeel.lookup(:minifi_feed_description)
      feed.channel.language = @session.language
      feed.encoding = 'ISO-8859-1'
      feed.xml_stylesheets.new_xml_stylesheet.href = @lookandfeel.resource(:css)
      @model.each { |minifi|

        document = minifi.send(@session.language)
        item = feed.items.new_item
        item.author = "ODDB.org"

        comp = MiniFiTemplate.new(minifi, @session, self)

        item.title = sanitize(document.heading)
        item.guid.content = item.link = @lookandfeel._event_url(:resolve, 
                                          :pointer => minifi.pointer)
        item.guid.isPermaLink = true
        item.date = date2time(minifi.publication_date)
        item.description = sanitize(comp.to_html(context))
      }
    }.to_s
  end
  def date2time(date)
    Time.parse(date.strftime('%Y-%m-%d 08:00:00 CET'))
  end
end
    end
  end
end
