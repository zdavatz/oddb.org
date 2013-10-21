#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Drugs::TestDDDPrice -- oddb.org -- 11.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/drugs/compare'
require 'view/drugs/ddd_price'
require 'htmlgrid/select'
require 'model/galenicgroup'
require 'model/analysis/group'

module ODDB
  class Session
    DEFAULT_FLAVOR = 'gcc'
  end
  module View
    class Copyright < HtmlGrid::Composite
      ODDB_VERSION = 'oddb_version'
    end
  end
end

module ODDB
  module View
    module Drugs

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
                          :get_currency_rate => 1.0
                         )
    fact       = flexmock('fact', :factor => 'factor')
    dose       = flexmock('dose', 
                          :fact => fact,
                          :unit => 'unit',
                          :want => 'want'
                         )
    @ddd       = flexmock('ddd', :dose => dose)
    atc_class  = flexmock('atc_class', :ddd => @ddd)
    @model     = flexmock('model', 
                          :atc_class    => atc_class,
                          :dose         => dose,
                          :price_public => 'price_public',
                          :ddd_price    => 'ddd_price',
                          :longevity    => 'longevity',
                          :size         => 'size'
                         )
    @composite = ODDB::View::Drugs::DDDPriceTable.new(@model, @session)
  end
  def test_ddd_oral
    assert_kind_of(HtmlGrid::Value, @composite.ddd_oral(@model))
  end
  def test_calculation
    assert_kind_of(HtmlGrid::Value, @composite.calculation(@model))
  end
  def test_calculation__longevity_nil
    flexmock(@model, :longevity => nil)
    assert_kind_of(HtmlGrid::Value, @composite.calculation(@model))
  end
  def test_calculation__mdose_ddose
    fact  = flexmock('fact', :factor => 'factor')
    mdose = flexmock('mdose', 
                     :want => 1,
                     :fact => fact
                    )
    ddose = flexmock('ddose', 
                     :want => 0,
                     :fact => fact,
                     :unit => 'unit'
                    )
    flexmock(@model, 
             :longevity => nil,
             :dose      => mdose
            )
    flexmock(@ddd, :dose => ddose)
    assert_kind_of(HtmlGrid::Value, @composite.calculation(@model))
  end
end

class TestDDDPriceComposite <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :enabled?   => nil,
                          :disabled?  => nil,
                          :lookup     => 'lookup',
                          :attributes => {},
                          :resource   => 'resource',
                          :_event_url => '_event_url'
                         )
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :error       => 'error',
                          :currency    => 'currency',
                          :get_currency_rate => 1.0,
                          :language    => 'language'
                         )
    fact       = flexmock('fact', :factor => 'factor')
    dose       = flexmock('dose', 
                          :fact => fact,
                          :unit => 'unit',
                          :want => 'want'
                         )
    @ddd       = flexmock('ddd', :dose => dose)
    atc_class  = flexmock('atc_class', :ddd => @ddd)
    commercial_form = flexmock('commercial_form', :language => 'language')
    part       = flexmock('part', 
                          :multi   => 'multi',
                          :count   => 'count',
                          :measure => 'measure',
                          :commercial_form => commercial_form
                         )
    indication = flexmock('indication', :language => 'language')
    @model     = flexmock('model', 
                          :name_base    => 'name_base',
                          :atc_class    => atc_class,
                          :dose         => dose,
                          :price_public => 'price_public',
                          :ddd_price    => 'ddd_price',
                          :longevity    => 'longevity',
                          :size         => 'size',
                          :commercial_forms => ['commercial_form'],
                          :parts        => [part],
                          :pointer      => 'pointer',
                          :indication   => indication,
                          :ikskey       => 'ikskey'
                         )
    @composite = ODDB::View::Drugs::DDDPriceComposite.new(@model, @session)
  end
  def test_init
    flexmock(@lnf, :enabled? => true)
    flexmock(@composite, :u => 'u')
    assert_equal({}, @composite.init)
  end
end

class TestDDDPrice <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf      = flexmock('lookandfeel', 
                         :enabled?   => nil,
                         :disabled?  => nil,
                         :attributes => {},
                         :resource   => 'resource',
                         :lookup     => 'lookup',
                         :zones      => ['zones'],
                         :direct_event => 'direct_event',
                         :_event_url => '_event_url',
                         :zone_navigation => ['zone_navigation'],
                         :navigation => ['navigation'],
                         :base_url   => 'base_url'
                        )
    user      = flexmock('user', :valid? => nil)
    sponsor   = flexmock('sponsor', :valid? => nil)
    snapback_model = flexmock('snapback_model', :pointer => 'pointer')
    state     = flexmock('state', 
                         :direct_event   => 'direct_event',
                         :snapback_model => snapback_model
                        )
    @session  = flexmock('session', 
                         :lookandfeel => @lnf,
                         :user        => user,
                         :sponsor     => sponsor,
                         :state       => state,
                         :allowed?    => nil,
                         :error       => 'error',
                         :currency    => 'currency',
                         :get_currency_rate => 1.0,
                         :zone        => 'zone',
                         :persistent_user_input => 'persistent_user_input',
                         :language    => 'language',
                         :flavor      => 'flavor',
                         :event       => 'event',
                         :get_cookie_input => 'get_cookie_input',
                        )
    fact      = flexmock('fact', :factor => 'factor')
    dose      = flexmock('dose', 
                         :fact => fact,
                         :unit => 'unit',
                         :want => 'want'
                        )
    ddd       = flexmock('ddd', :dose => dose)
    atc_class = flexmock('atc_class', :ddd => ddd)
    commercial_form = flexmock('commercial_form', :language => 'language')
    part      = flexmock('part', 
                         :multi   => 'multi',
                         :count   => 'count',
                         :measure => 'measure',
                         :commercial_form => commercial_form
                        )
    indication = flexmock('indication', :language => 'language')
    @model    = flexmock('model', 
                         :name_base  => 'name_base',
                         :atc_class  => atc_class,
                         :dose       => dose,
                         :price_public => 'price_public',
                         :ddd_price  => 'ddd_price',
                         :longevity  => 'longevity',
                         :size       => 'size',
                         :commercial_forms => [commercial_form],
                         :parts      => [part],
                         :ikskey     => 'ikskey',
                         :indication => indication
                        )
    @template = ODDB::View::Drugs::DDDPrice.new(@model, @session)
  end
  def test_meta_tag
    flexmock(@template, :u => 'u')
    context = flexmock('context', 
                       :meta => 'meta',
                       :link => 'link'
                      )
    assert_equal('metametalinkmeta', @template.meta_tags(context))
  end
  def test_pointer_descr
    assert_equal('lookup', @template.pointer_descr(@model))
  end
end

    end # Drugs
  end # View
end # ODDB
