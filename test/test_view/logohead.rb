#!/usr/bin/env ruby
# ODDB::View::TestLogoHead -- oddb.org -- 21.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/logohead'
require 'htmlgrid/span'

module ODDB
  module View
    module SponsorDisplay

class StubSponsorDisplay
  include ODDB::View::SponsorDisplay
  def initialize(model, session)
    @model = model
    @session = session
    @lookandfeel = session.lookandfeel
  end
end

class TestSponsorDisplay < Test::Unit::TestCase
  include FlexMock::TestCase
  def test_sponsor__sponsor_valid
    user    = flexmock('user', :valid? => nil)
    lnf     = flexmock('lookandfeel', 
                       :enabled? => true,
                       :language => 'language',
                       :lookup   => 'lookup',
                       :format_date     => 'format_date',
                       :resource_global => 'resource_global'
                      )
    sponsor = flexmock('sponsor', 
                       :valid? => true,
                       :name   => 'name',
                       :logo_filename => 'logo_filename',
                       :sponsor_until => 'sponsor_until'
                      )
    session = flexmock('session', 
                       :lookandfeel => lnf,
                       :user => user,
                       :sponsor => sponsor
                      )
    model   = flexmock('model')
    @view   = ODDB::View::SponsorDisplay::StubSponsorDisplay.new(model, session)
    assert_kind_of(ODDB::View::SponsorLogo, @view.sponsor(model, session))
  end
  def test_sponsor__sponsor_invalid
    user    = flexmock('user', :valid? => nil)
    lnf     = flexmock('lookandfeel', :enabled? => true)
    session = flexmock('session', 
                       :lookandfeel => lnf,
                       :user => user,
                       :sponsor => nil
                      )
    model   = flexmock('model')
    @view   = ODDB::View::SponsorDisplay::StubSponsorDisplay.new(model, session)
    assert_kind_of(ODDB::View::GoogleAdSense, @view.sponsor(model, session))
  end
end

    end # SponsorDisplay
  end # View
end # ODDB

