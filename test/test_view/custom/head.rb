#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Custom::TestHead -- oddb.org -- 23.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/custom/head'


module ODDB
  module View
    module Custom

class TestOekkHead < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :languages  => 'languages',
                          :enabled?   => nil,
                          :attributes => {},
                          :language   => 'language',
                          :resource   => 'resource'
                         )
    @session   = flexmock('session',
                          :lookandfeel  => @lnf,
                          :request_path => 'request_path'
                         )
    @model     = flexmock('model')
    @composite = ODDB::View::Custom::OekkHead.new(@model, @session)
  end
  def test_language_chooser
    assert_kind_of(ODDB::View::LanguageChooser, @composite.language_chooser(@model))
  end
  def test_oekk_logo
    assert_kind_of(HtmlGrid::Link, @composite.oekk_logo(@model))
  end
end

class StubHeadMethods
  include HeadMethods
  def initialize(model, session)
    @model = model
    @session = session
    @lookandfeel = session.lookandfeel
  end
end

class TestHeadMethods < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model')
    @headmethods = ODDB::View::Custom::StubHeadMethods.new(@model, @session)
  end
  def test_just_medical
    assert_kind_of(HtmlGrid::Div, @headmethods.just_medical(@model, @session))
  end
  def test_oekk_head
    assert_kind_of(ODDB::View::Custom::OekkHead, @headmethods.oekk_head(@model, @session))
  end
end

class StubHead
  include Head
  HEAD = self
  def initialize(model, session, *args)
    @model = model
    @session = session
    @lookandfeel = session.lookandfeel
  end
end

class TestHead < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup   => 'lookup',
                        :enabled? => nil
                       )
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model')
    @head    = ODDB::View::Custom::StubHead.new(@model, @session)
  end
  def test_head__just_medical_structure
    flexmock(@lnf, :enabled? => true)
    assert_kind_of(HtmlGrid::Div, @head.head(@model, @session))
  end
  def test_head__oekk_structure
    flexmock(@lnf) do |lnf|
      lnf.should_receive(:enabled?).with(:just_medical_structure, false).once.and_return(false)
      lnf.should_receive(:enabled?).with(:oekk_structure, false).once.and_return(true)
    end
    assert_kind_of(ODDB::View::Custom::OekkHead, @head.head(@model, @session))
  end
  def test_head__else
    assert_kind_of(ODDB::View::Custom::StubHead, @head.head(@model, @session))
  end
end

    end # Custom
  end # View
end # ODDB
