#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Doctors::TestDoctorList -- oddb.org -- 09.11.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/resulttemplate'
require 'view/doctors/doctorlist'
require 'model/company'

module ODDB
  module View
    module Doctors

class TestDoctorList <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :event_url  => 'event_url',
                        :_event_url => '_event_url',
                        :language   => 'language'
                       )
    state    = flexmock('state', 
                        :paged?    => true,
                        :interval  => 'interval',
                        :intervals => ['interval']
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :state       => state,
                        :event       => 'event'
                       )
    praxis_address = flexmock('praxis_address', 
                              :fon    => ['fon'],
                              :plz    => 'plz',
                              :city   => 'city',
                              :street => 'street',
                              :number => 'number',
                              :lines   => ['line']
                             )
    method   = flexmock('method', :arity => 1)
    @model   = flexmock('model', 
                        :name           => 'name',
                        :method         => method,
                        :pointer        => 'pointer',
                        :praxis_address => praxis_address,
                        :email          => 'email',
                        :specialities   => ['speciality'],
                        :ean13          => 'ean13'
                       )
    @list    = ODDB::View::Doctors::DoctorList.new([@model], @session)
  end
  def test_init
    assert_equal(nil, @list.init)
  end
end

class TestEmptyResultForm <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :_event_url => '_event_url',
                        :base_url   => 'base_url',
                        :disabled?  => nil
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :zone        => 'zone',
                        :persistent_user_input => 'persistent_user_input'
                       )
    @model   = flexmock('model')
    @form    = ODDB::View::Doctors::EmptyResultForm.new(@model, @session)
  end
  def test_title_none_found
    assert_equal('lookup', @form.title_none_found(@model, @session))
  end
end


    end # Doctors
  end # View
end # ODDB
