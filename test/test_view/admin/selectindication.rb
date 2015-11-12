#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Admin::TestSelectIndication -- oddb.org -- 27.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/admin/selectindication'


module ODDB
  module View
    module Admin

class TestSelectIndicationForm <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :base_url   => 'base_url'
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :event => 'event'
                       )
    @model   = flexmock('model', 
                        :selection      => [],
                        :new_indication => 'new_indication',
                        :user_input     => { 'user_input' => 'x'},
                       )
    @form    = ODDB::View::Admin::SelectIndicationForm.new(@model, @session)
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

class TestSelectIndicationComposite <Minitest::Test
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
    registration = flexmock('registration', :name_base => 'name_base')
    @model     = flexmock('model', 
                          :registration   => registration,
                          :selection      => ['selection'],
                          :new_indication => 'new_indication',
                          :user_input     => { 'user_input' => 'x'},
                         )
    @composite = ODDB::View::Admin::SelectIndicationComposite.new(@model, @session)
  end
  def test_registration_name
    expected = "name_base&nbsp;-&nbsp;lookup"
    assert_equal(expected, @composite.registration_name(@model, @session))
  end
end

    end # Admin
  end # View
end # ODDB
