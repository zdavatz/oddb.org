#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Interactions::TestBasket -- oddb.org -- 09.04.2012 -- yasaka@ywesee.com
# ODDB::View::Interactions::TestBasket -- oddb.org -- 25.03.2011 -- mhatakeyama@ywesee.com

#$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/interactions/basket'

module ODDB
module View
module Interactions

class TestCyP450List <Minitest::Test
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

class TestFiList <Minitest::Test
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

class TestBasketSubstrates <Minitest::Test
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
                         ).by_default
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
                          :sort   => {'key' => item}
                         )
    @model     = flexmock('model', 
                          :substance  => @substance,
                          :cyp450s    => cyp450s,
                          :inducers   => ['inducers'],
                          :inhibitors => ['inhibitor'],
                          :observed   => 'observed',
                          :atc_codes  => 'atc_codes',
                         )
    @list      = BasketSubstrates.new([@model], @session)
  end
  def test_cyp450s
    assert_kind_of(HtmlGrid::RichText, @list.cyp450s(@model, @session))
  end
  def test_substance
    effective_form = flexmock('effective_form', :language => 'lang_de')
    flexmock(@substance, 
             :has_effective_form? => true,
             :effective_form      => effective_form,
             :is_effective_form?  => nil
            )
    assert_equal('lang_de (language)', @list.substance(@model))
  end
end # TestBasketSubstrates

class TestBasketForm <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf      = flexmock('lookandfeel', 
                         :lookup     => 'lookup',
                         :attributes => {},
                         :_event_url => '_event_url',
                         :event_url  => 'event_url',
                         :disabled?  => nil,
                         :base_url   => 'base_url'
                        )
    @session  = flexmock('session', 
                         :lookandfeel => @lnf,
                         :zone        => 'zone',
                         :event       => 'event',
                         :language    => 'language',
                         :interaction_basket_count => 'interaction_basket_count'
                        )
    substance = flexmock('substance', 
                         :language => 'language',
                         :effective_form      => 'effective_form',
                         :has_effective_form? => nil
                        )
    link      = flexmock('link', 
                         :href   => 'href',
                         :empty? => nil,
                         :text   => 'text',
                         :info   => 'info'
                        )
    item      = flexmock('item', :links => [link])
    cyp450s   = flexmock('cyp450s', 
                         :empty? => nil,
                         :keys   => ['key, '],
                         :sort   => {'key' => item}
                        )
    inducer   = flexmock('inducer')
    inhibitor = flexmock('inhibitor')
    @model    = flexmock('model', 
                         :substance  => substance,
                         :cyp450s    => cyp450s,
                         :inducers   => [inducer],
                         :inhibitors => [inhibitor],
                         :observed   => 'observed',
                         :atc_codes  => 'atc_codes',
                        )
    @form     = BasketForm.new([@model], @session)
  end
  def test_interaction_basket_count
    assert_equal('lookup', @form.interaction_basket_count(@model, @session))
  end
end

end # Interactions
end # View
end # ODDB
