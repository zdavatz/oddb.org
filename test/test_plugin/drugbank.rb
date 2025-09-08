#!/usr/bin/env ruby

# ODDB::TestDrugbankPlugin -- oddb.org -- 25.06.2012 -- yasaka@ywesee.com

require "pathname"

require "minitest/autorun"
require "flexmock/minitest"

root = Pathname.new(__FILE__).realpath.parent.parent.parent
$: << root.join("test").join("test_plugin")
$: << root.join("src")

require "plugin/drugbank"

module ODDB
  class DrugbankPlugin < Plugin
    attr_accessor :checked, :activated, :nonlinked
  end
end

module ODDB
  class TestDrugbankPlugin < Minitest::Test
    ATC_FOUND_IN_DRUGBANK = "ABC1234"
    ATC_ABSENT_IN_DRUGBANK = "ABC5678"
    ATC_ERROR_IN_DRUGBANK = "ABC9999"
    def setup
      @app = FlexMock.new "app"
      @app.should_receive(:update).and_return do |pointer, hash|
        assert_equal "atc-pointer", pointer
        assert hash.has_key?(:db_id)
      end
      @valid_page = %(<html><bod>
      <meta content="DB00999" name="dc.identifier" /><meta content="Hydrochlorothiazide" name="dc.title" /><title>Hydrochlorothiazide - DrugBank</title><link rel="apple-touch-icon" type="image/x-icon" href="/favicons/apple-touch-icon-57x57-precomposed.png" sizes="57x57" />
      </body>
      </html>)
      @invalid_page = %(<html><bod>
      <main role="main"><h1>How did you get here? That page doesn't exist. Oh well, it happens.</h1>
      </body>
      </html>)
      @agent = flexmock("agent", Mechanize.new)
      start_url = "https://www.drugbank.ca/unearth/q?utf8=%E2%9C%93&query="
      end_of_url = "&searcher=drugs&approved=1&vet_approved=1&nutraceutical=1&illicit=1&withdrawn=1&investigational=1&button="
      @agent.should_receive(:get).with(start_url + "name" + end_of_url).and_return(Nokogiri::HTML(@valid_page)).by_default
      @agent.should_receive(:get).with(start_url + "invalid_name" + end_of_url).and_return(Nokogiri::HTML(@invalid_page)).by_default
      @plugin = DrugbankPlugin.new(@app, agent: @agent)
      @atc = flexmock("atc")
      @atc.should_receive(:pointer).and_return("atc-pointer")
      @atc.should_receive(:name).and_return("name")
      @atc.should_receive(:db_id).and_return("db_id").by_default
    end

    def teardown
      super # to clean up FlexMock
      # pass
    end

    def test_update_db_id_with_valid_atc
      @atc.should_receive(:code).and_return(ATC_FOUND_IN_DRUGBANK)
      @atc.should_receive(:description).and_return("desc")
      @app.should_receive(:atc_classes).and_return({good: @atc})
      @plugin.update_db_id
      assert_equal(1, @plugin.checked)
      assert_equal(0, @plugin.activated)
      assert_equal(1, @plugin.nonlinked)
    end

    def test_update_db_id_with_short_atc_code
      @atc.should_receive(:code).and_return("ABC")
      @atc.should_receive(:description).and_return("desc")
      @app.should_receive(:atc_classes).and_return({short: @atc})
      @plugin.update_db_id
      assert_equal(0, @plugin.checked)
      assert_equal(0, @plugin.activated)
      assert_equal(0, @plugin.nonlinked)
    end

    def test_update_db_id_with_empty_atc_desc
      @atc.should_receive(:code).and_return(ATC_FOUND_IN_DRUGBANK)
      @atc.should_receive(:description).and_return("")
      @app.should_receive(:atc_classes).and_return({empty: @atc})
      @plugin.update_db_id
      assert_equal(0, @plugin.checked)
      assert_equal(0, @plugin.activated)
      assert_equal(0, @plugin.nonlinked)
    end

    def test_update_db_id_with_no_id_found
      @atc.should_receive(:code).and_return(ATC_ABSENT_IN_DRUGBANK)
      @atc.should_receive(:description).and_return("desc")
      @app.should_receive(:atc_classes).and_return({nolink: @atc})
      @plugin.update_db_id
      assert_equal(1, @plugin.checked)
      assert_equal(0, @plugin.activated)
      assert_equal(1, @plugin.nonlinked)
    end

    def test_update_db_id_response_code_error
      @atc.should_receive(:code).and_return(ATC_ABSENT_IN_DRUGBANK)
      @atc.should_receive(:description).and_return("desc")
      @app.should_receive(:atc_classes).and_return({nolink: @atc})
      @plugin.update_db_id
      assert_equal(1, @plugin.checked)
      assert_equal(0, @plugin.activated)
      assert_equal(1, @plugin.nonlinked)
    end

    def test_update_db_id_with_multi_links
      @atc.should_receive(:code).and_return(ATC_FOUND_IN_DRUGBANK)
      @atc.should_receive(:description).and_return("desc")
      @app.should_receive(:atc_classes).and_return({multi: @atc})
      @app.should_receive(:update).and_return do |pointer, hash|
        assert_equal "atc-pointer", pointer
        assert_equal :db_id, hash.keys.first
        assert_equal Array, hash[:db_id].class
        assert_equal 2, hash[:db_id].length
      end
      assert_equal(0, @plugin.activated)
      @plugin.update_db_id
      assert_equal(1, @plugin.checked)
      assert_equal(1, @plugin.nonlinked)
    end

    def test_report
      report = @plugin.report
      assert_equal 5, report.split("\n").length
    end
  end
end
