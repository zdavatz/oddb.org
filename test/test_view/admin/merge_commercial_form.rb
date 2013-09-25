#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Admin::TestMergeCommercialForm -- oddb.org -- 29.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/privatetemplate'
require 'htmlgrid/errormessage'
require 'view/form'
require 'view/admin/merge_commercial_form'


module ODDB
  module View
    module Admin

class TestMergeCommercialFormForm <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :language   => 'language',
                        :attributes => {},
                        :base_url   => 'base_url'
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :warning? => nil,
                        :error?   => nil
                       )
    @model   = flexmock('model', :description => 'description')
    @form    = ODDB::View::Admin::MergeCommercialFormForm.new(@model, @session)
  end
  def test_init
    assert_nil(@form.init)
  end
end

class TestMergeCommercialFormComposite <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :language   => 'language',
                          :attributes => {},
                          :base_url   => 'base_url'
                         )
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :error => 'error',
                          :warning? => nil,
                          :error?   => nil
                         )
    @model     = flexmock('model', 
                          :package_count => 0,
                          :description   => 'description'
                         )
    @composite = ODDB::View::Admin::MergeCommercialFormComposite.new(@model, @session)
  end
  def test_merge_commercial_form
    assert_equal('lookup', @composite.merge_commercial_form(@model, @session))
  end
end

    end # Admin
  end # View
end # ODDB
