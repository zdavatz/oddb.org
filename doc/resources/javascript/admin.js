function replace_element(id, url) {
  document.body.style.cursor = 'wait';
  dojo.io.bind({
		url: url,
		load: function(type, data, evt) { 
      var container;
      if(container = document.getElementById(id))
      {
        container.parentNode.innerHTML = data;
      }
      document.body.style.cursor = 'auto';
		},
	});
 
}
