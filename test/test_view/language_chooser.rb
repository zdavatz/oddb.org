#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::TestLanguageChooser -- oddb.org -- 23.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/language_chooser'


module ODDB
  module View

class StubUserSettings
  include ODDB::View::UserSettings
  def initialize(model, session)
    @model       = model
    @session     = session
    @lookandfeel = session.lookandfeel
  end
end

class TestUserSettings < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :enabled?   => true,
                        :languages  => ['languages'],
                        :language   => 'language',
                        :attributes => {},
                        :currencies => ['currencies'],
                        :_event_url => '_event_url'
                       )
    @session = flexmock('session', 
                        :lookandfeel  => @lnf,
                        :request_path => 'request_path',
                        :currency     => 'currency'
                       )
    @model   = flexmock('model')
    @setting = ODDB::View::StubUserSettings.new(@model, @session)
  end
  def test_language_chooser
    assert_kind_of(ODDB::View::LanguageChooser, @setting.language_chooser(@model, @session))
  end
  def test_language_chooser_short
    assert_kind_of(ODDB::View::LanguageChooserShort, @setting.language_chooser_short(@model, @session))
  end
end

  end # View
end # ODDB
