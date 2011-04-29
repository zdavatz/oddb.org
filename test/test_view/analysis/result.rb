#!/usr/bin/env ruby
# ODDB::View::Analysis::TestResult -- oddb.org -- 29.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/resulttemplate'
require 'view/analysis/result'

module ODDB
  module View
    module Analysis

class TestList < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :event_url  => 'event_url',
                        :_event_url => '_event_url'
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :event       => 'event',
                        :language    => 'language'
                       )
    list_title = flexmock('list_title', :language => 'language')
    @model   = flexmock('model', 
                        :list_title => list_title,
                        :pointer    => 'pointer',
                        :language   => 'language',
                        :code       => 'code',
                        :localized_name => 'localized_name'
                       )
    @list    = ODDB::View::Analysis::List.new([@model], @session)
  end
  def test_description
    assert_kind_of(ODDB::View::PointerLink, @list.description(@model))
  end
  def test_description__text_size_lt_60
    flexmock(@model, :language => '1234567890'*5 + ' 1234567890')
    assert_kind_of(ODDB::View::PointerLink, @list.description(@model))
  end
  def test_description__block
    flexmock(@model, :language => 'block1234567890'*5 + ' 1234567890')
    assert_kind_of(ODDB::View::PointerLink, @list.description(@model))
  end
  def test_description__blutgase
    flexmock(@model, :language => 'Blutgase1234567890'*5 + ' 1234567890')
    assert_kind_of(ODDB::View::PointerLink, @list.description(@model))
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
    @form    = ODDB::View::Analysis::EmptyResultForm.new(@model, @session)
  end
  def test_title_none_found
    assert_equal('lookup', @form.title_none_found(@model, @session))
  end
end


    end # Analysis
  end # View
end # ODDB
