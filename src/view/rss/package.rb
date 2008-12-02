#!/usr/bin/env ruby
# View:Rss::Package -- oddb.org -- 23.05.2007 -- hwyss@ywesee.com

require 'view/drugs/package'
require 'view/latin1'
require 'rss/maker'

module ODDB
  module View
    module Rss
class PackageTemplate < HtmlGrid::Template
  LEGACY_INTERFACE = false
  COMPONENTS = {
    [0,0] => View::Drugs::PackageInnerComposite, 
    [0,1] => :package_feed_link,
  }
  CSS_MAP = {
    [0,1] => 'list',
  }
  def package_feed_link(model)
    link = HtmlGrid::Link.new(:package_feed_link, model, @session, self)
    link.href = @lookandfeel._event_url(:show, :pointer => model.pointer)
    link
  end
end
class Package < HtmlGrid::Component
  include View::Latin1
  def to_html(context)
    RSS::Maker.make('2.0') { |feed|
      feed.channel.title = @lookandfeel.lookup(@title)
      feed.channel.link = @lookandfeel._event_url(:home)
      feed.channel.description = @lookandfeel.lookup(@description)
      feed.channel.language = @session.language
      feed.image.url = @lookandfeel.resource_localized(:logo)
      feed.image.title = @lookandfeel.lookup(:logo)
      feed.encoding = 'ISO-8859-1'
      feed.xml_stylesheets.new_xml_stylesheet.href = @lookandfeel.resource(:css)
      language = @session.language
      @model.each { |package|
        item = feed.items.new_item
        item.author = "ODDB.org"
        pcurrent = package.price_public
        plast = package.price_public(1)
        args = pcurrent.valid_from.strftime(@lookandfeel.lookup(:date_format)),
          package.name, package.size, package.price_public
        fmt = "%s: %s, %s, %s"
        if plast
          args.push((pcurrent - plast) / plast * 100.0)
          fmt = "%s: %s, %s, %s, %+.1f%%"
        end
        item.title = sanitize sprintf(fmt, *args)
        
        url = @lookandfeel._event_url(:show, :pointer => package.pointer)
        item.guid.content = item.link = url
        item.guid.isPermaLink = true
        item.date = pcurrent.valid_from

        comp = PackageTemplate.new(package, @session, self)
        item.description = sanitize(comp.to_html(context))
      }
    }.to_s
  end
end
    end
  end
end
