#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Drugs::TestPatinfos -- oddb.org -- 23.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/resultfoot'
require 'view/drugs/patinfos'

module ODDB
  module View
    module Drugs

class TestPatinfoList < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :_event_url => '_event_url'
                       )
    state    = flexmock('state', 
                        :interval  => 'interval',
                        :intervals => ['interval']
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :state => state
                       )
    @model   = flexmock('model', 
                        :generic_type => 'generic_type',
                        :has_patinfo? => nil,
                        :name_base    => 'name_base'
                       )
    @list    = ODDB::View::Drugs::PatinfoList.new([@model], @session)
  end
  def test_name
    assert_kind_of(HtmlGrid::Link, @list.name(@model))
  end
end

class TestPatinfosComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :_event_url => '_event_url',
                          :enabled?   => nil,
                          :disabled?  => nil,
                          :base_url   => 'base_url',
                          :explain_result_components => {[0,0] => 'value'}
                         )
    state      = flexmock('state', 
                          :interval  => 'interval',
                          :intervals => ['interval']
                         )
    @session   = flexmock('session', 
                          :lookandfeel   => @lnf,
                          :patinfo_count => 0,
                          :state => state,
                          :zone  => 'zone'
                         )
    @model     = flexmock('model', 
                          :generic_type => 'generic_type',
                          :has_patinfo? => nil,
                          :name_base    => 'name_base'
                         )

    @composite = ODDB::View::Drugs::PatinfosComposite.new([@model], @session)
  end
  def test_title_patinfos
    assert_equal('lookup', @composite.title_patinfos([@model]))
  end
end

    end # Drugs
  end # View
end # ODDB
