#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Ajax::TestDDDPrice -- oddb.org -- 29.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/ajax/ddd_price'


module ODDB
  module View
    module Ajax

class TestDDDPriceTable <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :disabled?  => nil,
                          :enabled?   => nil,
                          :attributes => {}
                         )
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :error       => 'error',
                          :currency    => 'currency',
                          :get_currency_rate => 1
                         )
    @fact      = flexmock('fact', :factor => 'factor')
    dose       = flexmock('dose', 
                          :fact => @fact,
                          :unit => 'unit',
                          :want => 'want'
                         )
    @ddd       = flexmock('ddd', :dose => dose)
    atc_class  = flexmock('atc_class', :ddd => @ddd)
    @model     = flexmock('model', 
                          :atc_class => atc_class,
                          :dose      => dose,
                          :ddd_price => 'ddd_price',
                          :longevity => 'longevity',
                          :size      => 'size',
                          :price_public => 'price_public'
                         )
    @composite = ODDB::View::Ajax::DDDPriceTable.new(@model, @session)
  end
  def test_ddd_oral
    assert_kind_of(HtmlGrid::Value, @composite.ddd_oral(@model))
  end
  def test_calculation
    assert_kind_of(HtmlGrid::Value, @composite.calculation(@model))
  end
  def test_calculation__not_longevity
    flexmock(@model, :longevity => nil)
    assert_kind_of(HtmlGrid::Value, @composite.calculation(@model))
  end
  def test_calculation__mdose_lt_ddose
    ddd_dose   = flexmock('ddd_dose', 
                          :want => 1,
                          :fact => @fact,
                          :unit => 'unit'
                         )
    model_dose = flexmock('model_dose', 
                          :want => 2,
                          :fact => @fact,
                          :unit => 'unit'
                         )
    flexmock(@ddd, :dose => ddd_dose)
    flexmock(@model, 
             :longevity => nil,
             :dose      => model_dose
            )
    assert_kind_of(HtmlGrid::Value, @composite.calculation(@model))
  end
end

class TestDDDPrice <Minitest::Test
  include FlexMock::TestCase
  def setup
    lookup     = flexmock('lookup', 
                          :value  => 'value',
                          :value= => nil
                         )
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => lookup,
                          :enabled?   => true,
                          :disabled?  => true,
                          :attributes => {},
                          :resource   => 'resource',
                          :_event_url => '_event_url'
                         )
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :error       => 'error',
                          :currency    => 'currency',
                          :get_currency_rate => 1
                         )
    fact       = flexmock('fact', :factor => 'factor')
    dose       = flexmock('dose', 
                          :fact => fact,
                          :unit => 'unit',
                          :want => 'want'
                         )
    ddd        = flexmock('ddd', :dose => dose)
    atc_class  = flexmock('atc_class', :ddd => ddd)
    @model     = flexmock('model', 
                          :atc_class => atc_class,
                          :dose      => dose,
                          :ddd_price => 'ddd_price',
                          :longevity => 'longevity',
                          :size      => 'size',
                          :ikskey    => 'ikskey',
                          :name_base => 'name_base',
                          :price_public => 'price_public'
                         )
    @composite = ODDB::View::Ajax::DDDPrice.new(@model, @session)
  end
  def test_init
    expected = [[[0, 0], ODDB::View::Ajax::DDDPriceTable], [[0, 1], :ddd_chart]]
    assert_equal(expected, @composite.init)
  end
end


    end # Ajax
  end # View
end # ODDB

