#!/usr/bin/env ruby
# ODDB::View::Migel::TestGroup -- oddb.org -- 21.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/resulttemplate'
require 'view/migel/group'

module ODDB
  module View
    module Migel

class TestGroupInnerComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', :lookup => 'lookup')
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :error       => 'error',
                          :language    => 'language'
                         )
    limitation_text = flexmock('limitation_text', :language => 'language')
    @model     = flexmock('model', 
                          :language => 'language',
                          :limitation_text => limitation_text
                         )
    @composite = ODDB::View::Migel::GroupInnerComposite.new(@model, @session)
  end
  def test_description
    assert_kind_of(HtmlGrid::Value, @composite.description(@model))
  end
end

class TestGroupComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup => 'lookup',
                          :_event_url => '_event_url',
                          :language => 'language'
                         )
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :error       => 'error',
                          :language    => 'language',
                          :event       => 'event'
                         )
    limitation_text = flexmock('limitation_text', :language => 'language')
    method     = flexmock('method', :arity => 1)
    subgroup   = flexmock('subgroup', 
                          :pointer => 'pointer',
                          :migel_code => 'migel_code',
                          :method     => method
                         )
    @model     = flexmock('model', 
                          :language => 'language',
                          :limitation_text => limitation_text,
                          :subgroups => {'key' => subgroup}
                         )
    @composite = ODDB::View::Migel::GroupComposite.new(@model, @session)
  end
  def test_subgroups
    assert_kind_of(ODDB::View::Migel::SubgroupList, @composite.subgroups(@model))
  end
end

    end # Migel
  end # View
end # ODDB
