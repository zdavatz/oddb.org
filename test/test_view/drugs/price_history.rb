#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Drugs::TestPriceHistory -- oddb.org -- 20.04.2011 -- mhatakeyama@ywesee.com

#$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'model/galenicgroup'
require 'view/logo'
require 'model/analysis/group'
require 'view/drugs/price_history'
require 'htmlgrid/select'

module ODDB
  class Session
    DEFAULT_FLAVOR = 'gcc'
  end
  module View
    class Copyright < HtmlGrid::Composite
       ODDB_VERSION = 'oddb_version'
    end
    module Drugs

class TestPriceHistoryList < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :event_url  => 'event_url',
                        :disabled?  => nil,
                        :enabled?   => nil, 
                        :format_price => 'format_price'
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :event       => 'event',
                        :get_currency_rate => 1.0,
                        :currency    => 'CHF'
                       )
    ppublic  = flexmock('public', 
                        :authority => 'authority',
                        :to_i      => 1,
                        :origin    => 'url date',
                        :mutation_code => 'mutation_code'
                       ) 
    exfactory = flexmock('exfactory', 
                         :authority => 'authority',
                         :to_i      => 1,
                         :origin    => 'origin',
                         :mutation_code => 'mutation_code'
                        )
    @model   = flexmock('model', 
                        :exfactory  => exfactory,
                        :public     => ppublic,
                        :percent_exfactory => 0.5,
                        :percent_public    => 0.5,
                        :valid_from => 'valid_from'
                       )
    @config  = flexmock('config', :bsv_archives => 'bsv_archives')
    flexmock(ODDB, :config => @config)
    @list    = ODDB::View::Drugs::PriceHistoryList.new([@model], @session)
  end
  def test_authorities
    assert_kind_of(HtmlGrid::Span, @list.authorities(@model)[0])
  end
  def test_origins
    flexmock(@config, :bsv_archives => 'origin')
    result = @list.origins(@model)
    assert_equal(4, result.length)
    assert_kind_of(HtmlGrid::Link, result[0])
    assert_equal(' ', result[1])
    assert_equal('date', result[2])
    assert_kind_of(HtmlGrid::Link, result[3])
  end
end

class TestPriceHistoryComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :event_url  => 'event_url'
                         )
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :event       => 'event'
                         )
    package    = flexmock('package', 
                          :name  => 'name',
                          :size  => 'size',
                          :iksnr => 'iksnr',
                          :ikscd => 'ikscd'
                         )
    @model     = flexmock([], :package => package)
    @composite = ODDB::View::Drugs::PriceHistoryComposite.new(@model, @session)
  end
  def test_article_24
    assert_kind_of(HtmlGrid::Link, @composite.article_24(@model))
  end
end

class TestPriceHistory < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf      = flexmock('lookandfeel', 
                         :lookup     => 'lookup',
                         :enabled?   => nil,
                         :attributes => {},
                         :resource   => 'resource',
                         :zones      => ['zones'],
                         :disabled?  => nil,
                         :_event_url => '_event_url',
                         :event_url  => 'event_url',
                         :navigation => ['navigation'],
                         :base_url   => 'base_url',
                         :zone_navigation => ['zone_navigation'],
                         :direct_event    => 'direct_event'
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
                         :flavor      => 'gcc',
                         :get_cookie_input     => 'get_cookie_input',
                         :state       => state,
                         :allowed?    => nil,
                         :event       => 'event',
                         :zone        => 'zone',
                         :persistent_user_input => 'persistent_user_input'
                        )
    @package  = flexmock('package', 
                         :name  => 'name',
                         :size  => 'size',
                         :iksnr => 'iksnr',
                         :ikscd => 'ikscd'
                        )

  end
  def test_init
    model    = flexmock([], 
                         :package => @package,
                         :pointer_descr= => nil
                        )
    template = ODDB::View::Drugs::PriceHistory.new(model, @session)
    assert_equal({}, template.init)
  end
  def test_init__no_package
    model    = flexmock([], 
                         :package => nil,
                         :pointer_descr= => nil
                        )
    template = ODDB::View::Drugs::PriceHistory.new(model, @session)
    assert_equal({}, template.init)
  end

end

    end # Drugs
  end # View
end # ODDB

