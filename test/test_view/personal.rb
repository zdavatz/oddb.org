#!/usr/bin/env ruby
# ODDB::View::TestPersonal -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
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
class TestPersonal < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @user    = flexmock('user', 
                        :is_a? => true,
                        :name_first => 'name_first',
                        :name_last  => 'name_last'
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :user => @user
                       )
    @model   = flexmock('model')
    @view    = ODDB::View::StubPersonal.new(@model, @session)
  end
  def test_welcome
    assert_kind_of(HtmlGrid::Div, @view.welcome(@model, @session))
  end
  def test_welcome__name_empty
    flexmock(@user, 
             :name_first => '',
             :name_last  => '',
             :name => 'name'
            )
    assert_kind_of(HtmlGrid::Div, @view.welcome(@model, @session))
  end
end

  end # View
end # ODDB

