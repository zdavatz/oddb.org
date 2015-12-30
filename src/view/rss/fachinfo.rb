#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Rss::Fachinfo -- oddb.org -- 16.01.2012 -- mhatakeyama@ywesee.com
# ODDB::View::Rss::Fachinfo -- oddb.org -- 21.05.2007 -- hwyss@ywesee.com

require 'rss/maker'
require 'view/drugs/fachinfo'
require 'view/latin1'
require 'util/today'

module ODDB
  module View
    module Rss
class FachinfoItem < HtmlGrid::DivComposite
  COMPONENTS = {}
  DEFAULT_CLASS = View::Chapter
  def init
    @model = @model.send(@session.language)
    super
  end
end
class FachinfoTemplate < HtmlGrid::Template
  LEGACY_INTERFACE = false
  COMPONENTS = {
    [0,0] => FachinfoItem,
    }
end
class Fachinfo < HtmlGrid::Component
  include View::Latin1
  def initialize(model, session, container = nil, year = nil)
    @year = year
    super(model, session, container)
  end
  def item_to_html(context, fachinfo, feed)
    language = @session.language
    iksnrs = nil
    begin
      iksnrs = fachinfo.iksnrs
    rescue   => e
      puts "rss/fachinfo #{__LINE__}: rescue #{e.inspect} for rss/fachinfo #{__LINE__}: #{fachinfo.inspect}"
      return ""
    end
    puts "rss/fachinfo #{__LINE__}: #{fachinfo.inspect} iksnrs #{iksnrs.inspect} language #{language}"
    document = fachinfo.send(language)
    return "" unless(document.is_a?(FachinfoDocument))

    item = feed.items.new_item
    item.author = "ODDB.org"

    return "" unless fachinfo.respond_to?(:localized_name)
    name = item.title = sanitize(fachinfo.localized_name(language))
    return "" unless name
    return "" unless iksnrs && iksnrs.is_a?(Array)
    args = {:reg => iksnrs.first}
    item.guid.content = item.link = @lookandfeel._event_url(:fachinfo, args)
    item.guid.isPermaLink = true
    item.date = fachinfo.revision.utc

    comp = FachinfoTemplate.new(fachinfo, @session, self)

    ptrn = /#{Regexp.escape(name)}(®|\(TM\))?/u
    link = HtmlGrid::Link.new(:name, fachinfo, @session, self)
    link.href = @lookandfeel._event_url(:search,
                                        :search_type => 'st_sequence',
                                        :search_query => name.gsub('/', '%2F'))
    html = comp.to_html(context)
    html.gsub!(%r{<pre\b.*?</pre>}imu) { |match| match.gsub(%r{\n}u, '<BR>') }
    item.description = sanitize(html).gsub(ptrn) do |match|
      link.value = match
      link.to_html(context)
    end
  end

  def to_html(context)
    RSS::Maker.make('2.0') do |feed|
      feed.channel.title = @lookandfeel.lookup(:fachinfo_feed_title)
      feed.channel.link = @lookandfeel._event_url(:home)
      feed.channel.description = @lookandfeel.lookup(:fachinfo_feed_description)
      feed.channel.language = @session.language
      feed.image.url = @lookandfeel.resource(:logo_rss)
      feed.image.title = @lookandfeel.lookup(:logo)
      feed.encoding = 'UTF-8'
      feed.xml_stylesheets.new_xml_stylesheet.href = @lookandfeel.resource(:css)
      @model.each do |fachinfo|
        if @year
          next if (fachinfo.revision.utc.year != @year)
        else
          next if (fachinfo.revision.utc.year < @@today.year-1)
        end
        item_to_html(context, fachinfo, feed)
      end
    end.to_s
  end
end
    end
  end
end
