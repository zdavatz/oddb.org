#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Migel::TestProduct -- oddb.org -- 09.11.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/resulttemplate'
require 'htmlgrid/labeltext'
require 'view/migel/product'
require 'view/migel/group'
require 'view/migel/subgroup'
require 'sbsm/validator'
require 'model/package'
require 'state/drugs/compare'
require 'remote/migel/model_super'
require 'remote/migel/model/group'

module ODDB
  module View
    class Session
      DEFAULT_FLAVOR = 'gcc'
    end
    Copyright::ODDB_VERSION = 'version'
    module Migel

class TestProductInnerComposite <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lookandfeel    = flexmock('lookandfeel', 
                               :_event_url  => nil,
                               :attributes  => {},
                               :disabled?   => nil,
                               :enabled?    => nil,
                               :lookup      => 'lookup'
                              ).by_default
    @session        = flexmock('session', 
                               :lookandfeel => @lookandfeel,
                               :error       => nil,
                               :event_url   => nil,
                               :language    => 'language'
                              )
    group           = flexmock('group', 
                               :language => 'language',
                               :pointer  => 'pointer',
                               :migel_code => 'migel_code'
                              )
    product_text    = flexmock('product_text', :language => 'language')
    limitation_text = flexmock('limitation_text', :language => 'language')
    unit            = flexmock('unit', :language => 'language')
    pointer         = flexmock('pointer', :to_csv => 'to_csv')
    @model          = flexmock('model',
                               :group        => group,
                               :subgroup     => group,
                               :language     => 'language',
                               :product_text => product_text,
                               :limitation_text => limitation_text,
                               :price        => 'price',
                               :qty          => 'qty',
                               :unit         => unit,
                               :pointer      => pointer,
                               :localized_name => 'localized_name',
                               :items        => ['item'],
                               :migel_code   => 'migel_code'
                              )
    @composite = ODDB::View::Migel::ProductInnerComposite.new(@model, @session)
  end
  def test_comparable_size
    commercial_form = flexmock('commercial_form', :language => 'language')
    part = flexmock('part', 
                    :multi   => 'multi',
                    :count   => 'count',
                    :measure => 'measure',
                    :commercial_form => commercial_form
                   )
    flexmock(@model, 
             :commercial_forms => ['commercial_form'],
             :parts            => [part]
            )
    expected = "language &agrave; measure"
    assert_equal(expected, @composite.comparable_size(@model, @session))
  end
  def test_comparable_size__no_commercial_form
    flexmock(@model, 
             :commercial_forms => [],
             :size             => 'size'
            )
    assert_equal('size', @composite.comparable_size(@model, @session))
  end
  def test_part_size
    commercial_form = flexmock('commercial_form', :language => 'language')
    part = flexmock('part', 
                    :multi   => 2,
                    :count   => 2,
                    :measure => 'measure',
                    :commercial_form => commercial_form
                   )
    expected = "2 x 2 language &agrave; measure"
    assert_equal(expected, @composite.part_size(part, @session))
  end
  def test_part_size__no_parts
    part = flexmock('part', 
                    :multi   => 2,
                    :count   => 2,
                    :measure => "measure",
                    :commercial_form => nil
                   )
    expected = "2 x 2 x measure"
    assert_equal(expected, @composite.part_size(part, @session))
  end
  def test_atc_ddd_link
    app = flexmock('app', :atc_class => nil)
    flexmock(@session, :app => app)
    atc = flexmock('atc', 
                   :has_ddd?    => nil,
                   :parent_code => 'code'
                  )
    assert_equal(nil, @composite.atc_ddd_link(atc, @session))
  end
  def test_atc_description
    flexmock(@lookandfeel, :language => 'language')
    atc = flexmock('atc', 
                   :description => 'description',
                   :code        => 'code'
                  )
    expected = "description (code)"
    assert_equal(expected, @composite.atc_description(atc, @session))
  end
  def test_atc_description__else
    flexmock(@lookandfeel, :language => 'language')
    atc = flexmock('atc', 
                   :description => nil,
                   :code        => 'code'
                  )
    expected = "code"
    assert_equal(expected, @composite.atc_description(atc, @session))
  end
  def test_comarketing
    flexmock(@model, :parallel_import => 'parallel_import')
    assert_kind_of(HtmlGrid::Span, @composite.comarketing(@model, @session))
  end
  def test_comarketing__parent_protected
    patent = flexmock('patent', :certificate_number => 'certificate_number')
    flexmock(@model, 
             :parallel_import   => nil,
             :patent_protected? => true,
             :patent            => patent
            )
    assert_kind_of(HtmlGrid::Link, @composite.comarketing(@model, @session))
  end
  def test_comarketing__comarketing_with
    comarketing = flexmock('comarketing', :name_base => 'name_base')
    flexmock(@model, 
             :parallel_import   => nil,
             :patent_protected? => false,
             :comarketing_with  => comarketing
            )
    assert_kind_of(HtmlGrid::Link, @composite.comarketing(@model, @session))
  end
  def test_complementary_type
    flexmock(@model, :complementary_type => 'complementary_type')
    assert_kind_of(HtmlGrid::Span, @composite.complementary_type(@model, @session))
  end
  def test_compositions
    galenic_form = flexmock('galenic_form', :language => 'language')
    composition  = flexmock('composition', 
                            :galenic_form  => galenic_form,
                            :active_agents => ['active_agent', 'active_agent']
                           )
    flexmock(@model, 
             :compositions  => [composition],
             :active_agents => ['active_agent']
            )
    link = @composite.compositions(@model, @session)
    assert_kind_of(HtmlGrid::Link, link)
    assert_equal('language: lookup', link.value)
  end
  def test_compositions__active_agents_1
    galenic_form = flexmock('galenic_form', :language => 'language')
    composition  = flexmock('composition', 
                            :galenic_form  => galenic_form,
                            :active_agents => ['active_agent']
                           )
    flexmock(@model, :compositions  => [composition])
    link = @composite.compositions(@model, @session)
    assert_kind_of(HtmlGrid::Link, link)
    assert_equal('language: active_agent', link.value)
  end
  def test_ddd_price
    flexmock(@session, 
             :currency          => 'currency',
             :get_currency_rate => 1.0,
             :persistent_user_input => 'persistent_user_input'
            )
    flexmock(@model, :ddd_price => 'ddd_price')
    result = @composite.ddd_price(@model, @session)
    assert_kind_of(HtmlGrid::Span, result)
    assert_equal('ddd_price', result.value)
  end
  def test_ddd_price__chart
    flexmock(@lookandfeel, :enabled? => true)
    flexmock(@session, 
             :currency          => 'currency',
             :get_currency_rate => 1.0,
             :persistent_user_input => 'persistent_user_input'
            )
    flexmock(@model, :ddd_price => 'ddd_price')
    result = @composite.ddd_price(@model, @session)
    assert_kind_of(HtmlGrid::Link, result)
    assert_equal('ddd_price', result.value)
  end
  def test_description
    flexmock(@model, :language => 'Position 12.34.56.78.9')
    flexmock(@lookandfeel, :_event_url => '_event_url')
    assert_kind_of(HtmlGrid::Value, @composite.description(@model))
  end
  def test_migel_code
    assert_kind_of(ODDB::View::PointerLink, @composite.migel_code(@model))
  end
  def test_migel_code__else
    flexmock(@model, :items => nil)
    assert_kind_of(HtmlGrid::Value, @composite.migel_code(@model))
  end
