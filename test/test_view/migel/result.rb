#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Migel::TestResult -- oddb.org -- 26.09.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/resulttemplate'
require 'view/migel/result'


module ODDB
  module View
    module Migel

class TestList <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :_event_url => '_event_url',
                        :migel_list_components => {[0,0] => 'component'},
                        :language => 'language',
                       )
    @session = flexmock('session', :lookandfeel => @lnf,
                        :language => 'language').by_default
    @model   = flexmock('model',
                        :force_encoding => 'force_encoding',
                        :product_text => 'product_text').by_default
    @model.should_receive(:is_a?).with(String).and_return(true)
    @model.should_receive(:is_a?).and_return(false)
    @list    = ODDB::View::Migel::List.new([@model], @session)
  end
  def test_init
    assert_nil(@list.init)
  end
  def test_limitation_text
    limitation_text = flexmock('limitation_text', :pointer => 'pointer')
    flexmock(@model, 
             :limitation_text => limitation_text,
             :migel_code => 'migel_code'
            )
    assert_kind_of(HtmlGrid::Link, @list.limitation_text(@model))
  end
  def test_limitation_text__no_limitation_text
    flexmock(@model, :limitation_text => nil)
    assert_equal('', @list.limitation_text(@model))
  end
  def test_product_description
    flexmock(@session, :language => 'language')
    flexmock(@model, 
             :pointer  => 'pointer',
             :language => 'language'*100,
             :migel_code => 'migel_code'
            )
    assert_kind_of(ODDB::View::PointerLink, @list.product_description(@model))
  end
  def test_product_description__migel_group
    flexmock(@session, :language => 'language')
    flexmock(@model, 
             :pointer  => 'pointer',
             :language => 'language'*100,
             :migel_code => '12'
            )
    assert_kind_of(ODDB::View::PointerLink, @list.product_description(@model))
  end
  def test_product_description__migel_subgroup
    flexmock(@session, :language => 'language')
    flexmock(@model, 
             :pointer  => 'pointer',
             :language => 'language'*100,
             :migel_code => '12.34'
            )
    assert_kind_of(ODDB::View::PointerLink, @list.product_description(@model))
  end
  def test_migel_code
    flexmock(@model, :migel_code => 'migel_code')
    assert_equal('migel_code', @list.migel_code(@model))
  end
  def test_migel_code__items
    item = flexmock('item',
                    :ean_code => 'ean_code',
                    :status   => 'status'
                   )
    flexmock(@model, 
             :migel_code => 'migel_code',
             :items    => [item],
             :pointer  => 'pointer'
            )
    assert_kind_of(ODDB::View::PointerLink, @list.migel_code(@model))
  end

end

class TestResultList <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :_event_url => '_event_url',
                        :migel_list_components => {[1, 0] => 'component'}
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :language    => 'language'
                       )
    limitation_text = flexmock('limitation_text', :pointer => 'pointer')
    group    = flexmock('group', 
                        :limitation_text => limitation_text,
                        :migel_code      => 'migel_code',
                        :pointer         => 'pointer',
                        :language        => 'language',
                        :force_encoding => 'force_encoding',
                       )
    group.should_receive(:is_a?).with(String).and_return(true)
    group.should_receive(:is_a?).and_return(false)
    @model   = flexmock('model', 
                        :group           => group,
                        :migel_code      => 'migel_code',
                        :pointer         => 'pointer',
                        :language        => 'language',
                        :products        => ['product'],
                        :limitation_text => limitation_text,
                        :force_encoding => 'force_encoding',
                       ).by_default
    @model.should_receive(:is_a?).with(String).and_return(true)
    @model.should_receive(:is_a?).and_return(false)
    @list    = ODDB::View::Migel::ResultList.new([@model], @session)
  end
  def test_compose_list
    assert_equal([@model], @list.compose_list)
  end
end

class TestEmptyResultForm <Minitest::Test
  include FlexMock::TestCase
  def test_title_none_found
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :_event_url => '_event_url',
                        :disabled?  => nil,
                        :base_url   => 'base_url'
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :zone        => 'zone',
                        :persistent_user_input => 'persistent_user_input',
                        :event       => 'event',
                       )
    @model   = flexmock('model')
    @form    = ODDB::View::Migel::EmptyResultForm.new(@model, @session)
    assert_equal('lookup', @form.title_none_found(@model, @session))
  end
end

    end # Migel
  end # View
end # ODDB
