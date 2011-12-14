#!/usr/bin/env ruby
# encoding: utf-8
# View::Migel::TestProduct -- oddb.org -- 09.09.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/resulttemplate'
require 'view/migel/subgroup'

module ODDB
  module View
    Copyright::ODDB_VERSION = 'version'
    module Migel

class TestProductList < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup      => 'lookup',
                        :_event_url  => '_event_url',
                        :language    => 'language'
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :event       => 'event',
                        :language    => 'language'
                       )
    method   = flexmock('method', :arity => 0)
    product_text = flexmock('product_text', 
                            :to_s => 'product_text',
                            :language => 'language'*10
                           )
    @model   = flexmock('model', 
                        :pointer    => 'pointer',
                        :language   => 'language',
                        :migel_code => 'migel_code',
                        :method     => method,
                        :product_text => product_text,
                        :items      => 'items'
                       )
    @view    = ODDB::View::Migel::ProductList.new([@model], @session)
  end
  def test_description
    assert_kind_of(ODDB::View::PointerLink, @view.description(@model))
  end
  def test_migel_code
    flexmock(@model, :items => '')
    assert_equal('migel_code', @view.migel_code(@model))
  end
end

class TestSubgroupInnerComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', :_event_url => '_event_url')
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :error       => 'error',
                          :language    => 'language'
                         )
    group      = flexmock('group', 
                          :pointer  => 'pointer',
                          :language => 'language',
                          :migel_code => 'migel_code'
                         )
    limitation_text = flexmock('limitation_text', :language => 'language')
    @model     = flexmock('model', 
                          :group    => group,
                          :language => 'language',
                          :limitation_text => limitation_text
                         )
    @composite = ODDB::View::Migel::SubgroupInnerComposite.new(@model, @session)
  end
  def test_description
    assert_kind_of(HtmlGrid::Value, @composite.description(@model))
  end
end

class TestSubgroupComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup      => 'lookup',
                          :_event_url  => '_event_url'
                         )
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :error       => 'error',
                          :language    => 'language',
                          :event       => 'event'
                         )
    group      = flexmock('group', 
                          :pointer     => 'pointer',
                          :language    => 'language',
                          :migel_code  => 'migel_code'
                         )
    limitation_text = flexmock('limitation_text', :language => 'language')
    method     = flexmock('method', :arity => 0)
    product    = flexmock('product', 
                          :pointer    => 'pointer',
                          :language   => 'language',
                          :migel_code => 'migel_code',
                          :method     => method,
                          :items      => 'items'
                         )
    @model     = flexmock('model', 
                          :group       => group,
                          :language    => 'language',
                          :products    => {'key' => product},
                          :limitation_text => limitation_text
                         )
    @composite = ODDB::View::Migel::SubgroupComposite.new(@model, @session)
  end
  def test_products
    assert_kind_of(ODDB::View::Migel::ProductList, @composite.products(@model))
  end
end

class TestSubgroup < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup      => 'lookup',
                          :_event_url  => '_event_url',
                          :enabled?    => nil,
                          :attributes  => {},
                          :resource    => 'resource',
                          :zones       => 'zones',
                          :disabled?   => nil,
                          :direct_event => 'direct_event',
                          :zone_navigation => 'zone_navigation',
                          :navigation  => 'navigation',
                          :base_url    => 'base_url'
                         )
    user       = flexmock('user', :valid? => nil)
    sponsor    = flexmock('sponsor', :valid? => nil)
    state      = flexmock('state', 
                          :direct_event => 'direct_event',
                          :snapback_model => @model
                         )
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :error       => 'error',
                          :language    => 'language',
                          :event       => 'event',
                          :user        => user,
                          :sponsor     => sponsor,
                          :state       => state,
                          :zone        => 'zone'
                         )
    group      = flexmock('group', 
                          :pointer     => 'pointer',
                          :language    => 'language',
                          :migel_code  => 'migel_code'
                         )
    limitation_text = flexmock('limitation_text', :language => 'language')
    method     = flexmock('method', :arity => 0)
    product    = flexmock('product', 
                          :pointer    => 'pointer',
                          :language   => 'language',
                          :migel_code => 'migel_code',
                          :method     => method,
                          :items      => 'items'
                         )
    @model     = flexmock('model', 
                          :group       => group,
                          :language    => 'language',
                          :products    => {'key' => product},
                          :limitation_text => limitation_text
                         )
    @view = ODDB::View::Migel::Subgroup.new(@model, @session)
  end
  def test_backtracking
    assert_kind_of(ODDB::View::PointerSteps, @view.backtracking(@model))
  end
end


    end # Migel
  end # View
end # ODDB
