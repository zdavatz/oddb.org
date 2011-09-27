#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::Migel::TestItem -- oddb.org -- 09.09.2011 -- mhatakeyama@ywesee.com


$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'model/migel/item.rb'


module ODDB
  module Migel

class TestItem < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    product = flexmock('product', 
                       :price => 'price',
                       :qty   => 'qty',
                       :unit  => 'unit',
                       :migel_code => 'migel_code'
                      )
    @item = ODDB::Migel::Item.new(product)
  end
  def test_initialize
    assert_equal('price', @item.price)
    assert_equal('qty', @item.qty)
    assert_equal('unit', @item.unit)
    assert_equal('migel_code', @item.pointer_descr)
    assert_equal('migel_code', @item.migel_code)
  end
end

  end # Migel
end # ODDB
