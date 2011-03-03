#!/usr/bin/env ruby
# State::Interactions::TestResult -- oddb -- 01.03.2011 -- mhatakeyama@ywesee.com
# State::Interactions::TestResult -- oddb -- 01.06.2004 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'define_empty_class'
require 'view/search'
require 'state/interactions/result'
require 'mock'

module ODDB
	module State
		module Interactions
class Result < State::Interactions::Global
	attr_accessor :facades
	attr_reader :default_view
	class Facade < SimpleDelegator
		def clear_objects_array
			@objects.clear
		end
	end
end

class TestResultState < Test::Unit::TestCase
	def setup
		@session = Mock.new('session') 
		@state = State::Interactions::Result.new(@session, [])
	end
	def teardown
		@session.__verify
	end
	def test_empty_list
    @state.init
		assert_equal(ODDB::View::Interactions::EmptyResult, @state.default_view)
	end
=begin
	def test_check_facades
		facade1 = Mock.new('facade1')
		facade2 = Mock.new('facade2')
		object = Mock.new('object')
		@state.facades = {
			'bar_class'	=>	facade1, 
			'foo_class'	=>	facade2,
		}
		facade2.__next(:add_object) { |param| 
			assert_equal(object, param)
		}	
		@state.check_facades('foo_class', object)
		facade1.__verify
		facade2.__verify
		object.__verify
	end
	def test_check_facades2
		facade1 = Mock.new('facade1')
		facade2 = Mock.new('facade2')
		object = Mock.new('object')
		@state.facades = {
			'bar_class'	=>	facade1, 
			'foo_class'	=>	facade2,
		}
		assert_equal(2, @state.facades.size)
		@state.check_facades('foobar_class', object)
		assert_equal(3, @state.facades.size)
		result = @state.facades['foobar_class'].objects
		assert_equal([object], result)
		facade1.__verify
		facade2.__verify
		object.__verify
	end
=end
end
=begin
class TestFacade < Test::Unit::TestCase
	def setup
		@facade = ODDB::ResultState::Facade.new('foobar')
	end
	def test_empty
		@facade.clear_objects_array
		assert_equal(true, @facade.empty?)
	end
	def test_add_object
		object = Mock.new('object')
		@facade.clear_objects_array
		assert_equal(0, @facade.objects.size)
		@facade.add_object(object)
		assert_equal(1, @facade.objects.size)
	end
	def test_objects
		@facade.clear_objects_array
		object1 = Mock.new('object1')
		@facade.add_object(object1)
		result = @facade.objects
		assert_equal([object1], result)
		object1.__verify
	end
	def test_objects2
		@facade.clear_objects_array
		object1 = Mock.new('object1')
		object2 = Mock.new('object2')
		object3	= Mock.new('object3')
		@facade.add_object(object1)
		@facade.add_object(object2)
		@facade.add_object(object3)
		object1.__next(:name) { 'cname' }
		object2.__next(:name) { 'aname' }
		object2.__next(:name) { 'aname' }
		object3.__next(:name) { 'bname' }
		object1.__next(:name) { 'cname' }
		object3.__next(:name) { 'bname' }
		result = @facade.objects
		expected = [ object2, object3, object1 ]
		assert_equal(expected, result)
		object1.__verify
		object2.__verify
		object3.__verify
	end
end
=end
		end
	end
end
