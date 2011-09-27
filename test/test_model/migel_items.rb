#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::Migel::TestItems -- oddb.org -- 16.09.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'model/migel/items.rb'

module ODDB
  module Migel

class TestItems < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @item0  = flexmock('item', 
                       :pharmacode   => 'pharmacode0',
                       :article_name => 'bbb',
                       :ppub         => '123'
                      )
    @item1  = flexmock('item', 
                       :pharmacode   => 'pharmacode1',
                       :article_name => 'aaa',
                       :ppub         => '456'
                      )
    product = flexmock('product', 
                       :price => 'price',
                       :qty   => 'qty',
                       :unit  => 'unit',
                       :migel_code => 'migel_code',
                       :items => {'item0' => @item0, 'item1' => @item1}
                      )
    @items = ODDB::Migel::Items.new(product)
  end
  def test_empty
    assert_equal(@items.empty?, false)
    product = flexmock('product', 
                       :price => 'price',
                       :qty   => 'qty',
                       :unit  => 'unit',
                       :migel_code => 'migel_code',
                       :items => nil
                      )
    items = ODDB::Migel::Items.new(product)
    assert(items.empty?)
  end
  def test_sort_by
    result = @items.sort_by do |item|
      item.article_name
    end
    assert_equal([@item1, @item0], result)
  end
  def test_at
    assert_equal(@item0, @items.at(0))
    assert_equal(@item1, @items.at(1))
  end
  def test_sort
    @items.sort! do |a,b|
      a.article_name <=> b.article_name
    end

    assert_equal(@item1, @items.at(0))
    assert_equal(@item0, @items.at(1))
  end
  def test_reverse
    @items.reverse!


    assert_equal(@item1, @items.at(0))
    assert_equal(@item0, @items.at(1))
  end
  def test_each
    items = []
    @items.each do |item|
      items << item
    end

    assert_equal(@item0, @items.at(0))
    assert_equal(@item1, @items.at(1))
  end
  def test_each_with_index
    @items.each_with_index do |item, i|
      case i
      when 0
        assert_equal(@item0, item)
      when 1
        assert_equal(@item1, item)
      end
    end
  end
  def test_length
    assert_equal(@items.length, 2)
  end
  def test_index
    assert_equal(@items[0], @item0)
  end
end

  end # Migel
end # ODDB
