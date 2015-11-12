#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Admin::TestOrphanedPatinfo -- oddb.org -- 28.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'state/global'
gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'state/admin/orphaned_patinfo'
require 'util/pointerarray'


module ODDB
  module State
    module Admin

class TestOrphanedPatinfo <Minitest::Test
  include FlexMock::TestCase
  def setup
    @app     = flexmock('app')
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :app => @app
                       )
    @model   = flexmock('model', 
                        :meanings => [{'key' => 'meaning'}],
                        :pointer  => 'pointer'
                       )
    @state   = ODDB::State::Admin::OrphanedPatinfo.new(@session, @model)
  end
  def test_init
    assert_equal(nil, @state.init)
  end
  def test_choice
    flexmock(@session, :user_input => {:state_id => 123, :meaning_index => 0})
    assert_kind_of(ODDB::State::Admin::OrphanedPatinfoAssign, @state.choice)
  end
  def test_choice__error
    flexmock(@session, :user_input => {:meaning_index => 0})
    flexmock(@state, :error? => true)
    assert_equal(@state, @state.choice)
  end
  def test_delete_orphaned_patinfo
    flexmock(@app, :delete => 'delete')
    flexmock(@state, :orphaned_patinfos => 'orphaned_patinfos')
    assert_equal('orphaned_patinfos', @state.delete_orphaned_patinfo)
  end
  def test_preview
    flexmock(@session, :user_input => {:index => 0, :language_select => 'language_select'})
    assert_kind_of(ODDB::State::Admin::PatinfoPreview, @state.preview)
  end
  def test_preview__error
    flexmock(@session, :user_input => {:index => 0})
    flexmock(@state, :error? => true)
    assert_equal(@state, @state.preview)
  end
end

    end # Admin
  end # State
end # ODDB
