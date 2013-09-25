#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Admin::TestCommercialForm -- oddb.org -- 24.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/descriptionform'
require 'htmlgrid/labeltext'
require 'view/admin/registration'
require 'view/additional_information'
require 'view/admin/commercial_form'


module ODDB
  module View
    module Admin

class TestCommercialFormForm <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :languages  => ['language'],
                        :attributes => {},
                        :base_url   => 'base_url'
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :error    => 'error',
                        :warning? => nil,
                        :error?   => nil
                       )
    @model   = flexmock('model', :synonyms => ['synonym'])
    @form    = ODDB::View::Admin::CommercialFormForm.new(@model, @session)
  end
  def test_languages
    expected = ["language", "synonym_list"]
    assert_equal(expected, @form.languages)
  end
end

class TestCommercialFormComposite <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :languages  => ['language'],
                          :attributes => {},
                          :base_url   => 'base_url',
                          :event_url  => 'event_url',
                          :_event_url => '_event_url'
                         )
    state      = flexmock('state')
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :error    => 'error',
                          :warning? => nil,
                          :error?   => nil,
                          :event    => 'event',
                          :allowed? => nil,
                          :state    => state,
                          :language => 'language',
                          :persistent_user_input => 'persistent_user_input'
                         )
    indication   = flexmock('indication', :language => 'language')
    registration = flexmock('registration', :indication => indication)
    galenic_form = flexmock('galenic_form', :language => 'language')
    substance    = flexmock('substance', :language => 'language')
    active_agent = flexmock('active_agent', 
                            :substance => substance,
                            :dose => 'dose'
                           )
    composition  = flexmock('composition', 
                            :galenic_form  => galenic_form,
                            :active_agents => [active_agent]
                           )
    commercial_form = flexmock('commercial_form', :language => 'language')
    part       = flexmock('part', 
                          :multi => 'multi',
                          :count => 'count',
                          :measure => 'measure',
                          :commercial_form => commercial_form
                         )
    package    = flexmock('package', 
                          :ikscd   => 'ikscd',
                          :pointer => 'pointer',
                          :barcode => 'barcode',
                          :descr   => 'descr',
                          :parts   => [part],
                          :name_base    => 'name_base',
                          :photo_link   => 'photo_link',
                          :good_result? => nil,
                          :registration => registration,
                          :compositions => [composition],
                          :commercial_forms => [commercial_form]
                         )
    @model     = flexmock('model', 
                          :synonyms => ['synonym'],
                          :packages => [package]
                         )
    @composite = ODDB::View::Admin::CommercialFormComposite.new(@model, @session)
  end
  def test_packages
    assert_kind_of(ODDB::View::Admin::ComformPackages, @composite.packages(@model, @session))
  end
end

    end # Admin
  end    # View
end     # ODDB
