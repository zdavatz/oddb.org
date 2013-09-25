#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Admin::TestAssignPatinfo -- oddb.org -- 24.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'htmlgrid/labeltext'
require 'view/admin/assign_patinfo'

module ODDB
  module View
    module Admin

class TestAssignPatinfoForm <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :event_url  => 'event_url',
                        :_event_url => '_event_url',
                        :base_url   => 'base_url'
                       )
    state    = flexmock('state')
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :allowed?    => nil,
                        :state       => state,
                        :language    => 'language',
                        :warning?    => nil,
                        :error?      => nil
                       )
    galenic_form = flexmock('galenic_form', :language => 'language')
    substance    = flexmock('substance', :language => 'language')
    active_agent = flexmock('active_agent', 
                            :substance => substance,
                            :dose      => 'dose'
                           )
    composition  = flexmock('composition', 
                            :galenic_form  => galenic_form,
                            :active_agents => [active_agent]
                           )
    atc_class    = flexmock('atc_class', :code => 'code')   
    sequence = flexmock('sequence', 
                        :pdf_patinfo  => 'pdf_patinfo',
                        :pointer      => 'pointer',
                        :seqnr        => 'seqnr',
                        :compositions => [composition],
                        :atc_class    => atc_class,
                        :has_patinfo? => nil
                       )
    @model   = flexmock('model', 
                        :empty?   => nil,
                        :sequence => sequence,
                        :pointer  => 'pointer'
                       )
    flexmock(@model).should_receive(:each_with_index).and_yield(sequence, 0)
    @form    = ODDB::View::Admin::AssignPatinfoForm.new(@model, @session)
  end
  def test_patinfo_pointer__nothing
    assert_nil(@form.patinfo_pointer(@model, @session))
  end
  def test_patinfo_pointer__pdf_patinfo
    flexmock(@session, :allowed? => true)
    flexmock(@model, 
             :pdf_patinfo => 'pdf_patinfo',
             :patinfo     => 'patinfo'
            )
    assert_equal('lookup', @form.patinfo_pointer(@model, @session))
  end
  def test_patinfo_pointer__else
    flexmock(@session, :allowed? => true)
    flexmock(@model, 
             :pdf_patinfo => nil,
             :patinfo     => nil 
            )
    assert_kind_of(HtmlGrid::InputCheckbox, @form.patinfo_pointer(@model, @session))
  end
end

class TestAssignPatinfoComposite <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :_event_url => '_event_url',
                          :disabled?  => nil,
                          :base_url   => 'base_url',
                          :event_url  => 'event_url'
                         )
    state      = flexmock('state')
    @session   = flexmock('session', 
                          :zone => 'zone',
                          :lookandfeel => @lnf,
                          :allowed?    => nil,
                          :state       => state,
                          :language    => 'language',
                          :warning?    => nil,
                          :error?      => nil
                         )
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
    atc_class  = flexmock('atc_class', :code => 'code')
    sequence   = flexmock('sequence', 
                          :pdf_patinfo  => 'pdf_patinfo',
                          :pointer      => 'pointer',
                          :seqnr        => 'seqnr',
                          :compositions => [composition],
                          :atc_class    => atc_class,
                          :has_patinfo? => nil
                         )
    @model     = flexmock('model', 
                          :name_base => 'name_base',
                          :empty?    => nil,
                          :sequence  => sequence
                         )
    flexmock(@model).should_receive(:each_with_index).and_yield(sequence, 0)
    @composite = ODDB::View::Admin::AssignPatinfoComposite.new(@model, @session)
  end
  def test_init
    assert_nil(@composite.init)
  end
end

    end # Admin
  end # View
end # ODDB