end


class TestAccessoryOfList <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @app     = flexmock('app')
    @session = flexmock('session', 
                        :app => @app,
                        :lookandfeel => @lnf,
                        :event => 'event'
                       )
    @model = flexmock('model', :migel_code => 'migel_code')
    @list = ODDB::View::Migel::AccessoryOfList.new([@model], @session)
  end
  def test_migel_code
    flexmock(@model, 
             :is_a? => true,
             :pharmacode => 'pharmacode'
            )
    assert_equal('pharmacode', @list.migel_code(@model, @session))
  end
end

class TestPointerSteps <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :disabled?  => nil,
                        :lookup     => 'lookup',
                        :_event_url => '_event_url'
                       )
    method   = flexmock('method', :arity => 0)
    @model   = flexmock('model', 
                        :pointer => 'pointer',
                        :pointer_descr => 'pointer_descr',
                        :method  => method,
                        :migel_code => 'migel_code',
                        :is_a?      => true,
                        :oid        => 'oid',
                       ).by_default
    state    = flexmock('state', :snapback_model => @model)
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :state       => state
                       )
    @steps = ODDB::View::Migel::PointerSteps.new(@model, @session)
  end
  def test_pointer_descr__drb_group
    flexmock(@model) do |m|
      m.should_receive(:is_a?).with(ODDB::Company).and_return(false)
      m.should_receive(:is_a?).with(DRbObject).and_return(true)
      m.should_receive(:migel_code).and_return('12')
    end
    assert_kind_of(ODDB::View::PointerLink, @steps.pointer_descr(@model, @session))
  end
  def test_pointer_descr__drb_subgroup
    flexmock(@model) do |m|
      m.should_receive(:is_a?).with(ODDB::Company).and_return(false)
      m.should_receive(:is_a?).with(DRbObject).and_return(true)
      m.should_receive(:migel_code).and_return('12.34')
    end
    assert_kind_of(ODDB::View::PointerLink, @steps.pointer_descr(@model, @session))
  end
  def test_pointer_descr__drb_product
    flexmock(@model) do |m|
      m.should_receive(:is_a?).with(ODDB::Company).and_return(false)
      m.should_receive(:is_a?).with(DRbObject).and_return(true)
      m.should_receive(:migel_code).and_return('12.34.56.78.9')
    end
    assert_kind_of(ODDB::View::PointerLink, @steps.pointer_descr(@model, @session))
  end
  def test_pointer_descr__group
    skip("Avoid  uninitialized constant Migel::Group")
    flexmock(@model) do |m|
      m.should_receive(:is_a?).with(ODDB::Company).and_return(false)
      m.should_receive(:is_a?).with(DRbObject).and_return(false)
      m.should_receive(:is_a?).with(::Migel::Group).and_return(true)
    end
    skip("Avoid  uninitialized constant Migel::Group")
    assert_kind_of(ODDB::View::PointerLink, @steps.pointer_descr(@model, @session))
  end
  def test_pointer_descr__subgroup
    skip("Avoid  uninitialized constant Migel::Group")
    flexmock(@model) do |m|
      m.should_receive(:is_a?).with(ODDB::Company).and_return(false)
      m.should_receive(:is_a?).with(DRbObject).and_return(false)
      m.should_receive(:is_a?).with(::Migel::Group).and_return(false)
      m.should_receive(:is_a?).with(::Migel::Subgroup).and_return(true)
    end
    assert_kind_of(ODDB::View::PointerLink, @steps.pointer_descr(@model, @session))
  end
  def test_pointer_descr__product
    skip("Avoid  uninitialized constant Migel::Group")
    flexmock(@model) do |m|
      m.should_receive(:is_a?).with(ODDB::Company).and_return(false)
      m.should_receive(:is_a?).with(DRbObject).and_return(false)
      m.should_receive(:is_a?).with(::Migel::Group).and_return(false)
      m.should_receive(:is_a?).with(::Migel::Subgroup).and_return(false)
      m.should_receive(:is_a?).with(::Migel::Product).and_return(true)
    end
    assert_kind_of(ODDB::View::PointerLink, @steps.pointer_descr(@model, @session))
  end
