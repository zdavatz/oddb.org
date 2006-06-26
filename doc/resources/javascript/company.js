function sbsm_encode(value)
{
	value = encodeURIComponent(value);
	value = encodeURIComponent(value);
	return value;
}

function update_company(url)
{
  document.body.style.cursor = 'wait';
	dojo.io.bind({
		url: url,
		load: function(type, data, evt) { 
			var content;
			if(content = document.getElementById('company-content'))
			{
				content.parentNode.innerHTML = data	;
			}
      document.body.style.cursor = 'auto';
		},
		mimetype: "text/html"
	});
}
