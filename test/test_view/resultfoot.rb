#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::TestResultFoot -- oddb.org -- 08.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/resultfoot'
require 'htmlgrid/span'

module ODDB
	module View
    class TestExplainResult <Minitest::Test
      include FlexMock::TestCase
      def setup
        @container = flexmock('container')
        components = {[0,0] => :explain_fachinfo}
        @lnf       = flexmock('lookandfeel', 
                              :explain_result_components => components,
                              :lookup     => 'lookup',
                              :attributes => {},
                              :enabled?   => nil,
                              :disabled?  => nil
                             )
        @session   = flexmock('session', :lookandfeel => @lnf)
        @model     = flexmock('model')
        @composite = ODDB::View::ExplainResult.new(@model, @session, @container)
      end
      def test_init
        assert_equal({}, @composite.init)
      end
      def test_explain_comarketing
        result = @composite.explain_comarketing(@model, @session)
        assert_equal(2, result.length)
        assert_kind_of(HtmlGrid::Link, result[0])
        assert_equal('lookup', result[1])
      end
      def test_explain_ddd_price
        assert_kind_of(HtmlGrid::Link, @composite.explain_ddd_price(@model, @session))
      end
      def test_explain_deductible
        assert_kind_of(HtmlGrid::Link, @composite.explain_deductible(@model, @session))
      end
      def test_explain_anthroposophy
        result = @composite.explain_anthroposophy(@model, @session)
        assert_equal(2, result.length)
        assert_kind_of(HtmlGrid::Span, result[0])
        assert_equal('lookup', result[1])
      end
      def test_explain_complementary
        result = @composite.explain_complementary(@model, @session)
        assert_equal(2, result.length)
        assert_kind_of(HtmlGrid::Link, result[0])
        assert_equal('lookup', result[1])
      end
      def test_explain_feedback
        result = @composite.explain_feedback(@model, @session)
        assert_equal(2, result.length)
        assert_kind_of(HtmlGrid::Span, result[0])
        assert_equal('lookup', result[1])
      end
      def test_explain_generic
        assert_kind_of(HtmlGrid::Link, @composite.explain_generic(@model, @session))
      end
      def test_explain_google_search
        result = @composite.explain_google_search(@model, @session)
        assert_equal(2, result.length)
        assert_kind_of(HtmlGrid::Span, result[0])
        assert_equal('lookup', result[1])
      end
      def test_explain_limitation
        result = @composite.explain_limitation(@model, @session)
        assert_equal(2, result.length)
        assert_kind_of(HtmlGrid::Span, result[0])
        assert_equal('lookup', result[1])
      end
      def test_explain_minifi
        result = @composite.explain_minifi(@model, @session)
        assert_equal(2, result.length)
        assert_kind_of(HtmlGrid::Span, result[0])
        assert_equal('lookup', result[1])
      end
      def test_explain_original
        assert_kind_of(HtmlGrid::Link, @composite.explain_original(@model, @session))
      end
      def test_explain_patinfo
        result = @composite.explain_patinfo(@model, @session)
        assert_equal(2, result.length)
        assert_kind_of(HtmlGrid::Span, result[0])
        assert_equal('lookup', result[1])
      end
      def test_explain_homeopathy
        result = @composite.explain_homeopathy(@model, @session)
        assert_equal(2, result.length)
        assert_kind_of(HtmlGrid::Span, result[0])
        assert_equal('lookup', result[1])
      end
      def test_explain_parallel_import
        result = @composite.explain_parallel_import(@model, @session)
        assert_equal(2, result.length)
        assert_kind_of(HtmlGrid::Span, result[0])
        assert_equal('lookup', result[1])
      end
      def test_explain_phytotherapy
        result = @composite.explain_phytotherapy(@model, @session)
        assert_equal(2, result.length)
        assert_kind_of(HtmlGrid::Span, result[0])
        assert_equal('lookup', result[1])
      end
      def test_explain_vaccine
        result = @composite.explain_vaccine(@model, @session)
        assert_equal(2, result.length)
        assert_kind_of(HtmlGrid::Link, result[0])
        assert_equal('lookup', result[1])
      end
      def test_explain_cas
        assert_kind_of(HtmlGrid::Link, @composite.explain_cas(@model, @session))
      end
      def test_explain_lppv
        assert_kind_of(HtmlGrid::Link, @composite.explain_lppv(@model, @session))
      end
      def test_explain_narc
        result = @composite.explain_narc(@model, @session)
        assert_equal(2, result.length)
        assert_kind_of(HtmlGrid::Span, result[0])
        assert_equal('lookup', result[1])
      end
    end

    class StubResultFootBuilder < HtmlGrid::Composite
      include ResultFootBuilder
      COMPONENTS = {}
    end

    class TestResultFootBuilder <Minitest::Test
      include FlexMock::TestCase
      def test_result_foot
        @lnf     = flexmock('lookandfeel', 
                            :navigation => [],
                            :disabled?  => nil,
                            :enabled?   => nil,
                            :lookup     => 'lookup',
                            :attributes => {},
                            :explain_result_components => {[0,0] => :explain_fachinfo}
                           )
        @session = flexmock('session', :lookandfeel => @lnf)
        @model   = flexmock('model')
        @composite = ODDB::View::StubResultFootBuilder.new(@model, @session)
        assert_kind_of(ODDB::View::ResultFoot, @composite.result_foot(@model, @session))
      end
      def test_result_foot__legal_note
        @lnf     = flexmock('lookandfeel', 
                            :navigation => [:legal_note],
                            :disabled?  => nil,
                            :enabled?   => nil,
                            :lookup     => 'lookup',
                            :attributes => {},
                            :explain_result_components => {[0,0] => :explain_fachinfo}
                           )
        @session = flexmock('session', :lookandfeel => @lnf)
        @model   = flexmock('model')
        @composite = ODDB::View::StubResultFootBuilder.new(@model, @session)
        assert_kind_of(ODDB::View::ExplainResult, @composite.result_foot(@model, @session))
      end
    end

    class TestResultFoot <Minitest::Test
      include FlexMock::TestCase
      def test_init
        @lnf       = flexmock('lookandfeel', 
                              :navigation => ['navigation'],
                              :disabled?  => nil,
                              :enabled?   => true,
                              :lookup     => 'lookup',
                              :attributes => {},
                              :explain_result_components => {[0,0] => :explain_fachinfo}
                             )
        @session   = flexmock('session', :lookandfeel => @lnf)
        @model     = flexmock('model')
        @composite = ODDB::View::ResultFoot.new(@model, @session)
        expected = {[0, 0]=>"explain", [0, 1]=>"explain right"}
        assert_equal(expected, @composite.init)
      end
    end

  end # View
end # ODDB
