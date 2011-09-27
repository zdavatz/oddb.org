#!/usr/bin/env ruby
# ODDB::View::Admin::TestAssignDeprivedSequenceForm -- oddb.org -- 16.09.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'htmlgrid/labeltext'
require 'view/admin/assign_deprived_sequence'

module ODDB
  module View
    module Admin

class TestAssignDeprivedSequenceForm < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :event_url  => 'event_url',
                        :base_url   => 'base_url'
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :allowed?    => nil,
                        :state       => 'state',
                        :language    => 'language',
                        :warning?    => nil,
                        :error?      => nil
                       )
    @pointer  = flexmock('pointer', :to_csv => 'to_csv')
    flexmock(@pointer, :+ => @pointer)
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
    atc_class = flexmock('atc_class', :code => 'code')
    @sequence = flexmock('sequence', 
                        :pdf_patinfo => 'pdf_patinfo',
                        :pointer     => @pointer,
                        :seqnr       => 'seqnr',
                        :compositions => [composition],
                        :atc_class    => atc_class,
                        :has_patinfo? => nil
                       )
    @model   = flexmock('model', 
                        :empty? => nil,
                        :sequence => @sequence
                       )
    flexmock(@model).should_receive(:each_with_index).and_yield(@sequence, 0)
    @form    = ODDB::View::Admin::AssignDeprivedSequenceForm.new(@model, @session)
  end
  def test_init
    assert_nil(@form.init)
  end
  def test_patinfo_pointer__model_pdf_patinfo
    assert_kind_of(HtmlGrid::InputRadio, @form.patinfo_pointer(@sequence, @session))
  end
  def test_patinfo_pointer__model_sequence
    flexmock(@sequence, :sequence => @sequence)
    flexmock(@session).should_receive(:allowed?).once.with(:patinfo_shadow).and_return(true)
    assert_kind_of(HtmlGrid::Link, @form.patinfo_pointer(@sequence, @session))
  end
  def test_patinfo_pointer__model_patinfo
    patinfo = flexmock('patinfo', :pointer => @pointer)
    flexmock(@model, 
             :pdf_patinfo => nil,
             :patinfo     => patinfo
            )
    assert_kind_of(HtmlGrid::InputRadio, @form.patinfo_pointer(@model, @session))
  end

end

    end # Admin
  end # View
end # ODDB
