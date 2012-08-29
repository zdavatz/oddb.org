#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Facebook -- oddb.org -- 29.08.2012 -- yasaka@ywesee.com
# ODDB::View::Facebook -- oddb.org -- 28.09.2011 -- mhatakeyama@ywesee.com
# ODDB::View::Facebook -- oddb.org -- 28.01.2010 -- hwyss@ywesee.com

module ODDB
  module View
    module Facebook
      def facebook_sdk()
        sdk_setup_script = <<JS
<div id="fb-root"></div>
<script>(function(d, s, id) {
  var js, fjs = d.getElementsByTagName(s)[0];
  if (d.getElementById(id)) return;
  js = d.createElement(s); js.id = id;
  js.src = "//connect.facebook.net/de_DE/all.js#xfbml=1&appId=3252fd8899d16ddc5b75a43ecfcf3e8b";
  fjs.parentNode.insertBefore(js, fjs);
}(document, 'script', 'facebook-jssdk'));</script>
JS
      end
      def facebook_fan(model, session=@session)
        # TODO
        #  use facebook_sdk() for setup
        <<-EOS
<script type="text/javascript" src="http://static.ak.connect.facebook.com/js/api_lib/v0.4/FeatureLoader.js.php/en_US"></script>
<script type="text/javascript">FB.init("3252fd8899d16ddc5b75a43ecfcf3e8b");</script>
<fb:fan profile_id="273461529221" stream="0" connections="0" logobar="0" width="300"></fb:fan>
<div style="font-size:8px; padding-left:10px">
<a href="http://www.facebook.com/pages/Generika/273461529221">Generika</a> on Facebook</div>
        EOS
      end
      def facebook_share(model, session=@session, share_url=nil)
        if share_url
        <<-EOS
<div class="fb-like" data-href="#{share_url}" data-send="false" data-layout="button_count" data-width="450" data-show-faces="false" data-action="recommend" data-font="arial"></div>
        EOS
        else
        # TODO
        #  use facebook_sdk() for setup
        <<-EOS
<a name="fb_share" type="button_count" href="http://www.facebook.com/sharer.php">Share</a>
<script src="http://static.ak.fbcdn.net/connect.php/js/FB.Share" type="text/javascript"></script>
        EOS
        end
      end
      def facebook_send(model, session)
        # TODO
        #  use facebook_sdk() for setup
        <<-EOS
<script src="http://connect.facebook.net/de_DE/all.js#xfbml=1"></script>
<fb:send href="http://ywesee.com" show_faces="true" width="450" action="recommend" send="true"></fb:send>
        EOS
      end
    end
  end
end
