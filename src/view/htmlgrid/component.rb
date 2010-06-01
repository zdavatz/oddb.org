#!/usr/bin/env ruby
# HtmlGrid::Component -- oddb -- 04.08.2006 -- hwyss@ywesee.com

require 'htmlgrid/component'
require 'htmlgrid/dojotoolkit'

module HtmlGrid
  class Component
		unless(method_defined?(:oddb_dynamic_html))
			alias :oddb_dynamic_html :dynamic_html
			def dynamic_html(context)
        if(@lookandfeel.enabled?(:ajax))
          oddb_dynamic_html(context)
        else
          dojo_dynamic_html(context)
        end
			end
		end
    ## additional_javascripts should possibly be moved to htmlgrid proper.
    def additional_javascripts
      @additional_javascripts || (@container.additional_javascripts if @container)
    end
  end
end
