#!/usr/bin/env ruby
# TestCyP450Connection -- oddb -- 04.05.2004 -- maege@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'model/cyp450connection'
require 'mock'

module ODDB
	class CyP450Connection
		attr_accessor :pointer
	end
end

class TestCyP450Connection < Test::Unit::TestCase
	def setup
		@connection = ODDB::CyP450Connection.new
	end
	def test_init
		pointer = ODDB::Persistence::Pointer.new(:conn)
		@connection.pointer = pointer
		@connection.init
		expected = [ 
			":!conn,", 
			@connection.oid.to_s, 
			"." 
		].join
		result = @connection.pointer.to_s
		assert_equal(expected, result)
	end
end
class TestCyP450SubstrateConnection < Test::Unit::TestCase
	def setup
		@connection = ODDB::CyP450SubstrateConnection.new('cyp_id')
	end
=begin
	def test_has_interaction_with
		cytochrome = Mock.new('cytochrome')
		@connection.cytochromes = [ cytochrome ]
		cytochrome.__next(:has_connection?) { |param|
			assert_equal('other', param)
		}
		@connection.has_interaction_with?('other')
		cytochrome.__verify
	end
=end
	def test_adjust_types
		app = Mock.new('app')
		values = {
			:cyp450	=>	'foo_id'
		}
		app.__next(:cyp450) { |param|
			assert_equal('foo_id', param)
			'found cyp450'
		}
		result = @connection.adjust_types(values, app)
		expected = { :cyp450	=>	'found cyp450' }
		assert_equal(expected, result)
		app.__verify
	end
end
class TestCyP450InteractionConnection < Test::Unit::TestCase
	def setup
		@connection = ODDB::CyP450InteractionConnection.new('substance name')
	end
	def test_adjust_types
		app = Mock.new('app')
		values = { :substance	=>	'foo name' }
		app.__next(:substance_by_conn_name) { |param|
			assert_equal('foo name', param)
			'substance'
		}
		result = @connection.adjust_types(values, app)
		expected = { :substance	=>	'substance' }
		assert_equal(expected, result)
		app.__verify
	end
end
