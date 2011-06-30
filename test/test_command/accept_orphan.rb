#!/usr/bin/env ruby
# ODDB::TestAcceptOrphan -- oddb.org -- 30.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'state/global'

require 'test/unit'
require 'flexmock'
require 'command/accept_orphan'

module ODDB 
  class TestAcceptOrphan < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
      old_info = flexmock('old_info', 
                          :empty?  => true,
                          :pointer => 'pointer'
                         )
      parent   = flexmock('parent', 
                          :otype= => nil,
                          :otype  => old_info,
                          :odba_store => 'odba_store'
                         )
      @pointer = flexmock('pointer', :resolve => parent)
      @command = ODDB::AcceptOrphan.new('orphan', [@pointer], 'otype')
    end
    def test_execute
      accepted_orphans = flexmock('accepted_orphans', 
                                  :odba_store => 'odba_store',
                                  :store => 'store'
                                 )
      flexmock(accepted_orphans).should_receive(:fetch).and_yield
      app = flexmock('app', 
                     :accepted_orphans => accepted_orphans,
                     :update => 'update',
                     :delete => 'delete'
                    )
      assert_equal([@pointer], @command.execute(app))
    end
  end
end # ODDB
