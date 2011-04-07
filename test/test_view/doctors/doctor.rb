#!/usr/bin/env ruby
# ODDB::View::Doctors::TestDoctor -- oddb.org -- 07.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/doctors/doctor'
require 'htmlgrid/textarea'
require 'model/address'

module ODDB
  module View
    module Doctors

class TestDoctorInnerComposite < Test::Unit::TestCase
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

class TestDoctorForm < Test::Unit::TestCase
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

class TestDoctorComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :_event_url  => '_event_url'
                         )
    @session   = flexmock('session', :lookandfeel => @lnf)
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
                          :pointer      => 'pointer'
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
