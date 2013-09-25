#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::TestLookandfeelComponents -- oddb.org -- 05.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/lookandfeel_components'

module ODDB
	module View

class StubLookandfeelComponents
  CSS_KEYMAP = {'value' => 'klass'}
  CSS_HEAD_KEYMAP = {'value' => 'map'}
  include LookandfeelComponents
  def initialize(model, session)
    @model = model
    @session = session
    @lookandfeel = session.lookandfeel
  end
end
class TestLookandfeelComponents <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup => 'lookup',
                        :lookandfeel_key => {'key' => 'value'}
                       )
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model')
    @view    = ODDB::View::StubLookandfeelComponents.new(@model, @session)
  end
  def test_reorganize_components
    expected = {"key" => "value"}
    assert_equal(expected, @view.reorganize_components('lookandfeel_key'))
  end
end

	end # View
end # ODDB
