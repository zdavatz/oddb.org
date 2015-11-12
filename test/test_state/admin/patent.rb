#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Admin::TestPatent -- oddb.org -- 28.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'state/admin/patent'

module ODDB
  module State
    module Admin

class TestPatent <Minitest::Test
  include FlexMock::TestCase
  def setup
    flexmock(SwissregPlugin).new_instances do |s|
      s.should_receive(:get_detail).and_return({'key' => 'value'})
    end
    @app     = flexmock('app', :update => 'update')
    lookup   = flexmock('lookup', :request_uri => 'request_uri')
    @lnf     = flexmock('lookandfeel', :lookup => lookup)
    @session = flexmock('session', 
                        :app => @app,
                        :lookandfeel => @lnf,
                        :user_input  => {:certificate_number => 'certificate_number'}
                       )
    @model   = flexmock('model', :pointer => 'pointer')
    @view    = ODDB::State::Admin::Patent.new(@session, @model)
    flexmock(@view, :unique_email => 'unique_email')
  end
  def test_update
    assert_equal(@view, @view.update)
  end
end

class TestCompanyPatent <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model', :parent  => 'parent')
    @view    = ODDB::State::Admin::CompanyPatent.new(@session, @model)
  end
  def test_init
    flexmock(@view, :allowed? => nil)
    assert_equal(ODDB::View::Admin::ReadonlyPatent, @view.init)
  end
  def test_update
    flexmock(@model, :pointer => 'pointer')
    app = flexmock('app', :update => 'update')
    flexmock(@session, 
             :user_input => {},
             :app => app
            )
    flexmock(SwissregPlugin).new_instances do |s|
      s.should_receive(:get_detail).and_return({'key' => 'value'})
    end
    flexmock(@view, :allowed? => true)
    flexmock(@view, :unique_email => 'unique_email')
    assert_equal(@view, @view.update)
  end
end

    end # Admin
  end # State
end # ODDB
