#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Admin::TestOrphanedPatinfoAssign -- oddb.org -- 21.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'htmlgrid/labeltext'
require 'state/admin/orphaned_patinfo_assign'
require 'state/admin/patinfo_preview'

module ODDB
	module State
		module Admin

class TestOrphanedPatinfoFacade < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
  end
  def test_structural_ancestors
    pointer  = flexmock('pointer', :resolve => 'resolve')
    language = flexmock('language', :pointer => pointer)
    state    = ODDB::State::Admin::OrphanedPatinfoAssign::OrphanedPatinfoFacade.new(language)
    app = flexmock('app')
    assert_equal(["resolve"], state.structural_ancestors(app))
  end
  def test_structural_ancestors__else
    language = flexmock('language', :pointer => nil)
    state    = ODDB::State::Admin::OrphanedPatinfoAssign::OrphanedPatinfoFacade.new(language)
    app = flexmock('app')
    assert_equal([], state.structural_ancestors(app))
  end
end

class TestOrphanedPatinfoAssign < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @sequence = flexmock('sequence')
    @app      = flexmock('app', :search_sequences => [@sequence])
    @lnf      = flexmock('lookandfeel', :lookup => 'lookup')
    @session  = flexmock('session', 
                          :lookandfeel => @lnf,
                          :app => @app
                         )
    @model    = flexmock('model')
    @state    = ODDB::State::Admin::OrphanedPatinfoAssign.new(@session, @model)
  end
  def test_init
    assert_equal([@sequence], @state.init)
  end
  def test_assign
    flexmock(@app, :accept_orphaned => 'accept_orphaned')
    flexmock(@model, :languages => 'languages')
    pointer = flexmock('pointer')
    flexmock(@session, 
             :error?     => nil,
             :user_input => {'key' => pointer}
            )
    assert_equal(@state, @state.assign)
  end
  def test_assign__else
    flexmock(@session, :error? => true)
    assert_equal(@state, @state.assign)
  end
  def test_named_sequences
    assert_equal([], @state.named_sequences('na'))
  end
  def test_named_sequences__else
    flexmock(@app, :search_sequences => "search_sequences"*10)
    assert_equal([], @state.named_sequences('name'))
  end
  def test_search_sequences
    flexmock(@model, :sequences= => nil)
    flexmock(@session, :user_input => 'name')
    assert_equal(@state, @state.search_sequences)
  end
  def test_search_sequences__else
    user_input = flexmock('user_input', :to_s => 123)
    flexmock(@session, :user_input => user_input)
    assert_equal(@state, @state.search_sequences)
  end
  def test_symbol
    assert_equal(:name_base, @state.symbol)
  end
  def test_preview
    flexmock(@model, :languages => {'language' => 'value'})
    flexmock(@session, :user_input => 'language')
    assert_kind_of(ODDB::State::Admin::PatinfoPreview, @state.preview)
  end
end

		end # Admin
	end # State
end # ODDB
