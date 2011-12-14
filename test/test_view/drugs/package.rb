#!/usr/bin/env ruby
# encoding: utf-8
# View::Drugs::TestPackage -- oddb -- 23.03.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/drugs/package'
require 'htmlgrid/span'
require 'model/index_therapeuticus'
require 'sbsm/validator'

class TestCompositionList < Test::Unit::TestCase
  include FlexMock::TestCase
  def test_composition
    commercial_form = flexmock('commercial_form', :language => 'language')
    composition  = flexmock('composition', :label => 'label')
    substance    = flexmock('substance', :language => 'language')
    galenic_form = flexmock('galenic_form', :language => 'language')
    parent       = flexmock('parent', :galenic_form => galenic_form)
    active_agent = flexmock('active_agent', 
                            :substance => substance,
                            :dose      => 'dose',
                            :parent    => parent
                           )
    lookandfeel  = flexmock('lookandfeel', 
                            :lookup     => 'lookup',
                            :attributes => {}
                           )
    state        = flexmock('state')
    @app         = flexmock('app')
    @session     = flexmock('session', 
                            :language    => 'language',
                            :lookandfeel => lookandfeel,
                            :app         => @app,
                            :state       => state
                           )
    @model       = flexmock('model', 
                            :multi           => 'multi',
                            :count           => 'count',
                            :measure         => 'measure',
                            :commercial_form => commercial_form,
                            :composition     => composition,
                            :active_agents   => [active_agent]
                           )
    @list        = ODDB::View::Drugs::CompositionList.new([@model], @session)
    result       = @list.composition(@model)
    assert_equal(2, result.length)
    assert_kind_of(HtmlGrid::Div, result[0])
    assert_kind_of(ODDB::View::Admin::ActiveAgents, result[1])
  end
end

class TestPackageInnerComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lookandfeel = flexmock('lookandfeel', 
                            :lookup     => 'lookup',
                            :enabled?   => nil,
                            :language   => 'language',
                            :disabled?  => nil,
                            :attributes => {},
                            :_event_url => '_event_url'
                           )
    atc_class  = flexmock('atc_class', 
                          :description => 'description',
                          :code        => 'code',
                          :has_ddd?    => true,
                          :parent_code => 'parent_code',
                          :pointer     => 'pointer'
                         )
    @app       = flexmock('app', :atc_class => atc_class)
    @session   = flexmock('session', 
                          :lookandfeel       => @lookandfeel,
                          :error             => 'error',
                          :app               => @app,
                          :language          => 'language',
                          :currency          => 'currency',
                          :get_currency_rate => 1.0,
                          :persistent_user_input => 'persistent_user_input'
                         )
    @pointer   = flexmock('pointer')
    @model     = flexmock('model', 
                          :narcotic?           => nil,
                          :ddd_price           => 'ddd_price',
                          :production_science  => 'production_science',
                          :sl_entry            => nil,
                          :atc_class           => atc_class,
                          :parallel_import     => 'parallel_import',
                          :name                => 'name',
                          :name_base           => 'name_base',
                          :index_therapeuticus => 'index_therapeuticus',
                          :ikskey              => 'ikskey',
                          :ith_swissmedic      => 'ith_swissmedic',
                          :price_exfactory     => 'price_exfactory',
                          :deductible          => 'deductible',
                          :price_public        => 'price_public',
                          :pointer             => @pointer
                         )
    ith        = flexmock('ith', :language => 'language')
    flexmock(ODDB::IndexTherapeuticus, :find_by_code => ith)
    @composite = ODDB::View::Drugs::PackageInnerComposite.new(@model, @session)
  end
  def test_init
    assert_equal({}, @composite.init)
  end
  def test_init__narcotic
    flexmock(@model, :narcotic? => true)
    flexmock(@pointer, :+ => @pointer)
    assert_equal({}, @composite.init)
  end
  def test_init__feedback
    flexmock(@lookandfeel, :enabled? => true)
    flexmock(@composite, :hash_insert_row => 'hash_insert_row')
    flexmock(@model, 
             :fachinfo_active? => nil,
             :has_fachinfo?    => nil,
             :localized_name   => 'localized_name',
             :has_patinfo?     => nil
            )
    flexmock(@session, :allowed? => nil)
    assert_equal({}, @composite.init)
  end
  def test_init__patinfos
    flexmock(@lookandfeel) do |l|
      l.should_receive(:enabled?).once.with(:feedback).and_return(false)
      l.should_receive(:enabled?).once.with(:fachinfos).and_return(false)
      l.should_receive(:enabled?).once.with(:patinfos).and_return(true)
      l.should_receive(:enabled?).at_least.once.with(:popup_links, false)
      l.should_receive(:enabled?).once.with(:ddd_chart)
    end
    flexmock(@model, :has_patinfo? => nil)
    flexmock(@composite, :hash_insert_row => 'hash_insert_row')
    assert_equal({}, @composite.init)
  end
  def test_init__sl_entry
    flexmock(@model, 
             :sl_entry        => 'sl_entry',
             :limitation_text => 'limitation_text'
            )
    flexmock(@composite, :hash_insert_row => 'hash_insert_row')
    assert_equal({}, @composite.init)
  end
  def test_init__limitation_text
    @composite.instance_eval('components[[1,2,3]] = :limitation_text')
    limitation_text = flexmock('limitation_text', :language => 'language')
    flexmock(@model, :limitation_text => limitation_text)
    assert_equal({}, @composite.init)
  end
  def test_introduction_date
    assert_kind_of(HtmlGrid::DateValue, @composite.introduction_date(@model, @session))
  end
