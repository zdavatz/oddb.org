#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Admin::TestPatinfoPreview -- oddb.org -- 30.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/admin/patinfopreview'


module ODDB
  module View
    module Admin

class TestPatinfoPreviewComposite <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', :lookup => 'lookup')
    @session   = flexmock('session', :lookandfeel => @lnf)
    @model     = flexmock('model', :name => 'name')
    @composite = ODDB::View::Admin::PatinfoPreviewComposite.new(@model, @session)
  end
  def test_document
    assert_kind_of(ODDB::View::Drugs::PatinfoInnerComposite, @composite.document(@model, @session))
  end
end


    end # Admin
  end    # View
end     # ODDB
