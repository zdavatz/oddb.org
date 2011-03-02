#!/usr/bin/env ruby
# View::Companies::TestCompanyList -- oddb -- 02.03.2011 -- mhatakeyama@ywesee.com
# View::Companies::TestCompanyList -- oddb -- 30.07.2003 -- hwyss@ywesee.com 

$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'view/companies/companylist'
require 'flexmock'

module ODDB
	module View
		module Companies
module CompanyList
	attr_reader :model
	public :sort_model
end

class TestCompanyList < Test::Unit::TestCase
  include FlexMock::TestCase
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
		def app
			self
		end
		def attributes(*args)
			{}
		end
		def lookandfeel
			self
		end
		def lookup(*args)
			"foo"
		end
		def navigation
			[]
		end
		def enabled?(*args)
			true
		end
		def event_url(*args)
			"bar"
		end
		def resource_localized(*args)
			true
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
    flexstub(@session) do |s|
      s.should_receive(:_event_url)
    end
		list = View::Companies::UnknownCompanyList.new(orig, @session)
		assert_equal(orig, list.model)
	end
end
		end
	end
end
