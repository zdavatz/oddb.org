#!/usr/bin/env ruby
# View::Sponsorlogo -- oddb -- 30.07.2003 -- hwyss@ywesee.com 

require 'htmlgrid/image'

module ODDB
	module View
		class CompanyLogo < HtmlGrid::Component
			def init
				if(name = @model.logo_filename)
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
				@span.value = @lookandfeel.lookup(:sponsor_until, 
					@lookandfeel.format_date(@model.sponsor_until))
				@span.css_class = 'logo-r'
			end
			def to_html(context)
				url = @lookandfeel._event_url(:sponsorlink)
				context.a({'href' => url}) { 
					context.img(@attributes) << @span.to_html(context)
				}
			end
		end
	end
end
