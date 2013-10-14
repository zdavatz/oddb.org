#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::TestWelcomeHead -- oddb.org -- 24.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/welcomehead'

module ODDB
  class Session
    DEFAULT_FLAVOR = 'gcc'
  end
  module View


class TestWelcomeHead <Minitest::Test
  include FlexMock::TestCase
  def setup_welcome(lnf = nil)
    lnf ? @lnf = lnf : @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :enabled?   => nil,
                          :attributes => {},
                          :resource   => 'resource'
                         )
    user       = flexmock('user', :valid? => nil)
    sponsor    = flexmock('sponsor', :valid? => nil)
    state   = flexmock('state', :zone => 'zone')
    @session   = flexmock('session', 
                          :user => user,
                          :get_cookie_input     => 'get_cookie_input',
                          :flavor => Session::DEFAULT_FLAVOR,
                          :lookandfeel => @lnf,
                          :state => state,
                          :sponsor     => sponsor
                         )
    @model     = flexmock('model')
    @composite = ODDB::View::WelcomeHead.new(@model, @session)
  end
  def test_banner__epatents
    lnf = flexmock('lnf_epatents') do |lnf|
      lnf.should_receive(:resource_localized).and_return(false)
      lnf.should_receive(:attributes).and_return({})
      lnf.should_receive(:enabled?).and_return(true)
      lnf.should_receive(:resource).and_return('resource')
      lnf.should_receive(:lookup).and_return('lookup')
      lnf.should_receive(:_event_url)
    end
    setup_welcome(lnf)
    expected = "<A HREF=\"http://petition.eurolinux.org\"><img src=\"http://aful.org/images/patent_banner.gif\" alt=\"Petition against e-patents\"></A><BR>"
    assert_equal(expected, @composite.banner(@model, @session))
  end
  def test_bannr__banner
    lnf = flexmock('lnf_banner') do |lnf|
      lnf.should_receive(:attributes).and_return({})
      lnf.should_receive(:enabled?).with(:banner).once.and_return(true)
      lnf.should_receive(:enabled?).and_return(false)
      lnf.should_receive(:resource).and_return('resource')
      lnf.should_receive(:lookup).and_return('lookup')
      lnf.should_receive(:_event_url)
    end
    setup_welcome(lnf)
    assert_kind_of(HtmlGrid::Link, @composite.banner(@model, @session))
  end
  def test_banner__nil
    setup_welcome
    assert_nil(@composite.banner(@model, @session))
  end
  def test_home_welcome
    setup_welcome
    expected = ["lookup", "<br>", "lookup"]
    assert_equal(expected, @composite.home_welcome(@model, @session))
  end
  def test_home_welcome__screencast
    lnf = flexmock('lnf_epatents') do |lnf|
      lnf.should_receive(:resource_localized).and_return(false)
      lnf.should_receive(:attributes).and_return({})
      lnf.should_receive(:enabled?).and_return(true)
      lnf.should_receive(:resource).and_return('resource')
      lnf.should_receive(:lookup).and_return('lookup')
      lnf.should_receive(:_event_url)
    end
    setup_welcome(lnf)
    expected = ["lookup", "<br>", "lookup"]
    assert_kind_of(HtmlGrid::Link, @composite.home_welcome(@model, @session)[0])
  end

end

  end # View
end # ODDB

