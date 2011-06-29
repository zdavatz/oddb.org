#!/usr/bin/env ruby
# ODDB::View::Drugs::TestCompareSearch -- oddb.org -- 29.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/drugs/centeredsearchform'
require 'view/drugs/compare_search'

module ODDB
  module View
    module Drugs

class TestCompareSearchForm < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @container = flexmock('container', :additional_javascripts => [])
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :enabled?   => nil,
                        :attributes => {},
                        :base_url   => 'base_url'
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :persistent_user_input => 'persistent_user_input'
                       )
    @model   = flexmock('model')
    @form    = ODDB::View::Drugs::CompareSearchForm.new(@model, @session, @container)
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

    end # Drugs
  end # View
end # ODDB

