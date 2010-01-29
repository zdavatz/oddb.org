function bitly_for_twitter(url, tweet)
{
  document.body.style.cursor = 'wait';
  var bitly = "http://api.bit.ly/shorten?version=2.0.1&longUrl=";
  bitly += url + "&login=oddb&apiKey=R_0e2f8d420324c59276c450b5253b4e3f";
  dojo.xhrGet({
		url: bitly,
    handleAs: 'json',
		load: function(data, ioargs) {
      var redirect;
      document.body.style.cursor = 'auto';
      if(data['errorCode'] == '0') {
        redirect = data['results']['shortUrl'];
        document.location.href = tweet + redirect;
      } else {
        alert(data['errorMessage']);
      }
		},
    error: function(error, ioargs) {
      console.debug(error);
      console.debug(ioargs);
      document.location.href = tweet + url;
    }
	});
  return false;
}
