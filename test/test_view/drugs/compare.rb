#!/usr/bin/env ruby
# ODDB::View::Drugs::TestCompare -- oddb.org -- 05.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/drugs/compare'
require 'htmlgrid/select'
require 'sbsm/validator'

module ODDB
  module View
    class Copyright < HtmlGrid::Composite
      ODDB_VERSION = 'oddb_version'
    end
    module Drugs

class TestCompareList < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    comparison_sorter = Proc.new{}
    components = {[1, 2] => :active_agents}
    @lnf     = flexmock('lookandfeel', 
                        :compare_list_components => components,
                        :comparison_sorter       => comparison_sorter,
                        :lookup                  => 'lookup'
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :event       => 'event'
                       )
    @model   = flexmock('model', 
                        :sort_by! => 'sort_by!',
                        :empty?   => true
                       )
    @list    = ODDB::View::Drugs::CompareList.new(@model, @session)
  end
  def test_reorganize_components
    expected = {[1, 2]=>:active_agents}
    assert_equal(expected, @list.reorganize_components)
  end
  def test_active_agents
    flexmock(@model, :active_agents => ['active_agent'])
    assert_equal('active_agent', @list.active_agents(@model, @session))
  end
  def test_package_line
    offset = [0,0]
    assert_equal(nil, @list.package_line(offset))
  end
  def test_compose_list
    generic_type = flexmock('generic_type')
    comparable = flexmock('comparable', 
                          :generic_type => generic_type,
                          :active_agents => ['active_agent']
                         )
    flexmock(@model, :comparables => [comparable])
    assert_equal([0,2], @list.compose_list)
  end
  def test_price_difference
    flexmock(@model, :price_difference => 0.123)
    assert_equal('+12%', @list.price_difference(@model, @session))
  end
end

class TestCompare < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    components = {[1, 2] => :active_agents}
    @lnf     = flexmock('lookandfeel', 
                        :enabled?     => nil,
                        :attributes   => {},
                        :resource     => 'resource',
                        :lookup       => 'lookup',
                        :zones        => 'zones',
                        :disabled?    => nil,
                        :direct_event => 'direct_event',
                        :_event_url   => '_event_url',
                        :compare_list_components => components,
                        :comparison_sorter => Proc.new{},
                        :explain_result_components => {[0,0] => :explain_cas},
                        :zone_navigation => 'zone_navigation',
                        :navigation   => 'navigation',
                        :base_url     => 'base_url'
                       )
    user     = flexmock('user', :valid? => nil)
    sponsor  = flexmock('sponsor', :valid? => nil)
    snapback_model = flexmock('snapback_model', :pointer => 'pointer')
    state    = flexmock('state', 
                        :direct_event   => 'direct_event',
                        :snapback_model => snapback_model
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :user        => user,
                        :sponsor     => sponsor,
                        :state       => state,
                        :allowed?    => nil,
                        :event       => 'event',
                        :zone        => 'zone',
                        :persistent_user_input => 'persistent_user_input'
                       )
    comparable = flexmock('comparable', 
                          :generic_type  => 'generic_type',
                          :active_agents => ['active_agent']
                         )
    @model   = flexmock('model', 
                        :sort_by! => 'sort_by',
                        :empty?   => nil,
                        :comparables => [comparable]
                       )
    @temp    = ODDB::View::Drugs::Compare.new(@model, @session)
  end
  def test_reorganize_components
    flexmock(@lnf) do |l|
      l.should_receive(:enabled?).with(:breadcrumbs).and_return(true)
      l.should_receive(:enabled?).with(:compare_backbutton, false).and_return(true)
      l.should_receive(:enabled?).with_any_args.and_return(nil)
    end
    assert_equal('snapback', @temp.reorganize_components)
  end
  def test_back_button
    assert_kind_of(HtmlGrid::Button, @temp.back_button(@model, @session))
  end
  def test_backtracking
    flexmock(@lnf) do |l|
      l.should_receive(:enabled?).with(:breadcrumbs).and_return(true)
      l.should_receive(:enabled?).with_any_args.and_return(nil)
    end
    result = @temp.backtracking(@model, @session)
    assert_equal(3, result.length)
    assert_kind_of(HtmlGrid::Span, result[0])
    assert_kind_of(HtmlGrid::Span, result[1])
    assert_kind_of(HtmlGrid::Span, result[2])
  end
  def test_backtracking__home
    flexmock(@lnf) do |l|
      l.should_receive(:enabled?).with(:breadcrumbs).and_return(true)
      l.should_receive(:enabled?).with(:home).and_return(true)
      l.should_receive(:enabled?).with_any_args.and_return(nil)
    end
    result = @temp.backtracking(@model, @session)
    assert_equal(5, result.length)
    assert_kind_of(HtmlGrid::Span, result[0])
    assert_kind_of(HtmlGrid::Span, result[1])
    assert_kind_of(HtmlGrid::Span, result[2])
    assert_kind_of(HtmlGrid::Span, result[3])
    assert_kind_of(HtmlGrid::Span, result[4])
  end
  def test_backtracking__pointer_descr
    flexmock(@lnf) do |l|
      l.should_receive(:enabled?).with(:breadcrumbs).and_return(true)
      l.should_receive(:enabled?).with_any_args.and_return(nil)
    end
    flexmock(@temp, :pointer_descr => 'pointer_descr')
    result = @temp.backtracking(@model, @session)
    assert_equal(3, result.length)
    assert_kind_of(HtmlGrid::Span, result[0])
    assert_kind_of(HtmlGrid::Span, result[1])
    assert_kind_of(HtmlGrid::Span, result[2])
  end
  def test_backtracking__model_pointer_descr
    flexmock(@lnf) do |l|
      l.should_receive(:enabled?).with(:breadcrumbs).and_return(true)
      l.should_receive(:enabled?).with_any_args.and_return(nil)
    end
    flexmock(@model, :pointer_descr => 'pointer_descr')
    result = @temp.backtracking(@model, @session)
    assert_equal(3, result.length)
    assert_kind_of(HtmlGrid::Span, result[0])
    assert_kind_of(HtmlGrid::Span, result[1])
    assert_kind_of(HtmlGrid::Span, result[2])
  end
  def test_backtracking__super
    assert_kind_of(ODDB::View::PointerSteps, @temp.backtracking(@model, @session))
  end
end

class TestEmptyCompareComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {}
                         )
    @session   = flexmock('session', :lookandfeel => @lnf)
    package    = flexmock('package', :name_base => 'name_base')
    @model     = flexmock('model', :package => package)
    @composite = ODDB::View::Drugs::EmptyCompareComposite.new(@model, @session)
  end
  def test_compare_desc0_no_atc
    assert_equal('lookup', @composite.compare_desc0_no_atc(@model, @session))
  end
end

    end # Drugs
  end # View
end # ODDB

