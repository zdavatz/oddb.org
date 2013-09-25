#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::TestConfirm -- oddb.org -- 30.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/confirm'

module ODDB
  class Session
    DEFAULT_FLAVOR = 'gcc'
  end
  module View
  Copyright::ODDB_VERSION = 'version'
class TestConfirmComposite <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', :lookup => 'lookup')
    @session   = flexmock('session', :lookandfeel => @lnf)
    @model     = flexmock('model')
    @composite = ODDB::View::ConfirmComposite.new(@model, @session)
  end
  def test_confirm
    assert_equal('lookup', @composite.confirm(@model))
  end
end

class TestConfirm <Minitest::Test
  include FlexMock::TestCase
  def setup
    @zones    = flexmock('zones',
                         :sort_by => [],
                         )
    @navigation    = flexmock('navigation',
                         :sort_by => [],
                         :each_with_index => 'each_with_index',
                         )
    @zone_navigation    = flexmock('zone_navigation', 
                                   :sort_by => [],
                                   :empty? => true,
                                   )
    @lnf      = flexmock('lookandfeel', 
                         :lookup     => 'lookup',
                         :enabled?   => nil,
                         :attributes => {},
                         :resource   => 'resource',
                         :zones      => @zones,
                         :disabled?  => nil,
                         :_event_url => '_event_url',
                         :navigation => @navigation,
                         :zone_navigation => @zone_navigation,
                         :direct_event => 'direct_event',
                        )
    user      = flexmock('user', :valid? => nil)
    @logo = flexmock('session', )
    @session  = flexmock('session', 
                         :lookandfeel => @lnf,
                         :user    => user,
                         :sponsor => user,
                         :flavor  => 'default',
                         :logo    => @logo,
                        )
    @model    = flexmock('model')
    @template = ODDB::View::Confirm.new(@model, @session)
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
      expected = {"Refresh" => "10; url=_event_url"}
      assert_equal(expected, @template.http_headers)
    end
  end
end
  end # View
end # ODDB
