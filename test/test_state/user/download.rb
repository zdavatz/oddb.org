#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::User::TestDownload -- oddb.org -- 30.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../../../src', File.dirname(__FILE__))


gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/resulttemplate'
require 'htmlgrid/select'
require 'state/user/download'

module ODDB
  module State
    module User

class TestDownload <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model', 
                        :data => {:search_query => 'search_query', :search_type => 'search_type'},
                        :search_query= => nil,
                        :search_type=  => nil,
                        :session=      => nil
                       )
    @state   = ODDB::State::User::Download.new(@session, @model)
    flexmock(@state, :_search_drugs => @model)
  end
  def test_init
    assert_equal(ODDB::View::Drugs::CsvResult, @state.init)
  end
end

    end # User
  end # State
end # ODDB
