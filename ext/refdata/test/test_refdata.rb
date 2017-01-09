#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::Refdata::RefdataArticle -- oddb.org -- 01.11.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../src', File.dirname(__FILE__))
$: << File.expand_path('../../../src', File.dirname(__FILE__))
$: << File.expand_path('../../../test', File.dirname(__FILE__))


require 'minitest/autorun'
require 'flexmock/minitest'
begin
  require 'pry'
rescue LoadError
end
require 'refdata'
require 'test_helpers'
module ODDB

  class TestRefdataArticleFromUrl <Minitest::Test
      def stdout_null
        require 'tempfile'
        $stdout = Tempfile.open('stderr')
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
      assert_equal(TestHelpers::LEVETIRACETAM_PHAR.to_s, result[:phar])
      assert_equal(TestHelpers::LEVETIRACETAM_NAME_DE, result[:name_de])
    end

    def test_search_item_by_gtin
      # this is an integration test and will query refdata.ch
      result = @@refdata_article.search_item(TestHelpers::LEVETIRACETAM_GTIN)
      assert_equal(TestHelpers::LEVETIRACETAM_GTIN.to_s, result[:gtin])
      assert_equal(TestHelpers::LEVETIRACETAM_NAME_DE, result[:name_de])
    end

    def test_check_item
      # this is an integration test and will query refdata.ch
      item = @@refdata_article.get_refdata_info(TestHelpers::LEVETIRACETAM_GTIN.to_s, :gtin)
      assert_equal(TestHelpers::LEVETIRACETAM_GTIN.to_s, item[:gtin])
    end

    def test_search_item__error
      @@refdata_article = ODDB::Refdata::RefdataArticle.new
      response = flexmock('response', :to_hash => {:nonpharma => nil})
      wsdl = flexmock('wsdl', :document= => nil)
      client = flexmock('client') do |c|
        c.should_receive(:request).and_raise(StandardError)
      end
      flexmock(Savon::Client).should_receive(:new).and_yield(wsdl, @http).and_return(client)
      flexmock(@nonpharma,
                :sleep => nil,
                :server => 'server'
              )
      pharmacode = '1234567'
      stdout_null do
        assert_nil(@@refdata_article.search_item(pharmacode))
      end
    end
    def test_download_all_pharma
      puts "IntegrationTest: Download_all Pharma takes a few seconds"
      result = @@refdata_article.download_all
      assert_equal(true, result)
    end
    def test_download_all_non_pharma
      puts "IntegrationTest: Download_all NonPharma takes a few seconds"
      result = @@refdata_article.download_all('NonPharma')
      assert_equal(true, result)
    end
  end

end # ODDB
