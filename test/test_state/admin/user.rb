#!/usr/bin/env ruby
# ODDB::State::Admin::TestUser -- oddb.org -- 29.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'state/global'
module ODDB
  module State
    module Drugs
      class Fachinfo < Global; end
      class RootFachinfo < Fachinfo; end
    end
  end
end

require 'test/unit'
require 'flexmock'
require 'state/admin/user'
require 'state/admin/logout'
require 'state/drugs/fachinfo'

module ODDB
  module State
    module Admin

class StubSuper
  def resolve_state(pointer, type)
    'resolve_state'
  end
end
class StubUser < StubSuper
  include ODDB::State::Admin::User
  def initialize(session, model)
    @model = model
    @session = session
    @viral_modules = [ODDB::State::Admin::User]
  end
  def new_fachinfo(registration)
    _new_fachinfo(registration)
  end
end
class TestUser < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @session = flexmock('session')
    @model   = flexmock('model')
    @state   = ODDB::State::Admin::StubUser.new(@session, @model)
  end
  def test_resolve_state__type_standard
    pointer = flexmock('pointer', :skeleton => 'skeleton')
    assert_equal('resolve_state', @state.resolve_state(pointer))
  end
  def test_resolve_state__type_not_standard
    pointer = flexmock('pointer', :skeleton => 'skeleton')
    assert_equal('resolve_state', @state.resolve_state(pointer, :not_standard))
  end
  def test_user_navigation
    assert_equal([ODDB::State::Admin::Logout], @state.user_navigation)
  end
  def test_new_fachinfo
    flexmock(ODBA.cache, :next_id => 123)
    registration = flexmock('registration', 
                            :name_base => 'name_base',
                            :company   => 'company'
                           )
    flexmock(@session, :language => 'language')
    assert_kind_of(ODDB::State::Drugs::RootFachinfo, @state.new_fachinfo(registration))
  end
end

    end # Admin
  end # State
end # ODDB

