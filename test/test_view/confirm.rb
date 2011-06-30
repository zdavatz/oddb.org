#!/usr/bin/env ruby
# ODDB::View::TestConfirm -- oddb.org -- 30.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/confirm'

module ODDB
  module View
  Copyright::ODDB_VERSION = 'version'
class TestConfirmComposite < Test::Unit::TestCase
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

class TestConfirm < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf      = flexmock('lookandfeel', 
                         :lookup     => 'lookup',
                         :enabled?   => nil,
                         :attributes => {},
                         :resource   => 'resource',
                         :zones      => 'zones',
                         :disabled?  => nil,
                         :_event_url => '_event_url',
                         :navigation => 'navigation',
                         :zone_navigation => 'zone_navigation',
                         :direct_event => 'direct_event'
                        )
    user      = flexmock('user', :valid? => nil)
    @session  = flexmock('session', 
                         :lookandfeel => @lnf,
                         :user    => user,
                         :sponsor => user
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
