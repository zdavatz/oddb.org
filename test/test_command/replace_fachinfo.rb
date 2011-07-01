#!/usr/bin/env ruby
# ODDB::TestReplaceFachinfoCommand -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

#require 'state/global'

require 'test/unit'
require 'flexmock'
require 'command/replace_fachinfo'

module ODDB 
  class TestReplaceFachinfoCommand < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
      @fachinfo = flexmock('fachinfo', 
                           :empty?  => true,
                           :pointer => 'pointer'
                          )
      pointer  = flexmock('pointer', :resolve => @fachinfo)
      @command = ODDB::ReplaceFachinfoCommand.new('iksnr', pointer)
    end
    def test_execute
      registration = flexmock('registration', 
                              :fachinfo  => @fachinfo,
                              :fachinfo= => nil,
                              :odba_isolated_store => 'odba_isolated_store'
                             )
      app = flexmock('app', 
                     :registration => registration,
                     :delete => 'delete'
                    )
      assert_nil(@command.execute(app))
    end
  end
end # ODDB
