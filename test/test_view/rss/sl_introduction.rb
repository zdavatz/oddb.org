#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Rss::TestSlIntroduction -- oddb.org -- 05.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/rss/sl_introduction'

module ODDB
  module View
    module Rss

class TestSlIntroduction <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model')
    @view    = ODDB::View::Rss::SlIntroduction.new(@model, @session)
  end
  def test_init
    assert_nil(@view.init)
  end
end

    end # Interactions
  end # View
end # ODDB