end

class TestProduct <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :enabled? => nil,
                        :attributes => {},
                        :resource   => 'resource',
                        :lookup   => 'lookup',
                        :zones    => ['zones'],
                        :disabled?  => nil,
                        :direct_event => 'direct_event',
                        :_event_url   => '_event_url',
                        :zone_navigation => ['zone_navigation'],
                        :navigation   => ['navigation'],
                        :base_url  => 'base_url'
                       )
    user     = flexmock('user', :valid? => nil)
    group    = flexmock('group', 
                        :pointer    => 'pointer',
                        :language   => 'language',
                        :migel_code => 'migel_code'
                       )
    subgroup = flexmock('subgroup', 
                        :pointer   => 'pointer',
                        :language  => 'language',
                        :migel_code => 'migel_code'
                       )
    product_text = flexmock('product_text', :language => 'language')
    limitation_text = flexmock('limitation_text', :language => 'language')
    unit     = flexmock('unit', :language => 'language')
    method   = flexmock('method', :arity => 0)
    accessory    = flexmock('accessory', 
                            :pointer => 'pointer',
                            :migel_code => 'migel_code',
                            :method  => method
                           )
    product  = flexmock('product',
                        :ean_code => 'ean_code',
                        :status   => 'status'
                       )
    @model   = flexmock('model', 
                        :pointer => 'pointer',
                        :migel_code => 'migel_code',
                        :items   => ['item'],
                        :group   => group,
                        :subgroup => subgroup,
                        :language => 'language',
                        :product_text => product_text,
                        :limitation_text => limitation_text,
                        :price => 'price',
                        :qty   => 'qty',
                        :unit  => unit,
                        :localized_name => 'localized_name',
                        :accessories => [accessory],
                        :products => [product],
                        :pointer_descr => 'pointer_descr',
                        :oid        => 'oid',
                        :iksnr      => 'iksnr',
                        :seqnr      => 'seqnr',
                        :ikscd      => 'ikscd',
                        :is_a?      => true,
                       )
    state    = flexmock('state', 
                        :direct_event   => 'direct_event',
                        :snapback_model => @model
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :user    => user,
                        :sponsor => user,
                        :state   => state,
                        :error   => 'error',
                        :language => 'language',
                        :event   => 'event',
                        :zone    => 'zone',
                        :event   => 'event',
                        :flavor  => 'flavor',
                       )
    @view = ODDB::View::Migel::Product.new(@model, @session)
  end
  def test_backtracking
    assert_kind_of(ODDB::View::Migel::PointerSteps, @view.backtracking(@model, @session))
  end
end
    end # Migel
  end # View
end # ODDB
