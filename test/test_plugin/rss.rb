#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestRssPlugin -- oddb.org -- 21.11.2012 -- yasaka@ywesee.com
# ODDB::TestRssPlugin -- oddb.org -- 29.06.2011 -- mhatakeyama@ywesee.com

require 'date'
require 'pathname'
gem 'minitest'
require 'minitest/autorun'
require 'flexmock'

root = Pathname.new(__FILE__).realpath.parent.parent.parent
$: << root.join('test').join('test_plugin')
$: << root.join('src')

require 'plugin'
require 'plugin/rss'

module ODDB
  class RssPlugin < Plugin
    RSS_PATH = File.expand_path('../../data/rss', __FILE__)
  end
  class TestRssPlugin <Minitest::Test
    include FlexMock::TestCase
		Section = '00135'
    def setup
      @current = flexmock('current', :valid_from => Time.local(2011,2,3))
      @package = flexmock('package', 
                         :price_public => @current,
                         :data_origin  => 'data_origin'
                        )
      @app = FlexMock.new 'app'
      @plugin = RssPlugin.new @app
    end
    def setup_agent
      agent
    end
    def teardown
      path = RssPlugin::RSS_PATH
      %w[recall hpc].each do |feed|
        %w[de fr en].each do |lang|
          %w[just-medical].each do |flavor|
            file = File.join(path, lang, "#{feed}-#{flavor}.rss")
            if File.exists?(file)
              File.unlink(file)
            end
          end
        end
      end
      super # to clean up FlexMock
    end
    def test_report
      @plugin.instance_eval("@report = {'New recall.rss feeds' => 2, 'This month(2) total' => 2}")
      expected = <<REPORT
