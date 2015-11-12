#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::User::TestContributor -- oddb.org -- 30.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../../../src', File.dirname(__FILE__))


gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'state/user/contributor'

module ODDB
  module State
    module User

class StubSuper
  def resolve_state(pointer, type)
    'resolve_state'
  end
end
class StubContributor < StubSuper
  include ODDB::State::User::Contributor
  RESOLVE_STATES = {'skeleton' => self}
  def initialize(session, model)
    @model = model
    @session = session
    @viral_module = ODDB::State::User::StubContributor
  end
end

class TestContributor <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    object   = flexmock('object', :pointer => 'pointer')
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :[] => [object]
                       )
    @model   = flexmock('model')
    @state   = ODDB::State::User::StubContributor.new(@session, @model)
  end
  def test_resolve_state
    pointer = flexmock('pointer', 
                       :skeleton => 'skeleton',
                       :parent   => 'pointer'
                      )
    assert_equal(@state.class, @state.resolve_state(pointer))
  end
  def test_resolve_state__else
    pointer = flexmock('pointer', :skeleton => '')
    assert_equal('resolve_state', @state.resolve_state(pointer, 'type'))
  end
end

    end # User
  end # State
end # ODDB
