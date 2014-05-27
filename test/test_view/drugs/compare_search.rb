#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Drugs::TestCompareSearch -- oddb.org -- 29.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/drugs/centeredsearchform'
require 'view/drugs/compare_search'

module ODDB
  module View
    module Drugs

class TestCompareSearchForm <Minitest::Test
  include FlexMock::TestCase
  def setup
    @container = flexmock('container', :additional_javascripts => [])
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :enabled?   => nil,
                        :attributes => {},
                        :base_url   => 'base_url'
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :persistent_user_input => 'persistent_user_input',
                        :flavor => 'flavor',
                       )
    @model   = flexmock('model')
    @form    = ODDB::View::Drugs::CompareSearchForm.new(@model, @session, @container)
  end
  def test_init
    expected = ["require([\"dojo/parser\", \"dijit/ProgressBar\"], function(){
  show_progressbar = function(searchbar_id){
    var progressBar = searchProgressBar.set({
      style: \"display:block;\",
      value: Infinity,
    });
    var searchbar = dojo.byId(searchbar_id);
    searchbar.style.display = \"none\";
  };
});
", "function initMatches() {
  var searchbar = dojo.byId('searchbar');
  dojo.connect(searchbar, 'onkeypress', function(e) {
    if(e.keyCode == dojo.keys.ENTER) {
      setTimeout('show_progressbar(\\'widget_searchbar\\')', 10);
      searchbar.form.submit();
    }
  });
  dojo.connect(searchbar, 'onfocus', function(e) {
    if(searchbar.value == 'lookup')          { searchbar.value = ''; }
    if(searchbar.value.match(/^(\\d{13})$/)) { searchbar.value = ''; }
  });
  dojo.connect(searchbar, 'onblur', function(e) {
    if(searchbar.value == '') { searchbar.value = 'lookup'; }
  });
}
function selectSubmit() {
  var popup = dojo.byId('searchbar_popup');
  var searchbar = dojo.byId('searchbar');
  if (popup && popup.style.overflowX.match(/auto/) && searchbar.value != '') {
    setTimeout('show_progressbar(\\'widget_searchbar\\')', 10);
    searchbar.form.submit();
  }
}
require(['dojo/ready'], function(ready) {
  ready(function() {
    initMatches();
  });
});
", "require([\"dojo/parser\", \"dijit/ProgressBar\"], function(){
  show_progressbar = function(searchbar_id){
    var progressBar = searchProgressBar.set({
      style: \"display:block;\",
      value: Infinity,
    });
    var searchbar = dojo.byId(searchbar_id);
    searchbar.style.display = \"none\";
  };
});
"]
    assert_equal(expected, @form.init)
  end
end

    end # Drugs
  end # View
end # ODDB

