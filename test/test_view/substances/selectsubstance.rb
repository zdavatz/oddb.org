#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Substances::TestSelectSubstance -- oddb.org -- 27.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'htmlgrid/inputradio'
require 'view/substances/selectsubstance'

module ODDB
  module View
    module Substances

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
                          :event => 'event'
                         )
    source     = flexmock('source', :name => 'name')
    @model     = flexmock('model', 
                          :source  => source,
                          :targets => ['target']
                         )
    @composite = ODDB::View::Substances::SelectSubstanceComposite.new(@model, @session)
  end
  def test_source_name
    assert_equal('name', @composite.source_name(@model))
  end
end

    end # Substances
  end # View
end # ODDB
