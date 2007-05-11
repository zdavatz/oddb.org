#!/usr/bin/env ruby
# View::Drugs::MiniFi -- oddb.org -- 26.04.2007 -- hwyss@ywesee.com

require 'view/drugs/privatetemplate'
require 'view/chapter'

module ODDB
  module View
    module Drugs
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
      View::Chapter.new(@session.language, model, @session, self)
    end
  end
  def name(model)
    @lookandfeel.lookup(:minifi_name, model.name)
  end
end
class MiniFi < PrivateTemplate
  CONTENT = View::Drugs::MiniFiComposite
  SNAPBACK_EVENT = :result
end
    end
  end
end
