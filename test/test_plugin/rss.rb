#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestRssPlugin -- oddb.org -- 29.10.2012 -- yasaka@ywesee.com

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
    def test_sort_packages
      # pending
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
    def test_extract_recall_entry_from__with_no_match
      link = flexmock('Link')
      link.should_receive(:href).and_return('/../invalid.html')
      page = flexmock('Page')
      page.should_receive(:links).and_return([link])
      assert_empty(@plugin.extract_recall_entry_from(page))
    end
    def test_extract_recall_entry_from__with_match
      # TODO
      # refactor (too many mock! use stastic dummy html files)
      today = "#{Date.today.day}.#{Date.today.month}.#{Date.today.year}"
      link = flexmock('Link')
      link.should_receive(:href).and_return('../00091/00118/00000/index.html')
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
          :description => "Recall Description",
          :link        => '../00091/00118/00000/index.html',
          :title       => 'Recall Title'
        }],
        @plugin.extract_recall_entry_from(page)
      )
    end
    def test_update_recall_feeds
      # pending
    end
    def test_report
      # pending
    end
  end
end
