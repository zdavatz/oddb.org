#!/usr/bin/env ruby
# ODDB::View::TestSuggestAddressConfirm -- oddb.org -- 29.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'htmlgrid/labeltext'
require 'view/suggest_address_confirm'

module ODDB
  module View

class TestAddressSent < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :_event_url => '_event_url'
                         )
    @session   = flexmock('session', :lookandfeel => @lnf)
    pointer    = flexmock('pointer', :parent => 'parent')
    @model     = flexmock('model', 
                          :fon   => ['fon'],
                          :fax   => ['fax'],
                          :plz   => 'plz',
                          :city  => 'city',
                          :street => 'street',
                          :number => 'number',
                          :lines  => ['line'],
                          :message => 'message',
                          :address_pointer => pointer
                         )
    @composite = ODDB::View::AddressSent.new(@model, @session)
  end
  def test_address_sent
    assert_equal('lookup', @composite.address_sent(@model, @session))
  end
end

  end # View
end # ODDB
