#!/usr/bin/env ruby
# encoding: utf-8
# View::Drugs::TestCenteredSearch -- oddb.org -- 18.03.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/drugs/centeredsearchform'
require 'model/package'
require 'view/resulttemplate'
require 'htmlgrid/labeltext'
require 'view/migel/product'
require 'remote/migel/model_super'
require 'remote/migel/model/product'

module ODDB
  class Session
    DEFAULT_FLAVOR = 'gcc'
  end
  module Migel
    class Product
    end
  end
end

class TestCenteredSearchComposite <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lookandfeel = flexmock('lookandfeel',                             
                            :disabled?  => nil,
                            :lookup     => 'lookup',
                            :attributes => {},
                            :_event_url => '_event_url',
                            :zones      => ['zones'],
                            :zones      => ['zones'],
                            :base_url   => 'base_url',
                            :zone_navigation => ['zone_navigation'],
                            :direct_event    => 'direct_event',
                           ).by_default
    @lookandfeel.should_receive(:enabled?).by_default
    @app       = flexmock('app', :narcotics => 'narcotics')
    @session   = flexmock('session', 
                          :app         => @app,
                          :lookandfeel => @lookandfeel,
                          :zone        => 'zone',
                          :persistent_user_input => 'persistent_user_input',
                          :flavor => 'flavor',
                          :search_form => 'search_form',
                          :get_cookie_input => 'get_cookie_input',
                          :event => 'event',
                         )
    @model     = flexmock('model')
    @composite = ODDB::View::Drugs::CenteredSearchComposite.new(@model, @session)
  end
  def test_init
    expected = {[0, 9]=>"legal-note center", [0, 7]=>"legal-note"}
    assert_equal(expected, @composite.init)
  end
  def test_init__just_medical_structure
    flexmock(@lookandfeel) do |l|
      l.should_receive(:enabled?).once.with(:ajax, false).and_return(false)
      l.should_receive(:enabled?).once.with(:just_medical_structure, false).and_return(true)
      l.should_receive(:enabled?).never.with(:search_reset)
      l.should_receive(:enabled?).once.with(:custom_tab_navigation, false)
    end
    expected = {[0, 9]=>"legal-note center", [0, 7]=>"legal-note"}
    assert_equal(expected, @composite.init)
  end
  def test_init__oekk_structure
    flexmock(@lookandfeel) do |l|
      l.should_receive(:enabled?).once.with(:ajax, false).and_return(false)
      l.should_receive(:enabled?).once.with(:oekk_structure, false).and_return(true)
      l.should_receive(:enabled?).once.with(:just_medical_structure, false)
      l.should_receive(:enabled?).never.with(:search_reset)
      l.should_receive(:enabled?).once.with(:custom_tab_navigation, false)
      l.should_receive(:enabled?).once.with(:popup_links, false)
    end
    flexmock(@app, :recent_registration_count => 'recent_registration_count')
    expected = {[0, 9]=>"legal-note center", [0, 7]=>"legal-note"}
    assert_equal(expected, @composite.init)
  end
  def test_init__atupri_web
    @lookandfeel.should_receive(:enabled?).once.with(:ajax, false).and_return(false)
    @lookandfeel.should_receive(:enabled?).once.with(:atupri_web, false).and_return(true)
    @lookandfeel.should_receive(:enabled?).once.with(:just_medical_structure, false)
    @lookandfeel.should_receive(:enabled?).once.with(:oekk_structure, false)
    @lookandfeel.should_receive(:enabled?).never.with(:search_reset)
    @lookandfeel.should_receive(:enabled?).once.with(:custom_tab_navigation, false)
    flexmock(@app, :recent_registration_count => 'recent_registration_count')
    expected = {[0, 9]=>"legal-note center", [0, 7]=>"legal-note"}
    assert_equal(expected, @composite.init)
  end
  def test_init__data_counts
    flexmock(@lookandfeel) do |l|
      l.should_receive(:enabled?).once.with(:ajax, false).and_return(false)
      l.should_receive(:enabled?).once.with(:just_medical_structure, false)
      l.should_receive(:enabled?).once.with(:oekk_structure, false)
      l.should_receive(:enabled?).once.with(:atupri_web, false)
      l.should_receive(:enabled?).once.with(:data_counts).and_return(true)
      l.should_receive(:enabled?).once.with(:facebook_fan, false)
      l.should_receive(:enabled?).once.with(:fachinfos)
      l.should_receive(:enabled?).once.with(:patinfos)
      l.should_receive(:enabled?).once.with(:limitation_texts)
      l.should_receive(:enabled?).once.with(:screencast)
      l.should_receive(:enabled?).once.with(:language_switcher)
      l.should_receive(:enabled?).never.with(:search_reset)
      l.should_receive(:enabled?).once.with(:custom_tab_navigation, false)
      l.should_receive(:enabled?).twice.with(:popup_links, false)
      l.should_receive(:enabled?).once.with(:atc_chooser)
      l.should_receive(:enabled?).once.with(:paypal)
    end
    flexmock(@app, 
             :package_count   => 'package_count',
             :narcotics_count => 'narcotics_count',
             :vaccine_count   => 'vaccine_count',
             :fachinfo_count  => 'fachinfo_count',
             :patinfo_count   => 'patinfo_count',
             :atc_ddd_count   => 'atc_ddd_count',
             :limitation_text_count => 'limitation_text_count',
             :recent_registration_count => 'recent_registration_count'
            )
    expected = {[0, 9]=>"legal-note center", [0, 7]=>"legal-note", [0, 13]=>"legal-note"}
    assert_equal(expected, @composite.init)
  end
  def test_init__facebook_fan
    flexmock(@lookandfeel) do |l|
      l.should_receive(:enabled?).once.with(:ajax, false).and_return(false)
      l.should_receive(:enabled?).once.with(:just_medical_structure, false)
      l.should_receive(:enabled?).once.with(:oekk_structure, false)
      l.should_receive(:enabled?).once.with(:atupri_web, false)
      l.should_receive(:enabled?).once.with(:data_counts).and_return(true)
      l.should_receive(:enabled?).once.with(:facebook_fan, false).and_return(true)
      l.should_receive(:enabled?).once.with(:fachinfos)
      l.should_receive(:enabled?).once.with(:patinfos)
      l.should_receive(:enabled?).once.with(:limitation_texts)
      l.should_receive(:enabled?).once.with(:screencast)
      l.should_receive(:enabled?).once.with(:language_switcher)
      l.should_receive(:enabled?).never.with(:search_reset)
      l.should_receive(:enabled?).once.with(:custom_tab_navigation, false)
      l.should_receive(:enabled?).twice.with(:popup_links, false)
      l.should_receive(:enabled?).once.with(:atc_chooser)
      l.should_receive(:enabled?).once.with(:paypal)
    end
    flexmock(@app, 
             :package_count   => 'package_count',
             :narcotics_count => 'narcotics_count',
             :vaccine_count   => 'vaccine_count',
             :fachinfo_count  => 'fachinfo_count',
             :patinfo_count   => 'patinfo_count',
             :atc_ddd_count   => 'atc_ddd_count',
             :limitation_text_count => 'limitation_text_count',
             :recent_registration_count => 'recent_registration_count'
            )
    expected = {[0, 9]=>"legal-note center", [0, 7]=>"legal-note", [0, 13]=>"legal-note"}
    assert_equal(expected, @composite.init)
  end
  def test_create_link
    assert_kind_of(HtmlGrid::Link, @composite.create_link('text_key', 'href'))
  end
  def test_create_link__event
    flexmock(@lookandfeel, :enabled? => true)
    assert_kind_of(HtmlGrid::Link, @composite.create_link('text_key', 'href', true))
  end
  def test_screencast
    flexmock(@lookandfeel, :enabled? => true)
    result = @composite.screencast(@model, @session)
    assert_kind_of(HtmlGrid::Link, result)
    assert_equal('lookup', result.href)
  end
  def test_substance_count
    flexmock(@app, :substance_count => 'substance_count')
    assert_equal('substance_count', @composite.substance_count(@model, @session))
  end
