#!/usr/bin/env ruby
# ODDB::View::TestPrintTemplate -- oddb.org -- 24.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'htmlgrid/link'
require 'view/printtemplate'

module ODDB
  module View

    class StubPrint
      include ODDB::View::Print
      def initialize(model, session)
        @model = model
        @session = session
        @lookandfeel = session.lookandfeel
      end
    end

    class TestPrint < Test::Unit::TestCase
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

    class TestPrintTemplate < Test::Unit::TestCase
      include FlexMock::TestCase
      def setup
        @lnf      = flexmock('lookandfeel', 
                             :lookup => 'lookup',
                             :resource_global => 'resource_global'
                            )
        @session  = flexmock('session', :lookandfeel => @lnf)
        @model    = flexmock('model')
        @template = ODDB::View::PrintTemplate.new(@model, @session)
      end
      def test_init
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

    class TestPrintComposite < Test::Unit::TestCase
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
