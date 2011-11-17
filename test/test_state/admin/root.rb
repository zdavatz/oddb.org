#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Admin::TestRoot -- oddb.org -- 17.11.2011 -- mhatakeyama@ywesee.com
# ODDB::State::Admin::TestRoot -- oddb.org -- 13.10.2003 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'state/drugs/init'
require 'state/global'
require 'util/persistence'
require 'state/admin/login'
require 'state/admin/root'
require 'model/commercial_form'
require 'state/companies/fipi_overview'
require 'util/persistence'

module ODDB
	module State
		module Admin
class StubResolved; end
class StubResolvedState < State::Admin::Global; end
class StubResolvedRootState < State::Admin::Global
	include State::Admin::Root
end
module Root
	remove_const :RESOLVE_STATES
	RESOLVE_STATES = {
		[:resolve] =>	State::Admin::StubResolvedRootState,
	}
end
		end
		module Drugs
class Init < State::Drugs::Global
	RESOLVE_STATES = {
		[:resolve] =>	State::Admin::StubResolvedState
	}
end
		end

		module Admin
class TestRootState < Test::Unit::TestCase 
	class StubSession
		attr_accessor :user_input
		def user_input(*keys)
			if(keys.size > 1)
				res = {}
				keys.each { |key|
					res.store(key, user_input(key))
				}
				res
			else
				key = keys.first
				(@user_input ||= {
					:pointer	=>	StubPointer.new
				})[key]
			end
		end
		def logout
		end
	end
	class StubApp
		def invoice(key)
			@invoice_result
		end
	end
	class StubPointer
		def resolve(app)
			@model ||= State::Admin::StubResolved.new
		end
		def skeleton
			[:resolve]
		end
	end
	class TestState
		attr_accessor :session
		include State::Admin::Root
	end
	def setup
		@session = StubSession.new
		@state = State::Drugs::Init.new(@session, @session)
	end
	def test_resolve_root_state
		pointer = Persistence::Pointer.new([:resolve, "foo", "bar"])
		assert_equal(State::Admin::StubResolvedState, @state.resolve_state(pointer))
		@state.extend(State::Admin::Root)
		assert_equal(State::Admin::StubResolvedRootState, @state.resolve_state(pointer))
	end
	def test_root_state
		@state.extend(State::Admin::Root)
		assert(@state.is_a?(State::Admin::Root), 'extend did not work')
		state = @state.trigger(:login_form)
		assert_equal(State::Admin::Login, state.class)
		assert(state.is_a?(State::Admin::Root), 'trigger did not pass on RootState')
	#	newstate = state.trigger(:resolve)
	#	assert_equal(State::Admin::StubResolvedRootState, newstate.class)
		state = state.trigger(:logout)
		assert_equal(State::Drugs::Init, state.class)
		assert(!state.is_a?(State::Admin::Root), 'should not include RootState after logout')
	end
	def test_new_registration
		@state.extend(State::Admin::Root)
		regstate = @state.new_registration
		assert_equal(nil, regstate.model.company)
	end
end
		end
	end
end

module ODDB
  module State
    module Admin
      class Entity < ODDB::State::Admin::Global; end
    end
  end
