#!/usr/bin/env ruby
# View::Rss::Feedback -- oddb.org -- 29.06.2007 -- hwyss@ywesee.com

require 'rss/maker'
require 'view/feedbacks'
require 'view/drugs/feedbacks'
require 'view/migel/feedbacks'

module ODDB
  module View
    module Rss
class FeedbackTemplate < HtmlGrid::Template
  LEGACY_INTERFACE = false
  COMPONENTS = {
    [0,0] => :feedback, 
    [0,1] => :feedback_feed_link,
  }
  CSS_MAP = {
    [0,1] => 'list',
  }
  def feedback(model)
    view = case model.item.odba_instance
           when ODDB::Package
             View::Drugs::FeedbackList
           when ODDB::Migel::Product
             View::Migel::FeedbackList
           end
    view.new([model], @session, self)
  end
  def feedback_feed_link(model)
    link = HtmlGrid::Link.new(:feedback_feed_link, model, @session, self)
    link.href = @lookandfeel._event_url(:feedbacks, 
                                        :pointer => model.item.pointer)
    link
  end
end
class Feedback < HtmlGrid::Component
  include View::Latin1
  HTTP_HEADERS = {
    "Content-Type"  => "application/rss+xml",
  }
  def to_html(context)
    RSS::Maker.make('2.0') { |feed|
      feed.channel.title = @lookandfeel.lookup(:feedback_feed_title)
      feed.channel.link = @lookandfeel._event_url(:home)
      feed.channel.description = @lookandfeel.lookup(:feedback_feed_description)
      feed.channel.language = @session.language
      feed.encoding = 'ISO-8859-1'
      feed.xml_stylesheets.new_xml_stylesheet.href = @lookandfeel.resource(:css)
      @model.each { |feedback|
        if(parent = feedback.item)
          item = feed.items.new_item
          title = case parent.odba_instance
                  when ODDB::Package
                    title = @lookandfeel.lookup(:feedback_title, 
                                                parent.name, parent.size)
                  when ODDB::Migel::Product
                    title = [ @lookandfeel.lookup(:feedback_title_migel), 
                              parent.name ].join
                  end
          item.title = sanitize title
          
          url = @lookandfeel._event_url(:feedbacks, :pointer => parent.pointer)
          item.guid.content = item.link = url
          item.guid.isPermaLink = true
          item.date = feedback.time

          comp = FeedbackTemplate.new(feedback, @session, self)
          item.description = sanitize(comp.to_html(context))
        end
      }
    }.to_s
  end
end
    end
  end
end
