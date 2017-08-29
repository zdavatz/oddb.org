#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Drugs::TestPriceHistory -- oddb.org -- 29.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'minitest/autorun'
require 'flexmock/minitest'
require 'state/drugs/price_history'
begin require 'pry'; rescue LoadError; end

module ODDB
  module State
    module Drugs

class TestPriceHistory <Minitest::Test
  def setup
    price    =   ODDB::Util::Money.new(0.1)
    @package  = flexmock('package', :is_a? => ODDB::Package)
    @package.should_receive(:prices).and_return({'public' => [price, price]}).by_default
    @sequence = flexmock('sequence', :pointer => 'pointer', :package => @package)
    @registration = flexmock('registration', :sequence => @sequence)
    @app     = flexmock('app',
                        :registration => @registration,
                        )
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
  end
  
  DEFAULT_DATE = Date.new(2015,10,1)
  def create_price(amount, mut_code: 'SLAUFNAHME', type: :public, valid_from: DEFAULT_DATE)
    money =  ODDB::Util::Money.new(amount)
    money.country = 'ch',
    money.mutation_code = mut_code
    money.origin="http://bag.e-mediat.net/SL2007.Web.External/File.axd?file=XMLPublications.zip (#{valid_from.strftime('%Y-%m-%d') })"
    money.valid_from= Time.parse(valid_from.strftime('%Y-%m-%d') + ' 00:00:00')
    money.authority = 'sl'
    money.type = type
    money
  end
  def test_sort_valid_from_is_nil
    # Taken from http://generika.cc/de/generika/price_history/reg/54845/seq/02/pack/022
    first_price   = 40.2
    second_price = 62.85
    third_price  = 21.15
    @prices = {}
    @prices[:public]= [
      create_price(first_price),
      create_price(second_price),
      create_price(third_price, mut_code: 'AUSLANDPV', valid_from: DEFAULT_DATE + 360),
    ]
    @prices[:exfactory] =create_price(21.15)
    @package.should_receive(:prices).and_return(@prices)
    @pointer  = flexmock('pointer', :resolve => @package)
    @session = flexmock('session',
                        :app => @app,
                        :lookandfeel => @lnf,
                        :user_input  => @pointer
                       )
    @model   = flexmock('model')
    @state   = ODDB::State::Drugs::PriceHistory.new(@session, @model)
    result = @state.init
    assert_equal(2, result.size)
    assert(@state.model.first.is_a?(ODDB::State::Drugs::PriceHistory::PriceChange))
    assert_equal(second_price, @state.model.first.public.amount)
    assert_nil(@state.model.first.exfactory)
  end

  def test_sort_two_dates
    # Taken from http://ch.oddb.org/de/gcc/price_history/reg/55717/seq/01/pack/002
    first_price_public  = 1149.2
    first_price_ex      = 936.61
    second_price_public = 1294.25
    second_price_ex     = 1070.0
    @prices = {}
    @prices[:public]= [ 
      create_price(first_price_public),
      create_price(second_price_public, mut_code: 'AUSLANDPV', valid_from:DEFAULT_DATE + 360),
    ]
    @prices[:exfactory]= [ 
      create_price(first_price_ex, type: :exfactory),
      create_price(second_price_ex, mut_code: 'AUSLANDPV', type: :exfactory, valid_from:DEFAULT_DATE + 360),
    ]
    @package.should_receive(:prices).and_return(@prices)
    @pointer  = flexmock('pointer', :resolve => @package)
    @session = flexmock('session',
                        :app => @app,
                        :lookandfeel => @lnf,
                        :user_input  => @pointer
                       )
    @model   = flexmock('model')
    @state   = ODDB::State::Drugs::PriceHistory.new(@session, @model)
    result = @state.init
    assert(@state.model.first.is_a?(ODDB::State::Drugs::PriceHistory::PriceChange))
    assert(result.first.is_a?(ODDB::State::Drugs::PriceHistory::PriceChange))
    assert_equal(ODDB::State::Drugs::PriceHistory::PriceChange, result.first.class)

    assert_equal(ODDB::State::Drugs::PriceHistory::PriceChanges, result.class)
    assert_equal(2, result.size)
    assert_equal(DEFAULT_DATE,        result[0].valid_from.to_date)
    assert_equal(DEFAULT_DATE + 360,  result[1].valid_from.to_date)
    assert_equal(DEFAULT_DATE,        result[0].exfactory.valid_from.to_date)
    assert_equal(DEFAULT_DATE + 360,  result[1].exfactory.valid_from.to_date)
    assert_equal(first_price_public,  result[0].public.amount)
    assert_equal(second_price_public, result[1].public.amount)
    assert_equal(first_price_ex    ,  result[0].exfactory.amount)
    assert_equal(second_price_ex    , result[1].exfactory.amount)
  end
  def test_init
    price    = flexmock('price', 
                        :valid_from => Time.local(2011,2,3),
                        :credits => 'credits',
                        :to_f => 0.1,
                       )
    package  = flexmock('package',
                        :prices => {'public' => [price, price]},
                        :is_a? => true,
                       )
    @pointer  = flexmock('pointer', :resolve => @package)
    @session = flexmock('session', 
                        :app => @app,
                        :lookandfeel => @lnf,
                        :user_input  => @pointer
                       )
    @model   = flexmock('model')
    @state   = ODDB::State::Drugs::PriceHistory.new(@session, @model)
    assert_kind_of(ODDB::State::Drugs::PriceHistory::PriceChange, @state.init[0])
  end
end

    end # Drugs
  end # State
end # ODDB
