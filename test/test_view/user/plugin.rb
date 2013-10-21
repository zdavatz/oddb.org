#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::User::TestPlugin -- oddb.org -- 17.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/user/plugin'
require 'view/logo'

module ODDB
  module View
    class Session
      DEFAULT_FLAVOR = 'gcc'
    end
    Copyright::ODDB_VERSION = 'oddb_version'
    module User

class TestPluginInnerComposite <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :language   => 'language',
                          :resource_global => 'resource_global'
                         )
    @session   = flexmock('session', :lookandfeel => @lnf)
    @model     = flexmock('model')
    @composite = ODDB::View::User::PluginInnerComposite.new(@model, @session)
  end
  def test_plugin_javascript
    assert_kind_of(HtmlGrid::Link, @composite.plugin_javascript(@model, @session))
  end
  def test_plugin_description
    assert_kind_of(HtmlGrid::Link, @composite.plugin_description(@model, @session))
  end
  def test_plugin_description__language_de
    flexmock(@lnf, :language => 'de')
    assert_kind_of(HtmlGrid::Link, @composite.plugin_description(@model, @session))
  end
  def test_plugin_description__language_fr
    flexmock(@lnf, :language => 'fr')
    assert_kind_of(HtmlGrid::Link, @composite.plugin_description(@model, @session))
  end
  def test_plugin_description__language_en
    flexmock(@lnf, :language => 'en')
    assert_kind_of(HtmlGrid::Link, @composite.plugin_description(@model, @session))
  end
end

class TestPlugin <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :language   => 'language',
                          :enabled?   => nil,
                          :resource   => 'resource',
                          :zones      => ['zones'],
                          :disabled?  => nil,
                          :_event_url => '_event_url',
                          :navigation => ['navigation'],
                          :zone_navigation => ['zone_navigation'],
                          :resource_global => 'resource_global',
                          :direct_event    => 'direct_event'
                         )
    user       = flexmock('user', :valid? => nil)
    sponsor    = flexmock('sponsor', :valid? => nil)
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :user        => user,
                          :sponsor     => sponsor,
                          :flavor      => 'flavor',
                         )
    @model     = flexmock('model')
#    skip("Leads to ODDB::View::PopupLogo::Session ODDB::View::PopupLogo::Session")
    @plugin = ODDB::View::User::Plugin.new(@model, @session)
  end
  def test_html_head
    context = flexmock('context', 
                       :scrip => 'script',
                       :head  => 'head'
                      )
    assert_equal('head', @plugin.html_head(context))
  end
end
    end # User
  end # View
end # ODDB
