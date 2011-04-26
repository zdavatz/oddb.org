#!/usr/bin/env ruby
# ODDB::View::Drugs::TestSequences -- oddb.org -- 26.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/drugs/sequences'


module ODDB
  module View
    module Drugs

class TestOffsetPager < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :_event_url => '_event_url'
                       )
    state    = flexmock('state', :page => 'page')
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :state       => state,
                        :event       => 'event'
                       )
    @model   = flexmock('model', :to_i => 1)
    @pager   = ODDB::View::Drugs::OffsetPager.new([@model], @session)
  end
  def test_compose_header
    assert_equal('offset', @pager.compose_header('offset'))
  end
  def test_compose_footer
    assert_equal('offset', @pager.compose_footer('offset'))
  end
end

class TestSequenceList < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :sequence_list_components => {[0, 0] => 'component'}
                       )
    page     = flexmock('page', 
                        :content => 'content',
                        :to_i => 1
                       )
    state    = flexmock('state', 
                        :interval  => 'interval',
                        :intervals => ['interval'],
                        :pages     => [page],
                        :page      => page,
                        :range     => 'range'
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :state       => state,
                        :event       => 'event'
                       )
    @model   = flexmock('model', :generic_type => 'generic_type')
    @list    = ODDB::View::Drugs::SequenceList.new([@model], @session)
  end
  def test_init
    assert_equal(nil, @list.init)
  end
  def test_name_base
    flexmock(@lnf, 
             :disabled?  => nil,
             :_event_url => '_event_url'
            )
    flexmock(@model, :name_base => 'name_base')
    assert_kind_of(HtmlGrid::Link, @list.name_base(@model))
  end
end

class TestSequencesComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :navigation => [],
                          :disabled?  => nil,
                          :enabled?   => nil,
                          :_event_url => '_event_url',
                          :base_url   => 'base_url',
                          :sequence_list_components  => {[0,0] => 'component'},
                          :explain_result_components => {[0,1] => :explain_fachinfo}
                         )
    page       = flexmock('page', 
                          :content => 'content',
                          :to_i    => 1
                         )
    state      = flexmock('state', 
                          :interval  => 'interval',
                          :intervals => ['interval'],
                          :pages     => [page],
                          :page      => page,
                          :range     => 'range'
                         )
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :state       => state,
                          :event       => 'event',
                          :zone        => 'zone'
                         )
    @model     = flexmock('model', :generic_type => 'generic_type')
    flexmock(state, :model => [@model])
    @composite = ODDB::View::Drugs::SequencesComposite.new([@model], @session)
  end
  def test_title_sequences
    assert_equal('lookup', @composite.title_sequences([@model]))
  end
end


    end # Drugs
  end # View
end # ODDB
