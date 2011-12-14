#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Companies::TestFiPiOverview -- oddb.org -- 28.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/companies/fipi_overview.rb'


module ODDB
  module View
    module Companies

class TestFiPiOverviewList < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :event       => 'event',
                        :language    => 'language'
                       )
    commercial_form = flexmock('commercial_form', :language => 'language')
    part     = flexmock('part', 
                        :multi   => 'multi',
                        :count   => 'count',
                        :measure => 'measure',
                        :commercial_form => commercial_form
                       )
    fachinfo = flexmock('fachinfo', 
                        :iksnrs => ['iksnr'],
                        :descriptions => 'xescriptions'
                       )
    patinfo  = flexmock('patinfo', :descriptions => 'xescriptions')
    @model   = flexmock('model', 
                        :commercial_forms => [commercial_form],
                        :parts            => [part],
                        :fachinfo         => fachinfo,
                        :patinfo          => patinfo,
                        :name_base        => 'name_base'
                       )
    @list    = ODDB::View::Companies::FiPiOverviewList.new([@model], @session)
  end
  def test_info_date
    chapter   = flexmock('chapter', :sections => ['section 1234567'])
    language  = flexmock('language', :date => chapter)
    info      = flexmock('info', :descriptions => {'language' => language})
    model     = flexmock('model', :type => info)
    assert_equal('section 1234', @list.info_date(model, 'type', 'language'))
  end
  def test_swissmedic_numbers
    assert_equal('iksnr', @list.swissmedic_numbers(@model))
  end
  def test_swissmedic_numbers__no_fachinfo
    model = flexmock('model', 
                     :fachinfo => nil,
                     :iksnr    => 'iksnr'
                    )
    assert_equal('iksnr', @list.swissmedic_numbers(model))
  end
end

class TestExportCSV < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :base_url   => 'base_url',
                        :_event_url => '_event_url'
                       )
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model')
    @form    = ODDB::View::Companies::ExportCSV.new(@model, @session)
  end
  def test_init
    assert_equal("location.href='_event_url';return false;", @form.init)
  end
end

class TestFiPiOverviewComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :base_url   => 'base_url',
                          :_event_url => '_event_url'
                         )
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :event       => 'event',
                          :language    => 'language'
                         )
    commercial_form = flexmock('commercial_form', :language => 'language')
    part       = flexmock('part', 
                          :multi   => 'multi',
                          :count   => 'count',
                          :measure => 'measure',
                          :commercial_form => commercial_form
                         )
    chapter    = flexmock('chapter', :sections => ['section 1234'])
    language   = flexmock('langauge', :date => chapter)
    fachinfo   = flexmock('fachinfo', 
                          :iksnrs => ['iksnr'],
                          :descriptions => {'language' => language}
                         )
    patinfo    = flexmock('patinfo', :descriptions => {'language' => language})
    package    = flexmock('package', 
                          :commercial_forms => [commercial_form],
                          :parts            => [part],
                          :fachinfo         => fachinfo,
                          :patinfo          => patinfo,
                          :name_base        => 'name_base'
                         )
    @model     = flexmock('model', 
                          :fi_count => 'fi_count',
                          :pi_count => 'pi_count',
                          :packages => [package]
                         )
    @composite = ODDB::View::Companies::FiPiOverviewComposite.new(@model, @session)
  end
  def test_counts
    assert_equal('lookup', @composite.counts(@model)) 
  end
end


    end # Companies
  end # View
end # ODDB
