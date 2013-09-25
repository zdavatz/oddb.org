#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::User::TestDownload -- oddb.org -- 01.01.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/resulttemplate'
require 'htmlgrid/select'
require 'state/user/download'


module ODDB
  module View
    module User

class TestDownload <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :user_input  =>'user_input'
                       )
    @model   = flexmock('model')
    @view    = ODDB::View::User::Download.new(@model, @session)
  end
  def test_init
    assert_equal('../data/downloads/user_input', @view.init)
  end
  def test_to_html
    flexmock(@session, 
             :remote_addr => 'remote_addr',
             :passthru    => 'passthru'
            )
    assert_equal('', @view.to_html('context'))
  end
end

    end # User
  end# View
end # ODDB
