#!/usr/bin/env ruby
# TestAtcNode -- oddb -- 17.07.2003 -- maege@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'model/atcclass'
require 'model/atcnode'

module ODBA
	module Persistable
		def odba_store
		end
	end
end
class TestAtcNode < Test::Unit::TestCase
	class Array
		include ODBA::Persistable
	end
	class Hash
		include ODBA::Persistable
	end
	def setup
		@root = ODDB::AtcNode.new(nil)
		@atcN = ODDB::AtcClass.new('N')
		@atcN01 = ODDB::AtcClass.new('N01')
		@atcN02 = ODDB::AtcClass.new('N02')
		@atcN01A = ODDB::AtcClass.new('N01A')
		@nodeN = ODDB::AtcNode.new(@atcN)
		@nodeN01 = ODDB::AtcNode.new(@atcN01)
		@nodeN02 = ODDB::AtcNode.new(@atcN02)
		@nodeN01A = ODDB::AtcNode.new(@atcN01A)
		[@nodeN, @nodeN01, @nodeN02, @nodeN01A].each {|nd|
			@root.add_offspring(nd)
		}
	end
	def test_add_offspring
		root = ODDB::AtcNode.new(nil)
		atc = ODDB::AtcClass.new('N')
		node = ODDB::AtcNode.new(atc)
		root.add_offspring(node)
		assert_equal([node], root.children)
		atc2 = ODDB::AtcClass.new('N01')
		node2 = ODDB::AtcNode.new(atc2)
		root.add_offspring(node2)
		assert_equal([node], root.children)
		assert_equal([node2], node.children)
		atc3 = ODDB::AtcClass.new('N01A')
		node3 = ODDB::AtcNode.new(atc3)
		root.add_offspring(node3)
		assert_equal([node], root.children)
		assert_equal([node2], node.children)
		assert_equal([node3], node2.children)
		atc4 = ODDB::AtcClass.new('A')
		node4 = ODDB::AtcNode.new(atc4)
		root.add_offspring(node4)
		assert_equal([node, node4], root.children)
		assert_equal([node2], node.children)
		assert_equal([node3], node2.children)
	end
	def test_has_sequence
		assert_equal(false, @root.has_sequence?)
		assert_equal(false, @nodeN.has_sequence?)
		assert_equal(false, @nodeN01.has_sequence?)
		assert_equal(false, @nodeN02.has_sequence?)
		assert_equal(false, @nodeN01A.has_sequence?)
		@atcN01.add_sequence('seq')
		assert_equal(true, @root.has_sequence?)
		assert_equal(true, @nodeN.has_sequence?)
		assert_equal(true, @nodeN01.has_sequence?)
		assert_equal(false, @nodeN02.has_sequence?)
		assert_equal(false, @nodeN01A.has_sequence?)
	end
	def test_level
		atcN01AB = ODDB::AtcClass.new('N01AB')
		atcN01AB23 = ODDB::AtcClass.new('N01AB23')
		nodeN01AB = ODDB::AtcNode.new(atcN01AB)
		nodeN01AB23 = ODDB::AtcNode.new(atcN01AB23)
		assert_equal(0, @root.level)
		assert_equal(1, @nodeN.level)
		assert_equal(2, @nodeN01.level)
		assert_equal(3, @nodeN01A.level)
		assert_equal(4, nodeN01AB.level)
		assert_equal(5, nodeN01AB23.level)
	end
	def test_path_to
		atc = ODDB::AtcClass.new('N')
		atcnode = ODDB::AtcNode.new(atc)
		assert_equal(true, atcnode.path_to?('N01'))
		assert_equal(false, atcnode.path_to?('A01B'))
		atc = ODDB::AtcClass.new('A01B')
		atcnode = ODDB::AtcNode.new(atc)
		assert_equal(true, atcnode.path_to?('A01B'))
		assert_equal(false, atcnode.path_to?('A01'))
	end
	def test_root_node_path_to
		node = ODDB::AtcNode.new(nil)
		assert_equal(true, node.path_to?('A'))	
	end
	def test_delete
		assert_equal([@nodeN01, @nodeN02], @nodeN.children)
		@root.delete('N02')
		assert_equal([@nodeN01], @nodeN.children)
	end
end
