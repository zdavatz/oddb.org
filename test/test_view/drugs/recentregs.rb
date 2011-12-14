#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Drugs::TestRecentRegs -- oddb.org -- 26.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/drugs/recentregs'
require 'date'
require 'htmlgrid/select'
require 'view/htmlgrid/composite'

module ODDB
  module View
    module Drugs

class TestDateChooser < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :_event_url => '_event_url'
                         )
    state      = flexmock('state', 
                          :date   => Date.new(2011,2,3),
                          :months => (1..12).to_a,
                          :years  => [2010, 2011]
                         )
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :state       => state
                         )
    @model     = flexmock('model')
    @composite = ODDB::View::Drugs::DateChooser.new(@model, @session)
  end
  def test_years
    assert_kind_of(HtmlGrid::Link, @composite.years(@model)[0])
  end
end

class TestDateHeader < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', :lookup => 'lookup')
    @session   = flexmock('session', :lookandfeel => @lnf)
    @model     = flexmock('model', 
                          :date => Date.new(2011,2,3),
                          :package_count => 'package_count'
                         )
    @composite = ODDB::View::Drugs::DateHeader.new(@model, @session)
  end
  def test_date_packages
    expected = 'lookup 2011 - package_count lookup'
    assert_equal(expected, @composite.date_packages(@model))
  end
end

class TestRootRecentRegsList < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :event_url  => 'event_url',
                        :_event_url => '_event_url',
                        :result_list_components => {[0,0] => 'component'}
                       )
    state    = flexmock('state', 
                        :date   => Date.new(2011,2,3),
                        :months => (1..12).to_a,
                        :years  => [2010, 2011]
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :state       => state,
                        :persistent_user_input => 'persistent_user_input'
                       )
    registration = flexmock('registration', :pointer => 'pointer')
    sequence = flexmock('sequence', :pointer => 'pointer')
    package  = flexmock('package', 
                        :generic_type => 'generic_type',
                        :registration => registration,
                        :sequence     => sequence,
                        :pointer      => 'pointer'
                       )
    @model   = flexmock('model', 
                        :date => Date.new(2011,2,3),
                        :package_count => 1,
                        :packages => [package]
                       )
    @list    = ODDB::View::Drugs::RootRecentRegsList.new([@model], @session)
  end
  def test_init
    assert_equal(nil, @list.init)
  end
end

class TestRecentRegsList < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :event_url  => 'event_url',
                        :_event_url => '_event_url',
                        :result_list_components => {[0,0] => 'component'} 
                       )
    state    = flexmock('state', 
                        :date   => Date.new(2011,2,3),
                        :months => (1..12).to_a,
                        :years  => [2010, 2011]
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :state       => state,
                        :persistent_user_input => 'persistent_user_input'
                       )
    package  = flexmock('package', :generic_type => 'generic_type')
    @model   = flexmock('model', 
                        :date => Date.new(2011,2,3),
                        :package_count => 1,
                        :packages => [package]
                       )
    @list    = ODDB::View::Drugs::RecentRegsList.new([@model], @session)
  end
  def test_init
    assert_equal(nil, @list.init)
  end
end

class TestRecentRegsComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :enabled?   => nil,
                          :disabled?  => nil,
                          :event_url  => 'event_url',
                          :_event_url => '_event_url',
                          :navigation => [],
                          :base_url   => 'base_url',
                          :result_list_components    => {[0,0] => 'component'},
                          :explain_result_components => {[0,1] => :explain_fachinfo}
                         )
    state      = flexmock('state', 
                          :date   => Date.new(2011,2,3),
                          :months => (1..12).to_a,
                          :years  => [2010, 2011]

                         )
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :allowed?    => nil,
                          :state       => state,
                          :zone        => 'zone',
                          :persistent_user_input => 'persistent_user_input'
                         )
    package    = flexmock('package', :generic_type => 'generic_type')
    @model     = flexmock('model', 
                          :date => Date.new(2011,2,3),
                          :package_count => 1,
                          :packages      => [package]
                         )
    @composite = ODDB::View::Drugs::RecentRegsComposite.new([@model], @session)
  end
  def test_breadcrumbs
    result = @composite.breadcrumbs(@model, @session)
    assert_equal(3, result.length)
    assert_kind_of(HtmlGrid::Span, result[0])
    assert_kind_of(HtmlGrid::Span, result[1])
    assert_kind_of(HtmlGrid::Span, result[2])
  end
end



    end # Drugs
  end # View
end # ODDB
