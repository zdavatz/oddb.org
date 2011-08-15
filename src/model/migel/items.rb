#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::Migel::Items -- oddb.org -- 15.08.2011 -- mhatakeyama@ywesee.com

require 'plugin/swissindex'
require 'model/migel/item'

module ODDB
  module Migel

class Items
  attr_reader :price, :qty, :unit, :pointer_descr
  def initialize(product)
    if product and items = product.items
      @list = items.values
    else
      @list = []
    end
    @price = product.price
    @qty = product.qty
    @unit = product.unit
    @pointer_descr = product.migel_code
  end
  def empty?
    @list.empty?
  end
  def sort_by
    # This is called at the first time when a search result is shown
    @list.sort_by do |record|
      record.pharmacode
    end
  end
  def sort!
    # This is called when a header key is clicked
    @list.sort! do |a,b|
      yield(a,b) 
    end
  end
  def reverse!
    @list.reverse!
  end
  def each_with_index
    @list.each do |record| 
      yield record
    end
  end
  def at(index)
    @list[index]
  end
end

  end
end
