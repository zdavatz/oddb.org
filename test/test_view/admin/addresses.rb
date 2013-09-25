#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Admin::TestAddresses -- oddb.org -- 09.11.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/admin/addresses'
require 'model/company'


module ODDB
  module View
    module Admin

class TestAddressList <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :event_url  => 'event_url',
                        :language   => 'language',
                        :_event_url => '_event_url'
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :event => 'event'
                       )
    method   = flexmock('method', :arity => 1)
    address_pointer = flexmock('address_pointer')
    parent   = flexmock('parent')
    @model   = flexmock('model', 
                        :url     => 'url',
                        :time    => Time.local(2011,2,3),
                        :method  => method,
                        :pointer => 'pointer',
                        :resolve => 'resolve',
                        :parent  => parent,
                        :address_pointer => address_pointer
                       )
    flexmock(address_pointer, :parent => @model)
    @list    = ODDB::View::Admin::AddressList.new([@model], @session)
  end
  def test_address_type
    assert_equal('lookup', @list.address_type(@model))
  end
end

    end # Admin
  end # View
end # ODDB

