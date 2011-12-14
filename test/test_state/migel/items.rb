#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Migel::TestItems -- oddb.org -- 09.09.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'state/page_facade'
require 'state/migel/items'

module ODDB
  module State
    module Migel

class TestItems < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :language => 'language'
                       )
    @model   = flexmock('model')
    @state   = ODDB::State::Migel::Items.new(@session, @model)
  end
  def test_compare_entries__ppub
    sortby   = [:ppub]
    @state.instance_eval('@sortby = sortby')
    item1 = flexmock('item1', :ppub => '100')
    item2 = flexmock('item2' ,:ppub => '200')
    assert_equal(-1, @state.compare_entries(item1, item2))
  end
  def test_compare_entries__article_name
    sortby   = [:article_name]
    @state.instance_eval('@sortby = sortby')
    item1 = flexmock('item1', :article_name => 'article_name1')
    item2 = flexmock('item2', :article_name => 'article_name2')
    assert_equal(-1, @state.compare_entries(item1, item2))
  end
  def test_compare_entries__nil_case1
    sortby   = [:article_name]
    @state.instance_eval('@sortby = sortby')
    item1 = flexmock('item1', :article_name => nil)
    item2 = flexmock('item2', :article_name => 'article_name2')
    assert_equal(1, @state.compare_entries(item1, item2))
  end
  def test_compare_entries__nil_case2
    sortby   = [:article_name]
    @state.instance_eval('@sortby = sortby')
    item1 = flexmock('item1', :article_name => 'article_name1')
    item2 = flexmock('item2', :article_name => nil)
    assert_equal(-1, @state.compare_entries(item1, item2))
  end
  def test_compare_entries__nil_case3
    sortby   = [:article_name]
    @state.instance_eval('@sortby = sortby')
    item1 = flexmock('item1', :article_name => nil)
    item2 = flexmock('item2', :article_name => nil)
    assert_equal(0, @state.compare_entries(item1, item2))
  end
  def test_compare_entries__error
    sortby   = [:article_name]
    @state.instance_eval('@sortby = sortby')
    flexmock(@state).should_receive(:umlaut_filter).and_raise(RuntimeError)
    item1 = flexmock('item1', :article_name => 'article_name1')
    item2 = flexmock('item2', :article_name => 'article_name2')
    assert_nothing_raised do
      assert_equal(0, @state.compare_entries(item1, item2))
    end
  end
  def test_sort
    sortby   = [:article_name]
    @state.instance_eval do
      @sortby = sortby
      @sort_reverse = true
    end
    flexmock(@session, :user_input => nil)
    item1 = flexmock('item1', :article_name => 'article_name1')
    item2 = flexmock('item2', :article_name => 'article_name2')
    flexmock(@model) do |s|
      s.should_receive(:sort!).and_yield(item1, item2)
      s.should_receive(:reverse!)
    end
    assert_equal(@state, @state.sort)
  end
end

    end # Migel
  end # State
end # ODDB
