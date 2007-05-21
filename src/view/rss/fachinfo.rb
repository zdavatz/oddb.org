#!/usr/bin/env ruby
# View::Rss::Fachinfo -- oddb.org -- 21.05.2007 -- hwyss@ywesee.com

require 'rss/maker'
require 'view/drugs/fachinfo'

module ODDB
  module View
    module Rss
class FachinfoItem < View::Drugs::FachinfoInnerComposite
  def header(context)
    if(@registration)
      context.h3 { self.escape(@registration.company_name) }
    end
  end
  def to_html(context)
    header(context).to_s << super
  end
end
class Fachinfo < HtmlGrid::Component
  def to_html(context)
    RSS::Maker.make('2.0') { |feed|
      feed.channel.title = @lookandfeel.lookup(:fachinfo_feed_title)
      feed.channel.link = @lookandfeel._event_url(:home)
      feed.channel.description = @lookandfeel.lookup(:fachinfo_feed_description)
      feed.channel.language = @session.language
      feed.encoding = 'ISO-8859-1'
      feed.xml_stylesheets.new_xml_stylesheet.href = @lookandfeel.resource(:css)
      @model.each { |fachinfo|

        document = fachinfo.send(@session.language)
        next unless(document.is_a?(FachinfoDocument))

        item = feed.items.new_item
        chapter = View::Drugs::FachinfoInnerComposite.new(document, 
                                                          @session, self)

        name = item.title = fachinfo.name_base
        item.guid.content = item.link = @lookandfeel._event_url(:resolve, 
                                          :pointer => fachinfo.pointer)
        item.guid.isPermaLink = true
        item.date = fachinfo.revision
        ptrn = /#{name}(\256|\(TM\))?/
        link = HtmlGrid::Link.new(:name, fachinfo, @session, self)
        link.href = @lookandfeel._event_url(:search, 
                                            :search_type => 'st_sequence', 
                                            :search_query => fachinfo.name)
        item.description = chapter.to_html(context)
      }
    }.to_s
  end
end
    end
  end
end
