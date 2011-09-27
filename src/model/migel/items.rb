#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::Migel::Items -- oddb.org -- 27.09.2011 -- mhatakeyama@ywesee.com

require 'plugin/swissindex'
require 'model/migel/item'

module ODDB
  module Migel

class Items
  def initialize(product, sortvalue = nil, reverse = nil)
    if product and items = product.items
      @sortvalue = sortvalue
      @list = items.values
      @reverse = reverse
    else
      @list = []
    end
  end
  def empty?
    @list.empty?
  end
  def sort_by(&block)
    # This is called at the first time when a search result is shown
    @list.sort_by(&block)
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
    @list.each_with_index do |record, i| 
      yield(record, i)
    end
  end
  def each
    @list.each do |record|
      yield record
    end
  end
  def at(index)
    @list[index]
  end
  def length
    @list.length
  end
  def [](*args)
    @list[*args]
  end
end

  end
end
