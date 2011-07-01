#!/usr/bin/env ruby
# ODDB::View::Drugs::TestSearch -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/drugs/search'


module ODDB
  module View
    Copyright::ODDB_VERSION = 'version'
    module Drugs

class TestSearch < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @app     = flexmock('app')
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :enabled?   => nil,
                        :attributes => {},
                        :resource   => 'resource',
                        :disabled?  => nil,
                        :_event_url => '_event_url',
                        :zones      => 'zones',
                        :base_url   => 'base_url',
                        :navigation => 'navigation',
                        :zone_navigation => 'zone_navigation',
                        :direct_event    => 'direct_event'
                       )
    user     = flexmock('user', :valid? => nil)
    @session = flexmock('session', 
                        :app     => @app,
                        :user    => user,
                        :sponsor => user,
                        :zone    => 'zone',
                        :lookandfeel => @lnf,
                        :valid_values => ['channel'],
                        :persistent_user_input => 'persistent_user_input'
                       )
    @model   = flexmock('model')
    @view    = ODDB::View::Drugs::Search.new(@model, @session)
  end
  def test_other_html_headers
    assert_equal('', @view.other_html_headers('context'))
  end
  def test_other_html_headers__enabled
    flexmock(@lnf, 
             :enabled? => true,
             :resource_global => 'resource_global'
            )
    context = flexmock('context', 
                       :script => 'script',
                       :style  => 'style',
                       :link   => 'link'
                      )
    expected = 'scriptscriptscriptscriptstylescriptlink'
    assert_equal(expected, @view.other_html_headers(context))
  end
end

    end # Drugs
  end # View
end # ODDB
