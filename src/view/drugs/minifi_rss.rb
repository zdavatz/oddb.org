#!/usr/bin/env ruby
# View::Drugs::MinifiRss -- oddb.org -- 11.05.2007 -- hwyss@ywesee.com

require 'rss/maker'
require 'view/drugs/minifi'

module ODDB
  module View
    module Drugs
class MiniFiRssItem < MiniFiChapter
  def header(context)
    if(@registration)
      context.h3 { self.escape(@registration.company_name) }
    end
  end
  def to_html(context)
    header(context).to_s << super
  end
end
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

        chapter = MiniFiRssItem.new(minifi, @session, self)

        item.title = chapter.sanitize(document.heading)
        item.guid.content = item.link = @lookandfeel._event_url(:resolve, 
                                          :pointer => minifi.pointer)
        item.guid.isPermaLink = true
        item.date = date2time(minifi.publication_date)
        ptrn = /#{minifi.name}(\256|\(TM\))?/
        link = HtmlGrid::Link.new(:name, minifi, @session, self)
        link.href = @lookandfeel._event_url(:search, 
                                            :search_type => 'st_sequence', 
                                            :search_query => minifi.name)
        item.description = chapter.to_html(context)
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
