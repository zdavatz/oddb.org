#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::User::TestInvalidUser -- oddb.org -- 28.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'htmlgrid/errormessage'
require 'htmlgrid/inputradio'
require 'view/user/invalid_user'


module ODDB
  module View
    module User

class TestInvalidUserComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :base_url   => 'base_url',
                        :_event_url => '_event_url',
                        :format_price => 'format_price'
                       )
    user     = flexmock('user', 
                        :is_a? => true,
                        :poweruser_duration => 'poweruser_duration',
                        :salutation => 'salutation',
                        :name_first => 'name_first',
                        :name_last  => 'name_last',
                        :pointer    => 'pointer'
                       )
    state    = flexmock('state', :price => 'price')
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :user  => user,
                        :error => 'error',
                        :state => state,
                        :warning? => nil,
                        :error?   => nil
                       )
    @model   = flexmock('model')
    @view    = ODDB::View::User::InvalidUserComposite.new(@model, @session)
  end
  FlexMock::QUERY_LIMIT = 5
  def test_invalid_user_explain
    assert_equal('lookup', @view.invalid_user_explain(@model))
  end
  def test_renew_poweruser
    assert_kind_of(HtmlGrid::Link, @view.renew_poweruser(@model))
  end
end

    end # User
  end # View
end # ODDB
