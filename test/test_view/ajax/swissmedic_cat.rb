#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Ajax::TestSwissmedicCat -- oddb.org -- 15.03.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/ajax/swissmedic_cat'
require 'htmlgrid/link'

module ODDB
  module View
    module Ajax

class TestSwissmedicCat < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup      => 'lookup',
                          :format_date => 'format_date',
                          :attributes  => {},
                          :result_list_components => {'key' => 'component'}
                         )
    @session   = flexmock('session', :lookandfeel => @lnf)
    sl_entry   = flexmock('sl_entry', :introduction_date => Time.local(2011,2,3))
    @parent    = flexmock('parent', 
                          :certificate_number => 'certificate_number',
                          :expiry_date => Time.local(2011,2,3)
                         )
    @model     = flexmock('model', 
                          :ikscat   => 'ikscat',
                          :sl_entry => sl_entry,
                          :lppv     => 'lppv',
                          :preview? => nil,
                          :patent   => @parent,
                          :sl_generic_type   => 'sl_generic_type',
                          :registration_date => Time.local(2011,2,3),
                          :sequence_date     => Time.local(2011,2,3),
                          :revision_date     => Time.local(2011,2,3),
                          :expiration_date   => Time.local(2011,2,3),
                          :index_therapeuticus => 'index_therapeuticus',
                          :ith_swissmedic      => 'ith_swissmedic',
                          :production_science  => 'production_science'
                         )
    @composite = ODDB::View::Ajax::SwissmedicCat.new(@model, @session)
  end
  def test_init
    assert_equal({}, @composite.init)
  end
  def test_reorganize_components
    flexmock(@lnf, 
             :result_list_components => {'key' => :deductible},
             :enabled?   => nil
            )
    flexmock(@model, 
             :deductible => true,
             :preview?   => true
            )
    assert_equal('bold top list', @composite.reorganize_components)
  end
  def test_deductible
    flexmock(@lnf, :enabled? => nil)
    flexmock(@model, :deductible => true)
    assert_kind_of(HtmlGrid::Link, @composite.deductible(@model))
  end
  def test_deductible_label
    assert_kind_of(HtmlGrid::Link, @composite.deductible_label(@model))
  end
  def test_deductible_value
    flexmock(@lnf, :enabled? => true)
    flexmock(@model, :deductible_m => 'deductible_m')
    assert(@composite.deductible_value(@model))
  end
  def test_patent_protected
    flexmock(@parent, :certificate_number => nil)
    assert_kind_of(HtmlGrid::Value, @composite.patent_protected(@model))
  end
end

    end # Ajax
  end # View
end # ODDB

