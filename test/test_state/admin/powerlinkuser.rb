#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Admin::TestPowerLinkUser -- oddb.org -- 29.06.2011 -- mhatakeyama@ywesee.com

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
gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'state/admin/powerlinkuser'
require 'state/companies/fipi_overview'

module ODDB
  module State
    module Admin

class StubPowerLinkUser
  include ODDB::State::Admin::PowerLinkUser
  def initialize(session, model)
    @model = model
    @session = session
  end
end

class TestPowerLinkUser <Minitest::Test
  include FlexMock::TestCase
  def setup
    @app     = flexmock('app')
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @company = flexmock('company')
    pointer  = flexmock('pointer', :resolve => @company)
    @session = flexmock('session', 
                        :app => @app,
                        :lookandfeel => @lnf,
                        :user_input  => pointer
                       )
    @model   = flexmock('model')
    @state   = ODDB::State::Admin::StubPowerLinkUser.new(@session, @model)
  end
  def test_fipi_overview
    assert_kind_of(ODDB::State::Companies::FiPiOverview, @state.fipi_overview)
  end
  def test_new_fachinfo
    flexmock(@session, :language => 'language')
    flexmock(ODBA.cache, :next_id => 123)
    flexmock(@company, 
             :name_base => 'name_base',
             :company   => @company
            )
    assert_kind_of(ODDB::State::Drugs::RootFachinfo, @state.new_fachinfo)
  end
  def test_limited
    assert_equal(false, @state.limited?)
  end
end

    end # Admin
  end # State
end # ODDB
