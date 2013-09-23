#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestUpload -- oddb -- 05.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'util/upload'

module ODDB
  class TestUpload <Minitest::Test
    include FlexMock::TestCase
    def setup
      @io  = flexmock('io', 
                     :original_filename => 'original_filename',
                     :read => 'read'
                    )
      @model = ODDB::Upload.new(@io)
    end
    def test_name
      assert_equal('original_filename', @model.name)
    end
  end

end

