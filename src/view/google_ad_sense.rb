#!/usr/bin/env ruby

# GoogleAdSense -- oddb -- 19.12.2012 -- yasaka@ywesee.com
# GoogleAdSense -- oddb -- 15.09.2004 -- jlang@ywesee.com

module ODDB
  module View
    module GoogleAdSenseMethods
      def ad_sense(model, session, label)
        if @lookandfeel.enabled?(:google_adsense) \
          && !(@session.user.valid? || active_sponsor?)
          google = GoogleAdSense.new(model, session, self, label)
          google.channel = self.class::GOOGLE_CHANNEL
          google.format = self.class::GOOGLE_FORMAT
          google.width = self.class::GOOGLE_WIDTH
          google.height = self.class::GOOGLE_HEIGHT
          google
        end
      end

      def active_sponsor?
        (spons = @session.sponsor) && spons.valid?
        # \
        #	&& @lookandfeel.enabled?(:sponsorlogo))
      end
    end

    class GoogleAdSense < HtmlGrid::Component
      attr_accessor :channel, :format, :width, :height
      def initialize(model, session, container = nil, label = "undefined label")
        @my_label = label
        super(model, session, container)
      end

      def init
        @format = "250x250_as"
        @width = "250"
        @height = "250"
        super
      end

      def to_html(context)
        if /search_result/i.match?(@my_label)
          # To test the placement I prepended a string like Werbung #{@my_label} #{@width}x #{@height}<br>#{@script}
          # The if statement below is an ugly hack to prevent loading the adsbygoogle.js twice
          # Add  google_adtest = "on";  for showing ads on your Test-Server if you are behind a Dnydns IP.
          %(
        <style>
          .search_result { width: 320px; height: 100px; }
          @media(min-width: 500px) { .search_result { width: 468px; height: 60px; } }
          @media(min-width: 800px) { .search_result { width: 728px; height: 90px; } }
        </style>
          <script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
        <!-- search_result -->
        <ins class="adsbygoogle search_result"
          style="display:block height  #{@height}px width {@width}px"
          google_ad_channel ="#{@channel}";
          data-matched-content-ui-type="image_sidebyside"
          data-matched-content-rows-num=1
          data-matched-content-columns-num=1
          data-ad-client="ca-pub-6948570700973491"></ins>
<script>
     (adsbygoogle = window.adsbygoogle || []).push({});
</script>
)
        else
          %(
<style>
.homes_responsive { width: 320px; height: 100px; }
@media(min-width: 500px) { .homes_responsive { width: 168px; height: 60px; } }
@media(min-width: 800px) { .homes_responsive { width: 228px; height: 90px; } }
</style>
    <script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
        <!-- homes_responsive -->
        <ins class="adsbygoogle homes_responsive"
          style="display:block height  #{@height}px width {@width}px"
          google_ad_channel ="#{@channel}";
          data-matched-content-ui-type="text"
          data-matched-content-rows-num=4
          data-matched-content-columns-num=1
          data-ad-client="ca-pub-6948570700973491"></ins>
<script>
     (adsbygoogle = window.adsbygoogle || []).push({});
</script>
)
        end
      end
    end

    class GoogleAdSenseComposite < HtmlGrid::Composite
      include GoogleAdSenseMethods
      COMPONENTS = {
        [0, 0]	=>	:ad_sense_left,
        [1, 0]	=>	:content,
        [2, 0]	=>	:ad_sense_right
      }
      CSS_CLASS = "composite"
      CSS_MAP = {
        [1, 0]	=>	"left",
        [2, 0]	=>	"right"
      }
      GOOGLE_CHANNEL = ""
      GOOGLE_FORMAT = "250x250_as"
      GOOGLE_WIDTH = "250"
      GOOGLE_HEIGHT = "250"
      def ad_sense_right(model, session)
        @session.logged_in? ? nil : GoogleAdSense.new(:ad_sense_, model, session, "ad_sense_right")
      end

      def ad_sense_left(model, session)
        @session.logged_in? ? nil : GoogleAdSense.new(:ad_sense_, model, session, "ad_sense_left")
      end

      def content(model, session)
        self.class::CONTENT.new(model, @session, self)
      end

      # as template
      def onload=(script)
        @attributes["onload"] = script
      end
    end
  end
end
