#!/usr/bin/env ruby
# ODDB::Vewi::TestSearchBar -- oddb.org -- 27.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/searchbar'
require 'htmlgrid/select'

module ODDB
  module View
    class TestSearchBar < Test::Unit::TestCase
      include FlexMock::TestCase
      def setup
        @container = flexmock('container', :event => 'event')
        @lnf       = flexmock('lookandfeel', 
                              :lookup     => 'lookup',
                              :attributes => {},
                              :_event_url => '_event_url',
                              :disabled?  => nil
                             )
        @session   = flexmock('session', 
                              :lookandfeel => @lnf,
                              :zone        => 'zone'
                             )
        @model     = flexmock('model')
        @inputtext = ODDB::View::SearchBar.new('name', @model, @session, @container)
      end
      def test_init
        expected = "if(name.value!='lookup'){var href = '_event_url'+encodeURIComponent(name.value.replace(/\\//, '%2F'));if(this.search_type)href += '/search_type/' + this.search_type.value;href += '#best_result';document.location.href=href; } return false"
        assert_equal(expected, @inputtext.init)
      end
    end

    class TestAutocompleteSearchBar < Test::Unit::TestCase
      include FlexMock::TestCase
      def setup
        @container = flexmock('container', :additional_javascripts => [])
        @lnf       = flexmock('lookandfeel', 
                              :lookup     => 'lookup',
                              :attributes => {},
                              :_event_url => '_event_url'
                             )
        @session   = flexmock('session', 
                              :lookandfeel           => @lnf,
                              :persistent_user_input => 'persistent_user_input'
                             )
        @model     = flexmock('model')
        @inputtext = ODDB::View::AutocompleteSearchBar.new('name', @model, @session, @container)
      end
      def test_init
        expected = {
        "queryExpr"    => "${0}", 
        "name"         => "name", 
        "dojotype"     => "dijit.form.ComboBox", 
        "searchAttr"   => "search_query", 
        "jsId"         => "searchbar", 
        "type"         => "text", 
        "id"           => "searchbar", 
        "store"        => "search_matches", 
        "hasDownArrow" => "false", 
        "value"        => "persistent_user_input", 
        "autoComplete" => "false"
        }
        assert_equal(expected, @inputtext.init)
      end
      def test_to_html
        context = flexmock('context', 
                           :div   => 'div',
                           :input => 'input'
                          )
        flexmock(@container, :index_name => 'index_name') 
        assert_equal('divinput', @inputtext.to_html(context))
      end
    end
    
    class TestSelectSearchForm < Test::Unit::TestCase
      include FlexMock::TestCase
      def setup
        @lnf     = flexmock('lookandfeel', 
                            :lookup     => 'lookup',
                            :attributes => {},
                            :_event_url => '_event_url',
                            :disabled?  => nil,
                            :base_url   => 'base_url',
                            :search_type_selection => 'search_type_selection'
                           )
        @session = flexmock('session', 
                            :lookandfeel => @lnf,
                            :zone        => 'zone',
                            :persistent_user_input => 'persistent_user_input'
                           )
        @model   = flexmock('model')
        @form    = ODDB::View::SelectSearchForm.new(@model, @session)
      end
      def test_search_type
        assert_kind_of(HtmlGrid::Select, @form.search_type(@model, @session))
      end
    end
  end
end
