#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Analysis::TestGlobal -- oddb.org -- 28.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'state/global'
gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/welcomehead'
require 'state/analysis/global'

module ODDB
  module State
    module Analysis

class TestGlobal <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model', :language => 'language')
    @state   = ODDB::State::Analysis::Global.new(@model, @session)
  end
  def test_limit_state
    assert_kind_of(ODDB::State::Analysis::Limit, @state.limit_state)
  end
  def test_compare_entries
    @state.instance_eval('@sortby = [:description, :list_title, :sortby]')
    list_title = flexmock('list_title', :language => 'language')
    a = flexmock('a', 
                 :language   => 'language',
                 :list_title => list_title,
                 :sortby     => 'sortby'
                )
    b = flexmock('b', 
                 :language   => 'language',
                 :list_title => list_title,
                 :sortby     => 'sortby'
                )
    flexmock(@state, :umlaut_filter => 'umlaut_filter')
    assert_equal(0, @state.compare_entries(a,b))
  end
  def test_compare_entries__a_b_nil
    @state.instance_eval('@sortby = [:description, :list_title, :sortby]')
    list_title = flexmock('list_title', :language => 'language')
    a = flexmock('a', 
                 :language   => 'language',
                 :list_title => list_title,
                 :sortby     => 'sortby'
                )
    b = flexmock('b', 
                 :language   => 'language',
                 :list_title => list_title,
                 :sortby     => 'sortby'
                )
    flexmock(@state, :umlaut_filter => nil)
    assert_equal(0, @state.compare_entries(a,b))
  end
  def test_compare_entries__a_nil
    @state.instance_eval('@sortby = [:description]')
    list_title = flexmock('list_title', :language => 'language')
    a = flexmock('a', :language => 'a')
    b = flexmock('b', :language => 'b')
    flexmock(@state) do |s|
      s.should_receive(:umlaut_filter).with('a').and_return(nil)
      s.should_receive(:umlaut_filter).with('b').and_return('b')
    end
    assert_equal(1, @state.compare_entries(a,b))
  end
  def test_compare_entries__b_nil
    @state.instance_eval('@sortby = [:description]')
    list_title = flexmock('list_title', :language => 'language')
    a = flexmock('a', :language => 'a')
    b = flexmock('b', :language => 'b')
    flexmock(@state) do |s|
      s.should_receive(:umlaut_filter).with('a').and_return('a')
      s.should_receive(:umlaut_filter).with('b').and_return(nil)
    end
    assert_equal(-1, @state.compare_entries(a,b))
  end
  def stdout_null
    require 'tempfile'
    $stdout = Tempfile.open('stdout')
    yield
    $stdout.close
    $stdout = STDERR
  end
  def test_compare_entries__error
    @state.instance_eval('@sortby = [:description]')
    list_title = flexmock('list_title', :language => 'language')
    a = flexmock('a', :language => 'a')
    b = flexmock('b', :language => 'b')
    flexmock(@state).should_receive(:umlaut_filter).and_raise(::Exception)
    stdout_null do 
      assert_equal(0, @state.compare_entries(a,b))
    end
  end

end

    end # Admin
  end # State
end # ODDB
