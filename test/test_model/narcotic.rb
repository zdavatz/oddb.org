#!/usr/bin/env ruby
#  -- oddb -- 07.11.2005 -- ffricker@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'model/narcotic'
require 'flexmock'
require 'stub/odba'

module ODDB
	class TestNarcotic < Test::Unit::TestCase
		def setup
			@narcotic = Narcotic.new
		end
		def test_add_package
			odba = ODBA.cache = FlexMock.new
			odba.should_receive(:store, 2).and_return { |arg|
				assert_equal(@narcotic.packages, arg)
			}
			narc = FlexMock.new
			res = @narcotic.add_package(narc)
			assert_equal([narc], @narcotic.packages)
			assert_equal(narc, res)
			narc2 = FlexMock.new
			res = @narcotic.add_package(narc2)
			assert_equal([narc, narc2], @narcotic.packages)
			assert_equal(narc2, res)
			odba.flexmock_verify
		ensure
			ODBA.cache = nil
		end
		def test_remove_package
			odba = ODBA.cache = FlexMock.new
			odba.should_receive(:store, 2).and_return { |arg|
				assert_equal(@narcotic.packages, arg)
			}
			narc = FlexMock.new
			narc2 = FlexMock.new
			@narcotic.packages.push(narc)
			@narcotic.packages.push(narc2)
			res = @narcotic.remove_package(narc)
			assert_equal([narc2], @narcotic.packages)
			assert_equal(narc, res)
			res = @narcotic.remove_package(narc)
			assert_equal([narc2], @narcotic.packages)
			assert_equal(nil, res)
			res = @narcotic.remove_package(narc2)
			assert_equal([], @narcotic.packages)
			assert_equal(narc2, res)
			odba.flexmock_verify
		ensure
			ODBA.cache = nil
		end
	end
end
