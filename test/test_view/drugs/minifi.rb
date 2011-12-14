#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Drugs::TestMiniFi -- oddb.org -- 23.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/drugs/minifi'


module ODDB
  module View
    module Drugs

class TestMiniFiChapter < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @container = flexmock('container')
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :_event_url => '_event_url'
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :language    => 'language'
                       )
    @model   = flexmock('model', 
                        :registrations => ['registration'],
                        :name => 'name'
                       )
    @chapter = ODDB::View::Drugs::MiniFiChapter.new(@model, @session, @container)
  end
  def test_link_product
    assert_equal('html', @chapter.link_product('context', 'html'))
  end
end

    end # Drugs
  end # View
end # ODDB
