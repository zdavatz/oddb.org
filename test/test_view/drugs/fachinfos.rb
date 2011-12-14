#!/usr/bin/env ruby
# encoding: utf-8
# View::Drugs::TestFachinfos -- oddb.org -- 23.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/resultfoot'
require 'view/drugs/fachinfos'


module ODDB
  module View
    module Drugs

class TestFachinfoList < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :_event_url => '_event_url'
                       )
    state    = flexmock('state', 
                        :interval  => 'interval',
                        :intervals => ['interval']
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :state       => state,
                        :language    => 'language'
                       )
    registration = flexmock('registration', :fachinfo_active? => nil)
    @model   = flexmock('model', 
                        :generic_type  => 'generic_type',
                        :registrations => [registration],
                        :name => 'name',
                        :name_base => 'name_base'
                       )
    flexmock(@model, :language => @model)
    @list    = View::Drugs::FachinfoList.new([@model], @session)
  end
  def test_fachinfo
    assert_equal(nil, @list.fachinfo(@model))
  end
end

class TestFachinfosComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :_event_url => '_event_url',
                          :enabled?   => nil,
                          :disabled?  => nil,
                          :base_url   => 'base_url',
                          :explain_result_components => {[0,0] => 'explain_unknown'}
                         )
    state      = flexmock('state', 
                          :interval  => 'interval',
                          :intervals => ['interval']
                         )
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :state       => state,
                          :fachinfo_count => 0,
                          :language    => 'language',
                          :zone        => 'zone'
                         )
    registration = flexmock('registration', :fachinfo_active? => nil)
    @model     = flexmock('model', 
                          :generic_type => 'generic_type',
                          :registrations => [registration],
                          :name => 'name',
                          :name_base => 'name_base'
                         )
    flexmock(@model, :language => @model)
    @composite = View::Drugs::FachinfosComposite.new([@model], @session)
  end
  def test_title_fachinfos
    assert_equal('lookup', @composite.title_fachinfos([@model]))
  end
end

    end # Drugs
  end # View
end # ODDB
