#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Analysis::TestExplainResult -- oddb.org -- 28.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/analysis/explain_result'

module ODDB
  module View
    module Analysis

class TestExplainAnalysisTechnical1 <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', :lookup => 'lookup')
    @model     = flexmock('model')
  end
  def test_init
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :language    => 'de'
                         )
    @composite = ODDB::View::Analysis::ExplainAnalysisTechnical1.new(@model, @session)
    assert_equal({}, @composite.init)
  end
  def test_init__fr
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :language    => 'fr'
                         )
    @composite = ODDB::View::Analysis::ExplainAnalysisTechnical1.new(@model, @session)
    assert_equal({}, @composite.init)
  end
end

class TestExplainAnalysisTechnical2 <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', :lookup => 'lookup')
    @model     = flexmock('model')
  end
  def test_init__de
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :language    => 'de'
                         )
    @composite = ODDB::View::Analysis::ExplainAnalysisTechnical2.new(@model, @session)
    assert_equal({}, @composite.init)
  end
  def test_init__fr
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :language    => 'fr'
                         )
    @composite = ODDB::View::Analysis::ExplainAnalysisTechnical2.new(@model, @session)
    assert_equal({}, @composite.init)
  end
end


    end # Analysis
  end # View
end # ODDB
