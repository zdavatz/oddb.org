#!/usr/bin/env ruby
# View::Rss::Fachinfo -- oddb.org -- 21.05.2007 -- hwyss@ywesee.com

require 'rss/maker'
require 'view/drugs/fachinfo'
require 'view/latin1'

module ODDB
  module View
    module Rss
class FachinfoItem < HtmlGrid::DivComposite
  COMPONENTS = {}
  DEFAULT_CLASS = View::Chapter
  def init
    @model.chapter_names.each_with_index { |name, idx|
      components.store([0,idx], name)
      break if(name == :indications || idx > 4)
    }
    super
  end
end
class FachinfoTemplate < HtmlGrid::Template
  LEGACY_INTERFACE = false
  COMPONENTS = {
    [0,0] => FachinfoItem, 
    [0,1] => :fachinfo_feed_link,
  }
  SYMBOL_MAP = {
    :fachinfo_feed_link => PointerLink,
  }
end
class Fachinfo < HtmlGrid::Component
  include View::Latin1
  def to_html(context)
    RSS::Maker.make('2.0') { |feed|
      feed.channel.title = @lookandfeel.lookup(:fachinfo_feed_title)
      feed.channel.link = @lookandfeel._event_url(:home)
      feed.channel.description = @lookandfeel.lookup(:fachinfo_feed_description)
      feed.channel.language = @session.language
      feed.encoding = 'ISO-8859-1'
      feed.xml_stylesheets.new_xml_stylesheet.href = @lookandfeel.resource(:css)
      language = @session.language
      @model.each { |fachinfo|

        document = fachinfo.send(language)
        next unless(document.is_a?(FachinfoDocument))

        item = feed.items.new_item
        item.author = "ODDB.org"

        name = item.title = sanitize(fachinfo.localized_name(language))
        item.guid.content = item.link = @lookandfeel._event_url(:resolve, 
                                          :pointer => fachinfo.pointer)
        item.guid.isPermaLink = true
        item.date = fachinfo.revision

        comp = FachinfoTemplate.new(document, @session, self)

        ptrn = /#{Regexp.escape(name)}(\256|\(TM\))?/
        link = HtmlGrid::Link.new(:name, fachinfo, @session, self)
        link.href = @lookandfeel._event_url(:search, 
                                            :search_type => 'st_sequence', 
                                            :search_query => name)
        html = comp.to_html(context)
        html.gsub!(%r{<pre\b.*?</pre>}im) { |match|
          match.gsub(%r{\n}, '<BR>')
        }
        item.description = sanitize(html).gsub(ptrn) { |match|
          link.value = match
          link.to_html(context)
        }
      }
    }.to_s
  end
end
    end
  end
end
