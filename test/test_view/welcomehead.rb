#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::TestWelcomeHead -- oddb.org -- 24.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))


require 'minitest/autorun'
require 'flexmock/minitest'
require 'view/welcomehead'
require 'stub/cgi'

module ODDB
  class Session
    DEFAULT_FLAVOR = 'gcc' unless defined?(DEFAULT_FLAVOR)
  end
  module View


class TestWelcomeHead <Minitest::Test
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
                          :sponsor     => sponsor,
                          :sponsor => nil,
                          :persistent_user_input => nil,
                          :request_path => 'request_path',
                          :request_method => 'GET',
                         )
    @model     = flexmock('model')
    @composite = ODDB::View::WelcomeHead.new(@model, @session)
  end
  def test_home_welcome
    setup_welcome
    expected = '<TABLE cellspacing="0" class="composite"><TR><TD class="welcomeleft">lookup</TD><TD class="welcomecenter">&nbsp;</TD><TD class="welcomeright">lookup</TD></TR><TR><TD>lookup</TD><TD>&nbsp;</TD><TD>&nbsp;</TD></TR></TABLE>'

    assert_equal(expected,  @composite.to_html(CGI.new))
  end
end

  end # View
end # ODDB

