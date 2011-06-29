#!/usr/bin/env ruby
# ODDB::State::Drugs::TestPriceHistory -- oddb.org -- 29.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'state/drugs/price_history'


module ODDB
  module State
    module Drugs

class TestPriceHistory < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @app     = flexmock('app')
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    price    = flexmock('price', 
                        :valid_from => Time.local(2011,2,3),
                        :credits => 'credits'
                       )
    flexmock(price, 
             :- => price,
             :/ => price,
             :* => price
            )
    package  = flexmock('package', :prices => {'public' => [price, price]})
    pointer  = flexmock('pointer', :resolve => package)
    @session = flexmock('session', 
                        :app => @app,
                        :lookandfeel => @lnf,
                        :user_input  => pointer 
                       )
    @model   = flexmock('model')
    @state   = ODDB::State::Drugs::PriceHistory.new(@session, @model)
  end
  def test_init
    assert_kind_of(ODDB::State::Drugs::PriceHistory::PriceChange, @state.init[0])
  end
end

    end # Drugs
  end # State
end # ODDB
