#!/usr/bin/env ruby
# State::Drugs::TestResult -- oddb -- 11.03.2003 -- aschrafl@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'state/drugs/result'

module ODDB
	module State
		module Drugs
class Result < State::Drugs::Global
	attr_accessor :sortby, :session
	attr_reader :model, :default_view, :filter
	public :page
	remove_const :REVERSE_MAP
	REVERSE_MAP = {
		:size		=> true,
		:price	=> false,
		:mice		=> false,
	}
	def model=(model)
		session = StubResultSession.new
		@model = model.collect { |atc| AtcFacade.new(atc, session) }
	end
end
class StubResultPackage
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
class StubResultAtcFacade
	def initialize(atc)
		@atc = atc
	end
	def packages
		@atc.packages
	end
end
class StubResultAtc
	attr_writer :packages
	def active_packages
		@packages.dup
	end
	def package_count
		@packages.size
	end
end
class StubResultSession
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

class TestResult < Test::Unit::TestCase
	def setup
		@state = State::Drugs::Result.new(StubResultSession.new, [])
		@state.sortby = [:size, :price, :mice]
	end
	def test_compare_entries1
		p1 = StubResultPackage.new(1,2,3)
		p2 = StubResultPackage.new(3,2,1)
		assert_equal(-1, @state.compare_entries(p1, p2))
		assert_equal(1, @state.compare_entries(p2, p1))
	end
	def test_compare_entries2
		p1 = StubResultPackage.new(1,2,3)
		p2 = StubResultPackage.new(1,3,2)
		assert_equal(-1, @state.compare_entries(p1, p2))
		assert_equal(1, @state.compare_entries(p2, p1))
	end
	def test_compare_entries3
		p1 = StubResultPackage.new(1,2,3)
		p2 = StubResultPackage.new(1,2,4)
		assert_equal(-1, @state.compare_entries(p1, p2))
		assert_equal(1, @state.compare_entries(p2, p1))
	end
	def test_compare_entries4
		p1 = StubResultPackage.new(1,2,3)
		p2 = StubResultPackage.new(1,2,3)
		assert_equal(0, @state.compare_entries(p1, p2))
		assert_equal(0, @state.compare_entries(p2, p1))
	end
	def test_compare_entries5
		p1 = StubResultPackage.new(1,2,3)
		p2 = StubResultPackage.new(1,2,nil)
		assert_equal(-1, @state.compare_entries(p1, p2))
		assert_equal(1, @state.compare_entries(p2, p1))
	end
	def test_compare_entries6
		p1 = StubResultPackage.new(1,2,nil)
		p2 = StubResultPackage.new(1,2,nil)
		assert_equal(0, @state.compare_entries(p1, p2))
		assert_equal(0, @state.compare_entries(p2, p1))
	end
	def test_empty_list
		assert_equal(View::Drugs::EmptyResult, @state.default_view)
	end
	def test_filter
		p1 = StubResultPackage.new(1,2,3)
		p2 = StubResultPackage.new(3,2,1)
		atc = StubResultAtc.new
		atc.packages = [p1, p2]
		@state.model = Array.new(250, atc)
		@state.init
		filter = @state.filter
		assert_instance_of(Proc, filter)
		@state.session.user_input = { :page=>0 }
		result = filter.call(nil)
		assert_instance_of(State::PageFacade, result)
		assert_equal(75, result.size)
		@state.session.user_input = { :page=>3 }
		result = filter.call(nil)
		assert_instance_of(State::PageFacade, result)
		assert_equal(25, result.size)
	end
	def test_page
		p1 = StubResultPackage.new(1,2,3)
		p2 = StubResultPackage.new(3,2,1)
		atc = StubResultAtc.new
		atc.packages = [p1, p2]
		@state.model = Array.new(150, atc)
		@state.init
		assert_instance_of(State::PageFacade, @state.page)
		assert_equal(0, @state.page.to_i)
		@state.session.user_input = { :page => 1 }
		assert_equal(1, @state.page.to_i)
		@state.session.user_input = {}
		assert_equal(1, @state.page.to_i)
	end
	def test_init_sort
		p1 = StubResultPackage.new(1,2,3)
		p2 = StubResultPackage.new(3,2,1)
		p3 = StubResultPackage.new(5,2,1)
		atc1 = StubResultAtc.new
		atc2 = StubResultAtc.new
		atc1.packages = [p1, p2, p3]
		atc2.packages = [p1, p2]
		@state.model = [atc2, atc1]
		@state.init
		assert_equal(3, @state.model.first.package_count)
		assert_equal(2, @state.model.last.package_count)
	end
	def test_sort1
		@state.sortby = []
		@state.session.user_input = {
			:sortvalue => :size,
		}
		@state.trigger(:sort)
		assert_equal([:size], @state.sortby)
	end
	def test_sort2
		@state.session.user_input = {
			:sortvalue => :vice,
		}
		@state.trigger(:sort)
		assert_equal([:vice, :size, :price, :mice], @state.sortby)
	end
	def test_sort3
		@state.session.user_input = {
			:sortvalue => "price",
		}
		@state.trigger(:sort)
		assert_equal([:price, :size, :mice], @state.sortby)
	end
	def test_sort4
		p1 = StubResultPackage.new(1,2,3)
		p2 = StubResultPackage.new(3,2,1)
		atc = StubResultAtc.new
		atc.packages = [p1, p2]
		@state.model = [atc]
		@state.session.user_input = {
			:sortvalue => "mice",
		}
		@state.trigger(:sort)
		assert_equal([p2, p1], @state.model.first.packages)
		@state.trigger(:sort)
		assert_equal([p1, p2], @state.model.first.packages)
		@state.trigger(:sort)
		assert_equal([p2, p1], @state.model.first.packages)
	end
	def test_sort5
		p1 = StubResultPackage.new(1,2,3)
		p2 = StubResultPackage.new(3,2,1)
		atc = StubResultAtc.new
		atc.packages = [p1, p2]
		@state.model = [atc]
		@state.session.user_input = {
			:sortvalue => "size",
		}
		@state.trigger(:sort)
		assert_equal([p2, p1], @state.model.first.packages)
		@state.trigger(:sort)
		assert_equal([p1, p2], @state.model.first.packages)
		@state.trigger(:sort)
		assert_equal([p2, p1], @state.model.first.packages)
	end
	def test_sort6
		p1 = StubResultPackage.new(1,2,3)
		p2 = StubResultPackage.new(3,2,1)
		atc = StubResultAtc.new
		atc.packages = [p1, p2]
		@state.model = [atc]
		@state.session.user_input = {
			:sortvalue => "size",
		}
		@state.trigger(:sort)
		assert_equal([p2, p1], @state.model.first.packages)
		@state.trigger(:sort)
		assert_equal([p1, p2], @state.model.first.packages)
		@state.session.user_input = {
			:sortvalue =>	"mice",
		}
		@state.trigger(:sort)
		assert_equal([p2, p1], @state.model.first.packages)
		@state.trigger(:sort)
		assert_equal([p1, p2], @state.model.first.packages)
		@state.session.user_input = {
			:sortvalue => "size",
		}
		@state.trigger(:sort)
		assert_equal([p2, p1], @state.model.first.packages)
	end
	def test_sort_2_sessions
		state = State::Drugs::Result.new(StubResultSession.new, [])
		
		p1 = StubResultPackage.new(1,1,3)
		p2 = StubResultPackage.new(3,2,1)
		atc = StubResultAtc.new
		atc.packages = [p1, p2]
		@state.model = [atc]
		state.model = [atc]
		@state.session.user_input = {
			:sortvalue => "price",
		}
		state.session.user_input = {
			:sortvalue =>	"mice"
		}
		@state.trigger(:sort)
		state.trigger(:sort)
		assert_equal([p1, p2], @state.model.first.packages)
		assert_equal([p2, p1], state.model.first.packages)
	end
