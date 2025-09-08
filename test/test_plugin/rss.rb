#!/usr/bin/env ruby

# ODDB::TestRssPlugin -- oddb.org -- 21.11.2012 -- yasaka@ywesee.com
# ODDB::TestRssPlugin -- oddb.org -- 29.06.2011 -- mhatakeyama@ywesee.com

require "date"
require "pathname"

require "minitest/autorun"
require "flexmock/minitest"
require "stringio"

root = Pathname.new(__FILE__).realpath.parent.parent.parent
$: << root.join("test").join("test_plugin")
$: << root.join("src")

require "plugin"
require "plugin/rss"

module ODDB
  class RssPlugin < Plugin
    RSS_PATH = File.join(ODDB::TEST_DATA_DIR, "rss")
  end

  class TestRssPlugin < Minitest::Test
    Section = "00135"
    def setup
      @current = flexmock("current", valid_from: Time.local(2011, 2, 3))
      @package = flexmock("package",
        price_public: @current,
        data_origin: "data_origin")
      @app = FlexMock.new "app"
      @plugin = flexmock("rss_plugin", RssPlugin.new(@app))
    end

    def teardown
      path = RssPlugin::RSS_PATH
      %w[recall hpc].each do |feed|
        %w[de fr en].each do |lang|
          %w[just-medical].each do |flavor|
            file = File.join(path, lang, "#{feed}-#{flavor}.rss")
            if File.exist?(file)
              File.unlink(file)
            end
          end
        end
      end
      super # to clean up FlexMock
    end

    def test_report
      @plugin.instance_eval("@report = {'New recall.rss feeds' => 2, 'This month(2) total' => 2}", __FILE__, __LINE__)
      expected = <<~REPORT
        New recall.rss feeds:              2
        This month(2) total:               2
      REPORT
      assert_equal(expected.chomp, @plugin.report)
    end

    def test_sort_packages
      assert_equal([@package], @plugin.sort_packages([@package]))
    end

    def test_swissmedic_entries_of__with_unknown_type
      assert_empty(@plugin.swissmedic_entries_of(:invalid_type))
    end

    def test_generate_flavored_rss__with_recall
      expected = ["just-medical"]
      assert_equal(expected, @plugin.generate_flavored_rss("recall.rss"))
      assert(File.exist?(File.join(RssPlugin::RSS_PATH, "de", "recall-just-medical.rss")))
      assert(File.exist?(File.join(RssPlugin::RSS_PATH, "fr", "recall-just-medical.rss")))
      assert(File.exist?(File.join(RssPlugin::RSS_PATH, "en", "recall-just-medical.rss")))
    end

    def test_generate_flavored_rss__with_hpc
      expected = ["just-medical"]
      assert_equal(expected, @plugin.generate_flavored_rss("hpc.rss"))
      assert(File.exist?(File.join(RssPlugin::RSS_PATH, "de", "hpc-just-medical.rss")))
      assert(File.exist?(File.join(RssPlugin::RSS_PATH, "fr", "hpc-just-medical.rss")))
      assert(File.exist?(File.join(RssPlugin::RSS_PATH, "en", "hpc-just-medical.rss")))
    end

    def test_update_swissmedic_feed__with_recall
      flexmock(@app) do |app|
        app.should_receive(:rss_updates).and_return({})
        app.should_receive(:odba_isolated_store).times(1)
      end
      flexmock(@plugin) do |plug|
        plug.should_receive(:update_rss_feeds)
        plug.should_receive(:swissmedic_entries_of).with(:recall).and_return(["entry"])
      end
      assert_equal(["entry"], @plugin.update_swissmedic_feed(:recall))
    end

    def test_update_swissmedic_feed__with_hpc
      flexmock(@app) do |app|
        app.should_receive(:rss_updates).and_return({})
        app.should_receive(:odba_isolated_store).times(1)
      end
      flexmock(@plugin) do |plug|
        plug.should_receive(:update_rss_feeds)
        plug.should_receive(:swissmedic_entries_of).with(:hpc).and_return(["entry"])
      end
      assert_equal(["entry"], @plugin.update_swissmedic_feed(:hpc))
    end

    def test_update_recall_feed
      flexmock(@plugin) do |plug|
        plug.should_receive(:update_swissmedic_feed).with(:recall).and_return(nil)
      end
      assert_nil(@plugin.update_recall_feed)
    end

    def test_update_hpc_feed
      flexmock(@plugin) do |plug|
        plug.should_receive(:update_swissmedic_feed).with(:hpc).and_return(nil)
      end
      assert_nil(@plugin.update_hpc_feed)
    end

    def test_update_price_feeds
      flexmock(@app).should_receive(:each_package).and_yield(@package)
      assert_nil(@plugin.update_price_feeds(Date.new(2011, 2, 3)))
    end

    def test_update_price_feeds__previous_nil
      flexmock(@package) do |p|
        p.should_receive(:price_public).with_no_args.and_return(@current)
        # p.should_receive(:price_public).with(1).once.and_return(nil)
      end
      flexmock(@current, authority: :sl)
      flexmock(@app).should_receive(:each_package).and_yield(@package)
      flexmock(@plugin, update_rss_feeds: "update_rss_feeds")
      assert_equal("update_rss_feeds", @plugin.update_price_feeds(Date.new(2011, 2, 3)))
    end

    def test_update_price_feeds__sl
      flexmock(@app).should_receive(:each_package).and_yield(@package)
      flexmock(@package, data_origin: :sl)
      flexmock(@current, :> => true)
      flexmock(@plugin, update_rss_feeds: "update_rss_feeds")
      assert_equal("update_rss_feeds", @plugin.update_price_feeds(Date.new(2011, 2, 3)))
    end

    def test_update_price_feeds__sl__current
      flexmock(@app).should_receive(:each_package).and_yield(@package)
      flexmock(@package, data_origin: :sl)
      previous = flexmock("previous")
      flexmock(@package) do |p|
        p.should_receive(:price_public).with_no_args.and_return(@current)
        #        p.should_receive(:price_public).with(1).once.and_return(previous)
      end
      flexmock(previous, :> => false)
      flexmock(@current, :> => true)
      flexmock(@plugin, update_rss_feeds: "update_rss_feeds")
      assert_equal("update_rss_feeds", @plugin.update_price_feeds(Date.new(2011, 2, 3)))
    end

    def setup_marktueberwachung
      @host = "https://www.swissmedic.ch"
      @first_recall = {link: "https://www.swissmedic.ch/swissmedic/de/home/humanarzneimittel/marktueberwachung/qualitaetsmaengel-und-chargenrueckrufe/chargenrueckrufe/chargenrueckruf-acnecremepluswidmer.html",
                       title: "Chargenrückruf – Acne Crème plus Widmer",
                       date: "07.11.2017",
                       description: "<a href='https://ch.oddb.org/de/gcc/show/reg/47033' target='_blank'>Swissmedic-Registration 47033</a><br>Die Firma Louis Widmer AG zieht vorsorglich die obenerwähnten Chargen von 47033 Acne Crème plus Widmer bis auf Stufe Detailhandel vom Markt zurück. "}
      @first_hpc = {link: "https://www.swissmedic.ch/swissmedic/de/home/humanarzneimittel/marktueberwachung/health-professional-communication--hpc-/dhpc-dantrolen-ivinjektionsloesung.html",
                    title: "DHPC - Dantrolen i.v., Injektionslösung",
                    date: "17.11.2017",
                    description: "<a href='https://ch.oddb.org/de/gcc/show/reg/45217' target='_blank'>Swissmedic-Registration 45217</a><br>Die Firma Norgine AG informiert über wichtige, die Anwendung von Dantrolen i.v., Injektionslösung betreffende Änderungen."}

      @app.should_receive(:rss_updates).and_return({})
      @app.should_receive(:odba_isolated_store).and_return("odba_isolated_store")
      example_dir = File.join(ODDB::TEST_DATA_DIR, "html/swissmedic")
      @hpc_example_url = "https://www.swissmedic.ch/swissmedic/de/home/humanarzneimittel/marktueberwachung/health-professional-communication--hpc-/dhpc-dantrolen-ivinjektionsloesung.html"
      @recall_example_url = "https://www.swissmedic.ch/swissmedic/de/home/humanarzneimittel/marktueberwachung/health-professional-communication--hpc-/dhpc-dantrolen-ivinjektionsloesung.html"
      ODDB::RssPlugin::RSS_URLS.each do |lang, lang_cont|
        [:hpc, :recall].each do |rss_type|
          [1, 2, 3].each do |index|
            #            https://www.swissmedic.ch/dam/swissmedic/de/dokumente/listen/swissmedic/de/home/humanarzneimittel/qualitaetsmaengel-und-chargenrueckrufe/chargenrueckrufe/_jcr_content/par/teaserlist.content.paging-1.html?pageIndex=1
            file_url = lang_cont[rss_type][:index].gsub("1", index.to_s)
            if index == 1
              url = ((rss_type == :hpc) ? @first_hpc[:link] : @first_recall[:link])
              @plugin.should_receive(:fetch_with_http).with(url).and_return(File.read(File.join(example_dir, File.basename(url))))
            end
            example_file = File.join(example_dir, (index == 3) ? "page-empty.html" : "page-#{rss_type}-1.html")
            if File.exist?(example_file) && File.size(example_file) > 1024
              # puts "Added #{example_file}"
            else
              puts "Should call\nwget '#{file_url}' -O #{example_file}"
              assert(File.exist?(example_file))
            end
            @plugin.should_receive(:fetch_with_http).with(file_url).and_return(File.read(example_file))
          end
        end
      end
      @plugin.should_receive(:fetch_with_http).and_return("")
    end

    def test_recall_example
      setup_marktueberwachung
      first_page = Nokogiri::HTML(@plugin.fetch_with_http(ODDB::RssPlugin::RSS_URLS[:de][:recall][:index]))
      detail = first_page.xpath(".//div[@class='row']").first
      result = @plugin.detail_info(@host, detail, true)
      assert_equal("Chargenrückruf – Acne Crème plus Widmer", result[:title])
      @first_recall.each do |key, value|
        assert_equal(value, result[key])
      end
    end

    def test_hpc_example
      setup_marktueberwachung
      first_page = Nokogiri::HTML(@plugin.fetch_with_http(ODDB::RssPlugin::RSS_URLS[:de][:hpc][:index]))
      detail = first_page.xpath(".//div[@class='row']").first
      result = @plugin.detail_info(@host, detail, true)
      @first_hpc.each do |key, value|
        assert_equal(value, result[key], "key #{key} should match #{value}")
      end
    end

    def test_swissmedic_entries_of__with_recall
      setup_marktueberwachung
      to_test = @first_recall.clone
      entries = @plugin.update_recall_feed
      assert_equal(["de", "fr", "en"], entries.keys)
      assert_equal("Chargenrückruf – Acne Crème plus Widmer", entries["de"].first[:title])
      to_test.each do |key, value|
        assert_equal(value, entries["de"].first[key], "key #{key} should match #{value}")
      end
      assert_equal(10, entries["de"].length)
    end

    def test_swissmedic_entries_of__with_hpc
      setup_marktueberwachung
      entries = @plugin.update_hpc_feed
      @first_hpc.clone
      assert_equal(["de", "fr", "en"], entries.keys)
      assert_equal(12, entries["de"].length)
      assert_equal("DHPC - Dantrolen i.v., Injektionslösung", entries["de"].first[:title])
      assert_equal("DHPC – Cinryze 500 U (C1-INAKTIVATOR HUMAN)", entries["de"].last[:title])
      entries["de"].first
      @first_hpc.each do |key, value|
        assert_equal(value, entries["de"].first[key], "key #{key} should match #{value}")
      end
    end
  end
end
