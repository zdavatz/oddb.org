#!/usr/bin/env ruby
require "htmlgrid/div"
require "open-uri"
module ODDB
  module View
    # see https://dojotoolkit.org/api/?qs=1.10/dijit/TooltipDialog
    class TooltipHelper
      # ASCII-8BIT heisst in diesem Datenbestand zweierlei, und ein blosses
      # encode("UTF-8") scheitert an beidem: aus einem binaeren String laesst
      # sich kein Byte ueber 0x7F konvertieren, es wirft
      # Encoding::UndefinedConversionError. Gemessen an der Index-Therapeuticus-
      # Beschreibung zu Registrierung 29448, die als ASCII-8BIT gespeichert ist
      # und UTF-8-Bytes traegt (195 169 = "e mit Akzent") - jede Packungsseite
      # mit Tooltip antwortete beim ersten Aufruf mit 500.
      #
      # Also erst als UTF-8 lesen und pruefen; nur wenn das nicht aufgeht, ist
      # es Latin-1 (so liegen die Kapiteltexte da, siehe View::Chapter). Ein
      # Umetikettieren allein waere in dem Fall falsch und wuerde den Umlaut
      # verlieren.
      def self.to_utf8(content)
        text = content.to_s
        return text if text.encoding == Encoding::UTF_8 && text.valid_encoding?
        if text.encoding == Encoding::ASCII_8BIT
          tagged = text.dup.force_encoding("UTF-8")
          return tagged if tagged.valid_encoding?
          return text.dup.force_encoding("ISO-8859-1").encode("UTF-8")
        end
        text.encode("UTF-8", invalid: :replace, undef: :replace, replace: "?")
      rescue EncodingError
        text.dup.force_encoding("UTF-8").scrub("?")
      end

      def self.set_java_script(element, content, href = "none")
        return unless element.additional_javascripts
        content = to_utf8(content)
        script = <<~EOS
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
        element.additional_javascripts.push script
      end

      def self.set_tooltip(element, href = nil, content = nil)
        # "preload: false,  preventCache: false. Slow, displays sometimes to the right, but never the home page
        # "preload: true,  preventCache: false. Loads early, only first tooltip ever outside, displays sometimes the homePage
        # Therefore we decide to fetch the content via open-uri. This increases the size of the page by about 25%
        # set_preload = "preload: true," if href
        content.clone
        if href
          content ||= defined?(Minitest) ? href : open(href).read
        end
        return unless element.additional_javascripts # satisfy unittest without additional_javascripts
        set_java_script(element, content, href)
      end
    end
  end
end