end
class TestODDBViewDrugsPackageComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup 
    @lookandfeel = flexmock('lookandfeel', 
                            :enabled?   => nil,
                            :language   => 'language',
                            :lookup     => 'lookup',
                            :disabled?  => nil,
                            :attributes => {},
                            :_event_url => '_event_url'
                           )
    atc_class  = flexmock('atc_class', 
                          :description => 'description',
                          :code        => 'code',
                          :has_ddd?    => true,
                          :parent_code => 'parent_code',
                          :pointer     => 'pointer'
                         )
    @app       = flexmock('app', :atc_class => atc_class)
    @session   = flexmock('session', 
                          :lookandfeel => @lookandfeel,
                          :error       => 'error',
                          :app         => @app,
                          :language    => 'language',
                          :currency    => 'currency',
                          :state       => 'state',
                          :get_currency_rate     => 1.0,
                          :persistent_user_input => 'persistent_user_input'
                         )
    substance        = flexmock('substance', :language => 'language')
    galenic_form     = flexmock('galenic_form', :language => 'language')
    parent           = flexmock('parent', :galenic_form => galenic_form)
    @active_agent    = flexmock('active_agent', 
                                :substance => substance,
                                :dose      => 'dose',
                                :parent    => parent
                               )
    @commercial_form = flexmock('commercial_form', :language => 'language')
    composition      = flexmock('composition', :label => 'label')
    part       = flexmock('part', 
                          :multi           => 'multi',
                          :count           => 'count',
                          :measure         => 'measure',
                          :composition     => composition,
                          :active_agents   => [@active_agent],
                          :commercial_form => @commercial_form
                         )
    @model     = flexmock('model', 
                          :name      => 'name',
                          :size      => 'size',
                          :narcotic? => nil,
                          :ddd_price => 'ddd_price',
                          :sl_entry  => nil,
                          :atc_class => atc_class,
                          :name_base => 'name_base',
                          :ikskey    => 'ikskey',
                          :pointer   => 'pointer',
                          :parts     => [part],
                          :swissmedic_source   => 'swissmedic_source',
                          :deductible          => 'deductible',
                          :price_exfactory     => 'price_exfactory',
                          :price_public        => 'price_public',
                          :ith_swissmedic      => 'ith_swissmedic',
                          :production_science  => 'production_science',
                          :parallel_import     => 'parallel_import',
                          :index_therapeuticus => 'index_therapeuticus'
                         )
    ith        = flexmock('ith', :language => 'language')
    flexmock(ODDB::IndexTherapeuticus, :find_by_code => ith)
    @composite = ODDB::View::Drugs::PackageComposite.new(@model, @session)
  end
  def test_init
    assert_equal({}, @composite.init)
  end
  def test_init__twitter_share
    flexmock(@lookandfeel) do |l|
      l.should_receive(:enabled?).once.with(:twitter_share).and_return(true)
      l.should_receive(:enabled?).once.with(:facebook_share).and_return(false)
      l.should_receive(:resource).and_return('resource')
      l.should_receive(:enabled?).at_least.once.with(:feedback)
      l.should_receive(:enabled?).at_least.once.with(:fachinfos)
      l.should_receive(:enabled?).at_least.once.with(:patinfos)
      l.should_receive(:enabled?).at_least.once.with(:popup_links, false)
      l.should_receive(:enabled?).at_least.once.with(:ddd_chart)
    end
    indication = flexmock('indication', :language => 'language')
    flexmock(@model, 
             :commercial_forms => [@commercial_form],
             :indication       => indication
            )
    assert_equal({}, @composite.init)
  end
  def test_init__facebook_share
    flexmock(@lookandfeel) do |l|
      l.should_receive(:enabled?).once.with(:twitter_share).and_return(false)
      l.should_receive(:enabled?).once.with(:facebook_share).and_return(true)
      l.should_receive(:enabled?).at_least.once.with(:feedback)
      l.should_receive(:enabled?).at_least.once.with(:fachinfos)
      l.should_receive(:enabled?).at_least.once.with(:patinfos)
      l.should_receive(:enabled?).at_least.once.with(:popup_links, false)
      l.should_receive(:enabled?).at_least.once.with(:ddd_chart)
    end
    assert_equal({}, @composite.init)
  end
  def test_compositions
    composition  = flexmock('composition', :active_agents => [@active_agent])
    flexmock(@model, :compositions => [composition])
    assert_kind_of(ODDB::View::Admin::Compositions, @composite.compositions(@model, @session))
  end
