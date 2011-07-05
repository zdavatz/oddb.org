#!/usr/bin/env ruby
# ODDB::TestUpload -- oddb -- 05.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'util/upload'

module ODDB
  class TestUpload < Test::Unit::TestCase
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

