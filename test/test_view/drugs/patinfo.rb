#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Drugs::TestPatinfo -- oddb.org -- 09.11.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/drugs/patinfo'

module ODDB
  module View
    module Drugs

class TestPatinfoInnerComposite <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', :lookup => 'lookup')
    @session   = flexmock('session', :lookandfeel => @lnf)
    @model     = flexmock('model', :chapter_names => ['chapter_names'])
    @composite = ODDB::View::Drugs::PatinfoInnerComposite.new(@model, @session)
  end
  def test_init
    chapter = ['chapter']
    flexmock(@model, :galenic_form => chapter)
    assert_equal([], @composite.init)
  end
end

class TestPatinfoComposite <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :_event_url => '_event_url'
                         )
    state = flexmock('state', :allowed? => 'allowed?')
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :language    => 'language',
                          :state       => state,
                          :user_input  => 'user_input',
                         )
    language   = flexmock('language', :name => 'name', :chapter_names => ['chapter_names'])
    registration = flexmock('registration', :iksnr => 'iksnr')
    sequence   = flexmock('sequence', 
                          :registration => registration,
                          :seqnr => 'seqnr'
                         )
    pointer = flexmock('pointer', :skeleton => 'skeleton')
    @model     = flexmock('model', 
                          :language => language,
                          :pointer  => pointer,
                          :sequences => [sequence]
                         )
    @composite = ODDB::View::Drugs::PatinfoComposite.new(@model, @session)
  end
  def test_document
    skip("Class is ODDB::View::Chapter. is this correct?")
    assert_kind_of(ODDB::View::Drugs::PatinfoInnerComposite, @composite.document(@model, @session))
  end
  def test_document_composite
    model      = ODDB::PatinfoDocument2001.new
    language   = flexmock('language', :name => 'name', :chapter_names => ['chapter_names'])
    registration = flexmock('registration', :iksnr => 'iksnr')
    sequence   = flexmock('sequence', 
                          :registration => registration,
                          :seqnr => 'seqnr'
                         )
    pointer = flexmock('pointer', :skeleton => 'skeleton')
    flexmock(model,
             :language => language,
             :pointer  => pointer,
             :sequences => [sequence]
            )
    composite = ODDB::View::Drugs::PatinfoComposite.new(model, @session)
    skip("avoid undefined method `document_composite'")
    assert_kind_of(ODDB::View::Drugs::PatinfoInnerComposite, composite.document_composite(model, @session))
  end
end

    end # Drugs
  end # View
end # ODDB
