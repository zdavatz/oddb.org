#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Interactions::TestResultList -- oddb.org -- 22.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/interactions/resultlist'

module ODDB
  module View
    module Interactions

class TestResultList < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :event_url  => 'event_url',
                        :_event_url => '_event_url'
                       )
    @sequence = flexmock('sequence', :active_package_count => 0)
    @model   = flexmock('model', 
                        :language  => 'language',
                        :oid       => 'oid',
                        :sequences => [@sequence]
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :language    => 'language',
                        :interaction_basket      => [@model],
                        :interaction_basket_ids  => 'interaction_basket_ids',
                        :interaction_basket_link => 'interaction_basket_link'
                       )
    @list    = ODDB::View::Interactions::ResultList.new([@model], @session)
  end
  def test_interaction_basket_status
    assert_kind_of(HtmlGrid::Link, @list.interaction_basket_status(@model, @session))
  end
  def test_name
    assert_equal('language', @list.name(@model, @session))
  end
  def test_name__else
    flexmock(@session, :interaction_basket => [])
    assert_kind_of(HtmlGrid::Link, @list.name(@model, @session))
  end
  def test_search_oddb
    assert_equal(nil, @list.search_oddb(@model, @session))
  end
  def test_search_oddb__active_sequeces_not_empty
    flexmock(@sequence, :active_package_count => 1)
    flexmock(@model, :name => 'name')
    assert_kind_of(HtmlGrid::Link, @list.search_oddb(@model, @session))
  end
end
    end # Interactions
  end # View
end # ODDB
