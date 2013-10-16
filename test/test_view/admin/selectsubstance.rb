#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Admin::TestSelectSubstance -- oddb.org -- 27.03.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/admin/selectsubstance'


module ODDB
  module View
    module Admin

class TestSelectSubstanceForm <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :base_url   => 'base_url'
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :event       => 'event'
                       )
    @model   = flexmock('model', 
                        :selection     => '',
                        :new_substance => 'new_substance',
                        :user_input     => { 'user_input' => 'x'},
                       )
    @form    = ODDB::View::Admin::SelectSubstanceForm.new(@model, @session)
  end
  def test_init
    expected = {"NAME"=>"stdform", "METHOD"=>"POST", "ACTION"=>"base_url", "ACCEPT-CHARSET"=>"#<Encoding:UTF-8>"}
    skip('Niklaus does not know how to produce "ACCEPT-CHARSET"=>#<Encoding:UTF-8>}')
    assert_equal(expected, @form.init)
  end
  def test_selection_list
    assert_kind_of(ODDB::View::Admin::SelectionList, @form.selection_list(@model, @session))
  end
end

class TestSelectSubstanceComposite <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :base_url   => 'base_url'
                         )
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :event       => 'event'
                         )
    sequence   = flexmock('sequence', :name => 'name')
    active_agent = flexmock('active_agent', :sequence => sequence)
    @model     = flexmock('model', 
                          :selection     => '',
                          :active_agent  => active_agent,
                          :new_substance => 'new_substance',
                          :user_input     => { 'user_input' => 'x'},
                          :assigned      => ['assigned'],
                         )
    @composite = ODDB::View::Admin::SelectSubstanceComposite.new(@model, @session)
  end
  def test_init
    assert_equal({}, @composite.init)
  end
end

    end # Admin
  end # View
end # ODDB
