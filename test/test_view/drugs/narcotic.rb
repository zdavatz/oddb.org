#!/usr/bin/env ruby
# ODDB::View::Drugs::TestNarcotic -- oddb.org -- 19.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/drugs/narcotic'


module ODDB
  module View
    module Drugs

class TestPackagesList < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :_event_url => '_event_url'
                       )
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model', 
                        :name_base => 'name_base',
                        :size      => 'size',
                        :ikskey    => 'ikskey',
                        :pointer   => 'pointer'
                       )
    @list = ODDB::View::Drugs::PackagesList.new([@model], @session)
  end
  def test_init
    assert_nil(@list.init)
  end
end

class TestNarcoticComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :_event_url => '_event_url'
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :error       => 'error',
                        :language    => 'language'
                       )
    @reservation_text = flexmock('reservation_text', :language => 'language')
    package  = flexmock('package', 
                        :name_base => 'name_base',
                        :size      => 'size',
                        :ikskey    => 'ikskey',
                        :pointer   => 'pointer'
                       )
    @model   = flexmock('model',
                        :substances => ['substance'],
                        :reservation_text => @reservation_text,
                        :packages   => [package]
                       )

    @composite = ODDB::View::Drugs::NarcoticComposite.new(@model, @session)
  end
  def test_narcotic_connection
    assert_equal('lookup', @composite.narcotic_connection(@model))
  end
  def test_reservation_text
    flexmock(@reservation_text, :language => 'SR 123.456.78')
    assert_kind_of(HtmlGrid::Div, @composite.reservation_text(@model))
  end
end

    end # Drugs
  end # View
end # ODDB
