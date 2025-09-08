#!/usr/bin/env ruby

# ODDB::TestPlugin -- 21.06.2011 -- mhatakeyama@ywesee.com
# ODDB::TestPlugin -- oddb -- 30.05.2003 -- hwyss@ywesee.com

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "plugin/plugin"
require "fileutils"
require "test_helpers" # for VCR setup

module ODDB
  class TestPlugin < Minitest::Test
    def setup
      ODDB::TestHelpers.vcr_setup
      @app = flexmock("app")
      @plugin = ODDB::Plugin.new(@app)
    end

    def teardown
      File.delete("/tmp/oddbtest") if File.exist?("/tmp/oddbtest")
      super # to clean up FlexMock
    end

    def test_http_file
      VCR.use_cassette("googlexx") do
        session = flexmock("session") # , ODDB::Plugin::SessionStub)
        session.should_receive(:get).and_return("got_response")
        assert_nil(@plugin.http_file("www.oddb.org", "/unknown", "/tmp/oddbtest", session))
        res = @plugin.http_file("www.google.ch", "/search?q=generika", "/tmp/oddbtest")
        assert_equal(true, res)
        assert(File.exist?("/tmp/oddbtest"))
      end
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
      model = flexmock("model",
        pointer: "pointer",
        name_base: "name_base")
      expected = "name_base:                                        https://#{SERVER_NAME}/de/gcc/resolve/pointer/pointer "
      assert_equal(expected, @plugin.resolve_link(model))
    end

    def test_resolve_link__else
      model = flexmock("model", pointer: "pointer")
      expected = "https://#{SERVER_NAME}/de/gcc/resolve/pointer/pointer "
      assert_equal(expected, @plugin.resolve_link(model))
    end

    def test_resolve_link__error
      model = flexmock("model") do |m|
        m.should_receive(:pointer).and_raise(StandardError)
      end
      expected = "Error creating Link for nil"
      assert_equal(expected, @plugin.resolve_link(model))
    end

    def test_update_rss_feeds
      view_instance = flexmock("view_instance", to_html: "to_html")
      view_klass = flexmock("view_klass")
      # new method with 3 arguments as for hpc, price_cut, recall in update_rss_feeds
      view_klass.should_receive(:new).with(any, any, any).and_return(view_instance)
      name = "name"
      rss_updates = {"name" => name}
      flexmock(@app,
        rss_updates: rss_updates,
        odba_isolated_store: "odba_isolated_store")
      fh = flexmock("file_handler",
        puts: nil,
        read: nil)
      flexmock(File) do |file|
        file.should_receive(:open).and_yield(fh)
        file.should_receive(:mv)
      end
      flexmock(FileUtils, mkdir_p: nil)
      flexmock(CGI, new: "html4")
      @plugin.instance_eval("@month = Time.local(2011,2)", __FILE__, __LINE__)
      assert_equal("odba_isolated_store", @plugin.update_rss_feeds("name", ["model"], view_klass))
    end

    def test_update_rss_feeds_4_args
      view_instance = flexmock("view_instance", to_html: "to_html")
      view_klass = flexmock("view_klass")
      # new method with 4 arguments as for fachinfo in update_rss_feeds
      view_klass.should_receive(:new).with(any, any, any, any).and_return(view_instance)
      name = "name"
      rss_updates = {"name" => name}
      flexmock(@app,
        rss_updates: rss_updates,
        odba_isolated_store: "odba_isolated_store")
      fh = flexmock("file_handler",
        puts: nil,
        read: nil)
      flexmock(File) do |file|
        file.should_receive(:open).and_yield(fh)
        file.should_receive(:mv)
      end
      flexmock(FileUtils, mkdir_p: nil)
      flexmock(CGI, new: "html4")
      @plugin.instance_eval("@month = Time.local(2011,2)", __FILE__, __LINE__)
      assert_equal("odba_isolated_store", @plugin.update_rss_feeds("name", ["model"], view_klass))
    end

    def test_update_rss_feeds__model_empty
      assert_nil(@plugin.update_rss_feeds("name", [], "view_klass"))
    end
  end
end
