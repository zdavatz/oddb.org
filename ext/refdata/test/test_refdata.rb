#!/usr/bin/env ruby

# ODDB::Refdata::RefdataArticle -- oddb.org -- 01.11.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../src", File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))
$: << File.expand_path("../../../test", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "refdata"
require "test_helpers"
module ODDB
  class TestRefdataArticleFromUrl < Minitest::Test
    def stdout_null
      require "tempfile"
      $stdout = Tempfile.open("stderr")
      yield
    ensure
      $stdout.close
      $stdout = STDERR
    end

    def setup
      TestHelpers.vcr_setup
      @@refdata_article ||= ODDB::Refdata::RefdataArticle.new
    end

    def teardown
      TestHelpers.vcr_teardown
    end

    def test_search_item_by_pharmacode
      # this is an integration test and will query refdata.ch
      result = @@refdata_article.search_item(TestHelpers::LEVETIRACETAM_PHAR)
      assert_nil(result) # PHARMACODE is no longer supported in 2025
    end

    def test_search_item_by_gtin
      # this is an integration test and will query refdata.ch
      result = @@refdata_article.search_item(TestHelpers::LEVETIRACETAM_GTIN)
      assert_equal(TestHelpers::LEVETIRACETAM_GTIN.to_s, result[:gtin])
      assert_equal(TestHelpers::LEVETIRACETAM_NAME_DE, result[:name_de])
      expected = {gtin: TestHelpers::LEVETIRACETAM_GTIN.to_s,
                  name_de: TestHelpers::LEVETIRACETAM_NAME_DE,
                  name_fr: "LEVETIRACETAM DESITIN mini cpr pel 250 mg 30 pce",
                  name_it: "LEVETIRACETAM DESITIN mini cpr pel 250 mg 30 pce",
                  name_en: "LEVETIRACETAM DESITIN Mini Filmtab 250 mg 30 Stk",
                  type: "Pharma",
                  swmc_authnr: "62069008",
                  auth_holder_name: "Desitin Pharma GmbH",
                  auth_holder_gln: "7601001320451",
                  atc: "N03AX14"}
      assert_equal(expected, result)
    end

    def test_check_item
      # this is an integration test and will query refdata.ch
      item = @@refdata_article.get_refdata_info(TestHelpers::LEVETIRACETAM_GTIN.to_s, :gtin)
      assert_equal(TestHelpers::LEVETIRACETAM_GTIN.to_s, item[:gtin])
    end

    def test_search_item__error
      pharmacode = "1234567"
      assert_nil(@@refdata_article.search_item(pharmacode))
    end

    def test_download_all
      puts "IntegrationTest: Download_all Pharma takes a few seconds"
      @@refdata_article.download_all
      @@refdata_article.items["Pharma"].size
      assert_operator 1000, :<=, @@refdata_article.items["Pharma"].size
      assert_operator 100, :<=, @@refdata_article.items["NonPharma"].size
    end
  end
end # ODDB
