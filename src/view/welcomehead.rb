#!/usr/bin/env ruby
# WelcomeHead -- oddb -- 22.11.2002 -- hwyss@ywesee.com 

require 'htmlgrid/composite'
require 'htmlgrid/text'
require 'htmlgrid/link'
#require 'htmlgrid/flash'
require 'view/logo'

module ODDB
	class WelcomeHead < HtmlGrid::Composite
		CSS_CLASS = 'composite'
		COMPONENTS = {
			[0,0]		=>	Logo,
			#[1,0]		=>	:banner,
			[1,0,1]	=>	"break",
			[1,0,2]	=>	"home_welcome",
		}
		def banner(model, session)
			if(@lookandfeel.enabled?(:epatents)) #, false))
				%q{<A HREF="http://petition.eurolinux.org"><img src="http://aful.org/images/patent_banner.gif" alt="Petition against e-patents"></A><BR>}
			elsif(@lookandfeel.enabled?(:banner))
				#banner = @lookandfeel.resource(:banner)
				dest = @lookandfeel.lookup(:banner_destination)
				href = @lookandfeel.event_url(:passthru, {"destination"=>dest})
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
	end
end
