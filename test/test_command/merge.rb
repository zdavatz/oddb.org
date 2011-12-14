#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestMergeCommand -- oddb.org -- 05.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))


require 'test/unit'
require 'flexmock'
require 'command/merge'

module ODDB 
  class TestMergeCommand < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
      target = flexmock('target', 
                        :merge => 'merge',
                        :odba_store => 'odba_store'
                       )
      @target_pointer = flexmock('target_pointer', :resolve => target)
      @source_pointer = flexmock('source_pointer', :resolve => 'source')
      @model = ODDB::MergeCommand.new(@source_pointer, @target_pointer)
    end
    def test_execute
      app = flexmock('app', :delete => 'delete')
      assert_nil(@model.execute(app))
    end
  end
end # ODDB
