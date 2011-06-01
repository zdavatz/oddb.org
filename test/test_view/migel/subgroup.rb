#!/usr/bin/env ruby
# View::Migel::TestProduct -- oddb.org -- 19.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/resulttemplate'
require 'view/migel/subgroup'

module ODDB
  module View
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
                        :product_text => product_text
                       )
    @view    = ODDB::View::Migel::ProductList.new([@model], @session)
  end
  def test_description
    assert_kind_of(ODDB::View::PointerLink, @view.description(@model))
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
                          :language => 'language'
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
                          :language    => 'language'
                         )
    limitation_text = flexmock('limitation_text', :language => 'language')
    method     = flexmock('method', :arity => 0)
    product    = flexmock('product', 
                          :pointer    => 'pointer',
                          :language   => 'language',
                          :migel_code => 'migel_code',
                          :method     => method
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


    end # Migel
  end # View
end # ODDB
