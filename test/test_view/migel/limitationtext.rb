#!/usr/bin/env ruby
# ODDB::View::Migel::TestLimitationText -- oddb.org -- 28.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/migel/limitationtext'

module ODDB
  module View
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
    @model   = flexmock('model', :pointer => pointer)
    @view    = ODDB::View::Migel::LimitationTextComposite.new(@model, @session)
  end
  def test_limitation_text_title
    assert_equal('lookup', @view.limitation_text_title(@model, @session))
  end
end

    end # Migel
  end # View
end # ODDB
