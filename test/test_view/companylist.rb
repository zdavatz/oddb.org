#!/usr/bin/env ruby
# TestCompanyList -- oddb -- 30.07.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'view/companylist'

module ODDB
	module CompanyList
		attr_reader :model
		public :sort_model
	end
end

class TestCompanyList < Test::Unit::TestCase
	class StubModel
		attr_reader :name
		def initialize(name)
			@name = name
		end
		def method_missing(*args)
			"foo"
		end
	end
	class StubSession
		attr_accessor :event
		def lookandfeel
			self
		end
		def lookup(*args)
			"foo"
		end
		def attributes(*args)
			{}
		end
		def event_url(*args)
			"bar"
		end
		def state
			self
		end
		def id
			12345
		end
	end

	def setup
		@session = StubSession.new
	end
	def test_no_double_sort
		comp1 = StubModel.new("foo")
		comp2 = StubModel.new("bar")
		comp3 = StubModel.new("fru")
		orig = [comp1, comp2, comp3]
		@session.event = :sort
		list = ODDB::UnknownCompanyList.new(orig, @session)
		assert_equal(orig, list.model)
	end
end

