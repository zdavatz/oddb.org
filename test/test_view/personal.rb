#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::TestPersonal -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'htmlgrid/urllink'
require 'view/personal'

module ODDB
  module View

class StubPersonal
  include ODDB::View::Personal
  def initialize(model, session)
    @model = model
    @session = session
    @lookandfeel = session.lookandfeel
  end
end
class TestPersonal <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel',
                        :attributes => {},
                        :lookup => 'lookup',
                        :resource_global => 'resource_global',
                        )
    @yus_model = flexmock('yus_model',
                          :name => 'name',
                          :url => 'url',
                          :logo_filename => 'logo_filename',
                         )
    @app     = flexmock('app', :yus_model => @yus_model)
    @user    = flexmock('user', 
                        :is_a? => true,
                        :name       => 'name',
                        :name_first => 'name_first',
                        :name_last  => 'name_last'
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :app  => @app,
                        :user => @user
                       )
    @model   = flexmock('model')
    @view    = ODDB::View::StubPersonal.new(@model, @session)
  end
  def test_welcome
    assert_kind_of(HtmlGrid::HttpLink, @view.welcome(@model, @session)[0])
  end
  def test_welcome__name_empty
    flexmock(@user, 
             :name_first => '',
             :name_last  => '',
             :name => 'name'
            )
    assert_kind_of(HtmlGrid::HttpLink, @view.welcome(@model, @session)[0])
  end
end

  end # View
end # ODDB

