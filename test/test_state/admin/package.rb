#!/usr/bin/env ruby
# ODDB::State::Admin::TestPackage -- oddb.org -- 04.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'state/admin/package'
require 'flexmock'
require 'state/global'
require 'model/commercial_form'

module ODDB
  module State
    module Admin

class TestPackage < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @session = flexmock('session')
    @model   = flexmock('model')
    @state   = ODDB::State::Admin::Package.new(@session, @model)
  end
  def test_check_model
    flexmock(@model, :pointer => 'pointer')
    flexmock(@session, :user_input => 'pointer')
    flexmock(@state, :allowed? => true)
    assert_equal(nil, @state.check_model)
  end
  def test_check_model__e_state_expired
    flexmock(@model, :pointer => 'pointer')
    flexmock(@session, :user_input => 'xxx')
    flexmock(@state, :allowed? => true)
    assert_kind_of(SBSM::ProcessingError, @state.check_model)
  end
  def test_check_model__e_not_allowed
    flexmock(@model, :pointer => 'pointer')
    flexmock(@session, :user_input => 'pointer')
    flexmock(@state, :allowed? => false)
    assert_kind_of(SBSM::ProcessingError, @state.check_model)
  end
  def test_ajax_create_part
    pointer = flexmock('pointer')
    flexmock(pointer, :+ => pointer)
    flexmock(@model, 
             :pointer      => pointer,
             :parts        => [],
             :registration => 'registration'
            )
    flexmock(@session, :user_input => pointer)
    flexmock(@state, :allowed? => true)

    assert_kind_of(ODDB::State::Admin::AjaxParts, @state.ajax_create_part)
  end
  def test_ajax_delete_part
    input = {:part => 123}
    value = flexmock('value', :pointer => nil)
    flexmock(@model, 
             :pointer => input,
             :parts   => {123 => value}
            )
    flexmock(@session, 
             :user_input   => input,
             :"app.delete" => nil
            )
    flexmock(@state, :allowed? => true)

    assert_kind_of(ODDB::State::Admin::AjaxParts, @state.ajax_delete_part)
  end
  def test_delete
    flexmock(@session, :"app.delete" => nil)
    pointer  = flexmock('pointer', :skeleton => [:company])
    sequence = flexmock('sequence', :pointer => pointer)
    flexmock(@model, 
             :parent  => sequence,
             :pointer => pointer
            )
    assert_kind_of(ODDB::State::Companies::Company, @state.delete)
  end
  def test_update_parts
    part   = flexmock('part', :pointer => 'pointer')
    flexmock(@session, 
             :"app.update" => 'update',
             :user         => 'user'
            )
    composition  = flexmock('composition', :pointer => 'pointer')
    registration = flexmock('registration', :compositions => [composition])
    flexmock(@model, 
             :parts   => [part],
             :pointer => 'pointer',
             :registration => registration
            )
    counts = {'0' => '123'}
    #input  = {:count => counts, :composition => {'0' => '0'}, :commercial_form => {'0' => 'name'}}
    input  = {:count => counts, :composition => {'0' => '0'}}
    assert_equal(counts, @state.update_parts(input))
  end
end

    end # Admin
  end # State
end # ODDB
