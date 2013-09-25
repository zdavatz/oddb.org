#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestPlugin -- 21.06.2011 -- mhatakeyama@ywesee.com
# ODDB::TestPlugin -- oddb -- 30.05.2003 -- hwyss@ywesee.com 

#$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'plugin/plugin'
require 'fileutils'

module ODDB
  class Plugin
    class SessionStub
      class Session
        DEFAULT_FLAVOR = 'default_flavor'
      end
    end
  end

  class TestSessionStub <Minitest::Test
    include FlexMock::TestCase
    def setup
      @app     = flexmock('app', :get_currency_rate => 'get_currency_rate')
      @session = ODDB::Plugin::SessionStub.new(@app)
    end
    def test_get_currency_rate
      assert_equal('get_currency_rate', @session.get_currency_rate('currency'))
    end
  end

  class TestPlugin <Minitest::Test
    include FlexMock::TestCase
    def setup
      @app    = flexmock('app')
      @plugin = ODDB::Plugin.new(@app)
    end
    def teardown
      File.delete('/tmp/oddbtest') if File.exist?('/tmp/oddbtest')
      super # to clean up FlexMock
    end
    def test_http_file
      assert_equal(nil, @plugin.http_file('www.oddb.org', '/unknown', '/tmp/oddbtest'))
      assert_equal(true, @plugin.http_file('www.google.ch', '/search?q=generika', '/tmp/oddbtest'))
      assert(File.exist?('/tmp/oddbtest'))
    end
    def test_log_info
      info = @plugin.log_info
      [:report, :change_flags, :recipients].each { |key|
        assert(info.include?(key))
      }
    end
    def test_l10n_sessions
      @plugin.l10n_sessions do |stub|
        assert_kind_of(ODDB::Plugin::SessionStub, stub)
      end
    end
    def test_resolve_link
      model = flexmock('model', 
                       :pointer   => 'pointer',
                       :name_base => 'name_base'
                      )
      expected = "name_base:                                        http://ch.oddb.org/de/gcc/resolve/pointer/pointer "
      assert_equal(expected, @plugin.resolve_link(model))
    end
    def test_resolve_link__else
      model = flexmock('model', :pointer => 'pointer')
      expected = "http://ch.oddb.org/de/gcc/resolve/pointer/pointer "
      assert_equal(expected, @plugin.resolve_link(model))
    end
    def test_resolve_link__error
      model = flexmock('model') do |m|
        m.should_receive(:pointer).and_raise(StandardError)
      end
      expected = "Error creating Link for nil"
      assert_equal(expected, @plugin.resolve_link(model))
    end
=begin
    def test_update_rss_feeds
      view_instance = flexmock('view_instance', :to_html => 'to_html')
      view_klass = flexmock('view_klass', :new => view_instance)
      name = 'name'
      rss_updates = {'name' => name}
      flexmock(@app, 
               :rss_updates => rss_updates,
               :odba_isolated_store => 'odba_isolated_store'
              )
      fh = flexmock('file_handler', 
                    :puts => nil,
                    :read => nil
                   )
      flexmock(File) do |file|
        file.should_receive(:open).and_yield(fh)
        file.should_receive(:mv)
      end
      flexmock(FileUtils, :mkdir_p => nil)
      flexmock(CGI, :new => 'html4')
      @plugin.instance_eval('@month = Time.local(2011,2)')
      assert_equal('odba_isolated_store', @plugin.update_rss_feeds('name', ['model'], view_klass))
    end
=end
    def test_update_rss_feeds__model_empty
      assert_nil(@plugin.update_rss_feeds('name', [], 'view_klass'))
    end
  end
end
