#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestIndexTherapeuticus -- oddb.org -- 24.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'model/index_therapeuticus'


module ODDB
  class TestIndexTherapeuticus < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
      flexmock(ODBA.cache, :next_id => 123)
      @therapeuticus = ODDB::IndexTherapeuticus.new('code')
    end
    def test_find_by_code
      assert_kind_of(ODDB::Text::Document, @therapeuticus.create_comment)
    end
    def test_normalize_code
      assert_equal("12345678.90.", ODDB::IndexTherapeuticus.normalize_code('012345678.9'))
    end
    def test_find_by_code
      cache = flexmock('cache', :retrieve_from_index => ['data'])
      flexmock(ODBA, :cache => cache)
      assert_equal('data', ODDB::IndexTherapeuticus.find_by_code('123'))
    end
  end
end
