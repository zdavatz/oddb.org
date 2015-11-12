#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Admin::TestIndication -- oddb.org -- 27.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'state/admin/indication'

module ODDB
  module State
    module Admin

class TestIndication <Minitest::Test
  include FlexMock::TestCase
  def setup
    @app     = flexmock('app', :delete => 'delete')
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    registration = flexmock('registration')
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :app => @app
                       )
    @model   = flexmock('model', 
                        :registrations => [registration],
                        :pointer => 'pointer'
                       ).by_default
    @state   = ODDB::State::Admin::Indication.new(@session, @model)
    flexmock(@state, :indications => ['indication'])
  end
  def test_delete
    assert_kind_of(ODDB::State::Admin::MergeIndication, @state.delete)
  end
  def test_delete__empty
    flexmock(@model, 
             :sequences => [], 
             :registrations => []
            )
    assert_equal(['indication'], @state.delete)
  end
  def test_duplicate__true
    flexmock(@app, :indication_by_text => 'indication_by_text') 
    assert(@state.duplicate?('string'))
  end
  def test_duplicate__false
    assert_equal(false, @state.duplicate?(''))
  end
  def test_update
    flexmock(@app, :update => 'update')
    flexmock(@lnf, :languages => ['language'])
    flexmock(@session, :user_input => '')
    flexmock(@state, :unique_email => 'unique_email')
    assert_equal(@state, @state.update)
  end
  def test_update__error
    flexmock(@app, :indication_by_text => 'indication_by_text') 
    flexmock(@lnf, :languages => ['language'])
    flexmock(@session, :user_input => 'user_input')
    assert_equal(@state, @state.update)
  end
end

    end # Admin
  end # State
end # ODDB
