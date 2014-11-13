#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::HC_providers::TestHC_provider -- oddb.org -- 08.11.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/hc_providers/hc_provider'
require 'htmlgrid/textarea'
require 'model/company'

module ODDB
	module View
    module HC_providers

class TestHC_providerInnerComposite <Minitest::Test
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
                          :pointer   => 'pointer',
                          :ean13     => 'ean13'
                         )
    @composite = ODDB::View::HC_providers::HC_providerInnerComposite.new(@model, @session)
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

class TestHC_providerForm <Minitest::Test
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
    @form    = ODDB::View::HC_providers::HC_providerForm.new(@model, @session)
  end
  def test_additional_lines
    assert_kind_of(HtmlGrid::Textarea, @form.additional_lines(@model))
  end
end

    end # HC_providers
	end # View
end # ODDB
