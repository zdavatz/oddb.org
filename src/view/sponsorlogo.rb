#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Sponsorlogo -- oddb.org -- 01.10.2012 -- yasaka@ywesee.com
# ODDB::View::Sponsorlogo -- oddb.org -- 21.10.2011 -- mhatakeyama@ywesee.com 
# ODDB::View::Sponsorlogo -- oddb.org -- 30.07.2003 -- hwyss@ywesee.com 

require 'htmlgrid/image'

module ODDB
	module View
		class CompanyLogo < HtmlGrid::Component
			def init
				if(@model and name = @model.logo_filename)
					@attributes['src'] = @lookandfeel.resource_global(:company_logo, name)
					@attributes['alt'] = @model.name
				end
			end
			def to_html(context)
				context.img(@attributes)
			end
		end
		class SponsorLogo < HtmlGrid::Component
			def init
				if((name = @model.logo_filename(@lookandfeel.language)) \
					|| (name = @model.logo_filename(:default)))
					@attributes['src'] = @lookandfeel.resource_global(:sponsor, name)
					@attributes['alt'] = @model.name
				end
				@span = HtmlGrid::Span.new(@model, @session, self)
				if(time = @model.sponsor_until)
					@span.value = @lookandfeel.lookup(:sponsor_until,
						@lookandfeel.format_date(time))
				end
				@span.css_class = 'sponsor  right'
			end
      # This flash hasn't any clickTAG.
      # And modern Browsers do not handle anchor link wrapped this swf.
      # Then use a hack with transparent png. It needs postion and wmode as 'transparent'.
      # See also to_html().
      def logo(context)
        src = @attributes['src']
        case src[/\.[^.]+$/]
        when '.swf'
          <<-FLASH
<object
 codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,0,0"
 classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"
 style="pointer-events:none; position:relative;">
<param name="allowScriptAccess" value="always">
<param name="movie" value="#{src}"/>
<param name="play" value="true"/>
<param name="quality" value="best"/>
<param name="wmode" value="transparent" />
<embed
 src="#{src}"
 play="true" quality="best" type="application/x-shockwave-flash"
 pluginspage="http://www.macromedia.com/go/getflashplayer"
 allowScriptAccess="always"
 wmode="transparent"
 width="240px;" height="200px;"></embed>
</object>
          FLASH
        else
          context.img(@attributes)
        end
      end
			def to_html(context)
				url = @lookandfeel._event_url(:sponsorlink)
        context.div {
				  sponsor = context.a({'href' => url}) {
            # clickable transparent image
            context.img({
              'src'    => '/resources/transparent.png',
              'style'  => 'position:absolute;',
              'width'  => '240px',
              'height' => '200px',
            })
				  }
          sponsor << (logo(context) << @span.to_html(context))
          sponsor
        }
			end
		end
	end
end
