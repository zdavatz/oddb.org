#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::User::TestRegisterPowerUser -- oddb.org -- 28.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'htmlgrid/select'
require 'view/user/register_poweruser'


module ODDB
  module View
    module User

class TestRegisterPowerUserForm  <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :_event_url => '_event_url',
                        :base_url   => 'base_url'
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :user        => 'user',
                        :logged_in?  => nil,
                        :error       => 'error',
                        :warning?    => nil,
                        :error?      => nil
                       )
    @model   = flexmock('model')
    @form    = ODDB::View::User::RegisterPowerUserForm.new(@model, @session)
  end
  def test_init
    assert_equal(nil, @form.init)
  end
end

class TestRenewPowerUserComposite <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :_event_url => '_event_url',
                          :disabled?  => nil,
                          :base_url   => 'base_url',
                          :format_price => 'format_price'
                         )
    state      = flexmock('state', :currency => 'CHF')
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :zone        => 'zone',
                          :user        => 'user',
                          :logged_in?  => nil,
                          :error       => 'error',
                          :warning?    => nil,
                          :error?      => nil,
                          :event       => 'event',
                          :state       => state,
                          :persistent_user_input => 'persistent_user_input',
                          :get_cookie_input => 'get_cookie_input',
                         )
    item       = flexmock('item', 
                          :quantity => 1,
                          :text     => 'text',
                          :vat      => 2,
                          :total_netto  => 3,
                          :total_brutto => 4
                         )
    @model     = flexmock('model', :items => [item])
    @composite = ODDB::View::User::RenewPowerUserComposite.new(@model, @session)
  end
  def test_renew_poweruser_form
    assert_kind_of(ODDB::View::User::RenewPowerUserForm, @composite.renew_poweruser_form(@model))
  end
end



    end # User
  end # View
end # ODDB
