#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Admin::TestAssignFachinfo -- oddb.org -- 06.0.6.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'htmlgrid/labeltext'
require 'view/admin/assign_fachinfo'

module ODDB
  module View
    module Admin

class TestAssignFachinfoForm <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :event_url  => 'event_url',
                        :base_url   => 'base_url'
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :allowed?    => nil
                       )
    @registration = flexmock('registration', 
                            :fachinfo_active? => nil,
                            :has_fachinfo?    => nil
                           )
    @model   = flexmock('model', 
                        :empty? => nil,
                        :registration => @registration,
                        :fachinfo_active? => nil,
                        :has_fachinfo?    => nil
                       )
    flexmock(@model) do |model|
      model.should_receive(:each_with_index).and_yield(@model, 0)
    end
    @form    = ODDB::View::Admin::AssignFachinfoForm.new(@model, @session)
  end
  def test_compose_list
    offset = [0, 0]
    assert_equal([0, 3], @form.compose_list(@model, offset))
  end
  def test_fachinfo_pointer__nothing
    flexmock(@model, :registration => @model)
    assert_nil(@form.fachinfo_pointer(@model, @session))
  end
  def test_fachinfo_pointer__fachinfo
    flexmock(@session, :allowed? => true)
    flexmock(@model, :fachinfo => 'fachinfo')
    flexmock(@registration, :fachinfo => 'fachinfo')
    assert_equal('lookup', @form.fachinfo_pointer(@model, @session))
  end
  def test_fachinfo_pointer__else
    flexmock(@session, :allowed? => true)
    flexmock(@model, 
             :fachinfo => 'fachinfo',
             :pointer  => 'pointer'
            )
    flexmock(@registration, :fachinfo => nil)
    assert_kind_of(HtmlGrid::InputCheckbox, @form.fachinfo_pointer(@model, @session))
  end
end

    end # Admin
  end # View
end # ODDB
