#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::TestResultTemplate -- oddb.org -- 30.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/resulttemplate'

module ODDB
  module View
    Copyright::ODDB_VERSION = 'version'
    class TestResultTemplate < Test::Unit::TestCase
      include FlexMock::TestCase
      def stderr_null
        require 'tempfile'
        $stderr = Tempfile.open('stderr')
        yield
        $stderr.close
        $stderr = STDERR
      end
      def replace_constant(constant, temp)
        stderr_null do
          keep = eval constant
          eval "#{constant} = temp"
          yield
          eval "#{constant} = keep"
        end
      end
      def setup
        @lnf      = flexmock('lookandfeel', 
                             :lookup     => 'lookup',
                             :enabled?   => nil,
                             :attributes => {},
                             :resource   => 'resource',
                             :zones      => 'zones',
                             :disabled?  => nil,
                             :_event_url => '_event_url',
                             :navigation => 'navigation',
                             :zone_navigation => 'zone_navigation',
                             :direct_event => 'direct_event'
                            )
        user      = flexmock('user', :valid? => nil)
        @session  = flexmock('session', 
                             :lookandfeel => @lnf,
                             :user    => user,
                             :sponsor => user
                            )
        @model    = flexmock('model')
        @content  = flexmock('content', :new => 'new')
        replace_constant('ODDB::View::ResultTemplate::CONTENT', @content) do 
          @template = ODDB::View::ResultTemplate.new(@model, @session)
        end
      end
      def test_init
        replace_constant('ODDB::View::ResultTemplate::CONTENT', @content) do 
          assert_equal({}, @template.init)
        end
      end
      def test_init__enabled
        flexmock(@lnf, 
                 :enabled? => true,
                 :languages  => ['language'],
                 :currencies => ['currency'],
                 :language   => 'language',
                 :resource_localized => 'resource_localized'
                )
        state = flexmock('state', :zone => 'zone')
        flexmock(@session, 
                 :state    => state,
                 :currency => 'currency'
                )
        replace_constant('ODDB::View::ResultTemplate::CONTENT', @content) do 
          assert_equal({}, @template.init)
        end
      end
    end
  end # View
end # ODDB
