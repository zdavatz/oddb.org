#!/usr/bin/env ruby
# encoding: utf-8
# TestGenericGroup -- oddb -- 03.03.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'model/genericgroup'

module ODDB
	class GenericGroup
		attr_accessor :packages
	end
end
class StubGenericGroupPackage
end

class TestGenericGroup < Test::Unit::TestCase
	def setup
		@generic_group = ODDB::GenericGroup.new
	end
	def test_add_package
		@generic_group.packages = []
		package = StubGenericGroupPackage.new
		@generic_group.add_package(package)
		assert_equal([package], @generic_group.packages)
	end
	def test_remove_package
		package = StubGenericGroupPackage.new
		@generic_group.packages = [package]
		@generic_group.remove_package(package)
		assert_equal([], @generic_group.packages)
	end
end