end
class TestPackage < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    lookandfeel = flexmock('lookandfeel', 
                           :enabled?     => nil,
                           :attributes   => {},
                           :resource     => 'resource',
                           :lookup       => 'lookup',
                           :zones        => 'zones',
                           :disabled?    => nil,
                           :direct_event => 'direct_event',
                           :_event_url   => '_event_url',
                           :language     => 'language',
                           :languages    => 'languages',
                           :currencies   => 'currencies',
                           :base_url     => 'base_url',
                           :navigation   => 'navigation',
                           :resource_localized => 'resource_localized',
                           :zone_navigation    => 'zone_navigation'
                          )
    user      = flexmock('user', :valid? => nil)
    sponsor   = flexmock('sponsor', :valid? => nil)
    snapback_model = flexmock('snapback_model', :pointer => 'pointer')
    state     = flexmock('state', 
                        :direct_event   => 'direct_event',
                        :snapback_model => snapback_model,
                        :zone           => 'zone'
                       )
    atc_class = flexmock('atc_class', 
                         :description => 'description',
                         :code        => 'code',
                         :has_ddd?    => true,
                         :parent_code => 'parent_code',
                         :pointer     => 'pointer'
                        )
    app       = flexmock('app', :atc_class => atc_class)
    @session  = flexmock('session',
                         :lookandfeel  => lookandfeel,
                         :user         => user,
                         :sponsor      => sponsor,
                         :state        => state,
                         :allowed?     => nil,
                         :error        => 'error',
                         :app          => app,
                         :request_path => 'request_path',
                         :currency     => 'currency',
                         :language     => 'language',
                         :zone         => 'zone',
                         :get_currency_rate     => 1.0,
                         :persistent_user_input => 'persistent_user_input'
                         )
    commercial_form = flexmock('commercial_form', :language => 'language')
    composition = flexmock('composition', :label => 'label')
    substance = flexmock('substance', :language => 'language')
    galenic_form = flexmock('galenic_form', :language => 'language')
    parent = flexmock('parent', :galenic_form => galenic_form)
    active_agent = flexmock('active_agent', 
                            :substance => substance,
                            :dose      => 'dose',
                            :parent    => parent
                           )
    part      = flexmock('part', 
                         :multi   => 'multi',
                         :count   => 'count',
                         :measure => 'measure',
                         :active_agents => [active_agent],
                         :composition     => composition,
                         :commercial_form => commercial_form
                        )
    indication = flexmock('indication', :language => 'language')
    @model    = flexmock('model', 
                         :name       => 'name',
                         :size       => 'size',
                         :narcotic?  => nil,
                         :ddd_price  => 'ddd_price',
                         :sl_entry   => nil,
                         :atc_class  => atc_class,
                         :name_base  => 'name_base',
                         :parts      => [part],
                         :pointer    => 'pointer',
                         :indication => indication,
                         :ikskey     => 'ikskey',
                         :swissmedic_source   => 'swissmedic_source',
                         :deductible          => 'deductible',
                         :price_exfactory     => 'price_exfactory',
                         :price_public        => 'price_public',
                         :ith_swissmedic      => 'ith_swissmedic',
                         :production_science  => 'production_science',
                         :parallel_import     => 'parallel_import',
                         :commercial_forms    => [commercial_form],
                         :index_therapeuticus => 'index_therapeuticus'
                        )
    ith        = flexmock('ith', :language => 'language')
    flexmock(ODDB::IndexTherapeuticus, :find_by_code => ith)
    @package = ODDB::View::Drugs::Package.new(@model, @session)
  end
  ODDB::View::Copyright::ODDB_VERSION = 'oddb_version'
  def test_meta_tags
    context = flexmock('context', :meta => 'meta')
    assert_equal('metametameta', @package.meta_tags(context))
  end
end
