#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::TestException -- oddb.org -- 30.03.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/exception'

module ODDB
  module View

class TestExceptionComposite <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :_event_url => '_event_url',
                          :disabled?  => nil,
                          :base_url   => 'base_url'
                         )
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :event => 'event',
                          :zone => 'zone',
                         )
    @model     = flexmock('model', :message => 'message')
    @composite = ODDB::View::ExceptionComposite.new(@model, @session)
  end
  def test_exception
    assert_kind_of(HtmlGrid::Text, @composite.exception(@model, @session))
  end
end

  end # View
end # ODDB
