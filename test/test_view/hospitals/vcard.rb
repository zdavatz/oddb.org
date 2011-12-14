#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Hospitals::TestVCard -- oddb.org -- 05.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/hospitals/vcard'

module ODDB
	module View
    module Hospitals

class TestVCard < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model', 
                        :name  => 'first last',
                        :ean13 => '1234567890123'
                       )
    @view    = ODDB::View::Hospitals::VCard.new(@model, @session)
  end
  def test_init
    assert_equal([:name, :addresses], @view.init)
  end
  def test_get_filename
    assert_equal('first_last_1234567890123.vcf', @view.get_filename)
  end
end

    end # Hospitals
	end # View
end # ODDB
