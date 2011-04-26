#!/usr/bin/env ruby
# ODDB::View::Drugs::TestAtcChooser -- oddb.org -- 26.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/drugs/atcchooser'


module ODDB
  module View
    module Drugs

class TestAtcChooserList < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :_event_url => '_event_url'
                       )
    user     = flexmock('user', :allowed? => true)
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :user        => user,
                        :persistent_user_input => 'persistent_user_input'
                       )
    @model   = flexmock('model', 
                        :level         => 123,
                        :has_sequence? => nil,
                        :empty?        => nil
                       )
    flexmock(@model) do |m|
      m.should_receive(:children).and_return(@model)
      m.should_receive(:each).and_yield(@model)
    end
    @list    = ODDB::View::Drugs::AtcChooserList.new(@model, @session)
  end
  def test_init
    assert_equal(nil, @list.init)
  end
  def test_result_link__true
    flexmock(@model, 
             :code => 'code',
             :path_to? => true
            )
    assert_equal(true, @list.result_link?(@model))
  end
  def test_result_link__false
    flexmock(@model, 
             :code => 'code',
             :path_to? => false,
             :any? => true
            )
    assert_equal(false, @list.result_link?(@model))
  end
  def test_description
    flexmock(@model, 
             :code     => 'code',
             :path_to? => true,
             :pointer_descr => 'pointer_descr'
            )
    flexmock(@session, :language => 'language')
    assert_kind_of(HtmlGrid::Link, @list.description(@model, @session))
  end
  def test_description__else
    flexmock(@model, 
             :code     => 'code',
             :path_to? => false,
             :any?     => true,
             :pointer_descr => 'pointer_descr'
            )
    flexmock(@session, :language => 'language')
    assert_kind_of(HtmlGrid::Link, @list.description(@model, @session))
  end
  def test_edit
    flexmock(@model, :pointer => 'pointer')
    assert_kind_of(ODDB::View::PointerLink, @list.edit(@model, @session))
  end
=begin
  def test_compose_list
    flexmock(@model, 
             :has_sequence? => true,
             :code          => '',
             :path_to?      => true,
             :any?          => true,
             :pointer_descr => 'pointer_descr',
             :pointer       => 'pointer'
            )
    flexmock(@session, :language => 'language')
    expected = [0, 1]
    assert_equal(expected, @list.compose_list(@model))
  end
=end
end

    end # Drugs
  end # View
end # ODDB
