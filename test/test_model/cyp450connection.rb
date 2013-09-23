#!/usr/bin/env ruby
# encoding: utf-8
# TestCyP450Connection -- oddb -- 04.05.2004 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'stub/odba'
gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'model/cyp450connection'

module ODDB
  class CyP450Connection
    attr_accessor :pointer
  end
  class CyP450SubstrateConnection < CyP450Connection
    attr_accessor :cyp450
  end
  class TestAbstractLink <Minitest::Test
    def setup
      @link = ODDB::Interaction::AbstractLink.new
    end
    def test_empty
      assert_equal true, @link.empty?
      @link.href = 'http://ch.oddb.org/'
      assert_equal false, @link.empty?
    end
    def test_eql
      other = ODDB::Interaction::AbstractLink.new
      assert_equal other, @link
      @link.href = 'http://ch.oddb.org/'
      assert other != @link
      other.href = 'http://ch.oddb.org/'
      assert_equal other, @link
      other.href = 'http://de.oddb.org/'
      assert  other != @link
    end
    def test_hash
      @link.href = 'http://ch.oddb.org/'
      assert_equal 'http://ch.oddb.org/'.hash, @link.hash
    end
  end
  class TestCyP450Connection <Minitest::Test
    include FlexMock::TestCase
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
    def test_cyp_id
      assert_nil @connection.cyp_id
      @connection.cyp450 = flexmock :cyp_id => 'cyp-id'
      assert_equal 'cyp-id', @connection.cyp_id
    end
  end
  class TestCyP450SubstrateConnection <Minitest::Test
    include FlexMock::TestCase
    def setup
      @connection = ODDB::CyP450SubstrateConnection.new('cyp_id')
    end
    def test_adjust_types
      app = flexmock 'app'
      values = {
        :cyp450	=>	'foo_id'
      }
      app.should_receive(:cyp450).and_return do |param|
        assert_equal('foo_id', param)
        'found cyp450'
      end
      result = @connection.adjust_types(values, app)
      expected = { :cyp450	=>	'found cyp450' }
      assert_equal(expected, result)
    end
    def test_interactions_with__empty
      result = @connection.interactions_with(nil)
      assert_equal([], result)
    end
    def test_interactions_with
      cyp450 = flexmock 'cyp450'
      substance = flexmock 'substance'
      cyp450.should_receive(:interactions_with).and_return do |param|
        assert_equal(param, substance)
        [ 'int_connection' ]
      end
      @connection.cyp450 = cyp450 
      result = @connection.interactions_with(substance)
      assert_equal([ 'int_connection' ], result)
    end
  end
  class TestCyP450InteractionConnection <Minitest::Test
    include FlexMock::TestCase
    def setup
      @connection = ODDB::CyP450InteractionConnection.new('substance name')
    end
    def test_adjust_types
      app = flexmock 'app'
      values = { :substance	=>	'foo name' }
      app.should_receive(:substance).and_return do |param|
        assert_equal('foo name', param)
        'substance'
      end
      result = @connection.adjust_types(values, app)
      expected = { :substance	=>	'substance' }
      assert_equal(expected, result)
    end
  end
end
