#!/usr/bin/env ruby
# ODDB::State::Admin::TestCommercialForm -- oddb.org -- 27.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'state/admin/merge_commercial_form'
require 'view/descriptionform'
require 'htmlgrid/labeltext'
require 'view/additional_information'
require 'view/admin/registration'
require 'state/admin/commercial_form'
require 'model/commercial_form'

module ODDB
  module State
    module Admin

class TestCommercialForm < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @app     = flexmock('app')
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', 
                        :app => @app,
                        :lookandfeel => @lnf
                       )
    @model   = flexmock('model', :empty? => nil)
    @form    = ODDB::State::Admin::CommercialForm.new(@session, @model)
  end
  def test_delete
    assert_kind_of(ODDB::State::Admin::MergeCommercialForm, @form.delete)
  end
  def test_delete__empty
    flexmock(@app, :delete => 'delete')
    flexmock(@model, 
             :empty?  => true,
             :pointer => 'pointer'
            )
    flexmock(@form, :commercial_forms => 'commercial_forms')
    assert_equal('commercial_forms', @form.delete)
  end
  def test_duplicate__true
    flexmock(ODBA.cache, :retrieve_from_index => ['retrieve_from_index'])
    assert(@form.duplicate?('string'))
  end
  def test_duplicate__false
    assert_equal(false, @form.duplicate?(''))
  end
  def test_update
    flexmock(@app, :update => 'update')
    flexmock(@model, :pointer => 'pointer')
    flexmock(@lnf, :languages => ['language'])
    flexmock(@session, :user_input => '')
    flexmock(@form, :unique_email => 'unique_email')
    assert_equal(@form, @form.update)
  end

  def test_update__error
    flexmock(ODBA.cache, :retrieve_from_index => ['retrieve_from_index'])
    flexmock(@lnf, :languages => ['language'])
    flexmock(@session, :user_input => 'user_input')
    assert_equal(@form, @form.update)
  end
end

    end # Admin
  end # State
end # ODDB
