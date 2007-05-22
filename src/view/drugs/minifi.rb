#!/usr/bin/env ruby
# View::Drugs::MiniFi -- oddb.org -- 26.04.2007 -- hwyss@ywesee.com

require 'view/drugs/privatetemplate'
require 'view/additional_information'
require 'view/chapter'

module ODDB
  module View
module Latin1
  def sanitize(string)
    string = string.dup
    string.gsub!("\140", '-')
    string.gsub!(/[\x00-\x08\x0b-\x1f\x7f-\x9f]/, '')
    string
  end
end
    module Drugs
class MiniFiChapter < Chapter
  include AdditionalInformation
  include View::Latin1
  def initialize(model, session, container)
    super(session.language, model, session, container)
    @registration = @model.registrations.first
  end
  def link_product(context, html)
    ptrn = /#{@model.name}(\256|\(TM\))?/
    link = HtmlGrid::Link.new(:name, @model, @session, self)
    link.href = @lookandfeel._event_url(:search, 
                                        :search_type => 'st_sequence', 
                                        :search_query => @model.name)
    html.gsub(ptrn) { |match|
      link.value = match
      link.to_html(context)
    }
  end
  def to_html(context)
    link_product(context, sanitize(sections(context, @value.sections))) \
      << footer(context).to_s
  end
  def footer(context)
    if(@registration)
      [
        atc_ddd_link(@registration.atc_classes.first),
        comarketing(@registration),
        google_search(@registration),
      ].compact.collect { |part| 
        part.to_html(context) 
      }.join(@lookandfeel.lookup(:navigation_divider))
    end
  end
end
class MiniFiComposite < HtmlGrid::Composite
  COMPONENTS = {
    [0,0]	=>	:name,
    [0,1] =>	:document,
  }
  CSS_MAP = {
    [0,0] => 'th',
    [0,1]	=> 'list',
  }	
  LEGACY_INTERFACE = false
  def document(model)
    if(chapter = model.send(@session.language))
      MiniFiChapter.new(model, @session, self)
    end
  end
  def name(model)
    cname = (reg = model.registrations.first) ? reg.company_name : nil
    @lookandfeel.lookup(:minifi_name, model.name, cname)
  end
end
class MiniFi < PrivateTemplate
  CONTENT = View::Drugs::MiniFiComposite
  SNAPBACK_EVENT = :result
end
    end
  end
end
