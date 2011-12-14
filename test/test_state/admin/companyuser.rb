#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Admin::TestCompanyUser -- oddb.org -- 17.06.2011 -- mhatakeyama@ywesee.com
# ODDB::State::Admin::TestCompanyUser -- oddb.org -- 07.10.2003 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'state/global'
require 'state/admin/companyuser'
require 'flexmock'

module ODDB
	module State
		module Admin
class TestCompanyUserState < Test::Unit::TestCase
  include FlexMock::TestCase
	class StubSession
		attr_accessor :user_input, :user
		def user_input(*keys); end
		def app; end
		def logout; end
		def user
			self
		end
		def model
			'user_model'
		end
	end

	def setup
		@session = StubSession.new
		@state = State::Drugs::Init.new(@session, [1,11,2,22,3,33])
	end
	def test_extend_state
		@state.extend(State::Admin::CompanyUser)
		assert(@state.is_a?(State::Admin::CompanyUser), 'extend did not work')
	end
	def test_login
		@state.extend(State::Admin::CompanyUser)
		state = @state.trigger(:login_form)
		assert_equal(State::Admin::Login, state.class)
		assert(state.is_a?(State::Admin::CompanyUser), 'trigger did not pass on CompanyUserState')
	end
	def test_logout
		@state.extend(State::Admin::CompanyUser)
		state = @state.trigger(:logout)
		assert_equal(State::Drugs::Init, state.class)
		assert(!state.is_a?(State::Admin::CompanyUser), 'should not include CompanyUserState after logout')
#		state = @state.trigger(:login)
	end
	def test_new_registration
    flexstub(@session) do |ses|
      ses.should_receive(:model).and_return(flexmock('model') do |model|
        model.should_receive(:name).and_return('user_model')
      end)
    end
		@state.extend(State::Admin::CompanyUser)
		regstate = @state.new_registration
		assert_equal('user_model', regstate.model.company_name)
	end
end

class TestCompanyUser < Test::Unit::TestCase
  include FlexMock::TestCase
  class StubSuper
    def resolve_state(pinter, type)
      'resolve_state'
    end
  end
  class StubCompanyUser < StubSuper
    include ODDB::State::Admin::CompanyUser
    def initialize(model, session)
      @model = model
      @session = session
      @viral_modules = []
    end
  end
  def setup
    @session = flexmock('session')
    @model   = flexmock('model')
    @state   = StubCompanyUser.new(@model, @session)
  end
  def test_fipi_overview
    company = flexmock('company')
    flexmock(@session, :"user.model" => company)
    assert_kind_of(ODDB::State::Companies::FiPiOverview, @state.fipi_overview)
  end
  def test_new_fachinfo
    registration = flexmock('registration', 
                            :name_base => 'name_base',
                            :company   => 'company'
                           )
    pointer = flexmock('pointer', :resolve => registration)
    flexmock(@session, 
             :user_input => pointer,
             :allowed?   => true,
             :language   => 'language'
            )
    flexmock(ODBA.cache, :next_id => 123)
    assert_kind_of(ODDB::State::Drugs::RootFachinfo, @state.new_fachinfo)
  end
  def test_limited
    assert_equal(false, @state.limited?)
  end
  def test_patinfo_stats
    assert_kind_of(ODDB::State::Admin::PatinfoStatsCompanyUser, @state.patinfo_stats)
  end
  def test_patinfo_stats_company
    assert_kind_of(ODDB::State::Admin::PatinfoStatsCompanyUser, @state.patinfo_stats_company)
  end
  def test_zones
    expected = [:admin, :analysis, :interactions,:drugs, :migel, :user, :substances, :companies]
    assert_equal(expected, @state.zones)
  end
  def test_home_companies
    user = flexmock('user', :model => @model)
    flexmock(@session, :user => user)
    assert_kind_of(ODDB::State::Companies::UserCompany, @state.home_companies)
  end
  def test_home_companies__user_company
    user = flexmock('user', :model => @model)
    flexmock(@session, :user => user)
    flexmock(@state, :is_a? => true)
    assert_kind_of(ODDB::State::Companies::Init, @state.home_companies)
  end
  def test_resolve_state
    flexmock(@session, :allowed? => true)
    pointer = flexmock('pointer', 
                       :skeleton => [:company],
                       :to_yus_privilege => 'to_yus_privilege'
                      )
    assert_equal(ODDB::State::Companies::UserCompany, @state.resolve_state(pointer))
  end
  def test_resolve_state__else
    flexmock(@session, :allowed? => false)
    pointer = flexmock('pointer', 
                       :skeleton => [:company],
                       :to_yus_privilege => 'to_yus_privilege'
                      )
    assert_equal('resolve_state', @state.resolve_state(pointer))
  end

end

		end
	end
end
