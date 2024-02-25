#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestLppvPlugin -- oddb.org -- 13.04.2011 -- mhatakeyama@ywesee.com
# ODDB::TestLppvPlugin -- oddb.org -- 18.01.2006 -- sfrischknecht@ywesee.com

test_dir = File.expand_path("..", File.dirname(__FILE__))
$: << test_dir
$: << File.expand_path("../../src/", File.dirname(__FILE__))


require 'minitest/autorun'
require "plugin/lppv"
require "net/http"
require 'flexmock/minitest'
require 'vcr'
begin  require 'debug'; rescue LoadError; end # ignore error when debug cannot be loaded (for Jenkins-CI)
require 'test_helpers' # for VCR setup

module ODDB
  class TestLppvPlugin <Minitest::Test
    class MockApp
      def initialize(packages)
        @packages = packages
      end
      def each_package(&block)
        @packages.each(&block)
      end
    end
    def setup
      ODDB::TestHelpers.vcr_setup
      package1 = flexmock('package',
                         :barcode      => '7680554950049',
                         :data_origin  => :lppv,
                         :pharmacode   => 'pharmacode',
                         :name         => 'ACTIVITAL forte Brause Plv orange limet Btl 10 Stk',
                         :lppv         => nil,
                         :price_public => nil,
                         :sl_entry     => 'sl_entry',
                         :pointer      => 'package1-pointer',
                        )

      package2 = flexmock('package',
                         :barcode      => '7680452090328',
                         :data_origin  => :lppv,
                         :lppv         => 'lppv',
                         :pharmacode   => 'pharmacode',
                         :name         => 'ACETOCAUSTIN liq Fl 1 ml',
                         :price_public => 'price_public',
                         :sl_entry     => {},
                         :pointer      => 'package2-pointer',
                        )
      package3 = flexmock('package',
                         :barcode      => nil,
                         :pharmacode   => '710670',
                         :data_origin  => :lppv,
                         :lppv         => 'lppv',
                         :name         => 'WARUZOL sol 5.5 ml',
                         :price_public => 'price_public',
                         :sl_entry     => {},
                         :pointer      => 'package3-pointer',
                        )
      package4 = flexmock('package',
                         :barcode      => 'package4 gtin',
                         :pharmacode   => 'package4 pharma',
                         :data_origin  => :lppv,
                         :lppv         => 'lppv',
                         :pharmacode   => 'pharmacode',
                         :name         => 'package4',
                         :price_public => 'price_public',
                         :sl_entry     => {},
                         :pointer      => 'package3-pointer',
                        )
      @items = [package1, package2, package3, package4]
      @app = MockApp.new(@items)
      @mocked = flexmock(@app)
      @mocked.should_receive(:update, 1).at_least.once
      VCR.use_cassette("lppv", :tag => :lppv) do
        @plugin = LppvPlugin.new(@app)
        @plugin.update()
      end
    end
    def test_download
      assert_equal(0, @plugin.not_updated.size)
      assert_equal(1, @plugin.updated_packages.size)
      assert_equal(2, @plugin.packages_with_sl_entry.size)
      x = 0
      @app.each_package{|package| x+=1}
      assert_equal(@items.size, x)
    end
    def test_report
      report = @plugin.report
      expected = [ "Updated Packages (lppv flag true): 1 details:",
                   "Packages with SL-Entry: 2",
                   "Not updated were: 0 details:"]
      assert(/ACTIVITAL/.match(@plugin.updated_packages.last))
      # assert(/WARUZOL/.match(@plugin.updated_packages.last))
      expected.each do |one_line|
        puts report unless report.index(one_line)
        assert(report.index(one_line), "Should have '#{one_line}' in\n-------report\n#{report}\n----------end of report")
      end
      assert(/ACTIVITAL/.match(report), "Show name of updated packages")
      assert(/7680554950049/.match(report), "Show gtin of updated packages")
    end
	end
end
