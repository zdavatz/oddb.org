#!/usr/bin/env ruby
# ODDB::View::Admin::TestSelectIndication -- oddb.org -- 23.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/admin/selectindication'


module ODDB
  module View
    module Admin

class TestSelectIndicationForm < Test::Unit::TestCase
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
                        :selection      => 'selection',
                        :new_indication => 'new_indication',
                        :user_input     => 'user_input'
                       )
    @form    = ODDB::View::Admin::SelectIndicationForm.new(@model, @session)
  end
  def test_init
    expected = {
      "ACCEPT-CHARSET" => "ISO-8859-1",
      "NAME" => "stdform",
      "METHOD" => "POST",
      "ACTION" => "base_url"
    }
    assert_equal(expected, @form.init)
  end
end

    end # Admin
  end # View
end # ODDB
