#!/usr/bin/env ruby
# encoding: utf-9
# ODDB::View::Admin::TestGalenicGroup -- oddb.org -- 09.11.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'htmlgrid/select'
require 'view/admin/galenicgroup'
require 'model/company'


module ODDB
  module View
    module Admin

class TestGalenicGroupComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :languages  => ['language'],
                          :attributes => {},
                          :base_url   => 'base_url',
                          :language   => 'language',
                          :_event_url => '_event_url'
                         )
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :error    => 'error',
                          :warning? => nil,
                          :error?   => nil
                         )
    method = flexmock('method', :arity => 1)
    galenic_group = flexmock('galenic_group', :oid => 'oid')
    galenic_form = flexmock('galenic_form', 
                            :oid    => 'oid',
                            :method => method,
                            :description => 'description',
                            :pointer => 'pointer',
                            :galenic_group => galenic_group
                           )
    @model     = flexmock('model', 
                          :galenic_forms => {'key' => galenic_form},
                          :pointer => 'pointer'
                         )
    @composite = ODDB::View::Admin::GalenicGroupComposite.new(@model, @session)
  end
  def test_galenic_forms
    assert_kind_of(ODDB::View::Admin::GalenicForms, @composite.galenic_forms(@model, @session))
  end
  def test_galenic_forms__else
    flexmock(@model, :galenic_forms => nil)
    assert_kind_of(ODDB::View::Admin::GalenicForms, @composite.galenic_forms(@model, @session))
  end
end

    end # Admin
  end # View
end # ODDB
