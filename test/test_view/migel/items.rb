#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Migel::TestItems -- oddb.org -- 10.11.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/lookandfeel_components'
require 'view/migel/items'

module ODDB
  module View
    module Migel
      class SearchedList
        def u(str)
          'status'
        end
      end

class TestSubHeader <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :disabled?  => nil,
                        :enabled?   => nil,
                        :attributes => {},
                        :_event_url => '_event_url'
                       )
    page     = flexmock('page', :to_i => 1)
    state    = flexmock('state', 
                        :pages => [page],
                        :page  => page
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :language    => 'language',
                        :user_input  => 'user_input',
                        :state => state,
                        :event => 'event',
                        :cookie_set_or_get => 'cookie_set_or_get'
                       ).by_default
    multilingual = flexmock('multilingual', :language => 'language')
    @model   = flexmock('model', 
                        :price => 'price',
                        :qty   => 'qty',
                        :unit  => multilingual,
                        :migel_code => 'migel_code'
                       )
    @composite = ODDB::View::Migel::SubHeader.new(@model, @session)
  end
  def test_migel_code
    assert_kind_of(HtmlGrid::Link, @composite.migel_code(@model, @session))
  end
  def test_max_insure_value
    assert_equal('Montants Maximaux: ', @composite.max_insure_value(@model, @session))
  end
  def test_max_insure_value_de
    flexmock(@session, :language => 'de')
    assert_equal('Höchstvergütungsbetrag: ', @composite.max_insure_value(@model, @session))
  end
  def test_pages
    flexmock(@session, :cookie_set_or_get => 'pages')
    assert_kind_of(ODDB::View::Pager, @composite.pages(@model, @session))
  end
  def test_pages_not_migel_code
    flexmock(@session, 
             :cookie_set_or_get => 'pages',
             :user_input => nil,
             :persistent_user_input => 'persistent_user_input'
            )
    assert_kind_of(ODDB::View::Pager, @composite.pages(@model, @session))
  end
end

class TestSearchedList <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup => 'lookup',
                        :attributes => {},
                        :event_url => 'event_url',
                        :disabled? => nil,
                        :enabled? => nil,
                        :_event_url => '_event_url',
                        :resource  => 'resource',
                        :migel_item_list_components => {}
                       )
    page     = flexmock('page', :to_i => 1)
    state    = flexmock('state', 
                        :pages => [page],
                        :page  => page
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :language    => 'language',
                        :user_input  => nil,
                        :event => 'event',
                        :state => state,
                        :persistent_user_input => 'persistent_user_input',
                        :cookie_set_or_get => 'cookie_set_or_get'
                       )
    @multilingual = flexmock('multilingual', :language => 'language')
    commercial_form = flexmock('commercial_form', :language => 'language')
    part     = flexmock('part', 
                        :multi => 'multi',
                        :count => 'count',
                        :measure => 'measure',
                        :commercial_form => commercial_form
                       )
    indication = flexmock('indication', :language => 'language')
    @model   = flexmock('model', 
                        :migel_code => 'migel_code',
                        :price => 'price',
                        :qty => 'qty',
                        :unit => @multilingual,
                        :article_name => @multilingual,
                        :size => 'size',
                        :companyname => @multilingual,
                        :localized_name => 'localized_name',
                        :name_base => 'name_base',
                        :pointer => 'pointer',
                        :commercial_forms => ['commercial_form'],
                        :parts => [part],
                        :indication => indication
                       )
    @list = ODDB::View::Migel::SearchedList.new([@model], @session)
  end
  def test_article_name
    multilingual = flexmock('multilingual', 
                            :language => 'language',
                            :respond_to? => true,
                            :send => 'article_name'
                           )
    model   = flexmock('model', 
                        :migel_code => 'migel_code',
                        :price => 'price',
                        :qty => 'qty',
                        :unit => multilingual,
                        :article_name => multilingual,
                        :size => 'size',
                        :companyname => multilingual
                       )
 
    assert_equal('article_name', @list.article_name(model, @session))
  end
  def test_companyname
    multilingual = flexmock('multilingual', 
                            :language => 'language',
                            :respond_to? => true,
                            :send => 'companyname'
                           )
    model   = flexmock('model', 
                        :migel_code => 'migel_code',
                        :price => 'price',
                        :qty => 'qty',
                        :unit => multilingual,
                        :article_name => multilingual,
                        :size => 'size',
                        :companyname => multilingual
                       )
 
    assert_equal('companyname', @list.companyname(model, @session))
  end
  def test_size
    multilingual = flexmock('multilingual', 
                            :language => 'language',
                            :respond_to? => true,
                            :send => 'size'
                           )
    model   = flexmock('model', 
                        :migel_code => 'migel_code',
                        :price => 'price',
                        :qty => 'qty',
                        :unit => multilingual,
                        :article_name => multilingual,
                        :size => multilingual,
                        :companyname => multilingual
                       )
    flexmock(@session, :user_input => nil)
 
    assert_equal('size', @list.size(model, @session))
  end
  def test_sort_link
    assert_kind_of(HtmlGrid::Link, @list.sort_link('header_key', 'matrix', 'component'))
  end
  def test_sort_link__reverse
    flexmock(@session) do |session|
      session.should_receive(:user_input).with(:sortvalue).and_return('ean_code')
      session.should_receive(:user_input).with(:reverse).and_return('ean_code')
      session.should_receive(:user_input).with(:page).and_return(123)
      session.should_receive(:user_input).with(:search_query)
      session.should_receive(:zone).and_return('migel')
    end
    assert_kind_of(HtmlGrid::Link, @list.sort_link('header_key', 'matrix', 'ean_code'))
  end
  def test_sort_link__query
    flexmock(@session) do |session|
      session.should_receive(:user_input).with(:sortvalue).and_return('ean_code')
      session.should_receive(:user_input).with(:reverse).and_return('ean_code')
      session.should_receive(:user_input).with(:page).and_return(123)
      session.should_receive(:user_input).with(:search_query).and_return('search_query')
      session.should_receive(:zone).and_return('migel')
    end
    assert_kind_of(HtmlGrid::Link, @list.sort_link('header_key', 'matrix', 'ean_code'))
  end
end
    end # Migel
  end # View
end # ODDB
