#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Admin::TestIndication -- oddb.org -- 30.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/admin/indication'

module ODDB
  module View
    module Admin

class TestIndicationForm <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :languages  => ['language'],
                        :attributes => {},
                        :base_url   => 'base_url'
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :error => 'error',
                        :warning? => nil,
                        :error?   => nil
                       )
    @model   = flexmock('model', :synonyms => ['synonym'])
    @form    = ODDB::View::Admin::IndicationForm.new(@model, @session)
  end
  def test_languages
    expected = ["language", "lt", "synonym_list"]
    assert_equal(expected, @form.languages)
  end
end

    end # Admin
  end # View
end # ODDB
