#!/usr/bin/env ruby
# View::User::Plugin -- oddb -- 11.08.2003 -- mhuggler@ywesee.com

require 'view/publictemplate'
require 'htmlgrid/link'

module ODDB
	module View
		module User
class PluginInnerComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	:plugin_description,
		[0,1]	=>	:plugin_javascript,
		[0,2]	=>	:plugin_download_src,
		[0,3]	=>	:plugin_download_gif,
	}
	CSS_MAP = {
		[0,0,4,4]	=>	'list',
	}
	LABELS = false
	DEFAULT_CLASS = HtmlGrid::Value
	def plugin_javascript(model, session)
		link = HtmlGrid::Link.new(:plugin_javascript, model, session, self)
		link.href = "javascript:addEngine('oddb.org','gif','Health')"
		link.label = true
		link.set_attribute('class', 'list')
		link
	end
	def plugin_download_src(model, session)
		link = HtmlGrid::Link.new(:plugin_download_src, model, session, self)
		link.href = @lookandfeel.resource_global(:plugin_download_src)
		link.label = true
		link.set_attribute('class', 'list')
		link
	end
	def plugin_download_gif(model, session)
		link = HtmlGrid::Link.new(:plugin_download_gif, model, session, self)
		link.href = @lookandfeel.resource_global(:plugin_download_gif)
		link.label = true
		link.set_attribute('class', 'list')
		link
	end
				def plugin_description(model, session)
					link = HtmlGrid::Link.new(:plugin_description, model, @session, self)
					if(@lookandfeel.language == 'de')
					link.href =  "http://wiki.oddb.org/wiki.php?pagename=ODDB.Direktsuche"
					elsif(@lookandfeel.language == 'fr')
					link.href = "http://wiki.oddb.org/wiki.php?pagename=ODDB.DirectCherche"
					elsif(@lookandfeel.language == 'en')
					link.href = "http://wiki.oddb.org/wiki.php?pagename=ODDB.Plugin"
					end
					link
				end
end
class PluginComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	'plugin_oddb',
		[0,1]	=>	View::User::PluginInnerComposite,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'th',
	}
end
class Plugin < View::PublicTemplate
	CONTENT = View::User::PluginComposite
	def html_head(context)
		super {
			context.script({'type'=>'text/javascript'}) {
				<<-EOS
<!--
function errorMsg()
{
alert("Netscape 6 or Mozilla is needed to install a sherlock plugin");
}
function addEngine(name,ext,cat)
{
if ((typeof window.sidebar == "object") && (typeof window.sidebar.addSearchEngine == "function"))
	{
		window.sidebar.addSearchEngine(
			"http://www.oddb.org/resources/plugins/"+name+".src",
			"http://www.oddb.org/resources/plugins/"+name+"."+ext,
			name,
			cat );
	}
else
	{
	errorMsg();
	}
}
//-->
				EOS
			}
		}	
	end
end
		end
	end
end
