#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Doctors::TestDoctor -- oddb.org -- 09.11.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/doctors/doctor'
require 'htmlgrid/textarea'
require 'model/address'
require 'model/company'

module ODDB
  module View
    module Doctors

class TestDoctorInnerComposite <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {}
                         )
    @session   = flexmock('session', :lookandfeel => @lnf)
    @model     = flexmock('model', 
                          :specialities => ['speciality'],
                          :capabilities => ['capability']
                         )
    @composite = ODDB::View::Doctors::DoctorInnerComposite.new(@model, @session)
  end
  def test_specialities
    assert_equal('speciality', @composite.specialities(@model))
  end
end

class TestDoctorForm <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :base_url   => 'base_url'
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :error       => 'error',
                        :warning?    => nil,
                        :error?      => nil
                       )
    @model   = flexmock('model')
    @form    = ODDB::View::Doctors::DoctorForm.new(@model, @session)
  end
  def test_init
    assert_equal(nil, @form.init)
  end
end

class TestDoctorComposite <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :_event_url  => '_event_url'
                         )
    hospital   = flexmock('hospital', :addresses => ['address'])
    doctor     = flexmock('doctor', :addresses => ['address'])
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :user_input  => 'user_input',
                          :search_hospital => hospital,
                          :search_doctors  => [doctor],
                          :search_doctor   => doctor,
                          :persistent_user_input => 'persistent_user_input'
                         )
    address    = flexmock('address', 
                          :fon    => ['fon'],
                          :fax    => ['fax'],
                          :plz    => 'plz',
                          :city   => 'city',
                          :street => 'street',
                          :number => 'number',
                          :lines => ['line']
                         )
    @model     = flexmock('model', 
                          :specialities => ['speciality'],
                          :capabilities => ['capability'],
                          :addresses    => [address],
                          :pointer      => 'pointer',
                          :ean13        => 'ean13'
                         )
    @composite = ODDB::View::Doctors::DoctorComposite.new(@model, @session)
  end
  def test_addresses
    assert_kind_of(ODDB::View::Doctors::Addresses, @composite.addresses(@model))
  end
  def test_addresses__empty
    flexmock(@model, 
             :addresses => [],
             :pointer   => []
            )
    flexmock(@session, :zone => 'zone')
    assert_kind_of(ODDB::View::Doctors::Addresses, @composite.addresses(@model))
  end
end

    end # Doctors
  end # View
end # ODDB
