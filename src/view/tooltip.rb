#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::LogoHead -- oddb -- 30.11.2012 -- yasaka@ywesee.com
# ODDB::View::LogoHead -- oddb -- 24.10.2002 -- hwyss@ywesee.com

require 'htmlgrid/div'
require 'open-uri'
module ODDB
  module View
    # see https://dojotoolkit.org/api/?qs=1.10/dijit/TooltipDialog
    class TooltipHelper
      def self.set_java_script(element, content, href = 'none')
      return unless element.additional_javascripts
      content =  content.force_encoding('UTF-8')
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
        content:  "#{content.gsub('"', '\\"')}",
        onMouseLeave: function(){
          popup.close(#{element.css_id}_dialog);
        }
    });
    console.log("Added #{element.css_id}_dialog for href #{href}.isLoaded " +  #{element.css_id}_dialog.isLoaded);
    on(dom.byId('#{element.css_id}'), 'mouseover', function(){
        popup.open({
          popup: #{element.css_id}_dialog,
          orient: ['before'],
          around: dom.byId('#{element.css_id}')
      });
    });
});
EOS
      end
      def self.set_tooltip(element,  href=nil, content=nil)
        # "preload: false,  preventCache: false. Slow, displays sometimes to the right, but never the home page
        # "preload: true,  preventCache: false. Loads early, only first tooltip ever outside, displays sometimes the homePage
        # Therefore we decide to fetch the content via open-uri. This increases the size of the page by about 25%
        # set_preload = "preload: true," if href
        saved_content = content.clone
        if href
          unless content
            content = defined?(Minitest) ? href : open(href).read
          end
        end
        return unless element.additional_javascripts # satisfy unittest without additional_javascripts
        self.set_java_script(element, content, href)
      end
    end
  end
end
