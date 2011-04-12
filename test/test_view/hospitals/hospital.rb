#!/usr/bin/env ruby
# ODDB::View::Hospitals::TestHospital -- oddb.org -- 12.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/hospitals/hospital'
require 'htmlgrid/textarea'

module ODDB
	module View
    module Hospitals

class TestHospitalInnerComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :_event_url => '_event_url'
                         )
    @session   = flexmock('session', :lookandfeel => @lnf)
    @address   = flexmock('address', 
                          :fon    => ['fon'],
                          :fax    => ['fax'],
                          :lines  => ['line'],
                          :plz    => 'plz',
                          :city   => 'city',
                          :street => 'street',
                          :number => 'number',
                          :type   => 'type'
                         )
    @model     = flexmock('model', 
                          :addresses => [@address],
                          :pointer   => 'pointer'
                         )
    @composite = ODDB::View::Hospitals::HospitalInnerComposite.new(@model, @session)
  end
  def test_mapsearch_format
    args = ['1','2','3']
    assert_equal('1-2-3', @composite.mapsearch_format(*args))
  end
  def test_location
    flexmock(@address, :location => 'location')
    assert_equal('location', @composite.location(@model))
  end
end

class TestHospitalForm < Test::Unit::TestCase
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
    @address = flexmock('address', 
                        :fon    => ['fon'],
                        :fax    => ['fax'],
                        :lines  => ['line'],
                        :plz    => 'plz',
                        :city   => 'city',
                        :street => 'street',
                        :number => 'number',
                        :type   => 'type'
                       )
    @model   = flexmock('model', :address => @address )
    @form    = ODDB::View::Hospitals::HospitalForm.new(@model, @session)
  end
  def test_additional_lines
    assert_kind_of(HtmlGrid::Textarea, @form.additional_lines(@model))
  end
end

    end # Hospitals
	end # View
end # ODDB
