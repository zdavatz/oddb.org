#!/usr/bin/env ruby
# ODDB::View::Admin::TestOrphandPatinfo -- oddb.org -- 21.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'htmlgrid/labeltext'
require 'view/admin/orphaned_patinfo_assign'


module ODDB
  module View
    module Admin

class TestOrphanedPatinfoListInnerComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :event_url  => 'event_url'
                         )
    @container = flexmock('container', :list_index => 'list_index')
    @session   = flexmock('session', :lookandfeel => @lnf)
    @model     = flexmock('model')
    @composite = ODDB::View::Admin::OrphanedPatinfoListInnerComposite.new(@model, @session, @container)
  end
  def test_meaning_index
    assert_kind_of(HtmlGrid::Link, @composite.meaning_index(@model, @session))
  end
  def test_list_index
    assert_equal('list_index', @composite.list_index)
  end
end

class TestOrphanedPatinfoComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :event_url  => 'event_url',
                          :base_url   => 'base_url'
                         )
    @session   = flexmock('session', :lookandfeel => @lnf)
    @model     = flexmock('model', 
                          :reason   => 'reason',
                          :meanings => 'meanings'
                         )
    @composite = ODDB::View::Admin::OrphanedPatinfoComposite.new(@model, @session)
  end
  def test_reason
    assert_equal('lookup', @composite.reason(@model, @session))
  end
end

    end # Admin
  end    # View
end     # ODDB
