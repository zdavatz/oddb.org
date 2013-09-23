#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Admin::TestWaitForFachinfo -- oddb.org -- 28.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/admin/wait_for_fachinfo'


module ODDB
  module View
    module Admin

class TestStatusBar <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', :lookup => 'lookup')
    state      = flexmock('state', :wait_counter => 0)
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :state => state
                         )
    @model     = flexmock('model')
    @composite = ODDB::View::Admin::StatusBar.new(@model, @session)
  end
  def test_init
    assert_equal('20', @composite.init)
  end
end

class TestWaitForFachinfo <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :enabled?   => nil,
                        :resource   => 'resource',
                        :event_url  => 'event_url'
                       )
    user     = flexmock('user', :valid? => nil)
    sponsor  = flexmock('sponsor', :valid? => nil)
    state    = flexmock('state', :wait_counter => 0)
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :user    => user,
                        :sponsor => sponsor,
                        :state   => state
                       )
    @model   = flexmock('model')
    @view    = ODDB::View::Admin::WaitForFachinfo.new(@model, @session)
  end
  def stderr_null
    require 'tempfile'
    $stderr = Tempfile.open('stderr')
    yield
    $stderr.close
    $stderr = STDERR
  end
  def replace_constant(constant, temp)
    stderr_null do
      keep = eval constant
      eval "#{constant} = temp"
      yield
      eval "#{constant} = keep"
    end
  end

  def test_http_headers
    replace_constant('ODDB::View::PublicTemplate::HTTP_HEADERS', {}) do 
      expected = {"Refresh" => "5; url=event_url"}
      assert_equal(expected, @view.http_headers)
    end
  end
end

    end # Admin
  end # View
end # ODDB
