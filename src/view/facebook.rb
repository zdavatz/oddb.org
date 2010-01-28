module ODDB
  module View
    module Facebook
      def facebook_fan(model, session=@session)
        <<-EOS
<script type="text/javascript" src="http://static.ak.connect.facebook.com/js/api_lib/v0.4/FeatureLoader.js.php/en_US"></script>
<script type="text/javascript">FB.init("3252fd8899d16ddc5b75a43ecfcf3e8b");</script>
<fb:fan profile_id="273461529221" stream="0" connections="0" logobar="0" width="300"></fb:fan>
<div style="font-size:8px; padding-left:10px">
<a href="http://www.facebook.com/pages/Generika/273461529221">Generika</a> on Facebook</div>
        EOS
      end
      def facebook_share(model, session=@session)
        <<-EOS
<a name="fb_share" type="button_count" href="http://www.facebook.com/sharer.php">Share</a>
<script src="http://static.ak.fbcdn.net/connect.php/js/FB.Share" type="text/javascript"></script>
        EOS
      end
    end
  end
end
