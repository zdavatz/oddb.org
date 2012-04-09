#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Admin::TestOrphanedLanguages -- oddb.org -- 09.04.2012 -- yasaka@ywesee.com
# ODDB::View::Admin::TestOrphanedLanguages -- oddb.org -- 27.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'htmlgrid/labeltext'
require 'view/admin/orphaned_fachinfo_assign'


module ODDB
  module View
    module Admin

class TestOrphanedLanguagesList < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :event_url  => 'event_url'
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :event       => 'event'
                       )
    document = flexmock('document', :name => 'name')
    @model   = flexmock('model', 
                        :language => 'language',
                        :document => document
                       )
    @container = flexmock('container', :list_index => 'list_index')
    @list    = ODDB::View::Admin::OrphanedLanguagesList.new([@model], @session, @container)
  end
  def test_language
    assert_equal('lookup', @list.language(@model, @session))
  end
  def test_name
    assert_equal('name', @list.name(@model, @session))
  end
  def test_name__error
    flexmock(@model).should_receive(:document).and_raise(RuntimeError)
    assert_equal('RuntimeError', @list.name(@model, @session))
  end
  def test_preview
    assert_kind_of(HtmlGrid::PopupLink, @list.preview(@model, @session))
  end
end

class StubOrphanedLanguages
  include ODDB::View::Admin::OrphanedLanguages
  def initialize(model, session)
    @model = model
    @session = session
    @lookandfeel = session.lookandfeel
  end
end
class TestOrphanedLanguages < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :event_url  => 'event_url'
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :event       => 'event'
                       )
    document = flexmock('document', :name => 'name')
    @model   = ['language', document]
    @orphan  = ODDB::View::Admin::StubOrphanedLanguages.new(@model, @session)
  end
  def test_languages
    assert_kind_of(ODDB::View::Admin::OrphanedLanguagesList, @orphan.languages(@model, @session))
  end
end


    end # Admin
  end    # View
end     # ODDB
