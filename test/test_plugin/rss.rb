#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestRssPlugin -- oddb.org -- 01.11.2012 -- yasaka@ywesee.com

require 'date'
require 'pathname'
require 'test-unit'
require 'flexmock'

root = Pathname.new(__FILE__).realpath.parent.parent.parent
$: << root.join('test').join('test_plugin')
$: << root.join('src')

require 'plugin/rss'

module ODDB
  class TestRssPlugin < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
      @app = FlexMock.new 'app'
      @plugin = RssPlugin.new @app
    end
    def setup_agent
      agent
    end
    def teardown
      # pass
    end
    def test_update_price_feeds
      # pending
    end
    def test_download
      agent = flexmock(Mechanize.new)
      agent.should_receive(:user_agent_alias=).and_return(true)
      agent.should_receive(:get).and_return('Mechanize Page')
      uri = 'http://www.example.com'
      response = @plugin.download(uri, agent)
      assert_equal('Mechanize Page', response)
    end
    def test_extract_swissmedic_entry_from__with_no_match
      link = flexmock('Link')
      link.should_receive(:href).and_return('/../invalid.html')
      page = flexmock('Page')
      page.should_receive(:links).and_return([link])
      host = 'http://www.example.com'
      assert_empty(@plugin.extract_swissmedic_entry_from('00000', page, host))
      assert_empty(@plugin.extract_swissmedic_entry_from('00018', page, host))
      assert_empty(@plugin.extract_swissmedic_entry_from('00092', page, host))
    end
    # TODO
    # refactor (too many mock! use stastic dummy html files)
    def test_extract_swissmedic_entry_from__with_recall
      category = '00118'
      yesterday = Date.today - 1
      today = "#{yesterday.day}.#{yesterday.month}.#{yesterday.year}"
      host = 'http://www.example.com'
      link = flexmock('Link')
      link.should_receive(:href).and_return("/recall/00091/#{category}/00000/index.html")
      date = flexmock('Date')
      node = flexmock('Node')
      date.should_receive(:text).and_return(today)
      node.should_receive(:next).and_return(date)
      link.should_receive(:node).and_return(node)
      title = flexmock('Title')
      title.should_receive(:text).and_return('Recall Title')
      container = flexmock('Container')
      container.should_receive(:xpath).with(".//h1[@id='contentStart']").and_return(title)
      content = flexmock('Content')
      content.should_receive(:inner_html).and_return("Recall Description")
      container.should_receive(:xpath).with(".//div[starts-with(@id, 'sprungmarke')]/div").and_return(content)
      page = flexmock('NextPage')
      page.should_receive(:at).with("div[@id='webInnerContentSmall']").and_return(container)
      link.should_receive(:click).and_return(page)
      page = flexmock('Page')
      page.should_receive(:links).and_return([link])
      assert_equal(
        [{
          :date        => Date.parse(today).to_s,
          :title       => 'Recall Title',
          :description => "Recall Description",
          :link        => "http://www.example.com/recall/00091/00118/00000/index.html",
        }],
        @plugin.extract_swissmedic_entry_from(category, page, host)
      )
    end
    def test_extract_swissmedic_entry_from__with_hpc
      category = '00092'
      yesterday = Date.today - 1
      today = "#{yesterday.day}.#{yesterday.month}.#{yesterday.year}"
      host = 'http://www.example.com'
      link = flexmock('Link')
      link.should_receive(:href).and_return("/recall/00091/#{category}/00000/index.html")
      date = flexmock('Date')
      node = flexmock('Node')
      date.should_receive(:text).and_return(today)
      node.should_receive(:next).and_return(date)
      link.should_receive(:node).and_return(node)
      title = flexmock('Title')
      title.should_receive(:text).and_return('Health Professional Communication Title')
      container = flexmock('Container')
      container.should_receive(:xpath).with(".//h1[@id='contentStart']").and_return(title)
      content = flexmock('Content')
      content.should_receive(:inner_html).and_return("Health Professional Communication Description")
      container.should_receive(:xpath).with(".//div[starts-with(@id, 'sprungmarke')]/div").and_return(content)
      page = flexmock('NextPage')
      page.should_receive(:at).with("div[@id='webInnerContentSmall']").and_return(container)
      link.should_receive(:click).and_return(page)
      page = flexmock('Page')
      page.should_receive(:links).and_return([link])
      assert_equal(
        [{
          :date        => Date.parse(today).to_s,
          :title       => 'Health Professional Communication Title',
          :description => "Health Professional Communication Description",
          :link        => 'http://www.example.com/recall/00091/00092/00000/index.html',
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
      assert_equal(3,                  entries['de'].length)
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
      assert_equal(5,                  entries['de'].length)
    end
    def test_update_swissmedic_feed
      # pending
    end
    def test_update_recall_feed
      # pending
    end
    def test_update_hpc_feed
      # pending
    end
    def test_report
      # pending
    end
  end
end
