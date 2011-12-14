#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Ajax::TestJson -- oddb.org -- 05.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/ajax/json'


module ODDB
  module View
    module Ajax

class TestJson < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model', :to_json => 'to_json')
    @view    = ODDB::View::Ajax::Json.new(@model, @session)
  end
  def test_to_html
    assert_equal('to_json', @view.to_html('context'))
  end
end


    end # Ajax
  end # View
end # ODDB

