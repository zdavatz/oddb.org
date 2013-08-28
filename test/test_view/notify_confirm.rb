#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::TestNotifyConfirm -- oddb.org -- 27.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/resulttemplate'
require 'view/notify_confirm'

module ODDB
  class Session
    DEFAULT_FLAVOR = 'gcc'
  end
  module View
    Copyright::ODDB_VERSION = 'version' 

class TestNotifyConfirmComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :_event_url => '_event_url',
                          :disabled?  => nil,
                          :base_url   => 'base_url'
                         )
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :event       => 'event',
                          :flavor      => Session::DEFAULT_FLAVOR,
                          :zone        =>  'zone',
                         )
    item       = flexmock('item', :name => 'name')
    @model     = flexmock('model', 
                          :item => item,
                          :notify_recipient => 'notify_recipient'
                         )
    @composite = ODDB::View::NotifyConfirmComposite.new(@model, @session)
  end
  def test_notify_sent
    assert_equal('lookup', @composite.notify_sent(@model, @session))
  end
  def test_notify_sent__mail_not_empty
    flexmock(@model, :notify_recipient => ['mail1', 'mail2'])
    assert_equal('lookup', @composite.notify_sent(@model, @session))
  end
end

class TestNotifyConfirm < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @zones = flexmock('zones',
                      :sort_by => [],
                      )
    @navigation = flexmock('navigation',
                            :sort_by => [],
                            :each_with_index => 'each_with_index',
                            :empty? => false,
                            )
    @zone_navigation = flexmock('zone_navigation',
                                :sort_by => [],
                                :each_with_index => 'each_with_index',
                                :empty? => false,
                          )
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :enabled?   => nil,
                        :attributes => {},
                        :resource   => 'resource',
                        :zones      => @zones,
                        :_event_url => '_event_url',
                        :disabled?  => nil,
                        :base_url   => 'base_url',
                        :navigation => @navigation,
                        :zone_navigation => @zone_navigation,
                        :direct_event    => 'direct_event'
                       )
    user     = flexmock('user', :valid? => nil)
    sponsor  = flexmock('sponsor', :valid? => nil)
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :user    => user,
                        :sponsor => sponsor,
                        :event   => 'event',
                        :zone    => 'zone',
                        :flavor      => Session::DEFAULT_FLAVOR,
                        :get_cookie_input => 'get_cookie_input',
                        :persistent_user_input => 'persistent_user_input',
                       )
    item     = flexmock('item', :name => 'name')
    @model   = flexmock('model', 
                        :item => item,
                        :notify_recipient => 'notify_recipient'
                       )
    @result  = ODDB::View::NotifyConfirm.new(@model, @session)
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
      expected = {"Refresh"=>"5; URL=_event_url"}
      assert_equal(expected, @result.http_headers)
    end
  end
  def test_http_headers__user_input_empty
    flexmock(@session, :persistent_user_input => nil)
    replace_constant('ODDB::View::PublicTemplate::HTTP_HEADERS', {}) do 
      expected = {"Refresh"=>"5; URL=_event_url"}
      assert_equal(expected, @result.http_headers)
    end
  end
  def test_http_headers__best_result_disabled
    flexmock(@lnf, :disabled? => true)
    replace_constant('ODDB::View::PublicTemplate::HTTP_HEADERS', {}) do 
      expected = {"Refresh"=>"5; URL=_event_url"}
      assert_equal(expected, @result.http_headers)
    end
  end

end

  end # View
end # ODDB
