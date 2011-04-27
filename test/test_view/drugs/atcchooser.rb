#!/usr/bin/env ruby
# ODDB::View::Drugs::TestAtcChooser -- oddb.org -- 27.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/drugs/atcchooser'


module ODDB
  module View
    module Drugs

      class StubAtcDddLink
        include AtcDddLink
        def initialize(model, session)
          @model       = model
          @session     = session
          @lookandfeel = session.lookandfeel
        end
      end

class TestAtcDddLink < Test::Unit::TestCase
  include FlexMock::TestCase
  def test_atc_ddd_link
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :_event_url => '_event_url'
                       )
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model')
    @link    = ODDB::View::Drugs::StubAtcDddLink.new(@model, @session)
    atc      = flexmock('atc', 
                        :has_ddd? => true,
                        :pointer  => 'pointer'
                       )
    assert_kind_of(HtmlGrid::Link, @link.atc_ddd_link(atc, @session))
  end
end


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
  def test_compose_list
    flexmock(@lnf, :language => 'langauge')
    method = flexmock('method', :arity => 1)
    child  = flexmock('child', :has_sequence? => nil)
    model  = flexmock('model', 
                      :has_sequence? => true,
                      :code          => 'co',
                      :pointer_descr => 'pointer_descr',
                      :level         => 1,
                      :method        => method,
                      :pointer       => 'pointer',
                      :path_to?      => true,
                      :children      => [child]
                     ) 
    flexmock(@session, :language => 'language')
    expected = [0, 2]
    assert_equal(expected, @list.compose_list([model]))
  end
end

    end # Drugs
  end # View
end # ODDB
