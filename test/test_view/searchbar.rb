#!/usr/bin/env ruby

# ODDB::Vewi::TestSearchBar -- oddb.org -- 03.06.2013 -- yasaka@ywesee.com
# ODDB::Vewi::TestSearchBar -- oddb.org -- 27.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "view/searchbar"
require "htmlgrid/select"
require "util/session"
require "rack/test"

module ODDB
  module View
    class TestSearchBar < Minitest::Test
      def setup
        @container = flexmock("container", event: "event")
        @lnf = flexmock("lookandfeel",
          lookup: "lookup",
          attributes: {},
          _event_url: "_event_url",
          disabled?: nil)
        @session = flexmock("session",
          flavor: "gcc",
          lookandfeel: @lnf,
          zone: "zone",
          event: "search")
        @model = flexmock("model")
        @inputtext = ODDB::View::SearchBar.new("name", @model, @session, @container)
      end

      def test_init
        expected = %(
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


if (name.value!='lookup') {

  var href = '_event_url' + encodeURIComponent(name.value.replace(/\\//, '%2F'));
  if (this.search_type) {
    href += '/search_type/' + this.search_type.value + '#best_result';
  }
  get_to(href);
};
return false;
)
        assert_equal(expected, @inputtext.init)
      end
    end

    class TestAutocompleteSearchBar < Minitest::Test
      def setup
        @container = flexmock("container", additional_javascripts: [])
        @lnf = flexmock("lookandfeel",
          lookup: "lookup",
          attributes: {},
          _event_url: "_event_url")
        @session = flexmock("session",
          flavor: "gcc",
          lookandfeel: @lnf,
          persistent_user_input: "persistent_user_input")
        @model = flexmock("model")
        @inputtext = ODDB::View::AutocompleteSearchBar.new("name", @model, @session, @container)
      end

      def test_init
        # AutocompleteSearchBar now uses vanilla JS autocomplete instead of Dojo
        # init sets up @attributes with id, autocomplete, and value
        attrs = @inputtext.instance_variable_get(:@attributes)
        assert_equal("searchbar", attrs["id"])
        assert_equal("off", attrs["autocomplete"])
        assert_equal("persistent_user_input", attrs["value"])
      end

      def test_to_html
        context = flexmock("context",
          div: "div",
          input: "input")
        flexmock(@container, index_name: "index_name")
        assert_equal("inputdiv", @inputtext.to_html(context))
      end
    end

    class TestSelectSearchForm < Minitest::Test
      def setup
        @lnf = flexmock("lookandfeel",
          lookup: "lookup",
          attributes: {},
          _event_url: "_event_url",
          disabled?: nil,
          base_url: "base_url",
          search_type_selection: "search_type_selection")
        @session = flexmock("session",
          lookandfeel: @lnf,
          zone: "zone",
          event: "search",
          persistent_user_input: "persistent_user_input",
          get_cookie_input: "get_cookie_input")
        @model = flexmock("model")
        @form = ODDB::View::SelectSearchForm.new(@model, @session)
      end

      def test_search_type
        assert_kind_of(HtmlGrid::Select, @form.search_type(@model, @session))
      end
    end
  end
end
