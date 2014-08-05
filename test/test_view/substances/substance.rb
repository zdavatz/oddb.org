#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Substances::TestSubstance -- oddb.org -- 19.01.2012 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'model/company'
require 'view/substances/substance'

module ODDB
	module View
    module Substances

class TestActiveFormForm <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :base_url   => 'base_url'
                       )
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model', 
                       :is_effective_form?  => nil,
                       :has_effective_form? => nil
                       )
    @form    = ODDB::View::Substances::ActiveFormForm.new(@model, @session)
  end
  def test_effective_label
    assert_equal('lookup', @form.effective_label(@model))
  end
  def test_effective_label__is_effective_form
    flexmock(@model, :is_effective_form? => true)
    assert_equal('lookup', @form.effective_label(@model))
  end
  def test_effective_label__has_effective_form
    flexmock(@model, :has_effective_form? => true)
    assert_equal('lookup', @form.effective_label(@model))
  end
end

class TestDescriptionForm <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :languages  => ['de', 'fr'],
                        :attributes => {},
                        :base_url   => 'base_url',
                        :lookup     => 'lookup'
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :error       => 'error',
                        :warning?    => nil,
                        :error?      => nil
                       )
    @model   = flexmock('model', :synonyms => [])
    @form    = ODDB::View::Substances::DescriptionForm.new(@model, @session)
  end
  def test_languages
    expected = ["de", "fr", "lt", "synonym_list"]
    assert_equal(expected, @form.languages)
  end
end

class TestConnectionKeys <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :event_url   => 'event_url'
                       )
    @session = flexmock('session', 
                        :event       => 'event',
                        :lookandfeel => @lnf
                       )
    @model   = flexmock('model')
    @list    = ODDB::View::Substances::ConnectionKeys.new([@model], @session)
  end
  def test_connection_key
    assert_equal(@model.to_s, @list.connection_key(@model))
  end
end

    end # Substances
	end # View
end # ODDB
