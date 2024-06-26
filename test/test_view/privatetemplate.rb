#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::TestPrivateTemplate -- oddb.org -- 27.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))


require 'minitest/autorun'
require 'flexmock/minitest'
require 'model/company'
require 'model/doctor'
require 'model/galenicgroup'
require 'view/privatetemplate'


module ODDB
  module View
    Copyright::ODDB_VERSION = 'version' unless defined?(Copyright::ODDB_VERSION)
    class Session
      DEFAULT_FLAVOR = 'gcc' unless defined?(DEFAULT_FLAVOR)
    end
class StubPrivateTemplate < ODDB::View::PrivateTemplate
  CONTENT = 'content'
end

class TestPrivateTemplate <Minitest::Test
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
                         :lookup      => 'lookup',
                         :enabled?    => nil,
                         :attributes  => {},
                         :resource    => 'resource',
                         :zones       => ['zones'],
                         :disabled?   => nil,
                         :_event_url  => '_event_url',
                         :navigation  => ['navigation'],
                         :base_url    => 'base_url',
                         :direct_event    => 'direct_event',
                         :zone_navigation => ['zone_navigation'],
                        )
    sponsor   = flexmock('sponsor', :valid? => nil)
    user      = flexmock('user', :valid? => nil)
    snapback_model = flexmock('snapback_model', :pointer => 'pointer')
    state     = flexmock('state', 
                         :direct_event   => 'direct_event',
                         :snapback_model => snapback_model
                        )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :zone => 'zone',
                        :event => 'event',
                        :user => user,
                         :allowed?   => nil,
                        :flavor => Session::DEFAULT_FLAVOR,
                        :state => state,
                        :request_path => 'request_path',
                        :get_cookie_input => 'get_cookie_input',
                        :sponsor => user,
                        :sponsor => nil,
                        :persistent_user_input => nil,
                        :request_method => 'GET',
                        )
    @model    = flexmock('model')
    content = flexmock('content', :new => 'new')
    replace_constant('ODDB::View::PublicTemplate::CONTENT', content) do 
      @template = ODDB::View::PrivateTemplate.new(@model, @session)
    end
  end

  def test_reorganize_components
    assert_equal('right', @template.reorganize_components)
  end
  def test_reorganize_components__topfoot
    flexmock(@lnf, :enabled? => true)
    assert_equal('right', @template.reorganize_components)
  end
end

  end # View
end # ODDB
