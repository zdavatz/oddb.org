#!/usr/bin/env ruby
# TestSubstanceIndex -- oddb/fipdf -- 18.02.2004 -- mwalder@ywesee.com

$: << File.expand_path("../src/", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require "substance_index"

module ODDB
	module FiPDF
		class TestSubstanceIndex <Minitest::Test
			def setup
				@index = SubstanceIndex.new
			end
			def test_store
				assert_equal({}, @index)
				element1 = ["baar", "buur", 34, :symbol]
				@index.store("foo", element1)
				expected = {"foo" => [element1]}
				assert_equal(expected, @index)
				element2 = ["froh", "frah", 99, :generic]
				@index.store("baz", element2)
				expected = {
					"foo" => [element1],
					"baz" => [element2]
				}
				assert_equal(expected, @index)
				element3 = ["test", "void", 99, :original]
				@index.store("foo", element3)
				expected = {
					"foo" => [element1, element3],
					"baz" => [element2]
				}
				assert_equal(expected, @index)
			end
			def test_sort
				element1 = ["aaa", "bbb", 1, :foo]
				element2 = ["bbb", "aaa", 2, :bar]
				element3 = ["ccc", "ddd", 0, :ook]
				@index['foo'] = [element2, element3, element1]
				result = @index.sort
				expected = [
					["foo", [element1, element2, element3]]
				]
				assert_equal(expected, result)
			end
		end
	end
end
