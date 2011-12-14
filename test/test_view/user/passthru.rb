#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::User::TestPassThru -- oddb.org -- 30.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/user/passthru'


module ODDB
  module View
    module User

class TestPassThru < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :user_input  => 'https://www.xxx.zzz'
                       )
    @model   = flexmock('model')
    @view    = ODDB::View::User::PassThru.new(@model, @session)
  end
  def test_passthru
    assert_equal('https://www.xxx.zzz', @view.passthru)
  end
  def test_passthru__else
    flexmock(@session, :user_input => 'www.xxx.zzz')
    assert_equal('http://www.xxx.zzz', @view.passthru)
  end
  def test_http_headers
    expected = {"Location" => "https://www.xxx.zzz"}
    assert_equal(expected, @view.http_headers)
  end
  def test_to_html
    flexmock(@session, :remote_addr => 'remote_addr')
    assert_equal('', @view.to_html('context'))
  end
end

    end # User
  end # View
end # ODB

