#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::SearchBar -- oddb.org -- 06.08.2012 -- yasaka@ywesee.com
# ODDB::View::SearchBar -- oddb.org -- 19.01.2012 -- mhatakeyama@ywesee.com 
# ODDB::View::SearchBar -- oddb.org -- 22.11.2002 -- hwyss@ywesee.com 

require 'view/form'
require 'htmlgrid/divform'
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
		script << "+encodeURIComponent(#{@name}.value.replace(/\\//, '%2F'));"
		script << "if(this.search_type)"
		script << "href += '/search_type/' + this.search_type.value;"
    unless @lookandfeel.disabled?(:best_result)
      script << "href += '#best_result';"
    end
		script << "document.location.href=href; } return false"
		self.onsubmit = script
	end
end
class AutocompleteSearchBar < HtmlGrid::InputText
  def init
    super
    val = @session.lookandfeel.lookup(@name)
    @container.additional_javascripts.push <<-EOS
function initMatches() {
  var searchbar = dojo.byId('searchbar');
  dojo.connect(searchbar, 'onkeypress', function(e) {
    if(e.keyCode == dojo.keys.ENTER) {
      searchbar.form.submit();
    }
  });
  dojo.connect(searchbar, 'onfocus', function(e) {
    if(searchbar.value == '#{val}') { searchbar.value = ''; }
  });
  dojo.connect(searchbar, 'onblur', function(e) {
    if(searchbar.value == '') { searchbar.value = '#{val}'; }
  });
}
function selectSubmit() {
  var popup = dojo.byId('searchbar_popup');
  var searchbar = dojo.byId('searchbar');
  if (!popup.style.overflowX.match(/auto/) && searchbar.value != '') {
    searchbar.form.submit();
  }
}
require(['dojo/ready'], function(ready) {
  ready(function() {
    initMatches();
  });
});
    EOS
    @attributes.update 'data-dojo-type' => 'dijit.form.ComboBox',
                       'jsId'           => 'searchbar',
                       'id'             => 'searchbar',
                       'store'          => 'search_matches',
                       'queryExpr'      => '${0}',
                       'searchAttr'     => 'search_query',
                       'hasDownArrow'   => 'false',
                       'autoComplete'   => 'false',
                       'onChange'       => 'selectSubmit',
                       'value'          => @session.persistent_user_input(:search_query)
  end
  def to_html(context, *args)
    args = []
    if @container.respond_to?(:index_name) && (index = @container.index_name)
      args.push :index_name, index
    end
    target = @session.lookandfeel._event_url(:ajax_matches, args)
    html = context.div 'data-dojo-type' => 'dojox.data.JsonRestStore',
                       'jsId'           => 'search_matches',
                       'idAttribute'    => 'search_query',
                       'target'         => target
    html << super(context)
  end
end
class PrescriptionDrugSearchBar < HtmlGrid::InputText
  def init
    super
    id  = 'prescription_searchbar'
    val = @session.lookandfeel.lookup(:add_drug)
    url = @session.lookandfeel.event_url(:ajax_add_drug)
    @container.additional_javascripts.push <<-EOS
function xhrGet(arg) {
  var ean13 = (arg.match(/^(\\d{13})$/)||[])[1];
  if(ean13) {
    var id = 'drugs';
    var url = '#{url}/ean/' + ean13;
    replace_element(id, url)
  }
}
function initMatches() {
  var searchbar = dojo.byId('#{id}');
  searchbar.value = '#{val}';
  dojo.connect(searchbar, 'onkeypress', function(e) {
    var popup = dojo.byId('prescription_searchbar_popup');
    if(popup && popup.style.overflowX.match(/auto/) && e.keyCode == dojo.keys.ENTER) {
      xhrGet(searchbar.value);
      searchbar.value = '';
    }
  });
  dojo.connect(searchbar, 'onfocus', function(e) {
    if(searchbar.value == '#{val}') { searchbar.value = ''; }
  });
  dojo.connect(searchbar, 'onblur', function(e) {
    if(searchbar.value == '') { searchbar.value = '#{val}'; }
  });
}
function selectXhrRequest() {
  var popup = dojo.byId('prescription_searchbar_popup');
  var searchbar = dojo.byId('#{id}');
  if(!popup.style.overflowX.match(/auto/) && searchbar.value != '') {
    xhrGet(searchbar.value);
    searchbar.value = '';
  }
}
require(['dojo/ready'], function(ready) {
  ready(function() {
    initMatches();
  });
});
    EOS
    @attributes.update 'data-dojo-type' => 'dijit.form.ComboBox',
                       'jsId'           => 'prescription_searchbar',
                       'id'             => 'prescription_searchbar',
                       'store'          => 'search_matches',
                       'queryExpr'      => '${0}',
                       'searchAttr'     => 'search_query', # name
                       'labelAttr'      => 'drug',         # label
                       'hasDownArrow'   => 'false',
                       'autoComplete'   => 'false',
                       'onChange'       => 'selectXhrRequest',
                       'value'          => @session.persistent_user_input(:search_query)
  end
  def to_html(context, *args)
    args = []
    if @container.respond_to?(:index_name) && (index = @container.index_name)
      args.push :index_name, index
    end
    target = @session.lookandfeel._event_url(:ajax_matches, args)
    html = context.div 'data-dojo-type' => 'dojox.data.JsonRestStore',
                       'jsId'           => 'search_matches',
                       'idAttribute'    => 'drug',
                       'target'         => target
    html << super(context)
  end
end
module SearchBarMethods
	def search_type(model, session=@session)
		select = HtmlGrid::Select.new(:search_type, model, @session, self)
		if(@lookandfeel.respond_to?(:search_type_selection))
			select.valid_values = @lookandfeel.search_type_selection
		end
		select.set_attribute('onChange', 'this.form.onsubmit();')
		select.selected = @session.persistent_user_input(:search_type)
		select
	end
end
class SelectSearchForm < HtmlGrid::DivForm
  include SearchBarMethods
	COMPONENTS = {
		[0,0,0]	=>	:search_query,
		[0,0,1]	=>	:search_type,
	}
	SYMBOL_MAP = {
		:search_query	=>	View::SearchBar,	
	}
	LEGACY_INTERFACE = false
	EVENT = :search
	FORM_METHOD = 'GET'
end
class SearchForm < HtmlGrid::DivForm
  CSS_CLASS = 'right'
	COMPONENTS = {
		[0,0,0]	=>	:search_query,
		[0,0,1]	=>	:submit,
	}
	EVENT = :search
	FORM_METHOD = 'GET'
	SYMBOL_MAP = {
		:search_query		=>	View::SearchBar,	
	}
end
	end
end
