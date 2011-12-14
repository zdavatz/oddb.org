#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Admin::TestSlEntry -- oddb.org -- 20.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/admin/slentry'

module ODDB
  module View
    module Admin

class TestSlEntryForm < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :base_url   => 'base_url'
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :error       => 'error',
                        :warning?    => nil,
                        :error?      => nil
                       )
    @model   = flexmock('model')
    @form    = ODDB::View::Admin::SlEntryForm.new(@model, @session)
  end
  def test_init
    assert_nil(@form.init)
  end
end

class TestSlEntryComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @app       = flexmock('app')
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {}
                         )
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :app         => @app,
                          :error       => 'error'
                         )
    parent     = flexmock('parent', 
                          :name_base => 'name_base',
                          :size      => 'size'
                         )
    @model     = flexmock('model', :parent => parent)
    @composite = ODDB::View::Admin::SlEntryComposite.new(@model, @session)
  end
  def test_package_name
    expected = "name_base&nbsp;-&nbsp;size&nbsp;-&nbsp;lookup"
    assert_equal(expected, @composite.package_name(@model, @session))
  end
end
    end # Admin
  end # View
end # ODDB


