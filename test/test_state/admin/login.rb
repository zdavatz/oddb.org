#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Admin::TestLogin -- oddb.org -- 21.06.2011 -- mhatakeyama@ywesee.com
# ODDB::State::Admin::TestLogin -- oddb.org -- 13.10.2003 -- mhuggler@ywesee.com

#$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'state/admin/login'
require 'state/global'
require 'util/language'
require 'flexmock'

class StubResolvedRootState < ODDB::State::Global
	include ODDB::State::Admin::Root
end

module ODDB
	module State
		module Admin
module Root
	remove_const :RESOLVE_STATES
	RESOLVE_STATES = {
		[:resolve] =>	StubResolvedRootState,
	}
end

class StubLoginMethods
  include ODDB::State::Admin::LoginMethods
  attr_accessor  :http_headers
  def initialize(session)
    @session = session
    @errors  = {}
  end
  def request_path
    'dummyLocation'
  end
end

class TestLoginMethods < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @session      = flexmock('session')
    @loginmethods = ODDB::State::Admin::StubLoginMethods.new(@session)
  end
  def test_autologin
    user = flexmock('user', 
                    :valid?   => nil,
                    :allowed? => nil
                   )
    assert_kind_of(ODDB::State::User::InvalidUser, @loginmethods.autologin(user))
  end
  def test_autologin__valid
    state = flexmock('state', :augment_self => 'augment_self', :request_path => 'request_path')
    flexmock(@session, 
             :desired_state  => state,
             :desired_state= => nil
            )
    user = flexmock('user', 
                    :valid?   => true,
                    :allowed? => nil
                   )
    assert_equal('augment_self', @loginmethods.autologin(user))
  end
  def test_autologin__allowed
    state = flexmock('state', :augment_self => 'augment_self', :request_path => 'request_path')
    flexmock(@session, 
             :desired_state  => state,
             :desired_state= => nil
            )
    user = flexmock('user', 
                    :valid?   => true,
                    :allowed? => true
                   )
    assert_equal('augment_self', @loginmethods.autologin(user))
  end

  def test_login
    user = flexmock('user', 
                    :valid?   => nil,
                    :allowed? => nil
                   )
    flexmock(@session, :login => user)
    assert_kind_of(ODDB::State::User::InvalidUser, @loginmethods.login)
  end
  def test_login__unknownentityerror
    user = flexmock('user', 
                    :valid?   => nil,
                    :allowed? => nil
                   )
    flexmock(@session) do |s|
      s.should_receive(:login).and_raise(Yus::UnknownEntityError)
    end
    flexmock(@loginmethods, :create_error => 'create_error')
    assert_equal(@loginmethods, @loginmethods.login)
  end
  def test_login__authentificationerror
    user = flexmock('user', 
                    :valid?   => nil,
                    :allowed? => nil
                   )
    flexmock(@session) do |s|
      s.should_receive(:login).and_raise(Yus::AuthenticationError)
    end
    flexmock(@loginmethods, :create_error => 'create_error')
    assert_equal(@loginmethods, @loginmethods.login)
  end
end

class TestTransparentLogin < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    user     = flexmock('user', 
                        :valid?   => nil,
                        :allowed? => nil
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :login       => user
                       )
    @model   = flexmock('model')
    @state   = ODDB::State::Admin::TransparentLogin.new(@session, @model)
  end
  def test_login
    assert_equal(@state, @state.login)
  end
  def test_login__unknownentityerror
    flexmock(@session) do |s|
      s.should_receive(:login).and_raise(Yus::UnknownEntityError)
    end
    assert_equal(@state, @state.login)
  end
  def test_login__authentificationerror
    flexmock(@session) do |s|
      s.should_receive(:login).and_raise(Yus::AuthenticationError)
    end
    assert_equal(@state, @state.login)
  end
end

class TestTransparentLoginState < Test::Unit::TestCase
  include FlexMock::TestCase
	class StubSession
		def app
			@app ||= StubApp.new
		end
		def login
			StubUser.new
		end
	end
	class StubApp
		attr_accessor :state_transp_called
		def initialize
			@state_transp_called = false
		end
		def company(oid)
			@companies[oid.to_i]
		end
		def galenic_group(oid)
			@galenic_groups[oid.to_i]
		end
	end
	class StubUser
		def viral_module
			State::Admin::Root
		end
	end
	class StubGalenicGroup
		include Language
	end

	def setup
		@session = StubSession.new
	end

	def test_transparent_login
    flexstub(ODBA.cache) do |cache|
      cache.should_receive(:next_id).and_return(123)
    end
    user = flexmock('user') do |usr|
      usr.should_receive(:valid?)
      usr.should_receive(:allowed?)
    end
    flexstub(@session) do |ses|
      ses.should_receive(:login).and_return(user)
    end
		model = StubGalenicGroup.new
		pointer = Persistence::Pointer.new([:resolve, 3])
		model.pointer = pointer
		state = State::Admin::TransparentLogin.new(@session, model)
    newstate = flexmock('newstate') do |sta|
      sta.should_receive(:extend)
    end
    klass = flexmock('klass') do |klass|
      klass.should_receive(:new).and_return(newstate)
    end
    flexstub(state) do |sta|
      sta.should_receive(:resolve_state).and_return(klass)
    end
		expected = state.login
		assert_equal(expected, state.login)
	end
end
		end
	end
end
