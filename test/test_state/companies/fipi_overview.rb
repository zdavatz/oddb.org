#!/usr/bin/env ruby
# State::Companies::TestFiPiOverview -- oddb -- 29.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'state/companies/fipi_overview'

module ODDB
  module State
    module Companies

class TestFiPiOverview < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', :lookandfeel => @lnf)
    package  = flexmock('package', 
                        :public?  => true,
                        :fachinfo => 'fachinfo',
                        :has_patinfo? => true,
                        :pdf_patinfo  => 'pdf_patinfo'
                       )
    @model   = flexmock('model', 
                        :name     => 'name',
                        :packages => [package]
                       )
    @state   = State::Companies::FiPiOverview.new(@session, @model)
  end
  def test_init
    assert_kind_of(OpenStruct, @state.init)
  end
  def test_export_csv
    assert_kind_of(FiPiCsv, @state.export_csv)
  end
end

    end # Companies
  end # State
end # ODDB
