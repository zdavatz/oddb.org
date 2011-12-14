#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Doctors::TestVCard -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/doctors/vcard'

module ODDB
  module View
    module Doctors

class TestVCard < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model')
    @view    = ODDB::View::Doctors::VCard.new(@model, @session)
  end
  def test_init
    assert_equal([:name, :title, :email, :addresses], @view.init)
  end
  def test_get_filename
    flexmock(@model, 
             :name => 'name',
             :firstname => 'firstname'
            )
    assert_equal('name_firstname.vcf', @view.get_filename)
  end
  def test_name
    flexmock(@model, 
             :name => 'name',
             :firstname => 'firstname'
            )
    expected = ["FN;CHARSET=UTF-8:firstname name", "N;CHARSET=UTF-8:name;firstname"]
    assert_equal(expected, @view.name)
  end
end

    end # Doctors
  end # View
end # ODDB
