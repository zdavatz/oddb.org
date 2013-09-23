#!/usr/bin/env ruby
# encoding: utf-8
# View::Drugs::TestFachinfos -- oddb.org -- 23.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../..", File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'stub/odba'
require 'stub/cgi'
require 'view/resultfoot'
require 'view/drugs/fachinfos'
require 'model/fachinfo'
require 'model/text'


module ODDB
  class Fachinfo
    attr_accessor :registrations, :name, :name_base, :language
  end
  class FachinfoDocument
    attr_accessor :registrations, :name, :name_base, :language
  end
  class FachinfoDocument2001
    attr_accessor :registrations, :name, :name_base, :language
  end
  module View
    module Drugs

class TestFachinfoList <Minitest::Test
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

class TestFachinfosComposite <Minitest::Test
  include FlexMock::TestCase
    class StubRegistration
      attr_accessor :company_name
      attr_accessor :generic_type
      attr_accessor :substance_names
    end
  def setup
    fachinfo = ODDB::FachinfoDocument2001.new
    fachinfo.amzv = ODDB::Text::Chapter.new
    fachinfo.composition = ODDB::Text::Chapter.new
    fachinfo.effects = ODDB::Text::Chapter.new
    chapter = Text::Chapter.new
    chapter.heading = "Tabellentest"
    table = Text::Table.new
    table << 'first'
    table.next_row!
    cell1 = table.next_cell!
    table << 'cell1'
    cell2 = table.next_cell!
    table << 'cell2'
    chapter.sections << table
    fachinfo.composition = chapter
    
    chapters = []
    fachinfo.each_chapter { |chap|
      chapters << chap  
                          pp chap
    }
    registration = flexmock('registration', :fachinfo_active? => nil)
    fachinfo.registrations = [registration]
    fachinfo.name = "\nMeine Fachinfo\n"
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :_event_url => '_event_url',
                          :enabled?   => nil,
                          :disabled?  => nil,
                          :base_url   => 'base_url',
                          :flavor   => 'flavor',
                          :language   => 'de',
                          :explain_result_components => {[0,0] => 'explain_unknown'},
                          :navigation => {} ,
                         )
    state      = flexmock('state', 
                          :interval  => 'interval',
                          :intervals => ['interval'],
                         )
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :state       => state,
                          :fachinfo_count => 1,
                          :language    => 'language',
                          :zone        => 'zone',
                          :event => {} ,
                         )
    @model = fachinfo 
    @model.name = 'dummy'
    skip "Don't know how to handle NoMethodError: undefined method `name' for nil:NilClass"
    @list      = View::Drugs::FachinfoList.new([@model], @session)
    @composite = View::Drugs::FachinfosComposite.new([@model], @session)
  end
  
  def test_title_fachinfos
    assert_equal('lookup', @composite.title_fachinfos([@model]))
  end
  
  def test_fachinfo_list_not_empty
    assert_not_nil(@list.model.fachinfo(@model))
  end

  def test_table_fachinfos
    html = @list.to_html CGI.new
    html = @composite.to_html CGI.new
    expected = [
      'name_base',
      'cell1',
      '<br>',
      'cell2',
      '<br>xxxxx',
    ]
    expected.each { |line| 
      assert(html.index(line), "missing: #{line}\nin:\n#{html}")
    }
  end
end

    end # Drugs
  end # View
end # ODDB