end
class TestAtcFacade < Test::Unit::TestCase
	class Package
		attr_reader :generic_type, :name_base, :galenic_form, :dose, :comparable_size 
		def initialize(generic_type, name_base, galenic_form, dose, comparable_size)
			@name_base, @galenic_form = name_base, galenic_form
			@dose, @comparable_size = dose, comparable_size
			@generic_type = generic_type
		end
		def active?
			true
		end
	end
	def setup
		@p1 = Package.new(:original, 'Bcd', 'aFilm', 100, 80)
		@p2 = Package.new(:original, 'Bcd', 'aFilm', 120, 60)
		@p3 = Package.new(:original, 'Bcd', 'aFilm', 120, 80)
		@p4 = Package.new(:generic, 'Abc', 'aFilm', 120, 80)
		@p5 = Package.new(:generic, 'Abc', 'bFilm', 120, 80)
		@p6 = Package.new(nil, 'Cde', 'aFilm', 120, 80)
		@p7 = Package.new(nil, 'Efg', 'aFilm', 120, 80)
		@p8 = Package.new(nil, nil, 'aFilm', 120, 80)
		@p9 = Package.new(nil, 'Efg', nil, 120, 80)
		@p10 = Package.new(nil, 'Efg', 'aFilm', nil, 80)
		@atc = StubResultAtc.new
		@atc.packages = [
			@p6, @p5, @p3, @p8, @p4,
			@p1, @p7, @p2, @p9, @p10,
		]
		@session = StubResultSession.new
	end
	def test_initialize
		atcfacade = nil
		assert_nothing_raised {
			atcfacade = State::Drugs::Result::AtcFacade.new(@atc, @session)
		}
		expected = [
			@p1, @p2, @p3, @p4, @p5, 
			@p8, @p6, @p9, @p10, @p7, 
		]
		result = atcfacade.packages
		expected.each_with_index { |pn, idx|
			assert_equal(pn, result[idx], "expected @p#{idx+1}")
		}
	end
end
		end
	end
end
