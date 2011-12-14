#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Interactions::TestResult -- oddb.org -- 21.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/resulttemplate'
require 'view/interactions/result'

module ODDB
  module View
    module Interactions

class TestResultForm < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :_event_url => '_event_url',
                        :disabled?  => nil,
                        :event_url  => 'event_url',
                        :base_url   => 'base_url'
                       )
    state    = flexmock('state', :object_count => 1)
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :zone        => 'zone',
                        :state       => state,
                        :language    => 'language',
                        :interaction_basket    => [],
                        :interaction_basket_ids => 'interaction_basket_ids',
                        :persistent_user_input => 'persistent_user_input'
                       )
    sequence = flexmock('sequence', :active_package_count => 0)
    @model   = flexmock('model', 
                        :language  => 'language',
                        :oid       => 'oid',
                        :sequences => [sequence]
                       )
    @form    = ODDB::View::Interactions::ResultForm.new([@model], @session)
  end
  def test_interaction_basket
    assert_kind_of(HtmlGrid::Button, @form.interaction_basket(@model, @session))
  end
  def test_interaction_basket_link
    flexmock(@session, :interaction_basket_link => 'interaction_basket_link')
    assert_kind_of(HtmlGrid::Link, @form.interaction_basket_link(@model, @session))
  end
end

class TestEmptyResultForm < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :_event_url => '_event_url',
                        :disabled?  => nil,
                        :base_url   => 'base_url'
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :zone        => 'zone',
                        :persistent_user_input => 'persistent_user_input'
                       )
    @model   = flexmock('model')
    @form    = ODDB::View::Interactions::EmptyResultForm.new(@model, @session)
  end
  def test_title_none_found
    assert_equal('lookup', @form.title_none_found(@model, @session))
  end
end

    end # Interactions
  end # View
end # ODDB
