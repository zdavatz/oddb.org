#!/usr/bin/env ruby
# ODDB::View::Drugs::TestNarcotics -- oddb.org -- 03.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/drugs/narcotics'


module ODDB
  module View
    module Drugs

class TestNarcoticList < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup      => 'lookup',
                        :attributes  => {},
                        :_event_url  => '_event_url'
                       )
    state    = flexmock('state', 
                        :interval  => 'interval',
                        :intervals => 'intervals'
                       )
    @session = flexmock('session', 
                        :lookandfeel  => @lnf,
                        :event        => 'event',
                        :state        => state,
                        :direct_event => 'direct_event',
                        :language     => 'language'
                       )
    package  = flexmock('package')
    narcotic = flexmock('narcotic', 
                        :pointer   => 'pointer',
                        :category  => 'category',
                        :packages  => [package]
                       )
    @model   = flexmock('model', 
                        :narcotic => narcotic,
                        :language => 'language'
                       )
    @list    = ODDB::View::Drugs::NarcoticList.new([@model], @session)
  end
  def test_casrn
    assert_kind_of(ODDB::View::PointerLink, @list.casrn(@model, @session))
  end
end

class TestNarcoticsComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :_event_url => '_event_url',
                          :navigation => [],
                          :disabled?  => nil,
                          :enabled?   => nil,
                          :base_url   => 'base_url'
                         )
    state      = flexmock('state', 
                          :interval  => 'interval',
                          :intervals => 'intervals'
                         )
    @session   = flexmock('session', 
                          :lookandfeel  => @lnf,
                          :state        => state,
                          :event        => 'event',
                          :direct_event => 'direct_event',
                          :language     => 'language',
                          :zone         => 'zone'
                         )
    package    = flexmock('package')
    narcotic   = flexmock('narcotic', 
                          :pointer   => 'pointer',
                          :category  => 'category',
                          :packages  => [package]
                         )
    @model     = flexmock('model', 
                          :narcotic => narcotic,
                          :language => 'language',
                          :empty?   => nil
                         )
    @composite = ODDB::View::Drugs::NarcoticsComposite.new([@model], @session)
  end
  def test_title_narcotics
    assert_equal('lookup', @composite.title_narcotics(@model))
  end
end

    end # Drugs
  end # View
end # ODDB
