#!/usr/bin/env ruby

# ODDB::TestDownloadExport -- oddb.org -- 29.06.2011 -- mhatakeyama@ywesee.com
# ODDB::TestDownloadExport -- oddb.org -- 19.04.2005 -- hwyss@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))
$: << File.expand_path("..", File.dirname(__FILE__))

require "minitest/autorun"
require "define_empty_class"
require "htmlgrid/select"
require "state/user/download_export"

module ODDB
  module State
    module User
      class TestDownloadExport < Minitest::Test
        def test_price
          assert_equal(600, DownloadExport.price("oddb.yaml.gz"))
          assert_equal(600, DownloadExport.price("oddb.yaml.zip"))
        end

        def test_duration
          assert_equal(0, DownloadExport.duration("file"))
        end

        def test_subscription_duration
          assert_equal(0, DownloadExport.subscription_duration("file"))
          assert_equal(365, DownloadExport.subscription_duration("chde.xls"))
        end

        def test_subscription_price
          assert_equal(0, DownloadExport.subscription_price("file"))
          assert_equal(2000, DownloadExport.subscription_price("chde.xls"))
        end
      end
    end
  end
end
