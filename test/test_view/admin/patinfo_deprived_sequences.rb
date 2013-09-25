#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Admin::TestPatinfoDeprivedSequences -- oddb.org -- 27.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'htmlgrid/labeltext'
require 'view/admin/patinfo_deprived_sequences'


module ODDB
  module View
    module Admin

class TestPatinfoDeprivedSequencesList <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :event_url  => 'event_url'
                       )
    state    = flexmock('state', 
                        :interval  => 'interval',
                        :intervals => ['interval']
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :event       => 'event',
                        :state       => state
                       )
    @model   = flexmock('model', 
                        :pointer   => 'pointer',
                        :name_base => 'name_base',
                        :name => 'name'
                       )
    @list    = ODDB::View::Admin::PatinfoDeprivedSequencesList.new([@model], @session)
  end
  def test_nr
    assert_kind_of(HtmlGrid::Link, @list.nr(@model, @session))
  end
end

class TestShadowPatternForm <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :base_url   => 'base_url'
                       )
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model')
    @form    = ODDB::View::Admin::ShadowPatternForm.new(@model, @session)
  end
  def test_pattern
    assert_kind_of(HtmlGrid::InputText, @form.pattern(@model, @session))
  end
end


    end # Admin
  end    # View
end     # ODDB
