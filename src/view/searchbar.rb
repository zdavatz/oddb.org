#!/usr/bin/env ruby

# ODDB::View::SearchBar -- oddb.org -- 03.06.2013 -- yasaka@ywesee.com
# ODDB::View::SearchBar -- oddb.org -- 19.01.2012 -- mhatakeyama@ywesee.com
# ODDB::View::SearchBar -- oddb.org -- 22.11.2002 -- hwyss@ywesee.com

require "view/form"
require "htmlgrid/divform"
require "htmlgrid/inputtext"
require "htmlgrid/select"

module ODDB
  module View
    GET_TO_JS = %(
function get_to(url) {
  var url2 = url.replace('/,','/').replace(/\\?$/,'').replace('\\?,', ',').replace('ean,', 'ean/').replace(/\\?$/, '');
  console.log('get_to window.top.location.replace url '+ url + ' url2 ' + url2);
  if (window.location.href == url2 || window.top.location.href == url2) { return; }
  var form = document.createElement("form");
  form.setAttribute("method", "GET");
  form.setAttribute("action", url2);
  document.body.appendChild(form);
  form.submit();
}

)

    module SearchBarMethods
      def search_type(model, session = @session)
        select = HtmlGrid::Select.new(:search_type, model, @session, self)
        if @lookandfeel.respond_to?(:search_type_selection)
          select.valid_values = @lookandfeel.search_type_selection
        end
        # Avoid displaying a select pull down if only one value is offered
        if select.valid_values and select.valid_values.size == 1
          @session.set_persistent_user_input(:search_type, select.valid_values.first)
          return
        end
        name = "search_query" # name of input field
        val = @session.lookandfeel.lookup(name)
        progressbar = ""
        if respond_to?(:progress_bar)
          progressbar = "setTimeout('show_progressbar(\\'searchbar\\')', 10);"
        end
        submit = @lookandfeel._event_url(@container.event, ["search", "zone", @session.zone, name, ""]) if @container
        @lookandfeel.disabled?(:best_result) ? nil : " + '#best_result'"
        script = <<~JS
          var query = this.form.#{name}.value;
            console.log('#{__LINE__}: query.submit #{val} query is: '+query);
          #{GET_TO_JS}
          if (query != "#{val}" && query != "") {
            #{progressbar}
            var href = '#{submit}' + encodeURIComponent(#{name}.value.replace(/\\//, '%2F'));
            href += '/search_type/' + this.value;
            var price_or_combined  =  ( (this.value.indexOf('st_oddb')) > 0 || (this.value.indexOf('st_combined') ))
            if ( (href.indexOf('#best_result') == -1) && price_or_combined != -1 ) {
              href += '&#best_result';
            }
            get_to(href);
          }
        JS
        select.set_attribute("onChange", script)
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
        id = "#{target}_searchbar"
        url = @session.create_search_url(:home_interactions)
        val = @session.lookandfeel.lookup(:add_drug)
        if @container.respond_to?(:progress_bar)
          progressbar = "setTimeout('show_progressbar('#{id}')', 10);"
        end
        @container.additional_javascripts.push <<~EOS
          #{GET_TO_JS}
          function xhrGet(arg) {
            var new_url = '#{url}';
            var ean13 = arg.match(/(^\\d{13})/);
            console.log('xhrGet arg '+ arg + ' ean13 ' + ean13 + ' for new_url ' + new_url);
            if(ean13) {
              ean13 = ean13[0];
              var id = 'drugs';
              new_url = new_url + ',' + ean13;
              console.log('xhrGet call replace_element id '+ id + ' new_url '+new_url);
              replace_element(id, new_url)
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
                console.log('selectXhrRequest: window.location.href ' + window.location.href + ' searchbar: ' + searchbar.value);
                var ean13 = (searchbar.value.match(/^(\\d{13})$/)||[])[1];
                var path = window.location.href;
                if (path.match(/home_interactions/)) {
                  if (path.match(/\\/$/)) {
                    path = path + ean13;
                  } else if (path.match(/home_interactions$/)) {
                    path = path +  '/' + ean13;
                  } else {
                    path = path +  ',' + ean13;
                  }
                  get_to(path.replace('?/','/') );
                } else if (path.match(/rezept/))
                {
                  if (path.match(/ean/) == null) {
                    if (path.match(/\\/$/)) {
                      path = path +  'ean/' + ean13;
                    } else {
                      path = path +  '/ean/' + ean13;
                  }
                  } else { 
                     path = path + ',' + ean13;
                  }
                  searchbar.value = '';
                  get_to(path.replace('?/','/'));
                } else { // neither home_interactions nor rezept
                  xhrGet(searchbar.value);
                  searchbar.value = '';
                }
              } else console.log('selectXhrRequest cannot find enough information');
            }
          }
          require(['dojo/ready'], function(ready) {
            ready(function() {
              initMatches();
            });
          });
        EOS
        @attributes.update "data-dojo-type" => "dijit.form.ComboBox",
          "jsId"           => "#{target}_searchbar",
          "id"             => "#{target}_searchbar",
          "store"          => "search_matches",
          "queryExpr"      => "${0}",
          "searchAttr"     => "search_query", # name
          "labelAttr"      => "drug",         # label
          "hasDownArrow"   => "false",
          "autoComplete"   => "false",
          "onChange"       => "selectXhrRequest",
          "value"          => @session.persistent_user_input(:search_query)
      end

      def to_html(context, *args)
        args = []
        if @container.respond_to?(:index_name) && (index = @container.index_name)
          args.push :index_name, index
        end
        @session.set_persistent_user_input(:drugs, @session.choosen_drugs)
        target = @session.lookandfeel._event_url(:ajax_matches, args)
        html = context.div "data-dojo-type" => "dojox.data.JsonRestStore",
          "jsId"           => "search_matches",
          "idAttribute"    => "drug",
          "target"         => target
        html << super(context)
      end
    end

    class SearchBar < HtmlGrid::InputText
      def init
        super
        val = @lookandfeel.lookup(@name)
        if @value.nil? || @value.is_a?(StandardError)
          txt_val = if @session.respond_to?(:persistent_user_input) and
              @session.persistent_user_input(@name)
                    end || val
          @attributes.store("value", txt_val)
        end
        @attributes.update({
          "onFocus" => "if (value=='#{val}') { value='' };",
          "onBlur" => "if (value=='') { value='#{val}' };",
          "id" => "searchbar"
        })
        if @session.event == :interaction_chooser # remove ean13 text
          @attributes.update({"value" => val})
        end
        submit = @lookandfeel._event_url(@container.event, ["zone", @session.zone, @name, ""])
        # show dojo ProgressBar
        timer = @container.respond_to?(:progress_bar) ? "  setTimeout('show_progressbar(\\'searchbar\\')', 10);" : nil
        # instead of document.location.
        # because location stops gif animation.
        param = @lookandfeel.disabled?(:best_result) ? nil : " + '#best_result'"
        self.onsubmit = <<~JS
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
        @searchbar_id ||= "searchbar"
        @label_attr ||= ""
        id = @searchbar_id
        val = @lookandfeel.lookup(@name)
        progressbar = ""
        if @container.respond_to?(:progress_bar)
          progressbar = "setTimeout('show_progressbar(\\'widget_searchbar\\')', 10);"
        end
        @container.additional_javascripts.push <<~EOS
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
            if (popup && (popup.style.overflowX.match(/auto/) || popup.style.overflowX.match(/hidden/)) && searchbar.value != '') {
              searchbar.form.submit();
            }
          }
          require(['dojo/ready'], function(ready) {
            ready(function() {
              initMatches();
            });
          });
        EOS
        @attributes.update "data-dojo-type" => "dijit.form.ComboBox",
          "jsId"           => @searchbar_id,
          "id"             => @searchbar_id,
          "store"          => "search_matches",
          "queryExpr"      => "${0}",
          "searchAttr"     => "search_query", # name
          "labelAttr"      => @label_attr,    # label
          "hasDownArrow"   => "false",
          "autoComplete"   => "false",
          "onChange"       => "selectSubmit",
          "value"          => @session.persistent_user_input(:search_query) || val
      end

      def to_html(context, *args)
        args = []
        if @container.respond_to?(:index_name) && (index = @container.index_name)
          args.push :index_name, index
        end
        target = @session.lookandfeel._event_url(:ajax_matches, args)
        html = context.div "data-dojo-type" => "dojox.data.JsonRestStore",
          "jsId"           => "search_matches",
          "idAttribute"    => "search_query",
          "target"         => target
        html << super(context)
      end
    end

    class InteractionSearchBar < AutocompleteSearchBar # home_interactions
      def init
        @searchbar_id = "interaction_searchbar"
        @label_attr = "drug"
        super
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
        [0, 0, 0] => :search_query,
        [0, 0, 1] => :search_type
      }
      SYMBOL_MAP = {
        search_query: View::SearchBar
      }
      LEGACY_INTERFACE = false
      EVENT = :search
      FORM_METHOD = "GET"
    end

    class SearchForm < HtmlGrid::DivForm
      CSS_CLASS = "right"
      COMPONENTS = {
        [0, 0, 0] => :search_query,
        [0, 0, 1] => :submit
      }
      EVENT = :search
      FORM_METHOD = "GET"
      SYMBOL_MAP = {
        search_query: View::SearchBar
      }
    end
  end
end
