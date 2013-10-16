#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Drugs::TestVaccines -- oddb.org -- 29.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/drugs/sequences'
require 'view/resultfoot'
require 'view/drugs/vaccines'

module ODDB
  module View
    module Drugs

class TestVaccinesComposite <Minitest::Test
  include FlexMock::TestCase
  def setup
    component  = flexmock('component')
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :_event_url => '_event_url',
                          :navigation => [],
                          :disabled?  => nil,
                          :enabled?   => nil,
                          :base_url   => 'base_url',
                          :sequence_list_components => {[0,0 ] => component},
                          :explain_result_components => {[0,0 ] => component}
                         )
    state      = flexmock('state', 
                          :pages => ['pages'],
                          :page  => 'page',
                          :range => 'range',
                          :interval  => 'interval',
                          :intervals => ['interval']
                         )
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :state => state,
                          :event => 'event',
                          :zone  => 'zone'
                         )
    @model     = flexmock('model', :generic_type => 'generic_type')
    @composite = ODDB::View::Drugs::VaccinesComposite.new([@model], @session)
  end
  def test_title_vaccines
    assert_equal('lookup', @composite.title_vaccines([@model]))
  end
end

    end # Drugs
  end # View
end # ODDB

