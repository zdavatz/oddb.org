#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::LogoHead -- oddb -- 30.11.2012 -- yasaka@ywesee.com
# ODDB::View::LogoHead -- oddb -- 24.10.2002 -- hwyss@ywesee.com

require 'htmlgrid/div'
module ODDB
  module View
    class TooltipHelper
      def self.set_tooltip(element,  href=nil, content=nil)
        element.additional_javascripts.push <<-EOS
require([
    "dijit/TooltipDialog",
    "dijit/popup",
    "dojo/on",
    "dojo/dom",
    "dojo/domReady!"
], function(TooltipDialog, popup, on, dom){
    var #{element.css_id}_dialog = new TooltipDialog({
        id: '#{element.css_id}_dialog',
        content:  '#{content}',
        href: '#{href}', // the initialization of href must come after content!!
        onMouseLeave: function(){
            popup.close(#{element.css_id}_dialog);
        }
    });
    on(dom.byId('#{element.css_id}'), 'mouseover', function(){
        popup.open({
            popup: #{element.css_id}_dialog,
            around: dom.byId('#{element.css_id}')
        });
    });
});
EOS
      end
    end
  end
end