end

#class TestRssFeedbackList <Minitest::Test
class TestRssFeedbackList   <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lookandfeel = flexmock('lookandfeel', 
                            :lookup     => 'lookup',
                            :attributes => {},
                            :_event_url => '_event_url'
                           )
    @session   = flexmock('session', :lookandfeel => @lookandfeel)
    @item      = flexmock('item', :pointer => 'pointer')
    @model     = flexmock('model', :item => @item)
    @composite = ODDB::View::Drugs::RssFeedbackList.new([@model], @session)
  end
  def test_heading
    assert_kind_of(HtmlGrid::Link, @composite.heading(@model))
  end
  def test_heading__package
    flexmock(ODBA.cache, :next_id => 123)
    flexmock(@item, 
             :name => 'name',
             :size => 'size',
             :odba_instance => ODDB::Package.new('12345')
            )
    assert_kind_of(HtmlGrid::Link, @composite.heading(@model))
  end
  def test_heading__migel_product
    flexmock(ODBA.cache, :next_id => 123)
    flexmock(@item, 
             :name => 'name',
             :size => 'size',
             :odba_instance => ODDB::Migel::Product.new
            )
    assert_kind_of(HtmlGrid::Link, @composite.heading(@model))
  end
end

class TestRssFeedbacks <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lookandfeel = flexmock('lookandfeel',
                            :lookup     => 'lookup',
                            :attributes => {},
                            :_event_url => '_event_url',
                            :resource   => 'resource',
                            :resource_global => 'resource_global'
                           )
    @session   = flexmock('session',
                          :lookandfeel => @lookandfeel
                         )
    item       = flexmock('item', :pointer => 'pointer')
    @model     = flexmock('model', :item => item)
    @composite = ODDB::View::Drugs::RssFeedbacks.new([@model], @session)
  end
  def test_rss_image
    assert_kind_of(HtmlGrid::Link, @composite.rss_image([@model]))
  end
