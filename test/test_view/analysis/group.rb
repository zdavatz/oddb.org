#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Analysis::TestGroup -- oddb.org -- 09.11.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/resulttemplate'
require 'view/analysis/group'

module ODDB
  module View
    module Analysis

class TestPositionList <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup => 'lookup',
                        :_event_url => '_event_url',
                        :attributes => {}
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :event       => 'event',
                        :language    => 'language'
                       )
    @model   = flexmock('model', 
                        :poscd    => 'poscd',
                        :pointer  => 'pointer',
                        :language => 'language',
                        :localized_name => 'localized_name',
                        :groupcd  => 'groupcdt_positionlist'
                       )
    @list    = ODDB::View::Analysis::PositionList.new([@model], @session)
  end
  def test_description
    assert_kind_of(ODDB::View::PointerLink, @list.description(@model))
  end
end

class TestGroupHeader <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', :lookup => 'lookup')
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :error       => 'error'
                         )
    @model     = flexmock('model', 
                          :groupcd => 'groupcd',
                          :poscd   => 'poscd'
                         )
    @composite = ODDB::View::Analysis::GroupHeader.new(@model, @session)
  end
  def test_analysis_positions
    assert_equal('lookup groupcd', @composite.analysis_positions(@model))
  end
end

class TestGroupComposite <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :_event_url => '_event_url',
                          :attributes => {}
                         )
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :error       => 'error',
                          :event       => 'event',
                          :language    => 'language'
                         )
    position   = flexmock('position', 
                          :poscd    => 'poscd',
                          :pointer  => 'pointer',
                          :language => 'language',
                          :groupcd  => 'groupcd',
                          :localized_name => 'localized_name'
                         )
    @model     = flexmock('model', 
                          :poscd     => 'poscd',
                          :groupcd   => 'groupcd',
                          :positions => {'key' => position}
                         )
    @composite = ODDB::View::Analysis::GroupComposite.new(@model, @session)
  end
  def test_positionlist
    assert_kind_of(ODDB::View::Analysis::PositionList, @composite.positionlist(@model))
  end
end
    end # Analysis
  end # View
end # ODDB
