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
        url = @session.create_search_url
        val = @session.lookandfeel.lookup(:add_drug)
        ajax_args = []
        if @container.respond_to?(:index_name) && (index = @container.index_name)
          ajax_args.push :index_name, index
        end
        ajax_url = @session.lookandfeel._event_url(:ajax_matches, ajax_args)
        @container.additional_javascripts.push <<~EOS
          #{GET_TO_JS}
          var _ac_dropdown = null;
          var _ac_activeIdx = -1;
          var _ac_selectDrug = null;

          // Inline onkeydown handler - fires before form submission
          window._acKeydown = function(e) {
            var dropdown = _ac_dropdown;
            if (!dropdown) return true;
            var items = dropdown.querySelectorAll('.ac-item');
            var visible = dropdown.style.display === 'block';
            if (e.key === 'Enter') {
              if (visible && items.length > 0) {
                var selected = (_ac_activeIdx >= 0 && items[_ac_activeIdx]) ? items[_ac_activeIdx] : items[0];
                dropdown.style.display = 'none';
                _ac_selectDrug(selected.getAttribute('data-ean'));
              }
              return false; // prevent form submission
            }
            if (!visible || items.length === 0) return true;
            if (e.key === 'ArrowDown') {
              e.preventDefault();
              _ac_activeIdx = Math.min(_ac_activeIdx + 1, items.length - 1);
            } else if (e.key === 'ArrowUp') {
              e.preventDefault();
              _ac_activeIdx = Math.max(_ac_activeIdx - 1, -1);
            } else if (e.key === 'Escape') {
              dropdown.style.display = 'none';
              return true;
            } else { return true; }
            items.forEach(function(el) { el.classList.remove('ac-active'); });
            if (_ac_activeIdx >= 0 && items[_ac_activeIdx]) { items[_ac_activeIdx].classList.add('ac-active'); items[_ac_activeIdx].scrollIntoView({block:'nearest'}); }
            return false;
          };

          document.addEventListener('DOMContentLoaded', function() {
            var searchbar = document.getElementById('#{id}');
            var dropdown = document.getElementById('#{id}_dropdown');
            if (!searchbar || !dropdown) return;
            var ajaxUrl = '#{ajax_url}';
            var baseUrl = '#{url}';
            var placeholder = '#{val}';
            var debounceTimer = null;
            _ac_dropdown = dropdown;
            _ac_activeIdx = -1;

            searchbar.value = placeholder;

            _ac_selectDrug = function(ean13) {
              if (!ean13) return;
              var path = window.location.href;
              if (path.match(/home_interactions/)) {
                if (path.match(/\\/$/)) {
                  path = path + ean13;
                } else if (path.match(/home_interactions$/)) {
                  path = path + '/' + ean13;
                } else {
                  path = path + ',' + ean13;
                }
              } else if (path.match(/rezept/)) {
                if (path.match(/ean/) == null) {
                  path = path + (path.match(/\\/$/) ? '' : '/') + 'ean/' + ean13;
                } else {
                  path = path + ',' + ean13;
                }
              } else {
                path = baseUrl + ',' + ean13;
              }
              get_to(path.replace('?/','/'));
            };

            function showDropdown(items) {
              dropdown.innerHTML = '';
              _ac_activeIdx = -1;
              if (items.length === 0) { dropdown.style.display = 'none'; return; }
              items.forEach(function(item, i) {
                var div = document.createElement('div');
                div.className = 'ac-item';
                div.textContent = item.drug;
                div.setAttribute('data-ean', item.search_query);
                div.addEventListener('mousedown', function(e) {
                  e.preventDefault();
                  _ac_selectDrug(item.search_query);
                });
                dropdown.appendChild(div);
              });
              dropdown.style.display = 'block';
            }

            function fetchMatches(query) {
              var url = ajaxUrl + '/search_query/' + encodeURIComponent(query);
              fetch(url).then(function(r) { return r.json(); }).then(function(data) {
                showDropdown(data);
              }).catch(function() { dropdown.style.display = 'none'; });
            }

            searchbar.addEventListener('input', function() {
              var q = searchbar.value.trim();
              if (q.length < 2 || q === placeholder) {
                dropdown.style.display = 'none'; return;
              }
              clearTimeout(debounceTimer);
              debounceTimer = setTimeout(function() { fetchMatches(q); }, 200);
            });

            searchbar.addEventListener('focus', function() {
              if (searchbar.value === placeholder) searchbar.value = '';
            });
            searchbar.addEventListener('blur', function() {
              setTimeout(function() { dropdown.style.display = 'none'; }, 150);
              if (searchbar.value === '') searchbar.value = placeholder;
            });
          });
        EOS
        @attributes.update(
          "id" => id,
          "autocomplete" => "off",
          "onkeydown" => "return window._acKeydown ? window._acKeydown(event) : true;"
        )
      end

      def to_html(context, *args)
        @session.set_persistent_user_input(:drugs, @session.choosen_drugs)
        id = @attributes["id"]
        html = super(context)
        html << context.div("id" => "#{id}_dropdown", "class" => "ac-dropdown") { "" }
        html
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
        ajax_args = []
        if @container.respond_to?(:index_name) && (index = @container.index_name)
          ajax_args.push :index_name, index
        end
        ajax_url = @session.lookandfeel._event_url(:ajax_matches, ajax_args)
        @container.additional_javascripts.push <<~EOS
          document.addEventListener('DOMContentLoaded', function() {
            var searchbar = document.getElementById('#{id}');
            var dropdown = document.getElementById('#{id}_dropdown');
            if (!searchbar || !dropdown) return;
            var ajaxUrl = '#{ajax_url}';
            var placeholder = '#{val}';
            var debounceTimer = null;
            var activeIdx = -1;
            var labelAttr = '#{@label_attr}';

            function showDropdown(items) {
              dropdown.innerHTML = '';
              activeIdx = -1;
              if (items.length === 0) { dropdown.style.display = 'none'; return; }
              items.forEach(function(item) {
                var div = document.createElement('div');
                div.className = 'ac-item';
                div.textContent = labelAttr && item[labelAttr] ? item[labelAttr] : item.search_query;
                div.setAttribute('data-value', item.search_query);
                div.addEventListener('mousedown', function(e) {
                  e.preventDefault();
                  searchbar.value = item.search_query;
                  dropdown.style.display = 'none';
                  searchbar.form.submit();
                });
                dropdown.appendChild(div);
              });
              dropdown.style.display = 'block';
            }

            function fetchMatches(query) {
              var url = ajaxUrl + '/search_query/' + encodeURIComponent(query);
              fetch(url).then(function(r) { return r.json(); }).then(function(data) {
                showDropdown(data);
              }).catch(function() { dropdown.style.display = 'none'; });
            }

            searchbar.addEventListener('input', function() {
              var q = searchbar.value.trim();
              if (q.length < 2 || q === placeholder) {
                dropdown.style.display = 'none'; return;
              }
              clearTimeout(debounceTimer);
              debounceTimer = setTimeout(function() { fetchMatches(q); }, 200);
            });

            searchbar.addEventListener('keydown', function(e) {
              var items = dropdown.querySelectorAll('.ac-item');
              if (e.key === 'ArrowDown') {
                e.preventDefault();
                activeIdx = Math.min(activeIdx + 1, items.length - 1);
              } else if (e.key === 'ArrowUp') {
                e.preventDefault();
                activeIdx = Math.max(activeIdx - 1, 0);
              } else if (e.key === 'Enter') {
                e.preventDefault();
                if (activeIdx >= 0 && items[activeIdx]) {
                  searchbar.value = items[activeIdx].getAttribute('data-value');
                  dropdown.style.display = 'none';
                  searchbar.form.submit();
                } else if (items.length > 0) {
                  searchbar.value = items[0].getAttribute('data-value');
                  dropdown.style.display = 'none';
                  searchbar.form.submit();
                }
                return;
              } else if (e.key === 'Escape') {
                dropdown.style.display = 'none'; return;
              } else { return; }
              items.forEach(function(el) { el.classList.remove('ac-active'); });
              if (items[activeIdx]) { items[activeIdx].classList.add('ac-active'); items[activeIdx].scrollIntoView({block:'nearest'}); }
            });

            searchbar.addEventListener('keypress', function(e) {
              if (e.key === 'Enter') { e.preventDefault(); }
            });
            searchbar.addEventListener('focus', function() {
              if (searchbar.value === placeholder) searchbar.value = '';
            });
            searchbar.addEventListener('blur', function() {
              setTimeout(function() { dropdown.style.display = 'none'; }, 150);
              if (searchbar.value === '') searchbar.value = placeholder;
            });
          });
        EOS
        @attributes.update(
          "id" => @searchbar_id,
          "autocomplete" => "off",
          "value" => @session.persistent_user_input(:search_query) || val
        )
      end

      def to_html(context, *args)
        id = @attributes["id"]
        html = super(context)
        html += context.div("id" => "#{id}_dropdown", "class" => "ac-dropdown") { "" }
        html
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
