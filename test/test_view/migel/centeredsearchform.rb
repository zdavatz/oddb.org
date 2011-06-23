#!/usr/bin/env ruby
# ODDB::View::Migel::TestCenteredSearchComposite -- oddb.org -- 21.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/migel/centeredsearchform'

module ODDB
  module View
    module Migel

class TestCenteredSearchComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @app       = flexmock('app')
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :enabled?   => nil,
                          :attributes => {},
                          :_event_url => '_event_url',
                          :disabled?  => nil,
                          :zones      => 'zones',
                          :base_url   => 'base_url',
                          :zone_navigation => 'zone_navigation',
                          :direct_event    => 'direct_event',
                          :languages  => 'languages',
                          :currencies => 'currencies',
                          :language   => 'language'
                         )
    @session   = flexmock('session', 
                          :app  => @app,
                          :zone => 'zone',
                          :lookandfeel  => @lnf,
                          :migel_count  => 0,
                          :request_path => 'request_path',
                          :currency     => 'currency'
                         )
    @model     = flexmock('model')
    @composite = ODDB::View::Migel::CenteredSearchComposite.new(@model, @session)
  end
  def test_init
    assert_equal({}, @composite.init)
  end
  def test_init__just_medical_structure
    flexmock(@lnf, :enabled? => true)
    assert_equal({}, @composite.init)
  end
  def test_init__atupri_web
    flexmock(@lnf) do |lnf|
      lnf.should_receive(:enabled?).with(:just_medical_structure, false).once.and_return(false)
      lnf.should_receive(:enabled?).with(:atupri_web, false).once.and_return(true)
      lnf.should_receive(:enabled?).with(:search_reset)
      lnf.should_receive(:enabled?).with(:custom_tab_navigation, false)
    end
    assert_equal({}, @composite.init)
  end
end

    end # Migel
  end # View
end # ODDB
