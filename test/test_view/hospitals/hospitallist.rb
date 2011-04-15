#!/usr/bin/env ruby
# ODDB::View::Hospitals::TestHospitalList -- oddb.org -- 15.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'htmlgrid/labeltext'
require 'view/hospitals/hospitallist'

module ODDB
	module View
    module Hospitals

class TestHospitalList < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :event_url  => 'event_url',
                        :_event_url => '_event_url'
                       )
    state    = flexmock('state', 
                        :interval  => 'interval',
                        :intervals => ['interval']
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :event       => 'event',
                        :state       => state
                       )
    method   = flexmock('method', :arity => 0)
    address  = flexmock('address', 
                        :city   => 'city',
                        :plz    => 'plz',
                        :canton => 'canton',
                        :street => 'street',
                        :number => 'number'
                       )
    @model   = flexmock('model', 
                        :name      => 'name',
                        :method    => method,
                        :pointer   => 'pointer',
                        :ean13     => 'ean13',
                        :address   => address,
                        :addresses => [address],
                        :narcotics => 'narcotics'
                       )
    @list    = ODDB::View::Hospitals::HospitalList.new([@model], @session)
  end
  def test_plz
    assert_equal('plz', @list.plz(@model))
  end
  def test_narcotics
    flexmock(@model, :narcotics => 'Keine Betäubungsmittelbewilligung')
    assert_equal('lookup', @list.narcotics(@model))
  end
end
class TestHospitalsComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def test_hospital_list
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :event_url  => 'event_url',
                          :_event_url => '_event_url',
                          :disabled?  => nil,
                          :base_url   => 'base_url'
                         )
    state      = flexmock('state', 
                          :interval  => 'interval',
                          :intervals => ['interval']
                         )
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :zone        => 'zone',
                          :event       => 'event',
                          :state       => state
                         )
    method     = flexmock('method', :arity => 0)
    address    = flexmock('address', 
                          :city   => 'city',
                          :plz    => 'plz',
                          :canton => 'canton',
                          :street => 'street',
                          :number => 'number'
                         )
    @model     = flexmock('model', 
                          :name      => 'name',
                          :method    => method,
                          :pointer   => 'pointer',
                          :ean13     => 'ean13',
                          :address   => address,
                          :addresses => [address],
                          :narcotics => 'narcotics'
                         )
    @composite = ODDB::View::Hospitals::HospitalsComposite.new([@model], @session)
    assert_kind_of(ODDB::View::Hospitals::HospitalList, @composite.hospital_list([@model], @session))
  end
end
class TestEmptyResultForm < Test::Unit::TestCase
  include FlexMock::TestCase
  def test_title_none_found
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :_event_url => '_event_url',
                        :disabled?  => nil,
                        :base_url   => 'base_url'
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :zone        => 'zone',
                        :persistent_user_input => 'persistent_user_input'
                       )
    @model   = flexmock('model')
    @form    = ODDB::View::Hospitals::EmptyResultForm.new(@model, @session)
    assert_equal('lookup', @form.title_none_found(@model, @session))
  end
end


    end # Hospitals
	end # View
end # ODDB
