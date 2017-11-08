#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::TestPublicTemplate -- oddb.org -- 19.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))


require 'minitest/autorun'
require 'flexmock/minitest'
require 'view/publictemplate'
require 'htmlgrid/form'
require 'sbsm/cgi'

module ODDB
  class Session
    DEFAULT_FLAVOR = 'gcc' unless defined?(DEFAULT_FLAVOR)
  end
  module View
    class Copyright < HtmlGrid::Composite
      ODDB_VERSION = 'oddb_version' unless defined?(ODDB_VERSION)
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

class TestPublicTemplate <Minitest::Test
  def setup
    @zones    = flexmock('zones', )
    @lnf      = flexmock('lookandfeel',
                         :enabled?   => nil,
                         :attributes => {},
                         :resource   => 'resource',
                         :resource_global => 'resource_global',
                         :disabled?  => nil,
                         :zone_navigation => [ 'zone_navigation' ],
                         :direct_event    => 'direct_event',
                         :_event_url => '_event_url',
                         :navigation => ['navigation'],
                        )
    @lnf.should_receive(:lookup).and_return('lookup').by_default
    @lnf.should_receive(:zones).and_return([@zones]).by_default
    user      = flexmock('user', :valid? => nil)
    sponsor   = flexmock('sponsor', :valid? => nil)
    @session  = flexmock('session',
                         :flavor      => 'gcc',
                         :user        => user,
                         :sponsor     => sponsor,
                         :request_path => 'request_path',
                         :get_cookie_input => nil,
                        )
    @session.should_receive(:lookandfeel).and_return(@lnf).by_default
    @model    = flexmock('model')

    @template = ODDB::View::StubPublicTemplate.new(@model, @session)
  end
  def test_css_link
    context = flexmock('context', :link => 'link')
    assert_equal('link', @template.css_link(context))
  end
  def test_css_link__lookandfeel_enabled
    flexmock(@lnf,
             :enabled? => true,
             :resource_external => 'resource_external'
            )
    context = flexmock('context', :link => 'link')
    assert_equal('link', @template.css_link(context))
  end
  def test_dynamic_html_headers
    flexmock(@lnf,
             :enabled? => true,
             :resource_global => 'resource_global'
            )
    context = flexmock('context') do |c|
      c.should_receive(:script).and_return('script')
      c.should_receive(:style).and_return('style')
    end
    expected = 'scriptscriptstylestyle'
    assert_equal(expected, @template.dynamic_html_headers(context))
  end
  def test_dynamic_html_headers__not_enabled
    context = flexmock('context', :script => '', :style => '')
    assert_equal('', @template.dynamic_html_headers(context))
  end
  def test_javascripts
    additional_javascripts = ['additional_javascripts']
    @template.instance_eval('@additional_javascripts = additional_javascripts')
    context = flexmock('context', :script => 'script')
    assert_equal('script', @template.javascripts(context))
  end
  def test_title
    context = flexmock('context', :title => 'title')
    assert_equal('title', @template.title(context))
  end
  def test_title_part_three
    state = flexmock('state', :direct_event => 'direct_event')
    flexmock(@session, :state => state)
    assert_equal('lookup', @template.title_part_three)
  end
  def test_title_part_three__login_event
    state = flexmock('state', :direct_event => :login)
    flexmock(@session, :state => state)
    flexmock(@model, :pointer_descr => 'pointer_descr')
    assert_equal('pointer_descr', @template.title_part_three)
  end
  def test_title_part_three__login_event_name
    state = flexmock('state', :direct_event => :login)
    flexmock(@session, :state => state)
    flexmock(@model, :name => 'name')
    assert_equal('name', @template.title_part_three)
  end
  def test_meta_apple_app_id
    @lnf.should_receive(:lookup).and_return{|arg| arg.to_s}
    @lnf.should_receive(:zones).and_return([])
    @session.should_receive(:event).and_return(nil)
    @session.should_receive(:lookandfeel).and_return(@lnf)
    context = flexmock('context', :title => 'title')
    context = flexmock('context') do |c|
      c.should_receive(:script).and_return('script')
      c.should_receive(:style).and_return('style')
    end
    state = flexmock('state')
    state.should_receive(:zone).and_return('zone')
    state.should_receive(:direct_event).and_return(nil)
     @session.should_receive(:state).and_return(state)
     @cgi = CGI.initialize_without_offline_prompt('html4')
     @template.init
     html =  @template.to_html(@cgi)
     assert(/META name="apple-itunes-app" content="app-id.*/.match(html))
  end
end

	end # View
end # ODDB
