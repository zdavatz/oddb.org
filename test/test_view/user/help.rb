#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::User::TestHelp -- oddb.org -- 22.06.2011 -- mhatakeyama@ywesee.com

#$: << File.expand_path('../../', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/user/help'

module ODDB
  module View
    module User

class TestHelpComposite <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {}
                         )
    @session   = flexmock('session', :lookandfeel => @lnf)
    @model     = flexmock('model')
    @composite = ODDB::View::User::HelpComposite.new(@model, @session)
  end
  def test_contact_email
    assert_kind_of(HtmlGrid::Link, @composite.contact_email(@model, @session))
  end
end
    end # User
  end # View
end # ODDB
