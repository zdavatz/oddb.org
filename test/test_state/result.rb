#!/usr/bin/env ruby
# TestResultState -- oddb -- 11.03.2003 -- aschrafl@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'state/result'
require 'model/search_result'
require 'mock'

module ODDB
	class ResultState < GlobalState
		include ResultStateSort
		attr_accessor :sortby, :session, :pages
		attr_reader :model, :default_view, :filter
		public :compare_entries, :page
		remove_const :REVERSE_MAP
		REVERSE_MAP = {
			:size		=> true,
			:price	=> false,
			:mice		=> false,
		}
		def model=(model)
			session = StubResultStateSession.new
			#@model = model.collect { |atc| AtcFacade.new(atc, session) }
		end
=begin
		def init
			@model = Mock.new("model")
			@pages = Mock.new("pages")
			super
		end
=end
	end
end
class StubResultStatePackage
	attr_reader :size, :price, :mice
	def initialize(size, price, mice, *args)
		@size, @price, @mice = size, price, mice
	end
	def name_base
		'abc'
	end
	def galenic_form
		'abc'
	end
	def dose
		10
	end
	def comparable_size
		10
	end
	def generic_type
		'generika'
	end
	def active?
		true
	end
end
class StubResultStateAtcFacade
	def initialize(atc)
		@atc = atc
	end
	def packages
		@atc.packages
	end
end
class StubResultStateAtc
	attr_writer :packages
	def active_packages
		@packages.dup
	end
	def package_count
		@packages.size
	end
end
class StubResultStateSession
	attr_accessor :user_input
	def initialize
		@user_input = {}
	end
	def user_input(key)
		@user_input[key]
	end
	def valid_values(key)
		[nil, 'generika', 'original']
	end
	def language 
		:to_s
	end
end
	
class TestResultState < Test::Unit::TestCase
	def expect_init(mock,atc_classes)
		mock.__next(:session=) { "foo" }
		mock.__next(:atc_classes) { atc_classes}
	end
		
	def test_empty_list
		@model = Mock.new("model")
		expect_init(@model, nil)
		@state = ODDB::ResultState.new(StubResultStateSession.new, @model)
		@state.sortby = [:size, :price, :mice]
		assert_equal(ODDB::EmptyResultView, @state.default_view)
	end
	def test_page
		@model = Mock.new("model")
		atc_mock = Mock.new("atc_mock")
		page = Mock.new("page")
		page.__next(:package_count){ 2 }
		page.__next(:package_count){ 2 }
		expect_init(@model, [atc_mock])
		@model.__next(:atc_classes){[atc_mock]}
		@model.__next(:atc_sorted){[page]}
		@state = ODDB::ResultState.new(StubResultStateSession.new, @model)
		@state.sortby = [:size, :price, :mice]
		p1 = StubResultStatePackage.new(1,2,3)
		p2 = StubResultStatePackage.new(3,2,1)
		atc = StubResultStateAtc.new
		atc.packages = [p1, p2]
		@state.model = Array.new(150, atc)
		assert_equal([page], @state.page)
		page.__next(:to_i){ 1 }
		assert_equal(0, @state.page.to_i)
	end
end
