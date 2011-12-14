#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Analysis::TestPosition -- oddb.org -- 07.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/resulttemplate'
require 'htmlgrid/labeltext'
require 'view/analysis/position'

module ODDB
  module View
    module Analysis

class TestAdditionalInfoComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', :lookup => 'lookup')
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :error       => 'error'
                         )
    @model     = flexmock('model', 
                          :info_description    => 'info_description',
                          :info_interpretation => 'info_interpretation',
                          :info_indication     => 'info_indication',
                          :info_significance   => 'info_significance',
                          :info_ext_material   => 'info_ext_material',
                          :info_ext_condition  => 'info_ext_condition',
                          :info_storage_condition => 'info_storage_condition',
                          :info_storage_time   => 'info_storage_time'
                         )
    @composite = ODDB::View::Analysis::AdditionalInfoComposite.new(@model, @session)
  end
  def test_init
    assert_equal({}, @composite.init)
  end
  def test_info_ext_material
    flexmock(@model, :info_ext_material => 'info@dacapo.ch')
    assert_kind_of(HtmlGrid::Value, @composite.info_ext_material(@model))
  end
end

class TestPositionInnerComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup => 'lookup',
                          :attributes  => {}
                         )
    @session   = flexmock('session', 
                          :language    => 'language',
                          :lookandfeel => @lnf,
                          :error       => 'error'
                         )
    limitation_text = flexmock('limitation_text', :language => 'language')
    taxnote    = flexmock('taxnote', :language => 'language')
    footnote   = flexmock('footnote', :language => 'language')
    @model     = flexmock('model', 
                          :language        => 'language',
                          :localized_name  => 'localized_name',
                          :anonymous       => 'anonymous',
                          :anonymousgroup  => 'anonymousgroup',
                          :anonymouspos    => 'anonymouspos',
                          :taxpoints       => 'taxpoints',
                          :limitation_text => limitation_text,
                          :taxnote         => taxnote,
                          :footnote        => footnote
                         )
    @composite = ODDB::View::Analysis::PositionInnerComposite.new(@model, @session)
  end
  def test_anonymous
    assert_kind_of(HtmlGrid::Value, @composite.anonymous(@model))
  end
  def test_description
    flexmock(@model, :language => '1234.56')
    flexmock(@lnf, :_event_url => '_event_url')
    assert_kind_of(HtmlGrid::Value, @composite.description(@model))
  end
end

class TestPositionComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf        = flexmock('lookandfeel', 
                           :lookup     => 'lookup',
                           :attributes => {},
                           :navigation => ['navigation'],
                           :disabled?  => nil,
                           :enabled?   => nil
                          )
    @session    = flexmock('session', 
                           :lookandfeel => @lnf,
                           :language    => 'language',
                           :error       => 'error',
                           :event       => 'event'
                          )
    limitation_text = flexmock('limitation_text', :language => 'language')
    taxnote     = flexmock('taxnote', :language => 'language')
    footnote    = flexmock('footnote', :language => 'language')
    permissions = flexmock('permissions', :language => 'language')
    detail_info = flexmock('detail_info', 
                           :info_description    => 'info_description',
                           :info_interpretation => 'info_interpretation',
                           :info_indication     => 'info_indication',
                           :info_significance   => 'info_significance',
                           :info_ext_material   => 'info_ext_material',
                           :info_ext_condition  => 'info_ext_condition',
                           :info_storage_condition => 'info_storage_condition',
                           :info_storage_time   => 'info_storage_time'
                          )
    @model      = flexmock('model', 
                           :language        => 'language',
                           :localized_name  => 'localized_name',
                           :anonymous       => 'anonymous',
                           :anonymousgroup  => 'anonymousgroup',
                           :anonymouspos    => 'anonymouspos',
                           :taxpoints       => 'taxpoints',
                           :limitation_text => limitation_text,
                           :taxnote         => taxnote,
                           :footnote        => footnote,
                           :permissions     => permissions,
                           :detail_info     => detail_info
                         )
    @composite  = ODDB::View::Analysis::PositionComposite.new(@model, @session)
  end
  def test_additional_info
    assert_kind_of(ODDB::View::Analysis::AdditionalInfoComposite, @composite.additional_info(@model))
  end
end

    end # Analysis
  end # View
end # ODDB
