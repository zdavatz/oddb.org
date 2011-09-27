#!/usr/bin/env ruby
# ODDB::View::Migel::TestLimitationText -- oddb.org -- 16.09.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/migel/limitationtext'

module ODDB
  module View
    Copyright::ODDB_VERSION = 'version'
    module Migel

class TestLimitationTextInnerComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @app     = flexmock('app')
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', 
                        :app => @app,
                        :lookandfeel => @lnf,
                        :language    => 'language'
                       )
    @limitation_text = flexmock('limitation_text', :language => 'language')
    subgroup = flexmock('subgroup', :limitation_text => @limitation_text)
    @product = flexmock('product', :subgroup => subgroup)
    @model   = flexmock('model', :parent => @product)
    @view    = ODDB::View::Migel::LimitationTextInnerComposite.new(@model, @session)
  end
  def test_subgroup
    assert_equal('language', @view.subgroup(@model, @session))
  end
  def test_group
    group = flexmock('group', :limitation_text => @limitation_text)
    flexmock(@product, :group => group)
    assert_equal('language', @view.group(@model, @session))
  end
end

class TestLimitationTextComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @app     = flexmock('app')
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', 
                        :app => @app,
                        :lookandfeel => @lnf,
                        :language    => 'language'
                       )
    parent   = flexmock('parent', :language => 'language')
    pointer  = flexmock('pointer', :resolve => parent)
    flexmock(pointer, :parent => pointer)
    @model   = flexmock('model', 
                        :pointer => pointer,
                        :parent  => parent
                       )
    @view    = ODDB::View::Migel::LimitationTextComposite.new(@model, @session)
  end
  def test_limitation_text_title
    assert_equal('lookup', @view.limitation_text_title(@model, @session))
  end
end

class TestLimitationText < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :enabled?   => nil,
                        :attributes => {},
                        :resource   => 'resource',
                        :lookup     => 'lookup',
                        :zones      => 'zones',
                        :disabled?  => nil,
                        :direct_event => 'direct_event',
                        :_event_url => '_event_url',
                        :zone_navigation => 'zone_navigation',
                        :navigation => 'navigation',
                        :base_url   => 'base_url'
                       )
    @app     = flexmock('app')
    user     = flexmock('user', :valid? => nil)
    parent   = flexmock('parent', :language => 'language')
    @model   = flexmock('model', 
                        :pointer => 'pointer',
                        :parent  => parent,
                        :migel_code => 'migel_code'
                       )
    state    = flexmock('state', 
                        :direct_event => 'direct_event',
                        :snapback_model => @model
                       )
    @session = flexmock('session', 
                        :app  => @app,
                        :lookandfeel => @lnf,
                        :user    => user,
                        :sponsor => user,
                        :state   => state,
                        :allowed? => nil,
                        :language => 'language',
                        :zone    => 'zone'
                       )
    @view    = ODDB::View::Migel::LimitationText.new(@model, @session)
  end
  def test_backtracking
    assert_kind_of(ODDB::View::PointerSteps, @view.backtracking(@model))
  end
end
    end # Migel
  end # View
end # ODDB
