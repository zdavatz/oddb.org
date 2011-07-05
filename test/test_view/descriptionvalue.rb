#!/usr/bin/env ruby
# ODDB::View::TestDescriptionValue -- oddb.org -- 05.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/descriptionvalue'

module ODDB
	module View

class TestDescriptionValue < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model')
    @view    = ODDB::View::DescriptionValue.new('name', @model, @session)
  end
  def test_init
    assert_nil(@view.init)
  end
end

	end # View
end # ODDB
