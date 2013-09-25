#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Admin::TestPatinfoDeprivedSequences -- oddb.org -- 28.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'state/global'
gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'state/admin/patinfo_deprived_sequences'

module ODDB
	module State
		module Admin

class TestPatinfoDeprivedSequences <Minitest::Test
  include FlexMock::TestCase
  def setup
    @app     = flexmock('app')
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', 
                        :app => @app,
                        :lookandfeel => @lnf
                       )
    @model   = flexmock('model', :size => 1)
    @state   = ODDB::State::Admin::PatinfoDeprivedSequences.new(@session, @model)
  end
  def test_init
    assert_nil(@state.init)
  end
  def test_select_seq
    pointer = flexmock('pointer', :resolve => 'sequence')
    flexmock(@session, :user_input => {:pointer => pointer, :state_id => 123})
    assert_kind_of(ODDB::State::Admin::AssignDeprivedSequence, @state.select_seq)
  end
  def test_select_seq__error
    pointer = flexmock('pointer', :resolve => 'sequence')
    flexmock(@session, :user_input => {:pointer => pointer})
    flexmock(@state, :error? => true)
    assert_equal(@state, @state.select_seq)
  end
  def test_shadow_pattern
    flexmock(@app, :update => 'update')
    sequence = flexmock('sequence', 
                        :name_base => 'name_base',
                        :pointer   => 'pointer'
                       )
    flexmock(@session) do |s|
      s.should_receive(:user_input).and_return('name_base')
      s.should_receive(:each_sequence).and_yield(sequence)
    end
    flexmock(@state, 
             :patinfo_deprived_sequences => 'patinfo_deprived_sequences',
             :unique_email => 'unique_email'
            )
    assert_equal('patinfo_deprived_sequences', @state.shadow_pattern)
  end
  def test_shadow_pattern__no_user_input
    flexmock(@session, :user_input => nil)
    assert_equal(@state, @state.shadow_pattern)
  end
  def test_shadow_pattern__error
    sequence = flexmock('sequence', :name_base => 'name_base')
    flexmock(@session) do |s|
      s.should_receive(:user_input).and_return('user_input')
      s.should_receive(:each_sequence).and_yield(sequence)
    end
    flexmock(Regexp).new_instances do |reg|
      reg.should_receive(:match).and_raise(RegexpError)
    end
    assert_equal(@state, @state.shadow_pattern)
  end
  def test_symbol
    assert_equal(:name, @state.symbol)
  end
end


		end # Admin
	end # State
end # ODDB
