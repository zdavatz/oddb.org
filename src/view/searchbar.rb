#!/usr/bin/env ruby
# View::SearchBar -- oddb -- 22.11.2002 -- hwyss@ywesee.com 

require 'view/form'
require 'htmlgrid/inputtext'

module ODDB
	module View
class SearchBar < HtmlGrid::InputText
	def init
		super
		val = @lookandfeel.lookup(@name)
		if(@value.nil? || @value.is_a?(StandardError))
			txt_val = if(@session.respond_to?(:persistent_user_input))
				@session.persistent_user_input(@name) 
			end || val
			@attributes.store('value', txt_val)
		end
		@attributes.update({
			'onFocus'	=>	"if (value=='#{val}') { value='' }",
			'onBlur'	=>	"if (value=='') { value='#{val}' }",
			#'tabIndex'=>	"1",
		})
		args = ['zone', @session.state.zone, @name, '']
		submit = @lookandfeel.event_url(@container.event, args)
		script = "if(#{@name}.value!='#{val}'){"
		script << "var href = '#{submit}'"
		script << "+escape(#{@name}.value.replace(/\\//, '%2F'));"
		script << "if(this.exact_match)"
		script << "href += '/exact_match/' + this.exact_match.checked;"
		script << "document.location.href=href; } return false"
		self.onsubmit = script
	end
end
class SearchForm < View::Form
	COMPONENTS = {
		[0,0]	=>	:search_query,
		[1,0]	=>	:submit,
	}
	CSS_CLASS = 'right'
	EVENT = :search
	FORM_METHOD = 'GET'
	SYMBOL_MAP = {
		:search_query		=>	View::SearchBar,	
	}
	CSS_MAP = {
		[0,0] =>	'search',
		[1,0] =>	'button left padding',
	}
end
	end
end
