#!/usr/bin/env ruby
# View::WelcomeHead -- oddb -- 22.11.2002 -- hwyss@ywesee.com 

require 'htmlgrid/composite'
require 'htmlgrid/text'
require 'htmlgrid/link'
#require 'htmlgrid/flash'
require 'view/logohead'

module ODDB
	module View
		class WelcomeHead < HtmlGrid::Composite
			include Personal
			CSS_CLASS = 'composite'
			CSS_MAP = {
				[0,0]	=>	'logo',
				[1,0]	=>	'welcome',
			}
			COMPONENTS = {
				[0,0]		=>	View::Logo,
				[1,0]		=>	:sponsor,
				[1,0,1]	=>	"break",
				[1,0,2]	=>	"home_welcome",
				[1,0,3]	=>	:welcome,
			}
			def banner(model, session) 
				if(@lookandfeel.enabled?(:epatents)) #, false))
					%q{<A HREF="http://petition.eurolinux.org"><img src="http://aful.org/images/patent_banner.gif" alt="Petition against e-patents"></A><BR>}
				elsif(@lookandfeel.enabled?(:banner))
					#banner = @lookandfeel.resource(:banner)
					dest = @lookandfeel.lookup(:banner_destination)
					href = @lookandfeel._event_url(:passthru, {"destination"=>dest})
=begin
					case banner
					when /\.swf/
						fls = HtmlGrid::FlashComponent.new(:banner, model, session, self)
						fls.set_attribute('width', '468')
						fls.set_attribute('height', '62')
						fls.set_attribute('href', href)
						fls
					else
=end
						link = HtmlGrid::Link.new(:banner, model, session, self)
						link.set_attribute('target', '_blank')
						link.value = HtmlGrid::Image.new(:banner, model, session, self)
						link.set_attribute('href', href)
						link
					#end
				end
			end
			def sponsor(model, session)
				if((spons = @session.sponsor) && spons.valid? \
					&& @lookandfeel.enabled?(:sponsorlogo, false))
					View::SponsorLogo.new(spons, session, self)
				end
			end
		end
	end
end
