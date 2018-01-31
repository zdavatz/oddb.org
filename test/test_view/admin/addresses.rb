#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Admin::TestAddresses -- oddb.org -- 09.11.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))


require 'minitest/autorun'
require 'flexmock/minitest'
require 'view/admin/addresses'
require 'model/company'


module ODDB
  module View
    module Admin

class TestAddressList <Minitest::Test
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
                        :type    => 'type',
                        :time    => Time.utc(2011,2,3),
                        :method  => method,
                        :pointer => 'pointer',
                        :resolve => 'resolve',
                        :parent  => parent,
                        :address_pointer => address_pointer
                       )
    flexmock(address_pointer, :parent => @model)
  end
  def test_address_type
    @list    = ODDB::View::Admin::AddressList.new([@model], @session)
    assert_equal('lookup', @list.address_type(@model))
  end
  def test_address_model_nil
    address_pointer = flexmock('address_pointer')
    method   = flexmock('method', :arity => 1)
    @model   = flexmock('model_nil', 
                        :url     => 'url',
                        :type    => 'type',
                        :time    => Time.utc(2011,2,3),
                        :method  => method,
                        :pointer => 'pointer',
                        :resolve => 'resolve',
                        :parent  => nil,
                        :address_pointer => nil
                       )
    flexmock(address_pointer, :parent => nil)
    @list    = ODDB::View::Admin::AddressList.new([@model], @session)
  end
end

    end # Admin
  end # View
end # ODDB

