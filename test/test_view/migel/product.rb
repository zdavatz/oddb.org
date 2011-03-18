#!/usr/bin/env ruby
# View::Migel::TestProduct -- oddb.org -- 17.03.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/resulttemplate'
require 'htmlgrid/labeltext'
require 'view/migel/product'
require 'sbsm/validator'

class TestProductInnerComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lookandfeel    = flexmock('lookandfeel', 
                               :_event_url  => nil,
                               :attributes  => {},
                               :disabled?   => nil,
                               :enabled?    => nil,
                               :lookup      => 'lookup'
                              )
    @session        = flexmock('session', 
                               :lookandfeel => @lookandfeel,
                               :error       => nil,
                               :event_url   => nil,
                               :language    => 'language'
                              )
    group           = flexmock('group', 
                               :language => 'language',
                               :pointer  => 'pointer'
                              )
    product_text    = flexmock('product_text', :language => 'language')
    limitation_text = flexmock('limitation_text', :language => 'language')
    unit            = flexmock('unit', :language => 'language')
    @model          = flexmock('model',
                               :group        => group,
                               :subgroup     => group,
                               :language     => 'language',
                               :product_text => product_text,
                               :limitation_text => limitation_text,
                               :price        => 'price',
                               :qty          => 'qty',
                               :unit         => unit,
                               :pointer      => 'pointer',
                               :localized_name => 'localized_name'
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

end
