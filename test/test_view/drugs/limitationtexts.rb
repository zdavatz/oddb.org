#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Drugs::TestLimitationTexts -- oddb.org -- 22.03.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/resultfoot'
require 'view/drugs/limitationtexts'


module ODDB
  module View
    module Drugs

class TestLimitationTextList < Test::Unit::TestCase
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
                        :state       => state
                       )
    limitation_text = flexmock('limitation_text', :pointer => 'pointer')
    @model   = flexmock('model', 
                        :generic_type => 'generic_type',
                        :limitation_text => limitation_text,
                        :name_base  => 'name_base'
                       )
    @list    = ODDB::View::Drugs::LimitationTextList.new([@model], @session)
  end
  def test_name
    assert_kind_of(HtmlGrid::Link, @list.name(@model))
  end
end

class TestLimitationTextsComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :_event_url => '_event_url',
                          :enabled?   => nil,
                          :disabled?  => nil,
                          :base_url   => 'base_url',
                          :explain_result_components => {[0,0] => :explain_limitation_text}
                         )
    state      = flexmock('state', 
                          :interval  => 'interval',
                          :intervals => ['interval']
                         )
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :state       => state,
                          :limitation_text_count => 0,
                          :zone        => 'zone'
                         )
    limitation_text = flexmock('limitation_text', :pointer => 'pointer')
    @model     = flexmock('model', 
                          :generic_type => 'generic_type',
                          :limitation_text => limitation_text,
                          :name_base => 'name_base'
                         )
    @composite = ODDB::View::Drugs::LimitationTextsComposite.new([@model], @session)
  end
  def test_title_limitation_texts
    assert_equal('lookup', @composite.title_limitation_texts([@model]))
  end
end

    end # Drugs
  end # View
end # ODDB

