#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Admin::TestAssignFachinfo -- oddb.org -- 06.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'state/global'
gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'htmlgrid/labeltext'
require 'state/admin/assign_fachinfo'

module ODDB
	module State
		module Admin

class TestRegistrationFacade <Minitest::Test
  include FlexMock::TestCase
  def setup
    @registration   = flexmock('registration')
    @facade         = ODDB::State::Admin::AssignFachinfo::RegistrationFacade.new(@registration)
  end
  def test_structural_ancestors
    assert_equal([@registration], @facade.structural_ancestors('app'))
  end
  def test_each
    @facade.each do |reg|
      assert_equal(@registration, reg)
    end
  end
  def test_empty
    assert(@facade.empty?)
  end
  def test_name_base
    flexmock(@registration, :name_base => 'name_base')
    assert_equal('name_base', @facade.name_base)
  end
  def test_pointer
    flexmock(@registration, :pointer => 'pointer')
    assert_equal('pointer', @facade.pointer)
  end
  def test_registrations
    @facade.registrations = [@registration, 'registration']
    assert_equal(['registration'], @facade.registrations)
  end
end

class TestAssignFachinfo <Minitest::Test
  include FlexMock::TestCase
  def setup
    @registration = flexmock('registration')
    sequence  = flexmock('sequence', :registration => @registration)
    @app      = flexmock('app', :search_sequences => [sequence])
    @lnf      = flexmock('lookandfeel', :lookup => 'lookup')
    @session  = flexmock('session', 
                         :lookandfeel => @lnf,
                         :app         => @app
                        )
    @model    = flexmock('model', :name_base => 'name_base')
    @fachinfo = ODDB::State::Admin::AssignFachinfo.new(@session, @model)
  end
  def test_init
    flexmock(@fachinfo, :allowed? => nil)
    assert_equal([], @fachinfo.init)
  end
  def test_assign
    flexmock(@fachinfo, 
             :allowed? => true,
             :pointer  => 'pointer',
             :unique_email => 'unique_email'
            )
    flexmock(@app, :update => 'update')
    flexmock(@model, :registration => @registration)
    flexmock(@registration, :fachinfo => @fachinfo)
    pointer = flexmock('pointer', :resolve => 'resolve')
    user_input = {:pointers => {'key' => pointer}, :pointer => pointer}
    flexmock(@session, :user_input => user_input)
    assert_equal(@fachinfo, @fachinfo.assign)
  end
  def test_assign__error
    flexmock(@fachinfo, :allowed? => nil)
    pointer = flexmock('pointer', :resolve => 'resolve')
    user_input = {:pointers => {'key' => pointer}}
    flexmock(@session, :user_input => user_input)
    assert_equal(@fachinfo, @fachinfo.assign)
  end
  def test_named_registrations
    flexmock(@fachinfo, :allowed? => nil)
    assert_equal([], @fachinfo.named_registrations('na'))
  end
  def test_named_registrations__else
    flexmock(@fachinfo, :allowed? => true)
    sequences = Array.new(51).map{flexmock('sequence', :registration => flexmock('registration'))}
    flexmock(@app, :search_sequences => sequences)
    assert_kind_of(Array, @fachinfo.named_registrations('name'))
  end
  def test_search_registrations
    flexmock(@model, :registrations= => nil)
    flexmock(@fachinfo, :allowed? => nil)
    flexmock(@session, :user_input => 'name')
    assert_equal(@fachinfo, @fachinfo.search_registrations)
  end
  def test_search_registrations__else
    flexmock(@model, :registrations= => nil)
    flexmock(@fachinfo, :allowed? => nil)
    flexmock(@session, :user_input => ['name'])
    assert_equal(@fachinfo, @fachinfo.search_registrations)
  end

end

		end # Admin
	end # State
end # ODDB
