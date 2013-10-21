#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Admin::TestOrphanedFachinfoAssign -- oddb.org -- 22.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'state/drugs/global'
module ODDB
  module State
    module Drugs
      class Fachinfo < State::Drugs::Global;end
      class RootFachinfo < Fachinfo;end
    end
  end
end


gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'htmlgrid/labeltext'
require 'state/admin/orphaned_fachinfo_assign'
require 'state/drugs/fachinfo'

module ODDB
	module State
		module Admin

class TestOrphanedFachinfoFacade <Minitest::Test
  include FlexMock::TestCase
  def setup
    @app    = flexmock('app')
    @facade = ODDB::State::Admin::OrphanedFachinfoAssign::OrphanedFachinfoFacade.new(@app)
  end
  def test_structural_ancestors
    parent_pointer = flexmock('parent_pointer', :resolve => 'resolve')
    @facade.instance_eval('@parent_pointer = parent_pointer')
    assert_equal(['resolve'], @facade.structural_ancestors(@app))
  end
  def test_structural_ancestors__else
    assert_equal([], @facade.structural_ancestors(@app))
  end
end

class TestOrphanedFachinfoAssign <Minitest::Test
  include FlexMock::TestCase
  def setup
    sequence = flexmock('sequence', :registration => 'registration')
    @app     = flexmock('app', :search_sequences => [sequence]).by_default
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :app    => @app,
                        :error? => nil
                       )
    @model   = flexmock('model', :name => 'name', :languages => 'languages')
    @state   = ODDB::State::Admin::OrphanedFachinfoAssign.new(@session, @model)
  end
  def test_init
    assert_equal(['registration'], @state.init)
  end
  def test_assign
    flexmock(@app, :accept_orphaned => 'accept_orphaned')
    flexmock(@model, :languages => 'languages')
    pointer = flexmock('pointer')
    flexmock(@session, :user_input  => {'key' => pointer})
    assert_equal(@state, @state.assign)
  end
  def test_assign__else
    user_input = flexmock('user_input', :values => 'values', :empty? => true)
    flexmock(@session, :error? => true, :user_input => user_input)
    assert_equal(@state, @state.assign)
  end
  def test_delete_orphaned_fachinfo
    flexmock(@model, :pointer => 'pointer')
    flexmock(@app, :delete => 'delete')
    flexmock(@state, :orphaned_fachinfos => 'orphaned_fachinfos')
    assert_equal('orphaned_fachinfos', @state.delete_orphaned_fachinfo)
  end
  def test_named_registrations
    assert_equal(["registration"], @state.named_registrations('name'))
  end
  def test_named_registrations__short_name
    assert_equal([], @state.named_registrations('na'))
  end
  def test_named_registrations__long_registration
    sequences = Array.new(51).map{flexmock('sequence', :registration => flexmock('registration'))}
    flexmock(@app, :search_sequences => sequences)
    assert_equal([], @state.named_registrations('name'))
  end
  def test_search_registrations
    flexmock(@model, :registrations= => nil)
    flexmock(@session, :user_input => 'name')
    assert_equal(@state, @state.search_registrations)
  end
  def test_search_registrations__else
    flexmock(@model, :registrations= => nil)
    flexmock(@session, :user_input => 123)
    assert_equal(@state, @state.search_registrations)
  end
  def test_symbol
    assert_equal(:name_base, @state.symbol)
  end
  def test_preview
    flexmock(@model, :languages => {'languages' => 'document'})
    flexmock(@session, :user_input => 'language')
    assert_kind_of(ODDB::State::Drugs::FachinfoPreview, @state.preview)
  end
end

		end # Admin
	end # State
end # ODDB