end

class TestFachinfoNewsList <Minitest::Test
  include FlexMock::TestCase
  def test_name
    lookandfeel = flexmock('lookandfeel', 
                           :lookup     => 'lookup',
                           :attributes => {},
                           :_event_url => '_event_url'
                          )
    session = flexmock('session', 
                       :lookandfeel => lookandfeel,
                       :language    => 'language'
                      )
    registration = flexmock('registration',
                            :iksnr => 'iksnr'
                           )
    model   = flexmock('model',
                       :localized_name => 'localized_name',
                       :registrations  => [registration]
                      )
    list    = ODDB::View::Drugs::FachinfoNewsList.new([model], session)
    assert_kind_of(HtmlGrid::Link, list.name(model))
  end
end

class TestFachinfoNews <Minitest::Test
  include FlexMock::TestCase
  def test_title
    lookandfeel = flexmock('lookandfeel', 
                           :lookup     => 'lookup',
                           :attributes => {},
                           :_event_url => '_event_url',
                           :resource   => 'resource',
                           :resource_global => 'resource_global'
                          )
    session  = flexmock('sesion', 
                        :lookandfeel => lookandfeel,
                        :language    => 'language'
                       )
    revision = flexmock('revision', 
                        :month => 'month',
                        :year  => 'year'
                       )
    registration = flexmock('registration', :iksnr => 'iksnr')
    model    = flexmock('model', 
                        :revision       => revision,
                        :localized_name => 'localized_name',
                        :registrations  => [registration]
                       )
    news     = ODDB::View::Drugs::FachinfoNews.new([model], session)
    assert_kind_of(HtmlGrid::Link, news.title([model]))
  end
end

