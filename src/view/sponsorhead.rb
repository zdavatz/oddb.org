#!/usr/bin/env ruby
# SponsorHead -- oddb -- 30.07.2003 -- hwyss@ywesee.com 

require 'htmlgrid/composite'
require 'view/sponsorlogo'
require 'view/logo'

module ODDB
	class SponsorHead < HtmlGrid::Composite
		COMPONENTS = {
			[0,0]		=>	Logo,
			[1,0]		=>	:sponsor,
			[1,0,0]	=>	:sponsor_until,
		}
		CSS_MAP = {
			[1,0]	=>	'logo-r'
		}
		CSS_CLASS = 'composite'
		def sponsor(model, session)
			if((spons = @session.sponsor) \
				&& sponsor_represents?(spons, model))
				SponsorLogo.new(spons, session, self)
			end
		end
		def sponsor_until(model, session)
			if((spons = @session.sponsor) \
				&& sponsor_represents?(spons, model))
				@lookandfeel.lookup(:sponsor_until, @lookandfeel.format_date(spons.sponsor_until))
			end
		end
		private
		def sponsor_represents?(spons, model)
			model.respond_to?(:any?) \
			&& (date = spons.sponsor_until) \
			&& date >= Date.today \
			&& model.any? { |atc| 
				atc.packages.any? { |pac| spons.represents?(pac)}
			}
		end
	end
end
