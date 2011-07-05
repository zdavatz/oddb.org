#!/usr/bin/env ruby
# ODDB::View::User::TestAutoFill -- oddb.org -- 05.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'htmlgrid/inputtext'
require 'view/user/autofill'

module ODDB
  module View
    module User

class StubAutoFill
  include AutoFill
  def initialize(model, session)
    @modle = model
    @session = session
    @lookandfeel = session.lookandfeel
  end
end
class TestAutoFill < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :_event_url => '_event_url'
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :logged_in?  => true,
                        :user => 'user'
                       )
    @model   = flexmock('model')
    @view     = ODDB::View::User::StubAutoFill.new(@model, @session)
  end
  def test_email
    assert_kind_of(HtmlGrid::InputText, @view.email(@model, @session))
  end
  def test_email__else
    flexmock(@session, :logged_in? => false)
    assert_kind_of(HtmlGrid::InputText, @view.email(@model, @session))
  end
end

    end # User
  end # View
end # ODDB
