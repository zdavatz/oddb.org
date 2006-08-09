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
			'onFocus'	=>	"if (value=='#{val}') { value='' };",
			'onBlur'	=>	"if (value=='') { value='#{val}' };",
			'id'			=>	"searchbar",
		})
		args = ['zone', @session.zone, @name, '']
		submit = @lookandfeel._event_url(@container.event, args)
		script = "if(#{@name}.value!='#{val}'){"
		script << "var href = '#{submit}'"
		script << "+escape(#{@name}.value.replace(/\\//, '%2F'));"
		script << "if(this.search_type)"
		script << "href += '/search_type/' + this.search_type.value;"
		script << "href += '#best_result';"
		script << "document.location.href=href; } return false"
		self.onsubmit = script
	end
end
class SelectSearchForm < View::Form
	COMPONENTS = {
		[0,0,0]	=>	:search_query,
		[0,0,1]	=>	:search_type,
	}
	SYMBOL_MAP = {
		:search_query	=>	View::SearchBar,	
	}
	CSS_CLASS = 'right'
	LEGACY_INTERFACE = false
	EVENT = :search
	FORM_METHOD = 'GET'
	def search_type(model)
		select = HtmlGrid::Select.new(:search_type, model, @session, self)
		select.set_attribute('onChange', 'this.form.onsubmit();')
		select.selected = @session.persistent_user_input(:search_type)
		select
	end
end
class SearchForm < View::Form
	COMPONENTS = {
		[0,0,0]	=>	:search_query,
		[0,0,1]	=>	:submit,
	}
	CSS_CLASS = 'right'
	EVENT = :search
	FORM_METHOD = 'GET'
	SYMBOL_MAP = {
		:search_query		=>	View::SearchBar,	
	}
end
	end
end
