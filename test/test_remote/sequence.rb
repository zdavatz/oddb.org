#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::Remote::TestSequence -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'remote/sequence'

module ODDB
  module Remote

class TestSequence < ::Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    atc       = flexmock('atc', :code => 'code')
    @remote   = flexmock('remote', :atc => atc)
    @sequence = ODDB::Remote::Sequence.new(@remote)
  end
  def test_atc_code
    assert_equal('code', @sequence.atc_code)
  end
  def test_comparable
    description  = flexmock('description', :de => 'de')
    name         = flexmock('name', :de => 'de')
    group        = flexmock('group', :name => name)
    galenic_group = flexmock('galenic_group', :has_description? => nil)
    galenic_form = flexmock('galenic_form', 
                            :description => description,
                            :has_description? => nil,
                            :group => group,
                            :galenic_group => galenic_group
                           )
    flexmock(@remote, 
             :galenic_forms => [galenic_form],
             :doses => 'doses'
            )
    assert_equal(false, @sequence.comparable?(@remote))
  end
end

  end # Remote
end # ODDB
