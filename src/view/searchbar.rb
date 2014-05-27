#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::SearchBar -- oddb.org -- 03.06.2013 -- yasaka@ywesee.com
# ODDB::View::SearchBar -- oddb.org -- 19.01.2012 -- mhatakeyama@ywesee.com
# ODDB::View::SearchBar -- oddb.org -- 22.11.2002 -- hwyss@ywesee.com

require 'view/form'
require 'htmlgrid/divform'
require 'htmlgrid/inputtext'

module ODDB
  module View
  GET_TO_JS = %(
function get_to(url) {
  var url2 = url.replace(/(\\d{13})[/,]+(\\d{13})/, '$1,$2').replace('/,','/').replace(/\\?$/,'').replace('\\?,', ',');
  if (window.location.href ==  url2) { return; }
  var form = document.createElement("form");
  form.setAttribute("method", "GET");
  form.setAttribute("action", url2);
  document.body.appendChild(form);
  form.submit();
}
)

module SearchBarMethods
  def search_type(model, session=@session)
    select = HtmlGrid::Select.new(:search_type, model, @session, self)
    if(@lookandfeel.respond_to?(:search_type_selection))
      select.valid_values = @lookandfeel.search_type_selection
    end
    name = 'search_query' # name of input field
    val  = @session.lookandfeel.lookup(name)
    progressbar = ''
    if self.respond_to?(:progress_bar)
      progressbar = "setTimeout('show_progressbar(\\'searchbar\\')', 10);"
    end
    script = <<-JS
var query = this.form.#{name}.value;
if (query != "#{val}" && query != "") {
  #{progressbar}
  this.form.submit();
}
    JS
    select.set_attribute('onChange', script)
    if type = @session.get_cookie_input(:search_type)
      select.selected = type
    end
    if type = @session.persistent_user_input(:search_type)
      select.selected = type
    end
    select
  end
