#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestReplaceFachinfoCommand -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

#require 'state/global'

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'command/replace_fachinfo'

module ODDB 
  class TestReplaceFachinfoCommand <Minitest::Test
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