end
class TestODDBStateAdminRoot < Test::Unit::TestCase
  include FlexMock::TestCase
  class StubState < ODDB::State::Admin::Global
    include ODDB::State::Admin::Root
  end
  def setup
    company      = flexmock('company')
    registration = flexmock('registration', 
                            :name_base => 'name_base',
                            :company   => company
                           )
    @app     = flexmock('app', 
                        :address_suggestions => {'key' => 'value'},
                        :registration => registration
                       )
    @model   = flexmock('model')
    @session = flexmock('session', :app => @app)
    @state   = StubState.new(@session, @model)
  end
  def test_addresses
    assert_kind_of(ODDB::State::Admin::Addresses, @state.addresses)
  end
  def test_commercial_forms
    flexmock(ODDB::CommercialForm, :odba_extent => 'odba_extent')
    assert_kind_of(ODDB::State::Admin::CommercialForms, @state.commercial_forms)
  end
  def test_effective_substances
    substance = flexmock('substance', :is_effective_form? => nil)
    flexmock(@session, :substances => [substance])
    assert_kind_of(ODDB::State::Substances::EffectiveSubstances, @state.effective_substances)
  end
  def test_fipi_overview
    pointer = flexmock('pointer', :resolve => 'company')
    flexmock(@session, :user_input => pointer)
    flexmock(@app, :company => 'company')
    assert_kind_of(ODDB::State::Companies::FiPiOverview, @state.fipi_overview)
  end
  def test_galenic_groups
    galenic_group = flexmock('galenic_group')
    flexmock(@app, :galenic_groups => {'key' => galenic_group})
    assert_kind_of(ODDB::State::Admin::GalenicGroups, @state.galenic_groups)
  end
  def test_indications
    flexmock(@app, :indications => 'model')
    assert_kind_of(ODDB::State::Admin::Indications, @state.indications)
  end
  def test_limited
    assert_equal(false, @state.limited?)
  end
  def test_new_commercial_form
    assert_kind_of(ODDB::State::Admin::CommercialForm, @state.new_commercial_form)
  end
  def test_new_company
    assert_kind_of(ODDB::State::Companies::RootCompany, @state.new_company)
  end
  def test_new_fachinfo
    flexmock(@session, :language => 'language')
    flexmock(ODBA.cache, :next_id => 123)
    registration = flexmock('registration', 
                            :name_base => 'name_base',
                            :company   => 'company'
                           )
    pointer = flexmock('pointer', :resolve => registration)
    flexmock(@session, :user_input => pointer)
    assert_kind_of(ODDB::State::Drugs::RootFachinfo, @state.new_fachinfo)
  end
  def test_new_galenic_form
    pointer = flexmock('pointer', :resolve => 'model')
    flexmock(pointer, :+ => pointer)
    flexmock(@session, :user_input => pointer)
    assert_kind_of(ODDB::State::Admin::GalenicForm, @state.new_galenic_form)
  end
  def test_new_galenic_group
    assert_kind_of(ODDB::State::Admin::GalenicGroup, @state.new_galenic_group)
  end
  def test_new_indication
    assert_kind_of(ODDB::State::Admin::Indication, @state.new_indication)
  end
  def test_new_registration
    flexmock(@model, 
             :is_a? => true,
             :name  => 'name'
            )
    assert_kind_of(ODDB::State::Admin::Registration, @state.new_registration)
  end
  def test_new_substance
    assert_kind_of(ODDB::State::Substances::Substance, @state.new_substance)
  end
  def test_new_user
    assert_kind_of(ODDB::State::Admin::Entity, @state.new_user)
  end
  def test_new_user__company
    flexmock(ODBA.cache, :next_id => 123)
    odba_instance = ODDB::Company.new
    pointer = flexmock('pointer', :to_yus_privilege => 'to_yus_priviledge')
    flexmock(@model, 
             :odba_instance => odba_instance,
             :pointer       => pointer,
             :contact_email => 'contact_email',
             :contact       => 'firstname lastname'
            )
    assert_kind_of(ODDB::State::Admin::Entity, @state.new_user)
  end
  def test_orphaned_fachinfos
    flexmock(@app, :orphaned_fachinfos => {'key' => 'value'})
    assert_kind_of(ODDB::State::Admin::OrphanedFachinfos, @state.orphaned_fachinfos)
  end
  def test_orphaned_patinfos
    flexmock(@app, :orphaned_patinfos => {'key' => 'value'})
    assert_kind_of(ODDB::State::Admin::OrphanedPatinfos, @state.orphaned_patinfos)
  end
  def test_patinfo_deprived_sequences 
    galenic_group = flexmock('galenic_group', :de => 'Infxxx')
    galenic_form  = flexmock('galenic_form', :galenic_group => galenic_group)
    sequence      = flexmock('sequence', 
                             :patinfo_shadow => nil,
                             :"patinfo.nil?" => true,
                             :active?        => true,
                             :packages       => ['package'],
                             :galenic_form   => galenic_form
                            )
    registration  = flexmock('registration', :sequences => {'key' => sequence})
    flexmock(@app, :registrations => {'key' => registration})
    assert_kind_of(ODDB::State::Admin::PatinfoDeprivedSequences, @state.patinfo_deprived_sequences)
  end
  def test_patinfo_stats
    assert_kind_of(ODDB::State::Admin::PatinfoStats, @state.patinfo_stats)
  end
  def test_sponsor
    flexmock(ODDB::Persistence::Pointer).new_instances do |p|
      p.should_receive(:resolve).and_return('model')
    end
    flexmock(@session, :flavor => 'flavor')
    assert_kind_of(ODDB::State::Admin::Sponsor, @state.sponsor)
  end
  def test_substances
    flexmock(@session, :substances => 'model')
    assert_kind_of(ODDB::State::Substances::Substances, @state.substances)
  end
  def test_user
    flexmock(@session, 
             :user_input         => 'name',
             :"user.find_entity" => 'user'
            )
    assert_kind_of(ODDB::State::Admin::Entity, @state.user)
  end
  def test_zones
    expected = [:admin, :analysis, :doctors, :interactions, :drugs, :migel, :user, :hospitals, :substances, :companies]
    assert_equal(expected, @state.zones)
  end
end
