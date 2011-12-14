#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestRssPlugin -- oddb.org -- 29.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'plugin/rss'


module ODDB
  class TestRssPlugin < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
      @current = flexmock('current', :valid_from => Time.local(2011,2,3))
      @package = flexmock('package', 
                         :price_public => @current,
                         :data_origin  => 'data_origin'
                        )

      @app     = flexmock('app')
      @plugin  = ODDB::RssPlugin.new(@app)
    end
    def test_sort_packages
      assert_equal([@package], @plugin.sort_packages([@package]))
    end
    def test_update_price_feeds
      flexmock(@app).should_receive(:each_package).and_yield(@package)
      assert_equal(nil, @plugin.update_price_feeds(Date.new(2011,2,3)))
    end
    def test_update_price_feeds__previous_nil
      flexmock(@package) do |p|
        p.should_receive(:price_public).with_no_args.and_return(@current)
        p.should_receive(:price_public).with(1).once.and_return(nil)
      end
      flexmock(@current, :authority => :sl)
      flexmock(@app).should_receive(:each_package).and_yield(@package)
      flexmock(@plugin, :update_rss_feeds => 'update_rss_feeds')
      assert_equal('update_rss_feeds', @plugin.update_price_feeds(Date.new(2011,2,3)))
    end
    def test_update_price_feeds__sl
      flexmock(@app).should_receive(:each_package).and_yield(@package)
      flexmock(@package, :data_origin => :sl)
      flexmock(@current, :> => true)
      flexmock(@plugin, :update_rss_feeds => 'update_rss_feeds')
      assert_equal('update_rss_feeds', @plugin.update_price_feeds(Date.new(2011,2,3)))
    end
    def test_update_price_feeds__sl__current
      flexmock(@app).should_receive(:each_package).and_yield(@package)
      flexmock(@package, :data_origin => :sl)
      previous = flexmock('previous')
      flexmock(@package) do |p|
        p.should_receive(:price_public).with_no_args.and_return(@current)
        p.should_receive(:price_public).with(1).once.and_return(previous)
      end
      flexmock(previous, :> => false)
      flexmock(@current, :> => true)
      flexmock(@plugin, :update_rss_feeds => 'update_rss_feeds')
      assert_equal('update_rss_feeds', @plugin.update_price_feeds(Date.new(2011,2,3)))
    end

  end
end # ODDB
