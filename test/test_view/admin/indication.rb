#!/usr/bin/env ruby
# ODDB::View::Admin::TestIndication -- oddb.org -- 30.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/admin/indication'

module ODDB
  module View
    module Admin

class TestIndicationForm < Test::Unit::TestCase
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
