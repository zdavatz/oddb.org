#!/usr/bin/env ruby
# TestLevenshteinDistance -- ODDB -- 09.11.2004 -- hwyss@ywesee.com

$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'util/levenshtein_distance'

module ODDB
	class TestLevenshteinDistance < Test::Unit::TestCase
		def test_equal
			assert_equal(0, 'foo'.ld('foo'))
		end
		def test_ld_1
			assert_equal(1, 'foo'.ld('for'))
			assert_equal(1, 'foo'.ld('fro'))
			assert_equal(1, 'foo'.ld('boo'))
		end
		def test_ld_1_asym
			assert_equal(1, 'foo'.ld('fo'))
			assert_equal(1, 'fo'.ld('foo'))
		end
		def test_ld_2
			assert_equal(2, 'fooo'.ld('foar'))
			assert_equal(2, 'fooo'.ld('faor'))
			assert_equal(2, 'fooo'.ld('boor'))
			assert_equal(2, 'fooo'.ld('frao'))
			assert_equal(2, 'fooo'.ld('boro'))
			assert_equal(2, 'fooo'.ld('broo'))
		end
		def test_ld_2_asym
			assert_equal(2, 'fooo'.ld('for'))
			assert_equal(2, 'foo'.ld('foar'))
		end
	end
end
