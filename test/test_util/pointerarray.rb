#!/usr/bin/env ruby
# encoding: utf-8
# TestArray -- oddb -- 22.04.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'util/pointerarray'

class TestArray <Minitest::Test
	def setup
		@values = %w{a b c d e}
		@pointer = 'Pointer'
		@array = ODDB::PointerArray.new(@values, @pointer)
	end
	def test_initialize
		assert_equal(@values, @array)
		assert_respond_to(@array, :pointer)
		assert_equal('Pointer', @array.pointer)
	end
  def test_sort
    assert_equal(Array, @array.sort.class)  
  end
  def test_sort_by
    values = @array.sort_by { |item| item }
    assert_equal(ODDB::PointerArray, values.class)  
    assert_equal(ODDB::PointerArray, @array.class)  
  end
	def test_reverse
    assert_equal(Array, @array.reverse.class) 
    assert_equal(ODDB::PointerArray, @array.reverse!.class) 
	end
end
