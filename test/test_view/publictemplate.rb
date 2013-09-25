#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::TestPublicTemplate -- oddb.org -- 19.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/publictemplate'
require 'htmlgrid/form'

module ODDB
  class Session
    DEFAULT_FLAVOR = 'gcc'
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

class TestPublicTemplate <Minitest::Test
  include FlexMock::TestCase
  def setup
    @zones    = flexmock('zones', )
    @lnf      = flexmock('lookandfeel', 
                         :lookup     => 'lookup',
                         :enabled?   => nil,
                         :attributes => {},
                         :resource   => 'resource',
                         :resource_global => 'resource_global',
                         :zones      => [@zones],
                         :disabled?  => nil,
                         :zone_navigation => [ 'zone_navigation' ],
                         :direct_event    => 'direct_event',
                         :_event_url => '_event_url',
                         :navigation => ['navigation'],
                        )
    user      = flexmock('user', :valid? => nil)
    sponsor   = flexmock('sponsor', :valid? => nil)
    @session  = flexmock('session', 
                         :lookandfeel => @lnf,
                         :flavor      => 'gcc',
                         :user        => user,
                         :sponsor     => sponsor,
                         :get_cookie_input => nil,
                        )
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
    expected = 'scriptscriptscriptscriptstylescript'
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
  def test_topfoot
    assert_kind_of(ODDB::View::TopFoot, @template.topfoot(@model, @session))
  end
  def test_topfoot__just_medical_structure
    flexmock(@lnf, :enabled? => true)
    assert_kind_of(HtmlGrid::Div, @template.topfoot(@model, @session))
  end
  def test_topfoot__oekk_structure
    flexmock(@lnf) do |l|
      l.should_receive(:enabled?).with(:just_medical_structure, false).and_return(false)
      l.should_receive(:enabled?).with(:oekk_structure, false).and_return(true)
    end
    assert_kind_of(ODDB::View::Custom::OekkHead, @template.topfoot(@model, @session))
  end
end

	end # View
end # ODDB
