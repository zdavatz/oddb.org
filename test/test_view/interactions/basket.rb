#!/usr/bin/env ruby
# ODDB::View::Interactions::TestBasket -- oddb.org -- 24.03.2011 -- mhatakeyama@ywesee.com

#$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/interactions/basket'

module ODDB
module View
module Interactions

class TestCyP450List < Test::Unit::TestCase
  include FlexMock::TestCase
  def test_to_html
    @container = flexmock('container', :list_index => 'list_index')
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {}
                         )
    @session   = flexmock('session', 
                          :language    => 'language',
                          :lookandfeel => @lnf
                         )
    link       = flexmock('link', 
                          :href   => 'href',
                          :empty? => nil,
                          :text   => 'text',
                          :info   => 'info'
                         )
    item       = flexmock('item', 
                          :cyp_id     => 'cyp_id',
                          :auc_factor => 'auc_factor',
                          :links      => [link]
                         )
    items      = [item]
    substance  = flexmock('substance', 
                          :en       => 'en',
                          :language => 'language'
                         )
    @model     = [substance, items]
    @list      = CyP450List.new('type', [@model], @session, @container)
    base_substance = flexmock('base_substance', :en => 'en')
    @list.instance_eval('@base_substance = base_substance')
    context    = flexmock('context', 
                          :span => 'span',
                          :li   => 'li',
                          :ul   => 'ul'
                         )
    assert_equal('ul', @list.to_html(context))
  end
end # CyP450List

class TestFiList < Test::Unit::TestCase
  include FlexMock::TestCase
  def test_to_html
    lookandfeel  = flexmock('lookandfeel', 
                            :lookup     => 'lookup',
                            :attributes => {}
                           )
    @session     = flexmock('session', 
                            :language    => 'language',
                            :lookandfeel => lookandfeel
                           )
    language     = flexmock('language', :name => 'name')
    fachinfo     = flexmock('fachinfo', 
                            :language         => language,
                            :fachinfo_active? => nil
                           )
    interaction  = flexmock('interaction', 
                            :fachinfo => fachinfo,
                            :match    => 'match'
                           )
    interactions = [interaction]
    substance    = flexmock('substance',
                          :language => 'language'
#                          :en       => 'en',
                         )
    @model       = [substance, interactions]
    @list        = FiList.new([@model], @session)
    link         = flexmock('link', :href => 'href')
    flexmock(@list, :_fachinfo => link)
    context      = flexmock('context', 
                            :li => 'li',
                            :ul => 'ul'
                           )
    assert_equal('ul', @list.to_html(context))
  end
end # TestFiList

class TestBasketSubstrates < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :event_url  => 'event_url'
                         )
    @session   = flexmock('session',
                          :event       => 'event',
                          :lookandfeel => @lnf,
                          :language    => 'language'
                         )
    @substance = flexmock('substance', 
                          :language            => 'language',
                          :has_effective_form? => nil,
                          :effective_form      => 'effective_form'
                         )
    link       = flexmock('link', 
                          :href   => 'href',
                          :empty? => nil,
                          :text   => 'text',
                          :info   => 'info'
                         )
    item       = flexmock('item', :links => [link])
    cyp450s    = flexmock('cyp450s', 
                          :empty? => nil,
                          :keys   => ['key, '],
                          :sort   => {'key', item}
                         )
    @model     = flexmock('model', 
                          :substance  => @substance,
                          :cyp450s    => cyp450s,
                          :inducers   => ['inducers'],
                          :inhibitors => ['inhibitor'],
                          :observed   => 'observed'
                         )
    @list      = BasketSubstrates.new([@model], @session)
  end
  def test_cyp450s
    assert_kind_of(HtmlGrid::RichText, @list.cyp450s(@model, @session))
  end
  def test_substance
    effective_form = flexmock('effective_form', :language => 'language')
    flexmock(@substance, 
             :has_effective_form? => true,
             :effective_form      => effective_form,
             :is_effective_form?  => nil
            )
    assert_equal('language (language)', @list.substance(@model))
  end
end # TestBasketSubstrates

end # Interactions
end # View
end # ODDB
