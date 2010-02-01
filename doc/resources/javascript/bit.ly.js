var bitly_callback;
function bitly_for_twitter(url, tweet)
{
  document.body.style.cursor = 'wait';
  var bitly = "http://api.bit.ly/shorten?callback=bitly_callback&version=2.0.1&longUrl=";
  bitly += url + "&login=oddb&apiKey=R_0e2f8d420324c59276c450b5253b4e3f";
  bitly_callback = function(data) {
    var result;
    var redirect;
    document.body.style.cursor = 'auto';
    if(data.errorCode == '0') {
      result = data.results[unescape(url)];
      redirect = result.shortUrl;
      document.location.href = tweet + redirect;
    } else {
      alert(data.errorMessage);
    }
  };
  dojo.io.script.get({
		url: bitly,
    checkString: 'bitly_callback',
    error: function(error, ioargs) {
      console.debug(error);
      console.debug(ioargs);
      document.location.href = tweet + url;
    }
	});
  return false;
}
