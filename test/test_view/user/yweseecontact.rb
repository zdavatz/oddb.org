#!/usr/bin/env ruby
# ODDB::View::User::TestYweseeContact -- oddb.org -- 29.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/user/yweseecontact'


module ODDB
  module View
    module User

class TestYweseeContactForm < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :base_url   => 'base_url'
                       )
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model')
    @form    = ODDB::View::User::YweseeContactForm.new(@model, @session)
  end
  def test_ywesee_contact_email
    assert_kind_of(HtmlGrid::Link, @form.ywesee_contact_email(@model, @session))
  end
end

    end # User
  end # View
end # ODDB
