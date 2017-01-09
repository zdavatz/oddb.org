#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Drugs::TestLimitationText -- oddb.org -- 29.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))


require 'minitest/autorun'
require 'flexmock/minitest'
require 'view/drugs/limitationtext'


module ODDB
  module View
    module Drugs

class TestLimitationTextInnerComposite <Minitest::Test
  def setup
    @lnf       = flexmock('lookandfeel', :lookup => 'lookup')
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :language    => 'language'
                         )
    @model     = flexmock('model', :language => 'language')
    @composite = ODDB::View::Drugs::LimitationTextInnerComposite.new(@model, @session)
  end
  def test_init
    assert_equal({}, @composite.init)
  end
end

class TestLimitationTextComposite <Minitest::Test
  def setup
    @app       = flexmock('app')
    @lnf       = flexmock('lookandfeel', :lookup => 'lookup')
    @session   = flexmock('session', 
                          :app => @app,
                          :lookandfeel => @lnf,
                          :language    => 'language'
                         )
    parent     = flexmock('parent', :name_base => 'name_base')
    slentry    = flexmock('slentry', :"parent.resolve" => parent)
    @model     = flexmock('model', :"pointer.parent" => slentry)
    @composite = ODDB::View::Drugs::LimitationTextComposite.new(@model, @session)
  end
  def test_limitation_text_title
    assert_equal('lookup', @composite.limitation_text_title(@model, @session))
  end
end

    end # Drugs
  end # View
end # ODDB