New recall.rss feeds:              2
This month(2) total:               2
REPORT
      assert_equal(expected.chomp, @plugin.report)
    end
    def test_sort_packages
      assert_equal([@package], @plugin.sort_packages([@package]))
    end
    def test_download
      agent = flexmock(Mechanize.new)
      agent.should_receive(:user_agent_alias=).and_return(true)
      agent.should_receive(:get).and_return('Mechanize Page')
      uri = 'http://www.example.com'
      response = @plugin.download(uri, agent)
      assert_equal('Mechanize Page', response)
    end
    def test_compose_description
      # 12‘345
      desc = flexmock('Desc')
      text = "Zulassungsnummer: 12‘345"
      desc.should_receive(:text).and_return(text)
      content = flexmock('Content')
      content.should_receive(:xpath).with('.//p/strong').and_return(desc)
      content.should_receive(:inner_html).and_return(text)
      assert_equal(
        "Zulassungsnummer: <a href='http://#{SERVER_NAME}/de/gcc/show/reg/12345' target='_blank'>12‘345</a>",
        @plugin.compose_description(content)
      )
      # 54'321
      desc = flexmock('Desc')
      text = "Zulassungsnummer: 54'321"
      desc.should_receive(:text).and_return(text)
      content = flexmock('Content')
      content.should_receive(:xpath).with('.//p/strong').and_return(desc)
      content.should_receive(:inner_html).and_return(text)
      assert_equal(
        "Zulassungsnummer: <a href='http://#{SERVER_NAME}/de/gcc/show/reg/54321' target='_blank'>54'321</a>",
        @plugin.compose_description(content)
      )
    end
    def test_extract_swissmedic_entry_from__with_no_match
      link = flexmock('Link')
      link.should_receive(:href).and_return('/../invalid.html')
      page = flexmock('Page')
      page.should_receive(:links).and_return([link])
      host = 'http://www.example.com'
      assert_empty(@plugin.extract_swissmedic_entry_from('00000', page, host))
      assert_empty(@plugin.extract_swissmedic_entry_from('00018', page, host))
      assert_empty(@plugin.extract_swissmedic_entry_from('00158', page, host))
    end
    def test_extract_swissmedic_entry_from__with_recall
      category = '00166'
      today = (Date.today - 1).strftime('%d.%m.%Y')
      host = 'https://www.example.com'
      link = flexmock('Link')
      link.should_receive(:href).and_return("/recall/#{Section}/#{category}/00000/index.html")
			link.should_receive(:open)
      date = flexmock('Date')
      node = flexmock('Node')
      date.should_receive(:text).and_return(today)
      node.should_receive(:next).and_return(date)
      link.should_receive(:node).and_return(node)
      title = flexmock('Title')
      title.should_receive(:text).and_return('Recall Title')
      container = flexmock('Container')
      container.should_receive(:xpath).with(".//h1[@id='contentStart']").and_return(title)
      container.should_receive(:xpath).with(".//div[starts-with(@id, 'sprungmarke')]/div").and_return('Content')
      page = flexmock('NextPage')
      page.should_receive(:at).with("div[@id='webInnerContentSmall']").and_return(container)
      link.should_receive(:click).and_return(page)
      page = flexmock('Page')
      page.should_receive(:links).and_return([link])
      # dependent
      flexmock(@plugin) do |plug|
        plug.should_receive(:compose_description).with('Content').and_return('Recall Description')
      end
      assert_equal(
        [{
          :date        => Date.parse(today).to_s,
          :title       => 'Recall Title',
          :description => "Recall Description",
          :link        => "https://www.example.com/recall/#{Section}/00166/00000/index.html",
        }],
        @plugin.extract_swissmedic_entry_from(category, page, host)
      )
    end
    def test_extract_swissmedic_entry_from__with_hpc
      category = '00157'
      today = (Date.today - 1).strftime('%d.%m.%Y')
      host = 'http://www.example.com'
      link = flexmock('Link')
      link.should_receive(:href).and_return("/recall/#{Section}/#{category}/00000/index.html")
      date = flexmock('Date')
      node = flexmock('Node')
      date.should_receive(:text).and_return(today)
      node.should_receive(:next).and_return(date)
      link.should_receive(:node).and_return(node)
      title = flexmock('Title')
      title.should_receive(:text).and_return('HPC Title')
      container = flexmock('Container')
      container.should_receive(:xpath).with(".//h1[@id='contentStart']").and_return(title)
      container.should_receive(:xpath).with(".//div[starts-with(@id, 'sprungmarke')]/div").and_return('Content')
      page = flexmock('NextPage')
      page.should_receive(:at).with("div[@id='webInnerContentSmall']").and_return(container)
      link.should_receive(:click).and_return(page)
      page = flexmock('Page')
      page.should_receive(:links).and_return([link])
      # dependent
      flexmock(@plugin) do |plug|
        plug.should_receive(:compose_description).with('Content').and_return('HPC Description')
      end
      assert_equal(
        [{
          :date        => Date.parse(today).to_s,
          :title       => 'HPC Title',
          :description => "HPC Description",
          :link        => "http://www.example.com/recall/#{Section}/#{category}/00000/index.html",
        }],
        @plugin.extract_swissmedic_entry_from(category, page, host)
      )
    end
    def test_swissmedic_entries_of__with_unknown_type
      assert_empty(@plugin.swissmedic_entries_of(:invalid_type))
    end
    def test_swissmedic_entries_of__with_recall
      link = flexmock('Link')
      link.should_receive(:href).and_return("index.html&start=10")
      page = flexmock('Page')
      page.should_receive(:link_with).and_return(link)
      flexmock(@plugin) do |plug|
        plug.should_receive(:download).and_return(page)
        plug.should_receive(:extract_swissmedic_entry_from).and_return([{
          :date        => '01.11.2012',
          :title       => 'Recall Title',
          :description => 'Recall Description',
          :link        => 'http://www.example.com',
        }])
      end
      entries = @plugin.swissmedic_entries_of(:recall)
      assert_equal(['de', 'fr', 'en'], entries.keys)
      assert_equal('Recall Title',     entries['de'].first[:title])
      assert_equal(1,                  entries['de'].length)
    end
    def test_swissmedic_entries_of__with_hpc
      link = flexmock('Link')
      link.should_receive(:href).and_return("index.html&start=20")
      page = flexmock('Page')
      page.should_receive(:link_with).and_return(link)
      flexmock(@plugin) do |plug|
        plug.should_receive(:download).and_return(page)
        plug.should_receive(:extract_swissmedic_entry_from).and_return([{
          :date        => '01.11.2012',
          :title       => 'HPC Title',
          :description => 'HPC Description',
          :link        => 'http://www.example.com',
        }])
      end
      entries = @plugin.swissmedic_entries_of(:hpc)
      assert_equal(['de', 'fr', 'en'], entries.keys)
      assert_equal('HPC Title',        entries['de'].first[:title])
      assert_equal(1,                  entries['de'].length)
    end
    def test_generate_flavored_rss__with_recall
      expected = ['just-medical']
      assert_equal(expected, @plugin.generate_flavored_rss('recall.rss'))
      assert(File.exists?(File.join(RssPlugin::RSS_PATH, 'de', 'recall-just-medical.rss')))
      assert(File.exists?(File.join(RssPlugin::RSS_PATH, 'fr', 'recall-just-medical.rss')))
      assert(File.exists?(File.join(RssPlugin::RSS_PATH, 'en', 'recall-just-medical.rss')))
    end
    def test_generate_flavored_rss__with_hpc
      expected = ['just-medical']
      assert_equal(expected, @plugin.generate_flavored_rss('hpc.rss'))
      assert(File.exists?(File.join(RssPlugin::RSS_PATH, 'de', 'hpc-just-medical.rss')))
      assert(File.exists?(File.join(RssPlugin::RSS_PATH, 'fr', 'hpc-just-medical.rss')))
      assert(File.exists?(File.join(RssPlugin::RSS_PATH, 'en', 'hpc-just-medical.rss')))
    end
    def test_update_swissmedic_feed__with_recall
      flexmock(@app) do |app|
        app.should_receive(:rss_updates).and_return({})
        app.should_receive(:odba_isolated_store).times(1)
      end
      flexmock(@plugin) do |plug|
        plug.should_receive(:update_rss_feeds)
        plug.should_receive(:swissmedic_entries_of).with(:recall).and_return(['entry'])
      end
      assert_equal(nil, @plugin.update_swissmedic_feed(:recall))
    end
    def test_update_swissmedic_feed__with_hpc
      flexmock(@app) do |app|
        app.should_receive(:rss_updates).and_return({})
        app.should_receive(:odba_isolated_store).times(1)
      end
      flexmock(@plugin) do |plug|
        plug.should_receive(:update_rss_feeds)
        plug.should_receive(:swissmedic_entries_of).with(:hpc).and_return(['entry'])
      end
      assert_equal(nil, @plugin.update_swissmedic_feed(:hpc))
    end
    def test_update_recall_feed
      flexmock(@plugin) do |plug|
        plug.should_receive(:update_swissmedic_feed).with(:recall).and_return(nil)
      end
      assert_equal(nil, @plugin.update_recall_feed)
    end
    def test_update_hpc_feed
      flexmock(@plugin) do |plug|
        plug.should_receive(:update_swissmedic_feed).with(:hpc).and_return(nil)
      end
      assert_equal(nil, @plugin.update_hpc_feed)
    end
    def test_update_price_feeds
      flexmock(@app).should_receive(:each_package).and_yield(@package)
      assert_equal(nil, @plugin.update_price_feeds(Date.new(2011,2,3)))
    end
    def test_update_price_feeds__previous_nil
      flexmock(@package) do |p|
        p.should_receive(:price_public).with_no_args.and_return(@current)
        # p.should_receive(:price_public).with(1).once.and_return(nil)
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
#        p.should_receive(:price_public).with(1).once.and_return(previous)
      end
      flexmock(previous, :> => false)
      flexmock(@current, :> => true)
      flexmock(@plugin, :update_rss_feeds => 'update_rss_feeds')
      assert_equal('update_rss_feeds', @plugin.update_price_feeds(Date.new(2011,2,3)))
    end
  end
end
