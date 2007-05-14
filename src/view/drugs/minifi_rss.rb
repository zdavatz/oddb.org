#!/usr/bin/env ruby
# View::Drugs::MinifiRss -- oddb.org -- 11.05.2007 -- hwyss@ywesee.com

require 'rss/maker'
require 'view/chapter'

module ODDB
  module View
    module Drugs
class MiniFiRss < HtmlGrid::Component
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
        item.title = sanitize(document.heading)
        item.guid.content = item.link = @lookandfeel._event_url(:resolve, 
                                          :pointer => minifi.pointer)
        item.guid.isPermaLink = true
        item.date = date2time(minifi.publication_date)
        html = View::Chapter.new(@session.language, minifi, @session, 
                                 self).sections(context, document.sections)
        item.description = sanitize(html)
      }
    }.to_s
  end
  def sanitize(string)
    string.gsub(/[^\040-\377]/, '')
  end
  def date2time(date)
    Time.parse(date.strftime('%Y-%m-%d 08:00:00 CET'))
  end
end
    end
  end
end
