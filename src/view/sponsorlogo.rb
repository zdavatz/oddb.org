#!/usr/bin/env ruby
# Sponsorlogo -- oddb -- 30.07.2003 -- hwyss@ywesee.com 

require 'htmlgrid/image'

module ODDB
	class CompanyLogo < HtmlGrid::Component
		RESOURCE_TYPE = :company_logo
		def init
			if(name = @model.logo_filename)
				super
				@attributes['src'] = @lookandfeel.resource_global(self::class::RESOURCE_TYPE, name)
				@attributes['alt'] = @model.name
			end
		end
		def to_html(context)
			context.img(@attributes)
		end
	end
	class SponsorLogo < CompanyLogo
		RESOURCE_TYPE = :sponsor
		def to_html(context)
			if(@lookandfeel.enabled?(:sponsorlogo))
				super
			else
				'&nbsp;'
			end
		end
	end
end