class TestSLPriceNews <Minitest::Test
  include FlexMock::TestCase
  def test_title
    lookandfeel = flexmock('lookandfeel', 
                           :lookup     => 'lookup',
                           :attributes => {},
                           :_event_url => '_event_url',
                           :resource   => 'resource',
                           :resource_global => 'resource_global'
                          )
    session = flexmock('session',
                       :rss_updates => 'rss_updates',
                       :lookandfeel => lookandfeel
                      )
    model = flexmock('model')
    news = ODDB::View::Drugs::SLPriceNews.new([model], session)
    assert_kind_of(HtmlGrid::Link, news.title([model]))
  end
end

class TestGoogleAdSenseComposite <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lookandfeel = flexmock('lookandfeel',
                            :enabled?     => nil,
                            :disabled?    => nil,
                            :lookup       => 'lookup',
                            :attributes   => {},
                            :_event_url   => '_event_url',
                            :zones        => ['zones'],
                            :base_url     => 'base_url',
                            :zone_navigation => ['zone_navigation'],
                            :direct_event => 'direct_event'
                           ).by_default
    @app       = flexmock('app')
    @session   = flexmock('session', 
                          :lookandfeel => @lookandfeel,
                          :app         => @app,
                          :persistent_user_input => 'persistent_user_input',
                          :zone        => 'zone',
                          :flavor      => 'flavor',
                          :search_form => 'search_form',
                          :get_cookie_input => 'get_cookie_input',
                          :event => 'event',
                         ).by_default
    @model     = flexmock('model').by_default
    @composite = ODDB::View::Drugs::GoogleAdSenseComposite.new(@model, @session)
  end
  def test_rss_feeds_left
    flexmock(@session, 
             :language    => 'language',
             :rss_updates => 'rss_updates'
            )
    flexmock(@lookandfeel) do |l|
      l.should_receive(:enabled?).once.with(:recall_rss).and_return(false)
      l.should_receive(:enabled?).once.with(:hpc_rss).and_return(false)
      l.should_receive(:enabled?).once.with(:rss_box).and_return(true)
      l.should_receive(:enabled?).once.with(:fachinfo_rss).and_return(true)
      l.should_receive(:resource)
      l.should_receive(:resource_global)
      l.should_receive(:enabled?).once.with(:sl_introduction_rss).and_return(true)
      l.should_receive(:enabled?).once.with(:price_cut_rss).and_return(true)
      l.should_receive(:enabled?).once.with(:price_rise_rss).and_return(true)
    end
    revision      = flexmock('revision', 
                             :month => 'month',
                             :year  => 'year'
                            )
    registration  = flexmock('registration', :iksnr => 'iksnr')
    fachinfo_news = flexmock('fachinfo_news', 
                             :revision       => revision,
                             :localized_name => 'localized_name',
                             :registrations  => [registration]
                            )
    flexmock(@model,
             :fachinfo_news => [fachinfo_news]
            )
    result = @composite.rss_feeds_left(@model, @session)
    assert_equal(4, result.length)
    assert_kind_of(ODDB::View::Drugs::FachinfoNews, result[0])
    assert_kind_of(ODDB::View::Drugs::SLPriceNews, result[1])
    assert_kind_of(ODDB::View::Drugs::SLPriceNews, result[2])
    assert_kind_of(ODDB::View::Drugs::SLPriceNews, result[3])
  end
  def test_rss_feeds_right
    flexmock(@lookandfeel) do |l|
      l.should_receive(:enabled?).once.with(:rss_box).and_return(true)
      l.should_receive(:enabled?).once.with(:feedback_rss).and_return(true)
      l.should_receive(:resource)
      l.should_receive(:resource_global)
    end
    item     = flexmock('item', :pointer => 'pointer')
    feedback = flexmock('feedback', :item => item)
    flexmock(@model, :feedbacks => [feedback])
    assert_kind_of(ODDB::View::Drugs::RssFeedbacks, @composite.rss_feeds_right(@model, @session))
  end
end
