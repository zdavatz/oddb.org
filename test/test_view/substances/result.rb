#!/usr/bin/env ruby
# ODDB::View::Substances::TestResult -- oddb.org -- 27.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/substances/result'


module ODDB
  module View
    module Substances

class TestResultComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :_event_url => '_event_url',
                          :attributes => {},
                          :base_url   => 'base_url',
                          :disabled?  => nil,
                          :language   => 'language'
                         )
    state      = flexmock('state', :object_count => 0)
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :persistent_user_input => 'persistent_user_input',
                          :state => state,
                          :event => 'event',
                          :zone  => 'zone'
                         )
    method     = flexmock('method', :arity => 1)
    @model     = flexmock('model', 
                          :pointer => 'pointer',
                          :name    => 'name',
                          :method  => method
                         )
    @composite = ODDB::View::Substances::ResultComposite.new([@model], @session)
  end
  def test_title_found
    assert_equal('lookup', @composite.title_found(@model))
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
    @form    = ODDB::View::Substances::EmptyResultForm.new(@model, @session)
  end
  def test_title_none_found
    assert_equal('lookup', @form.title_none_found(@model))
  end
end
    end # Substances
  end # View
end # ODDB
