#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Admin::TestMergeGalenicGroup -- oddb.org -- 27.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/admin/mergegalenicform'


module ODDB
  module View
    module Admin

class TestMergeGalenicFormForm <Minitest::Test
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
    @form    = ODDB::View::Admin::MergeGalenicFormForm.new(@model, @session)
  end
  def test_init
    assert_equal(nil, @form.init)
  end
end

class TestMergeGalenicFormComposite <Minitest::Test
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
                          :error    => 'error',
                          :warning? => nil,
                          :error?   => nil
                         )
    @model     = flexmock('model', 
                          :sequence_count => 0,
                          :description    => 'description'
                         )
    @composite = ODDB::View::Admin::MergeGalenicFormComposite.new(@model, @session)
  end
  def test_merge_galenic_form
    assert_equal('lookup', @composite.merge_galenic_form(@model, @session))
  end
end
    end # Admin
  end # View
end # ODDB