end
module InstantSearchBarMethods
  def xhr_request_init(keyword)
    target = keyword.intern
    id  = "#{target}_searchbar"
    drugs = @session.persistent_user_input(:drugs)
    drugs = drugs.keys if drugs
    ean13 = @session.persistent_user_input(:ean)
    base_url = @lookandfeel.base_url
    splitted = @session.request_path.split(/#{base_url}\/(home_interactions|rezept\/ean)\/*/)
    url = @lookandfeel._event_url(target == 'prescription' ? 'rezept/ean' : 'home_interactions', [])
    url += drugs.join(',') if drugs
    val = @session.lookandfeel.lookup(:add_drug)
    progressbar = ""
    if @container.respond_to?(:progress_bar)
      progressbar = "setTimeout('show_progressbar(\'#{id}\')', 10);"
    end
    @container.additional_javascripts.push <<-EOS
#{GET_TO_JS}
function xhrGet(arg) {
  var ean13 = (arg.match(/^(\\d{13})$/)||[])[1];
  if(ean13) {
    var id = 'drugs';
    var url = '#{url}';
    if (url.match(/rezept\\/$/)) { url = url + 'ean/'; }
    if (url.match(/(\\d{13})$/))  url = url + ',' + ean13; else url = url + '/' + ean13;
    replace_element(id, url)
  }
}
function initMatches() {
  var searchbar = dojo.byId('#{id}');
  searchbar.value = '#{val}';
  dojo.connect(searchbar, 'onkeypress', function(e) {
    var popup = dojo.byId('#{target}_searchbar_popup');
    if(popup && popup.style.overflowX.match(/auto/) && e.keyCode == dojo.keys.ENTER) {
      #{progressbar}
      xhrGet(searchbar.value);
      searchbar.value = '';
    }
  });
  dojo.connect(searchbar, 'onfocus', function(e) {
    if(searchbar.value == '#{val}')          { searchbar.value = ''; }
    if(searchbar.value.match(/^(\\d{13})$/)) { searchbar.value = ''; }
  });
  dojo.connect(searchbar, 'onblur', function(e) {
    if(searchbar.value == '') { searchbar.value = '#{val}'; }
  });
}
function selectXhrRequest() {
  var popup = dojo.byId('#{target}_searchbar_popup');
  var searchbar = dojo.byId('#{id}');
  if(popup && !popup.style.overflowX.match(/auto/) && searchbar.value != '') {
    #{progressbar}
    if (searchbar && searchbar.value && window.location.href)
    {
      var ean13 = (searchbar.value.match(/^(\\d{13})$/)||[])[1];
      var path = window.location.href;
      xhrGet(searchbar.value);
      searchbar.value = '';
      var found = path.match(/home_interactions|rezept\\/ean/);
      if(found && ean13) {
        if (path.match(/(home_interactions|rezept\\/ean)$/)) (path = path + '/');
        get_to(path + ',' + ean13);
      }
    } else console.log("selectXhrRequest cannot find enough information");
  }
}
require(['dojo/ready'], function(ready) {
  ready(function() {
    initMatches();
  });
});
    EOS
    @attributes.update 'data-dojo-type' => 'dijit.form.ComboBox',
                       'jsId'           => "#{target}_searchbar",
                       'id'             => "#{target}_searchbar",
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
class SearchBar < HtmlGrid::InputText
  def init
    super
    val = @lookandfeel.lookup(@name)
    if(@value.nil? || @value.is_a?(StandardError))
      txt_val = if @session.respond_to?(:persistent_user_input) and
                  @session.persistent_user_input(@name)
                end || val
      @attributes.store('value', txt_val)
    end
    @attributes.update({
      'onFocus' =>  "if (value=='#{val}') { value='' };",
      'onBlur'  =>  "if (value=='') { value='#{val}' };",
      'id'      =>  "searchbar",
    })
    if @session.event == :interaction_chooser # remove ean13 text
      @attributes.update({'value' => val})
    end
    submit = @lookandfeel._event_url(@container.event, ['zone', @session.zone, @name, ''])
    # show dojo ProgressBar
    timer = @container.respond_to?(:progress_bar) ? "  setTimeout('show_progressbar(\\'searchbar\\')', 10);" : nil
    # instead of document.location.
    # because location stops gif animation.
    param = @lookandfeel.disabled?(:best_result) ? nil : " + '#best_result'"
    self.onsubmit = <<-JS
#{GET_TO_JS}
if (#{@name}.value!='#{val}') {
#{timer}
  var href = '#{submit}' + encodeURIComponent(#{@name}.value.replace(/\\//, '%2F'));
  if (this.search_type) {
    href += '/search_type/' + this.search_type.value#{param};
  }
  get_to(href);
};
return false;
    JS
  end
end
class AutocompleteSearchBar < HtmlGrid::InputText
  def init
    super
    @searchbar_id ||= 'searchbar'
    @label_attr   ||= ''
    id  = @searchbar_id
    if @session.flavor == 'just-medical' and
       @session.zone == :interactions
      val = @lookandfeel.lookup(:search_query_interactions)
    else
      val = @lookandfeel.lookup(@name)
    end
    progressbar = ""
    if @container.respond_to?(:progress_bar)
      progressbar = "setTimeout('show_progressbar(\\'widget_searchbar\\')', 10);"
    end
    @container.additional_javascripts.push <<-EOS
function initMatches() {
  var searchbar = dojo.byId('#{id}');
  dojo.connect(searchbar, 'onkeypress', function(e) {
    if(e.keyCode == dojo.keys.ENTER) {
      #{progressbar}
      searchbar.form.submit();
    }
  });
  dojo.connect(searchbar, 'onfocus', function(e) {
    if(searchbar.value == '#{val}')          { searchbar.value = ''; }
    if(searchbar.value.match(/^(\\d{13})$/)) { searchbar.value = ''; }
  });
  dojo.connect(searchbar, 'onblur', function(e) {
    if(searchbar.value == '') { searchbar.value = '#{val}'; }
  });
}
function selectSubmit() {
  var popup = dojo.byId('#{id}_popup');
  var searchbar = dojo.byId('#{id}');
  if (popup && popup.style.overflowX.match(/auto/) && searchbar.value != '') {
    #{progressbar}
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
                       'jsId'           => @searchbar_id,
                       'id'             => @searchbar_id,
                       'store'          => 'search_matches',
                       'queryExpr'      => '${0}',
                       'searchAttr'     => 'search_query', # name
                       'labelAttr'      => @label_attr,    # label
                       'hasDownArrow'   => 'false',
                       'autoComplete'   => 'false',
                       'onChange'       => 'selectSubmit',
                       'value'          => @session.persistent_user_input(:search_query) || val
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
class InteractionSearchBar < AutocompleteSearchBar # home_interactions
  def init
    @searchbar_id = 'interaction_searchbar'
    @label_attr   = 'drug'
    super
  end
end
class PrescriptionDrugSearchBar < HtmlGrid::InputText
  include InstantSearchBarMethods
  def init
    super
    xhr_request_init(:prescription)
  end
end
class FachinfoSearchDrugSearchBar < HtmlGrid::InputText
  include InstantSearchBarMethods
  def init
    super
    xhr_request_init(:fachinfo_search)
  end
end
class InteractionChooserBar < HtmlGrid::InputText  # interaction_chooser
  include InstantSearchBarMethods
  def init
    super
    xhr_request_init(:interaction_chooser)
  end
end
class SelectSearchForm < HtmlGrid::DivForm
  include SearchBarMethods
  COMPONENTS = {
    [0,0,0] => :search_query,
    [0,0,1] => :search_type,
  }
  SYMBOL_MAP = {
    :search_query => View::SearchBar,
  }
  LEGACY_INTERFACE = false
  EVENT = :search
  FORM_METHOD = 'GET'
end
class SearchForm < HtmlGrid::DivForm
  CSS_CLASS = 'right'
  COMPONENTS = {
    [0,0,0] => :search_query,
    [0,0,1] => :submit,
  }
  EVENT = :search
  FORM_METHOD = 'GET'
  SYMBOL_MAP = {
    :search_query => View::SearchBar,
  }
end
  end
end
