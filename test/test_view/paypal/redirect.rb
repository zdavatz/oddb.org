#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::PayPal::TestRedirect -- oddb.org -- 28.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/paypal/redirect'
require 'model/user'

module ODDB
  module View
    module PayPal
      PAYPAL_SERVER   = 'server'
      PAYPAL_RECEIVER = 'receiver'

class TestRedirect <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :_event_url => '_event_url',
                          :base_url   => 'base_url'
                         )
    @user      = flexmock('user', 
                          :is_a? => true,
                          :email => 'email',
                          :name_first => 'name_first',
                          :name_last  => 'name_last',
                          :address    => 'address',
                          :city       => 'city',
                          :plz        => 'plz'
                         ).by_default
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :user => @user
                         )
    item       = flexmock('item', :text => 'text')
    @model     = flexmock('model', 
                          :oid   => 'oid',
                          :items => {'key' => item},
                          :total_brutto => 123.0
                         )
    @component = ODDB::View::PayPal::Redirect.new(@model, @session)
  end
  def test_http_headers 
    expected = {"Location" => "https://server/cgi-bin/webscr?business=receiver&item_name=text&item_number=oid&invoice=oid&custom=#{SERVER_NAME}&amount=123.00&no_shipping=1&no_note=1&currency_code=EUR&return=_event_url&cancel_return=base_url&image_url=https://www.generika.cc/images/oddb_paypal.jpg&email=email&first_name=name_first&last_name=name_last&address1=address&city=city&zip=plz&redirect_cmd=_xclick&cmd=_ext-enter"}
    assert_equal(expected, @component.http_headers)
  end
  def test_http_headers__not_yususer
    flexmock(@user, :is_a? => nil)
    expected = {"Location" => "https://server/cgi-bin/webscr?business=receiver&item_name=text&item_number=oid&invoice=oid&custom=#{SERVER_NAME}&amount=123.00&no_shipping=1&no_note=1&currency_code=EUR&return=_event_url&cancel_return=base_url&image_url=https://www.generika.cc/images/oddb_paypal.jpg&cmd=_xclick"}
    assert_equal(expected, @component.http_headers)
  end
  def test_to_html
    assert_equal('', @component.to_html('context'))
  end
end

    end # PayPal
  end # View
end # ODDB
