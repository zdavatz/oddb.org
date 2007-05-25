#!/usr/bin/env ruby
# View:Rss::Package -- oddb.org -- 23.05.2007 -- hwyss@ywesee.com

require 'view/drugs/package'
require 'view/latin1'

module ODDB
  module View
    module Rss
class Package < HtmlGrid::Component
  include View::Latin1
  def to_html(context)
    RSS::Maker.make('2.0') { |feed|
      feed.channel.title = @lookandfeel.lookup(@title)
      feed.channel.link = @lookandfeel._event_url(:home)
      feed.channel.description = @lookandfeel.lookup(@description)
      feed.channel.language = @session.language
      feed.encoding = 'ISO-8859-1'
      feed.xml_stylesheets.new_xml_stylesheet.href = @lookandfeel.resource(:css)
      language = @session.language
      @model.each { |package|
        item = feed.items.new_item
        pcurrent = package.price_public
        plast = package.price_public(1)
        item.title = sanitize [
          package.name, package.size, package.price_public, 
          sprintf("%+.1f%%", (pcurrent - plast) / plast * 100.0),
        ].join(' | ')
        url = @lookandfeel._event_url(:show, :pointer => package.pointer)
        item.guid.content = item.link = url
        item.guid.isPermaLink = true
        item.date = package.revision

        comp = View::Drugs::PackageInnerComposite.new(package, @session, self)
        html = comp.to_html(context)

        read = HtmlGrid::Link.new(:package_feed_link, package, @session, self)
        read.href = url
        html << read.to_html(context)

        item.description = sanitize(html)
      }
    }.to_s
  end
end
    end
  end
end
