#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestSequenceObserver -- oddb.org -- 30.06.2003 -- hwyss@ywesee.com 

$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'model/sequence_observer'
require 'util/persistence'

module ODDB
  class StubSuper
  end
  class StubSequenceObserver < StubSuper
    include SequenceObserver
  end
  class TestSequenceObserver <Minitest::Test
    include FlexMock::TestCase
    def setup
      @observer = ODDB::StubSequenceObserver.new
    end
    def test_empty
      assert(@observer.empty?)
    end
    def test_add_sequence
      flexmock(@observer, :odba_isolated_store => 'odba_isolated_store')
      flexmock(ODBA.cache, 
               :next_id => 123,
               :store => 'store'
              )
      sequence = flexmock('sequence', 
                          :marshal_dump => 'marshal_dump',
                          :odba_isolated_store => 'odba_isolated_store'
                         )
      assert_equal(sequence, @observer.add_sequence(sequence))
    end
    def test_remove_sequence
      flexmock(@observer, :odba_isolated_store => 'odba_isolated_store')
      flexmock(ODBA.cache, 
               :next_id => 123,
               :store => 'store'
              )
      sequence = flexmock('sequence', 
                          :marshal_dump => 'marshal_dump',
                          :odba_isolated_store => 'odba_isolated_store'
                         )
      @observer.add_sequence(sequence)
      assert_equal([sequence], @observer.sequences)
      @observer.remove_sequence(sequence)
      assert_equal([], @observer.sequences)

    end
  end
end # ODDB
