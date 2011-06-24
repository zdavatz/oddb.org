#!/usr/bin/env ruby
# ODDB::View::Rss::TestPackage -- oddb.org -- 24.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/htmlgrid/composite'
require 'view/rss/package'
require 'htmlgrid/span'
require 'model/index_therapeuticus'
require 'sbsm/validator'

module ODDB
  module View
    module Rss

class TestPackage < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @app       = flexmock('app')
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :_event_url => '_event_url',
                          :resource   => 'resource',
                          :enabled?   => nil,
                          :language   => 'language',
                          :disabled?  => nil,
                          :attributes => {},
                          :format_price => 'format_price'
                         )
    @session   = flexmock('session', 
                          :app => @app,
                          :lookandfeel => @lnf,
                          :language    => 'language',
                          :error       => 'error',
                          :get_currency_rate => 1.0,
                          :currency    => 'currency',
                          :persistent_user_input => 'persistent_user_input'
                         )
    price_public = flexmock('price_public', 
                            :valid_from => Time.local(2011,2,3),
                            :to_f => 1.0,
                            :to_i => 1,
                            :to_s => 'price_public'
                           )
    flexmock(price_public, 
             :- => price_public,
             :/ => price_public,
             :* => price_public
            )
    atc_class  = flexmock('atc_class', 
                          :code => 'code',
                          :has_ddd?    => true,
                          :description => 'description',
                          :parent_code => 'parent_code',
                          :pointer     => 'pointer'
                         )
    flexmock(@app, :atc_class => atc_class)
    limitation_text = flexmock('limitation_text', :language => 'language')
    @model     = flexmock('model', 
                          :price_public => price_public,
                          :name => 'name',
                          :size => 'size',
                          :pointer   => 'pointer',
                          :narcotic? => nil,
                          :ddd_price => 'ddd_price',
                          :sl_entry  => 'sl_entry',
                          :atc_class => atc_class,
                          :name_base => 'name_base',
                          :ikskey    => 'ikskey',
                          :limitation_text     => limitation_text,
                          :production_science  => 'production_science',
                          :parallel_import     => 'parallel_import',
                          :ith_swissmedic      => 'ith_swissmedic',
                          :index_therapeuticus => 'index_therapeuticus',
                          :price_exfactory     => 'price_exfactory',
                          :deductible          => 'deductible'
                         )
    @component = ODDB::View::Rss::Package.new([@model], @session)
  end
  def test_to_html
    retrieve_from_index = flexmock('retrieve_from_index', :language => 'language')
    cache = flexmock('cache', :retrieve_from_index => [retrieve_from_index])
    flexmock(ODBA, :cache => cache)
    context = flexmock('context', :html => 'html')
    expected = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<rss version=\"2.0\"\n  xmlns:trackback=\"http://madskills.com/public/xml/rss/module/trackback/\">\n  <channel>\n    <title>lookup</title>\n    <link>_event_url</link>\n    <description>lookup</description>\n    <language>language</language>\n    <image>\n      <url>resource</url>\n      <title>lookup</title>\n      <link>_event_url</link>\n    </image>\n    <item>\n      <title>lookup: name, size, price_public, +1.0%</title>\n      <link>_event_url</link>\n      <description>html</description>\n      <author>ODDB.org</author>\n      <pubDate>Thu, 03 Feb 2011 00:00:00 +0100</pubDate>\n      <guid isPermaLink=\"true\">_event_url</guid>\n    </item>\n  </channel>\n</rss>"
    assert_equal(expected, @component.to_html(context))
  end
end

    end # Interactions
  end # View
end # ODDB
