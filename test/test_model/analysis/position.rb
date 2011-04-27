#!/usr/bin/env ruby
# ODDB::Analysis::TestPosition -- oddb.org -- 27.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'model/analysis/position'

module ODDB
  module Analysis

class TestPosition < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @position = ODDB::Analysis::Position.new('poscd')
    group     = flexmock('group', :groupcd => 'groupcd')
    @position.group = group
  end
  def test_code
    expected = 'groupcd.poscd'
    assert_equal(expected, @position.code)
  end
  def test_create_detail_info
    assert_kind_of(ODDB::Analysis::DetailInfo, @position.create_detail_info('lab_key'))
  end
  def test_create_footnote
    flexmock(ODBA.cache, :next_id => 123)
    assert_kind_of(ODDB::Text::Document, @position.create_footnote)
  end
  def test_create_limitation_text
    flexmock(ODBA.cache, :next_id => 123)
    assert_kind_of(ODDB::LimitationText, @position.create_limitation_text)
  end
  def test_create_list_title
    flexmock(ODBA.cache, :next_id => 123)
    assert_kind_of(ODDB::Text::Document, @position.create_list_title)
  end
  def test_create_permissions
    flexmock(ODBA.cache, :next_id => 123)
    assert_kind_of(ODDB::Text::Document, @position.create_permissions)
  end
  def test_create_taxnote
    flexmock(ODBA.cache, :next_id => 123)
    assert_kind_of(ODDB::Text::Document, @position.create_taxnote)
  end
  def test_delete_detail_info
    flexmock(ODBA.cache, 
             :next_id => 123,
             :store   => 'store'
            )
    @position.create_detail_info('lab_key')
    assert_kind_of(ODDB::Analysis::DetailInfo, @position.delete_detail_info('lab_key'))
  end
  def test_delete_footnote
    @position.instance_eval('@footnote = "footnote"')
    assert_equal('footnote', @position.delete_footnote)
  end
  def test_delete_limitation_text
    @position.instance_eval('@limitation_text = "limitation_text"')
    assert_equal('limitation_text', @position.delete_limitation_text)
  end
  def test_delete_list_title
    @position.instance_eval('@list_title = "list_title"')
    assert_equal('list_title', @position.delete_list_title)
  end
  def test_delete_permissions
    @position.instance_eval('@permissions = "permissions"')
    assert_equal('permissions', @position.delete_permissions)
  end
  def test_delete_taxnote
    @position.instance_eval('@taxnote = "taxnote"')
    assert_equal('taxnote', @position.delete_taxnote)
  end
  def test_detail_info__index
    @position.create_detail_info('key')
    assert_kind_of(ODDB::Analysis::DetailInfo, @position.detail_info('key'))
  end
  def test_detail_infos
    assert_equal({}, @position.detail_infos)
  end
  def test_localized_name
    flexmock(@position, :language => 'language')
    assert_equal('language', @position.localized_name('language'))
  end
  def test_search_text
    flexmock(@position, :language => 'language')
    permission  = flexmock('permission', 
                           :restriction    => 'restriction',
                           :specialization => 'specialization'
                          )
    permissions = flexmock('permissions', :language => [permission])
    @position.instance_eval('@permissions = permissions')
    expected = 'language restriction specialization groupcd groupcdposcd'
    assert_equal(expected, @position.search_text('language'))
  end
end

  end # Analysis
end # ODDB
