#!/usr/bin/env ruby
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
      def logo(context)
        src = @attributes['src']
        case src[/\.[^.]+$/]
        when '.swf'
          <<-FLASH
<object codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,0,0" classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000">
<param name="movie" value="#{src}"/>
<param name="play" value="true"/>
<param name="quality" value="best"/>
<embed src="#{src}" play="true" quality="best" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer"/>
</object>
          FLASH
        else
          context.img(@attributes)
        end
      end
			def to_html(context)
				url = @lookandfeel._event_url(:sponsorlink)
				context.a({'href' => url}) { 
          logo(context) << @span.to_html(context)
				}
			end
		end
	end
end
