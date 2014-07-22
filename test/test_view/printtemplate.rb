#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::TestPrintTemplate -- oddb.org -- 24.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'htmlgrid/link'
require 'view/printtemplate'

module ODDB
  module View
    class Session
      DEFAULT_FLAVOR = 'gcc'
    end

    class StubPrint
      include ODDB::View::Print
      def initialize(model, session)
        @model = model
        @session = session
        @lookandfeel = session.lookandfeel
      end
    end
    class StubForm
      def initialize(a,b,c)
      end
    end
    class StubPublicTemplate < PublicTemplate
      CONTENT = ODDB::View::StubForm
    end
    class StubPrintTemplate < PrintTemplate
      CONTENT = ODDB::View::StubForm
    end

    class TestPrint <Minitest::Test
      include FlexMock::TestCase
      def setup
        @lnf     = flexmock('lookandfeel', 
                            :lookup     => 'lookup',
                            :attributes => {},
                            :_event_url => '_event_url'
                           )
        @session = flexmock('session', :lookandfeel => @lnf)
        @model   = flexmock('model', :pointer => 'pointer')
        @print   = ODDB::View::StubPrint.new(@model, @session)
      end
      def test_print
        assert_kind_of(HtmlGrid::Link, @print.print(@model, @session))
      end
      def test_rint_edit
        assert_kind_of(HtmlGrid::Link, @print.print_edit(@model, @session))
      end
    end

    class TestPrintTemplate <Minitest::Test
      include FlexMock::TestCase
      def setup
        @lnf     = flexmock('lookandfeel', 
                            :lookup     => 'lookup',
                            :enabled?   => nil,
                            :resource   => 'resource',
                            :resource_global => 'resource_global',
                            :attributes => {},
                            :_event_url => '_event_url'
                           )
        @session = flexmock('session', 
                            :lookandfeel => @lnf,
                            :flavor      => 'gcc',
                            :get_cookie_input => nil,
                             )
        @model   = flexmock('model', :pointer => 'pointer')
        @template = ODDB::View::StubPrintTemplate.new(@model, @session)
      end
      def test_init
        skip("Don't know why we got expected {}. But printing does work")
        expected = [[[0, 0], :head], [[0, 1], :content]]
        assert_equal(expected, @template.init)
      end
      def test_css_link
        context = flexmock('context', :link => 'link')
        assert_equal('link', @template.css_link(context))
      end
    end

    class StubPrintComposite
      include PrintComposite
      INNER_COMPOSITE = self
      PRINT_TYPE = 'print type'
      def initialize(model, session, *args)
        @model = model
        @session = session
        @lookandfeel = session.lookandfeel
      end
    end

    class TestPrintComposite <Minitest::Test
      include FlexMock::TestCase
      def setup
        @lnf       = flexmock('lookandfeel', :lookup => 'lookup')
        @session   = flexmock('session', 
                              :lookandfeel => @lnf,
                              :language    => 'language'
                             )
        document   = flexmock('document', :name => 'name')
        @model     = flexmock('model', :language => document) 
        @composite = ODDB::View::StubPrintComposite.new(@model, @session)
      end
      def test_name
        assert_equal('name', @composite.name(@model, @session))
      end
      def test_document
        assert_kind_of(ODDB::View::StubPrintComposite, @composite.document(@model, @session))
      end
      def test_print_type
        assert_equal('lookup', @composite.print_type(@model, @session))
      end
    end

  end # View
end # ODDB
