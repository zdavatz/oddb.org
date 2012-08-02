function replace_element(id, url) {
  document.body.style.cursor = 'wait';
  dojo.xhrGet({
		url:  url,
		load: function(data) {
      var container;
      if(container = document.getElementById(id))
      {
        container.parentNode.innerHTML = data;
      }
      document.body.style.cursor = 'auto';
		},
    error: function(args) {
      if (args.dojoType =='cancel') { return; }
    }
	});
}
