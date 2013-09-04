#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Admin::TestAssignPatinfo -- oddb.org -- 30.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
#require 'htmlgrid/labeltext'
require 'state/admin/assign_patinfo'

module ODDB
  module State
    module Admine

class TestAssignPatinfo < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    match    = flexmock('match', :to_a => [':!registration,12345!sequence,1.'])
    pointer  = flexmock('pointer', :resolve => true, :match => match)
    @sequence = flexmock('sequence', :pointer => pointer)
    @registration = flexmock('registration', :sequence => @sequence)
    @app     = flexmock('app', :update => 'update', :registration => @registration)
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', 
                        :app => @app,
                        :lookandfeel => @lnf,
                        :user_input  => { "a" => ':!registration,12345!sequence,1.', "b"=> ':!registration,12345!sequence,1.'},
                       )
    @sequence = flexmock('sequence', :pdf_patinfo => 'pdf_patinfo')
    @model   = flexmock('model', :sequence => @sequence)
    @state   = ODDB::State::Admin::AssignPatinfo.new(@session, @model)
    flexmock(@state, :unique_email => 'unique_email')

  end
  def test_assign
    flexmock(@state, :allowed? => true)
    assert_equal(@state, @state.assign)
  end
  def test_assign__model_sequence_patinfo
    flexmock(@state, :allowed? => true)
    patinfo = flexmock('patinfo', :pointer => 'pointer')
    flexmock(@sequence, 
             :pdf_patinfo => nil,
             :patinfo     => patinfo
            )
    assert_equal(@state, @state.assign)
  end
  def test_assign__error
    flexmock(@state, :allowed? => nil)
    assert_equal(@state, @state.assign)
  end
end

    end # Admin
  end # State
end # ODDB
