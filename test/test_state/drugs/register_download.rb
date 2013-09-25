#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Drugs::TestRegisterDownload -- oddb.org -- 22.06.2011 -- mhatakeyama@ywesee.com
# ODDB::State::Drugs::TestRegisterDownload -- oddb.org -- 29.04.2005 -- hwyss@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))
$: << File.expand_path("..", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'htmlgrid/errormessage'
require 'htmlgrid/select'
require 'htmlgrid/list'
require 'htmlgrid/pass'
#require 'state/paypal/checkout'
require 'define_empty_class'
require 'view/paypal/invoice'
require 'util/resultsort'
require 'state/drugs/register_download'
require 'state/user/download'

module ODDB
  module State
    module Drugs

class TestRegisterDownload <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @user    = flexmock('user', :creditable? => nil)
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :user_input  => nil,
                        :user        => @user
                       )
    atc_class = flexmock('atc_class', :package_count => 0)
    @model   = flexmock('model', :atc_classes => [atc_class])
    @state   = ODDB::State::Drugs::RegisterDownload.new(@session, @model)
  end
  def test_init
    assert_nil(@state.init)
  end
  def test_init__creditable
    flexmock(@user, 
             :creditable? => true,
             :name => 'name'
            )
    assert_equal('name', @state.init)
  end
  def test_price
    assert_in_delta(0, RegisterDownload.price(0), 1e-10)
    assert_in_delta(3.50, RegisterDownload.price(1), 1e-10)
    assert_in_delta(3.50, RegisterDownload.price(100), 1e-10)
    assert_in_delta(4.50, RegisterDownload.price(101), 1e-10)
    assert_in_delta(4.50, RegisterDownload.price(200), 1e-10)
    assert_in_delta(5.50, RegisterDownload.price(201), 1e-10)
    assert_in_delta(5.50, RegisterDownload.price(300), 1e-10)
  end
end

class TestRegisterInvoicedDownload <Minitest::Test
  include FlexMock::TestCase
  def setup
    @app     = flexmock('app', 
                        :create => 'create',
                        :update => 'update'
                       )
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :app => @app,
                        :"user.name" => 'name'
                       )
    item     = flexmock('item', :values => {})
    @model   = flexmock('model', :items => [item])
    @state   = ODDB::State::Drugs::RegisterInvoicedDownload.new(@session, @model)
  end
  def test_price
    assert_in_delta(0, RegisterInvoicedDownload.price(0), 1e-10)
    assert_in_delta(5.00, RegisterInvoicedDownload.price(1), 1e-10)
    assert_in_delta(5.00, RegisterInvoicedDownload.price(100), 1e-10)
    assert_in_delta(6.50, RegisterInvoicedDownload.price(101), 1e-10)
    assert_in_delta(6.50, RegisterInvoicedDownload.price(200), 1e-10)
    assert_in_delta(8.00, RegisterInvoicedDownload.price(201), 1e-10)
    assert_in_delta(8.00, RegisterInvoicedDownload.price(300), 1e-10)
  end
  def test_checkout
    flexmock(@state, 
             :creditable?  => true,
             :unique_email => 'unique_email'
            )
    assert_kind_of(ODDB::State::User::Download, @state.checkout)
  end
end
    end # Drugs
  end # State
end # ODDB
