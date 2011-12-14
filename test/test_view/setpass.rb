#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::TestSetPass -- oddb.org -- 29.03.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/setpass'

module ODDB
  module View

class TestSetPassForm < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :base_url   => 'base_url'
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :error => 'error',
                        :warning? => nil,
                        :error?   => nil
                       )
    @model   = flexmock('model')
    @form    = ODDB::View::SetPassForm.new(@model, @session)
  end
  def test_iniT
    assert_nil(@form.init)
  end
end

  end # View
end # ODDB
