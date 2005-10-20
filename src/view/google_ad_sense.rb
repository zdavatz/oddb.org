#!/usr/bin/env ruby
# GoogleAdSense -- oddb -- 15.09.2004 -- jlang@ywesee.com

module ODDB
	module View
		module GoogleAdSenseMethods
			def ad_sense(model, session)
				if(@lookandfeel.enabled?(:google_adsense) \
					&& !(@session.user.valid? || active_sponsor?))
					google = GoogleAdSense.new(model, session, self)
					google.channel = self::class::GOOGLE_CHANNEL
					google.format = self::class::GOOGLE_FORMAT
					google.width = self::class::GOOGLE_WIDTH
					google.height = self::class::GOOGLE_HEIGHT
					google
				end
			end
			def active_sponsor?
				((spons = @session.sponsor) && spons.valid? \
					&& @lookandfeel.enabled?(:sponsorlogo, false))
			end
		end
		class GoogleAdSense < HtmlGrid::Component
			attr_accessor :channel, :format, :width, :height
			def init
				@format = "250x250_as"
				@width = "250"
				@height = "250"
				super
			end
			def to_html(context)
				<<-EOS
<script type="text/javascript"><!--
google_ad_client = "pub-6948570700973491";
google_ad_width = "#{@width}";
google_ad_height = "#{@height}";
google_ad_format = "#{@format}";
google_ad_channel ="#{@channel}";
google_ad_type = "text_image";
google_color_border = "DBE1D6";
google_color_bg = "E6FFD6";
google_color_link = "003366";
google_color_url = "FF3300";
google_color_text = "003399";
//--></script>
<script type="text/javascript"
  src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
	</script>
				EOS
			end
		end
		class GoogleAdSenseComposite < HtmlGrid::Composite
			include GoogleAdSenseMethods
			COMPONENTS = {
				[0,0]	=>	:ad_sense,
				[1,0]	=>	:content,
				[2,0]	=>	:ad_sense,
			}
			CSS_CLASS = 'composite'
			CSS_MAP = {
				[2,0]	=>	'right',
			}
			GOOGLE_CHANNEL = ''
			GOOGLE_FORMAT = '250x250_as'
			GOOGLE_WIDTH = '250'
			GOOGLE_HEIGHT = '250'
			def content(model, session)
				self::class::CONTENT.new(model, @session, self)
			end
		end
	end
end
