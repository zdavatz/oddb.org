#!/usr/bin/env ruby
# ODDB::View::TestForm -- oddb.org -- 24.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/form'
require 'util/persistence'

module ODDB
  module View

class StubViewForm < Form
  COMPONENTS = {}
end

class TestForm < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :base_url   => 'base_url',
                        :flavor     => 'flavor',
                        :language   => 'language',
                        :attributes => {},
                        :_event_url => '_event_url'
                       )
    state    = flexmock('state')
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :state => state,
                        :zone  => 'zone'
                       )
    @model   = flexmock('model')
    @form    = ODDB::View::StubViewForm.new(@model, @session)
  end
  def test_hidden_fields
    context = flexmock('context', :hidden => 'hidden')
    expected = "hiddenhiddenhiddenhiddenhidden"
    assert_equal(expected, @form.instance_eval('hidden_fields(context)'))
  end
  def test_hidden_fields__pointer
    flexmock(@model, :pointer => 'pointer')
    context = flexmock('context', :hidden => 'hidden')
    expected = "hiddenhiddenhiddenhiddenhiddenhidden"
    assert_equal(expected, @form.instance_eval('hidden_fields(context)'))
  end
  def test_delete_item
    assert_kind_of(HtmlGrid::Button, @form.instance_eval('delete_item(@model, @session)'))
  end
  def test_delete_item_warn
    assert_kind_of(HtmlGrid::Button, @form.instance_eval('delete_item_warn(@model, "warning")'))
  end
  def test_post_event_button
    assert_kind_of(HtmlGrid::Button, @form.instance_eval('post_event_button("event")'))
  end
  def test_get_event_button
    assert_kind_of(HtmlGrid::Button, @form.instance_eval('get_event_button("event")'))
  end

end

  end # View
end # ODDB

