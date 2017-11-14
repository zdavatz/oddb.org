#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::TestZsr -- oddb.org -- 08.11.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))


require 'minitest/autorun'
require 'flexmock/minitest'
require 'stub/cgi'
require 'view/user/preferences'

module ODDB
  class Session
    DEFAULT_FLAVOR = 'gcc' unless defined?(DEFAULT_FLAVOR)
  end
  module View
    class Copyright < HtmlGrid::Composite
      ODDB_VERSION = 'oddb_version'
    end
    class StubForm
      def initialize(a,b,c)
      end
    end
    class StubPublicTemplate < PublicTemplate
      CONTENT = ODDB::View::StubForm
    end
  end
end

module ODDB
  module View
    class TestZsr <Minitest::Test
      def test_zsr
        @lnf     = flexmock('lookandfeel', 
                            :lookup     => 'lookup',
                            :attributes => {},
                            :_event_url => '_event_url',
                            :enabled? => true,
                            :disabled? => true,
                            :flavor => 'gcc',
                            :language => 'de',
                            :resource_external => 'resource_external',
                            :resource_localized => 'resource_localized',
                            :resource_global => 'resource_global',
                            :resource => 'resource',
                            :base_url => 'http://dummy.oddb.org',
                            :google_analytics_token => 'google_analytics_token',
                          )
        state      = flexmock('state', :zone => 'zone',
                              :direct_event => true)
        user       = flexmock('user', :valid? => true)
        
        @session = flexmock('session', 
                            :lookandfeel => @lnf,
                            :zone => 'zone',
                            :user_input => 'user_input',
                            :request_path => 'dummy.oddb.org/de/gcc/preferences/',
                            :zsr_id => nil,
                            :state => state,
                            :get_cookie_input => 'get_cookie_input',
                            :user => user,
                            :flavor => 'gcc',
                            :valid_values => [:search_type],
                            :user_agent => 'Mozilla',
                            :sponsor => nil,
                            :persistent_user_input => nil,
                          )
        @view    = ODDB::View::User::Preferences.new(@model, @session)
        result = @view.to_html(CGI.new)
        assert(result.index('composite'), "HTML should contain a composite")
        assert(/ZSR/i.match(result), "HTML should contain ZSR")
      end
    end
  end # View
end # ODDB

